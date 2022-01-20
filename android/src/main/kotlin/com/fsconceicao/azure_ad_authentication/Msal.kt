package com.fsconceicao.azure_ad_authentication

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import com.microsoft.identity.client.*
import com.microsoft.identity.client.IPublicClientApplication.IMultipleAccountApplicationCreatedListener
import com.microsoft.identity.client.IPublicClientApplication.ISingleAccountApplicationCreatedListener
import com.microsoft.identity.client.exception.MsalClientException
import com.microsoft.identity.client.exception.MsalException
import com.microsoft.identity.client.exception.MsalServiceException
import com.microsoft.identity.client.exception.MsalUiRequiredException
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class Msal(context: Context, activity: FlutterActivity?) {
    internal val applicationContext = context
    internal var activity: FlutterActivity? = activity

    lateinit var adAuthentication: IPublicClientApplication
    lateinit var accountList: List<IAccount>

    fun setActivity(activity: FlutterActivity) {
        this.activity = activity;
    }

    internal fun isClientInitialized(): Boolean = ::adAuthentication.isInitialized

    internal fun getMultipleApplicationCreatedListener(result: MethodChannel.Result): IMultipleAccountApplicationCreatedListener {

        return object : IMultipleAccountApplicationCreatedListener {
            override fun onCreated(application: IMultipleAccountPublicClientApplication) {
                adAuthentication = application
                result.success(true)
            }

            override fun onError(exception: MsalException?) {
                result.error(
                    "INIT_ERROR",
                    "Error initializting client = ${exception.toString()}",
                    exception?.localizedMessage
                )
            }
        }
    }

    internal fun getSingleApplicationCreatedListener(result: MethodChannel.Result): ISingleAccountApplicationCreatedListener {

        return object : ISingleAccountApplicationCreatedListener {
            override fun onCreated(application: ISingleAccountPublicClientApplication) {
                adAuthentication = application
                result.success(true)
            }

            override fun onError(exception: MsalException?) {
                result.error(
                    "INIT_ERROR",
                    "Error initializting client = ${exception.toString()}",
                    exception?.localizedMessage
                )
            }
        }
    }

    internal fun getAuthCallback(result: MethodChannel.Result): AuthenticationCallback {
        return object : AuthenticationCallback {
            override fun onSuccess(authenticationResult: IAuthenticationResult) {
                Handler(Looper.getMainLooper()).post {
                    val account = authenticationResult.account as MultiTenantAccount;
                    result.success(
                        mapOf(
                            "identifier" to "${account.id}.${account.tenantId}",
                            "accessToken" to authenticationResult.accessToken,
                            "expiresOn" to "${authenticationResult.expiresOn}"
                        ))

                }
            }

            override fun onError(exception: MsalException) {
                Handler(Looper.getMainLooper()).post {
                    result.error(
                        "AUTH_ERROR",
                        "Authentication failed ${exception.localizedMessage}",
                        exception.errorCode
                    )
                }
            }

            override fun onCancel() {
                Handler(Looper.getMainLooper()).post {
                    result.error("CANCELLED", "User cancelled", null)
                }
            }
        }
    }

    /**
     * Callback used in for silent acquireToken calls.
     */
    internal fun getAuthSilentCallback(result: MethodChannel.Result): SilentAuthenticationCallback {
        return object : SilentAuthenticationCallback {
            override fun onSuccess(authenticationResult: IAuthenticationResult) {
                Handler(Looper.getMainLooper()).post {
                    result.success("{\"accessToken\":\"${authenticationResult.accessToken}\",\"expiresOn\":\"${authenticationResult.expiresOn}\"}")
                }
            }

            override fun onError(exception: MsalException) {
                when (exception) {
                    is MsalClientException -> {
                        result.error(
                            "NO_SCOPE",
                            "Call must include a scope",
                            exception.localizedMessage
                        )
                    }
                    is MsalServiceException -> {
                        result.error(
                            "NO_SCOPE",
                            exception.localizedMessage,
                            exception.localizedMessage
                        )
                    }
                    is MsalUiRequiredException -> {
                        result.error(
                            "NO_SCOPE",
                            "Call must include a scope",
                            exception.localizedMessage
                        )
                    }
                    else -> {
                        Log.d("MSAL_FLUTTER", "Authentication failed: $exception")
                    }
                }
            }
        }
    }

    /**
     * Load currently signed-in accounts, if there's any.
     */
    internal fun loadAccounts(result: MethodChannel.Result) {


        (adAuthentication as? IMultipleAccountPublicClientApplication)?.let {
            it.getAccounts(object : IPublicClientApplication.LoadAccountsCallback {

                override fun onTaskCompleted(resultList: List<IAccount>) {
                    accountList = resultList
                    result.success(true)
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
}

