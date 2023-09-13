package com.fsconceicao.azure_ad_authentication

import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding


class AzureAdAuthenticationPlugin : FlutterPlugin, ActivityAware {

    private var TAG = "AzureAdAuthenticationPlugin"
    private var msalCallHandler: MsalHandlerImpl? = null
    private var msal:Msal? = null


    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        msal = Msal(binding.applicationContext, null)
        msalCallHandler = MsalHandlerImpl(msal!!)
        msalCallHandler.let {
            it?.startListening(binding.binaryMessenger)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        if (msalCallHandler == null) {
            Log.wtf(TAG, "Already detached from the engine.")
            return
        }

        msalCallHandler.let {
            it?.stopListening()
        }
        msalCallHandler = null
        msal = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        if (msalCallHandler == null) {
            Log.wtf(TAG, "urlLauncher was never set.")
            return
        }
        msal.let {
            it?.setActivity(binding.activity)
        }
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivity() {
        if (msalCallHandler == null) {
            Log.wtf(TAG, "urlLauncher was never set.")
            return
        }
    }
}