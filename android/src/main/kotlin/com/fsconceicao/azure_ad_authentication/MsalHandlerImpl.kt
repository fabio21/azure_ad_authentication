package com.fsconceicao.azure_ad_authentication

import android.os.Handler
import android.os.Looper
import android.util.Log
import com.microsoft.identity.client.IAccount
import com.microsoft.identity.client.IMultipleAccountPublicClientApplication
import com.microsoft.identity.client.PublicClientApplication
import com.microsoft.identity.client.exception.MsalException
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.jetbrains.annotations.Nullable
import java.util.*


class MsalHandlerImpl(private val msal: Msal) : MethodChannel.MethodCallHandler {
    private val TAG = "MsalHandlerImpl"

    @Nullable
    private var channel: MethodChannel? = null

    fun startListening(messenger: BinaryMessenger?) {
        if (channel != null) {
            Log.wtf(TAG, "Setting a method call handler before the last was disposed.")
            stopListening()
        }

        channel = MethodChannel(messenger, "azure_ad_authentication")
        channel!!.setMethodCallHandler(this)
    }

    fun stopListening() {
        if (channel == null) {
            Log.d(TAG, "Tried to stop listening when no MethodChannel had been initialized.");
            return;
        }

        channel!!.setMethodCallHandler(null);
        channel = null;
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        Log.d("DART/NATIVE", "onMethodCall ${call.method}")
        val scopesArg: ArrayList<String>? = call.argument("scopes")
        val scopes: Array<String>? = scopesArg?.toTypedArray()
        val clientId: String? = call.argument("clientId")
        //our code
        when (call.method) {
            "initialize" -> {
                initialize(clientId, result)
            }
            "loadAccounts" -> Thread(Runnable { msal.loadAccounts(result) }).start()
            "acquireToken" -> Thread(Runnable { acquireToken(scopes, result) }).start()
            "acquireTokenSilent" -> Thread(Runnable { acquireTokenSilent(scopes, result) }).start()
            "logout" -> Thread(Runnable { logout(result) }).start()
            else -> result.notImplemented()
        }

    }

    private fun logout(result: MethodChannel.Result) {
        if (!msal.isClientInitialized()) {
            Handler(Looper.getMainLooper()).post {
                result.error(
                    "NO_ACCOUNT",
                    "No account is available to acquire token silently for",
                    null
                )
            }
            return
        }

        if (msal.accountList.isEmpty()) {
            Handler(Looper.getMainLooper()).post {
                result.error(
                    "NO_ACCOUNT",
                    "No account is available to acquire token silently for",
                    null
                )
            }
            return
        }

        msal.adAuthentication.removeAccount(
            msal.accountList.first(),
            object : IMultipleAccountPublicClientApplication.RemoveAccountCallback {
                override fun onRemoved() {
                    Thread(Runnable { msal.loadAccounts(result) }).start()
                }

                override fun onError(exception: MsalException) {
                    result.error(
                        "NO_ACCOUNT",
                        "No account is available to acquire token silently for",
                        exception
                    )
                }
            })


    }

    private fun acquireTokenSilent(scopes: Array<String>?, result: MethodChannel.Result) {
        //  check if client has been initialized

        if (!msal.isClientInitialized()) {
            Handler(Looper.getMainLooper()).post {
                result.error(
                    "NO_CLIENT",
                    "Client must be initialized before attempting to acquire a token.",
                    null
                )
            }
        }

        //check the scopes
        if (scopes == null) {
            Handler(Looper.getMainLooper()).post {
                result.error("NO_SCOPE", "Call must include a scope", null)
            }
            return
        }

        //ensure accounts exist
        if (msal.accountList.isEmpty()) {
            Handler(Looper.getMainLooper()).post {
                result.error(
                    "NO_ACCOUNT",
                    "No account is available to acquire token silently for",
                    null
                )
            }
            return
        }
        val selectedAccount: IAccount = msal.accountList.first();
        //acquire the token and return the result
        val sc = scopes.map { s -> s.toLowerCase() }.toTypedArray()

        msal.adAuthentication.acquireTokenSilentAsync(
            sc,
            selectedAccount,
            selectedAccount.authority,
            msal.getAuthSilentCallback(result)
        )
    }

    private fun acquireToken(scopes: Array<String>?, result: MethodChannel.Result) {
        if (!msal.isClientInitialized()) {
            Handler(Looper.getMainLooper()).post {
                result.error(
                    "NO_CLIENT",
                    "Client must be initialized before attempting to acquire a token.",
                    null
                )
            }
        }

        if (scopes == null) {
            result.error("NO_SCOPE", "Call must include a scope", null)
            return
        }

        //remove old accounts
        while (msal.adAuthentication.accounts.any())
            msal.adAuthentication.removeAccount(msal.adAuthentication.accounts.first())


        //acquire the token
        msal.activity?.let { msal.adAuthentication.acquireToken(it, scopes, msal.getAuthCallback(result)) }


    }

    private fun initialize(clientId: String?, result: MethodChannel.Result) {
        //ensure clientid provided
        if (clientId == null) {
            result.error("NO_CLIENTID", "Call must include a clientId", null)
            return
        }

        //if already initialized, ensure clientid hasn't changed

        if (msal.isClientInitialized()) {
            Log.d("initialize = TRUE", "${msal.isClientInitialized()}")
            if (msal.adAuthentication.configuration.clientId == clientId) {
                result.success(true)
            } else {
                result.error(
                    "CHANGED_CLIENTID",
                    "Attempting to initialize with multiple clientIds.",
                    null
                )
            }
        }
        if (!msal.isClientInitialized()) {
            // if authority is set, create client using it, otherwise use default
            msal.applicationContext.let {
                PublicClientApplication.createMultipleAccountPublicClientApplication(
                    it,
                    R.raw.msal_default_config, msal.getApplicationCreatedListener(result)
                )
            }
        }
    }

}