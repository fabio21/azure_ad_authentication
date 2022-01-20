package com.fsconceicao.azure_ad_authentication

import android.app.Activity
import android.os.Handler
import android.os.Looper
import android.util.Log
import com.google.gson.Gson
import com.google.gson.JsonObject
import com.microsoft.identity.client.*
import com.microsoft.identity.client.exception.MsalException
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.jetbrains.annotations.Nullable
import java.io.File
import java.io.FileWriter
import java.lang.reflect.InvocationTargetException
import java.lang.reflect.Method
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
        //val clientId: String? = call.argument("clientId")

        val config: Map<String, Any?>? = call.argument("config")

        //our code
        when (call.method) {
            "initialize" -> {
                initialize(config, result)
            }
            "loadAccounts" -> Thread(Runnable { msal.loadAccounts(result) }).start()
            "acquireToken" -> Thread(Runnable { acquireToken(scopes, result)}).start()
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


        (msal.adAuthentication as? IMultipleAccountPublicClientApplication)?.let {
            it.removeAccount(
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
    }

    private fun acquireTokenSilent(scopes: Array<String>?, result: MethodChannel.Result) {
        //  check if client has been initialized

        if (!msal.isClientInitialized()) {
            Handler(Looper.getMainLooper()).post {
                result.error(
                    "NO_CLIENT",
                    "Client must be initialized before attempting to acquire a token.",
                    ""
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
        val sc = scopes.map { s -> s.toLowerCase(Locale.ROOT) }

        val aquireTokenParameters = AcquireTokenSilentParameters
            .Builder()
            .forAccount(selectedAccount)
            .withScopes(sc)
            .fromAuthority(selectedAccount.authority)
            .withCallback(msal.getAuthSilentCallback(result))
            .build()

        msal.adAuthentication.acquireTokenSilentAsync(aquireTokenParameters)
    }


    private fun getPersistedCurrentAccount(): IAccount? {
        var account: IAccount? = null
        val c: Class<*> = SingleAccountPublicClientApplication::class.java
        var method: Method? = null
        try {
            method = c.getDeclaredMethod("getPersistedCurrentAccount")
            method.isAccessible = true
            account = method.invoke(msal.adAuthentication) as IAccount?
        } catch (e: NoSuchMethodException) {
            e.printStackTrace()
        } catch (e: IllegalAccessException) {
            return null
        } catch (e: InvocationTargetException) {
            return null
        } catch (e: Exception) {
            return null
        }
        return account
    }

    private fun acquireToken(scopes: Array<String>?, result: MethodChannel.Result) {
        if (!msal.isClientInitialized()) {
           // Handler(Looper.getMainLooper()).post {
                result.error(
                    "NO_CLIENT",
                    "Client must be initialized before attempting to acquire a token.",
                    null
                )
           // }
        }

        if (scopes == null) {
            result.error("NO_SCOPE", "Call must include a scope", null)
            return
        }

        //remove old accounts (is this needed for multi account?)
        (msal.adAuthentication as? IMultipleAccountPublicClientApplication)?.let {
            while(it.accounts.any())
                it.removeAccount(it.accounts.first())

        }


        //acquire the token
        msal.activity?.let {
            val persistedAccount = if (msal.adAuthentication is SingleAccountPublicClientApplication) {
                getPersistedCurrentAccount()
            } else null

            val acquireTokenParameters: AcquireTokenParameters = buildAcquireTokenParameters(
                it,
                scopes,
                //authority,
                persistedAccount,
                msal.getAuthCallback(result)
            )

            msal.adAuthentication.acquireToken(acquireTokenParameters)
        }
    }

    private fun buildAcquireTokenParameters(
        activity: Activity,
        scopes: Array<String>,
        account: IAccount?,
        callback: AuthenticationCallback
    ): AcquireTokenParameters {
        val builder = AcquireTokenParameters.Builder()
                builder.startAuthorizationFromActivity(activity)
            .withScopes(scopes.asList())
            .withCallback(callback)
        if (account != null) {
            builder.forAccount(account)
        }
        return builder.build()
    }

    private fun initialize(config: Map<String, Any?>?, result: MethodChannel.Result) {
        if (config == null) {
            result.error("NO_CONFIG", "Call must include a config", null)
            return
        }

        val gson = Gson()
        val jsonConfigString = gson.toJson(config);
        var jsonConfig = gson.fromJson(jsonConfigString, JsonObject::class.java)

        val accountMode = jsonConfig.get("account_mode").asString
        val clientId = jsonConfig.get("client_id").asString

        if (clientId == null) {
            result.error("NO_CLIENTID", "Call must include config with a clientId", null)
            return
        }

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
            return;
        }

        val configFile = File.createTempFile("configFile", "json")
        var configFileWriter: FileWriter? = null
        try {
            configFileWriter = FileWriter(configFile, true)
            configFileWriter.write(jsonConfig.toString())


            if (!msal.isClientInitialized()) {
                if (accountMode == "MULTIPLE") {
                    PublicClientApplication.createMultipleAccountPublicClientApplication(
                        msal.applicationContext,
                        configFile,
                        msal.getMultipleApplicationCreatedListener(result)
                    )
                } else {
                    PublicClientApplication.createSingleAccountPublicClientApplication(
                        msal.applicationContext,
                        configFile,
                        msal.getSingleApplicationCreatedListener(result)
                    )
                }

            }
        } finally {
            if (configFileWriter != null) {
                configFileWriter.flush()
                configFileWriter.close()
            }
        }
    }

}