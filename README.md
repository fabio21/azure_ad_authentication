# azure_ad_authentication

Azure Ad package Msal login for Android, iOS and MacOs, AD refund information user and token and expiration time session

## Register your App
This app comes pre-configured for testing. If you would like to register your own app, please follow the steps below.

To Register an app:


Sign in to the [Azure portal](https://portal.azure.com/#home) using either a work or school account.
In the left-hand navigation pane, select the Azure Active Directory blade, and then select App registrations.
Click on the New registration button at the top left of the page.

## Android Configs
* Version msal 4.+
- https://github.com/AzureAD/microsoft-authentication-library-for-android

- Note don't forget to add your Keystore folder to your App folder on android
with keystore key

## Extra Setup for Android Network Security for Msal 4.+
* Path folder res -> xml -> network_security_config.xml

* No Network Security Config specified, using platform default

* Example
```
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <debug-overrides>
        <trust-anchors>
            <!-- Trust preinstalled CAs -->
            <certificates src="system" />
            <!-- Trust user added CAs while debuggable only -->
            <certificates src="user" />
        </trust-anchors>
    </debug-overrides>
</network-security-config>
```
* AndroidManifest.xml
```
<application
   android:networkSecurityConfig="@xml/network_security_config"
```
* Network Security Config from resource network_security_config debugBuild: true
* [Check Network Security Android here](https://developer.android.com/training/articles/security-config?hl=pt-br)

For Andriod

* Integrating with a broker
Generate a redirect URI for a broker
You must register a redirect URI that is compatible with the broker. The redirect URI for the broker should include your app's package name and the Base64-encoded representation of your app's signature.

The format of the redirect URI is:
>msauth://yourpackagename/base64urlencodedsignature

You can use keytool to generate a Base64-encoded signature hash using your app's signing keys, and then use the Azure portal to generate your redirect URI using that hash.
- Linux and macOS:
```
keytool -exportcert -alias androiddebugkey -keystore ~/.android/debug.keystore | openssl sha1 -binary | openssl base64
```
- Windows
```
keytool -exportcert -alias androiddebugkey -keystore %HOMEPATH%\.android\debug.keystore | openssl sha1 -binary | openssl base64
```
* AndroidManifest.xml
```
<activity
        android:name="com.microsoft.identity.client.BrowserTabActivity">
        <intent-filter>
            <action android:name="android.intent.action.VIEW" />
            <category android:name="android.intent.category.DEFAULT" />
            <category android:name="android.intent.category.BROWSABLE" />
            <data
                android:scheme="msauth"
                android:host="<YOUR_PACKAGE_NAME>"
                android:path="/<YOUR_BASE64_ENCODED_PACKAGE_SIGNATURE>" />
        </intent-filter>
    </activity>
 ```

 * build.gradle
 ```
  signingConfigs {
        debug {
            storeFile file("Keystore/debug.keystore")
            storePassword 'android'
            keyAlias 'androiddebugkey'
            keyPassword 'android'
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
        debug {
            signingConfig signingConfigs.debug
        }
    }
 ```

* Path folder res -> raw ->  msal_default_config.json
> [MSAL (Microsoft Authentication Library)](https://docs.microsoft.com/pt-br/azure/active-directory/develop/msal-configuration)

```
{
  "client_id" : "xxxxxxxxxxx",
  "authorization_user_agent" : "DEFAULT",
  "redirect_uri" : "msauth://xxxxxxxxxx/U5rbvBLdFUbEazWhQfDgt6oRa24%3D",
  "account_mode" : "MULTIPLE",
  "minimum_required_broker_protocol_version": "3.0",
  "multiple_clouds_supported": false,
  "broker_redirect_uri_registered": true,
  "web_view_zoom_controls_enabled": true,
  "web_view_zoom_enabled": true,
  "environment": "Production",
  "power_opt_check_for_network_req_enabled": true,
  "handle_null_taskaffinity": false,
  "authorization_in_current_task": false,
  "authorities" : [
    {
      "type": "AAD",
      "authority_url": "https://login.microsoftonline.com/organizations",
      "audience": {
        "type": "AzureADMultipleOrgs"
      },
      "default": true
    }
  ],
  "browser_safelist": [
    {
      "browser_package_name": "com.android.chrome",
      "browser_signature_hashes": [
        "7fmduHKTdHHrlMvldlEqAIlSfii1tl35bxj1OXN5Ve8c4lU6URVu4xtSHc3BVZxS6WWJnxMDhIfQN0N0K2NDJg=="
      ],
      "browser_use_customTab" : true,
      "browser_version_lower_bound": "45"
    },
    {
      "browser_package_name": "com.android.chrome",
      "browser_signature_hashes": [
        "7fmduHKTdHHrlMvldlEqAIlSfii1tl35bxj1OXN5Ve8c4lU6URVu4xtSHc3BVZxS6WWJnxMDhIfQN0N0K2NDJg=="
      ],
      "browser_use_customTab" : false
    },
    {
      "browser_package_name": "org.mozilla.firefox",
      "browser_signature_hashes": [
        "2gCe6pR_AO_Q2Vu8Iep-4AsiKNnUHQxu0FaDHO_qa178GByKybdT_BuE8_dYk99G5Uvx_gdONXAOO2EaXidpVQ=="
      ],
      "browser_use_customTab" : false
    },
    {
      "browser_package_name": "org.mozilla.firefox",
      "browser_signature_hashes": [
        "2gCe6pR_AO_Q2Vu8Iep-4AsiKNnUHQxu0FaDHO_qa178GByKybdT_BuE8_dYk99G5Uvx_gdONXAOO2EaXidpVQ=="
      ],
      "browser_use_customTab" : true,
      "browser_version_lower_bound": "57"
    },
    {
      "browser_package_name": "com.sec.android.app.sbrowser",
      "browser_signature_hashes": [
        "ABi2fbt8vkzj7SJ8aD5jc4xJFTDFntdkMrYXL3itsvqY1QIw-dZozdop5rgKNxjbrQAd5nntAGpgh9w84O1Xgg=="
      ],
      "browser_use_customTab" : true,
      "browser_version_lower_bound": "4.0"
    },
    {
      "browser_package_name": "com.sec.android.app.sbrowser",
      "browser_signature_hashes": [
        "ABi2fbt8vkzj7SJ8aD5jc4xJFTDFntdkMrYXL3itsvqY1QIw-dZozdop5rgKNxjbrQAd5nntAGpgh9w84O1Xgg=="
      ],
      "browser_use_customTab" : false
    },
    {
      "browser_package_name": "com.cloudmosa.puffinFree",
      "browser_signature_hashes": [
        "1WqG8SoK2WvE4NTYgr2550TRhjhxT-7DWxu6C_o6GrOLK6xzG67Hq7GCGDjkAFRCOChlo2XUUglLRAYu3Mn8Ag=="
      ],
      "browser_use_customTab" : false
    },
    {
      "browser_package_name": "com.duckduckgo.mobile.android",
      "browser_signature_hashes": [
        "S5Av4cfEycCvIvKPpKGjyCuAE5gZ8y60-knFfGkAEIZWPr9lU5kA7iOAlSZxaJei08s0ruDvuEzFYlmH-jAi4Q=="
      ],
      "browser_use_customTab" : false
    },
    {
      "browser_package_name": "com.explore.web.browser",
      "browser_signature_hashes": [
        "BzDzBVSAwah8f_A0MYJCPOkt0eb7WcIEw6Udn7VLcizjoU3wxAzVisCm6bW7uTs4WpMfBEJYf0nDgzTYvYHCag=="
      ],
      "browser_use_customTab" : false
    },

    {
      "browser_package_name": "com.ksmobile.cb",
      "browser_signature_hashes": [
        "lFDYx1Rwc7_XUn4KlfQk2klXLufRyuGHLa3a7rNjqQMkMaxZueQfxukVTvA7yKKp3Md3XUeeDSWGIZcRy7nouw=="
      ],
      "browser_use_customTab" : false
    },

    {
      "browser_package_name": "com.microsoft.emmx",
      "browser_signature_hashes": [
        "Ivy-Rk6ztai_IudfbyUrSHugzRqAtHWslFvHT0PTvLMsEKLUIgv7ZZbVxygWy_M5mOPpfjZrd3vOx3t-cA6fVQ=="
      ],
      "browser_use_customTab" : false
    },

    {
      "browser_package_name": "com.opera.browser",
      "browser_signature_hashes": [
        "FIJ3IIeqB7V0qHpRNEpYNkhEGA_eJaf7ntca-Oa_6Feev3UkgnpguTNV31JdAmpEFPGNPo0RHqdlU0k-3jWJWw=="
      ],
      "browser_use_customTab" : false
    },

    {
      "browser_package_name": "com.opera.mini.native",
      "browser_signature_hashes": [
        "TOTyHs086iGIEdxrX_24aAewTZxV7Wbi6niS2ZrpPhLkjuZPAh1c3NQ_U4Lx1KdgyhQE4BiS36MIfP6LbmmUYQ=="
      ],
      "browser_use_customTab" : false
    },

    {
      "browser_package_name": "mobi.mgeek.TunnyBrowser",
      "browser_signature_hashes": [
        "RMVoXuK1sfJZuGZ8onG1yhMc-sKiAV2NiB_GZfdNlN8XJ78XEE2wPM6LnQiyltF25GkHiPN2iKQiGwaO2bkyyQ=="
      ],
      "browser_use_customTab" : false
    },

    {
      "browser_package_name": "org.mozilla.focus",
      "browser_signature_hashes": [
        "L72dT-stFqomSY7sYySrgBJ3VYKbipMZapmUXfTZNqOzN_dekT5wdBACJkpz0C6P0yx5EmZ5IciI93Q0hq0oYA=="
      ],
      "browser_use_customTab" : false
    }
  ]
}
```

## iOs Configs
* Version msal 1.2.9
* minimum support 14 
- [MSAL (Microsoft Authentication Library iOS)](https://github.com/AzureAD/microsoft-authentication-library-for-objc)



> Configuring MSAL
Adding MSAL to your project
Register your app in the Azure portal
Make sure you register a redirect URI for your application. It should be in the following format:

`
msauth.$(PRODUCT_BUNDLE_IDENTIFIER)://auth
`

> Add a new keychain group to your project Capabilities. Keychain group should be com.microsoft.adalcache on iOS and com.microsoft.identity.universalstorage on macOS.

![alt text](https://raw.githubusercontent.com/AzureAD/microsoft-authentication-library-for-objc/dev/Images/keychain_example.png)

> See more information about keychain groups and Silent SSO for MSAL.

>iOS only steps:
Add your application's redirect URI scheme to your Info.plist file

```
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>msauth.$(PRODUCT_BUNDLE_IDENTIFIER)</string>
        </array>
    </dict>
</array>
```
>Add LSApplicationQueriesSchemes to allow making call to Microsoft Authenticator if installed.
Note that "msauthv3" scheme is needed when compiling your app with Xcode 11 and later.
```
<key>LSApplicationQueriesSchemes</key>
<array>
	<string>msauthv2</string>
	<string>msauthv3</string>
</array>
```
>See more info about configuring redirect uri for MSAL


## MacOs Configs
* Version msal 1.2.9
- [MSAL (Microsoft Authentication Library MacOs)](https://github.com/Azure-Samples/ms-identity-macOS-swift-objc)

- Step 1: Configure your application Info.plist
> Add URI scheme in the Info.plist. Redirect URI scheme follows the format msauth.[app_bundle_id]. Make sure to substitute [app_bundle_id] with the Bundle Identifier for your application.

```
 String _authority = "https://login.microsoftonline.com/organizations/oauth2/v2.0/authorize";

 String _redirectUri = "msauth.msal2794d211-4e3f-4010-9f37-250f928d19c5://auth";
 
 String _clientId = "2794d211-4e3f-4010-9f37-250f928d19c5";
 
 Future<AzureAdAuthentication> intPca() async {
    return await AzureAdAuthentication.createPublicClientApplication(
        clientId: _clientId, authority: _authority, redirectUri: _redirectUri,);
  }
```

```
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>msauth.[app_bundle_id]</string>
    </array>
  </dict>
</array>
```
- Step 2: Configure Xcode project settings
Add a new keychain group to your project Signing & Capabilities. The keychain group should be com.microsoft.identity.universalstorage on macOS.

![alt text](https://raw.githubusercontent.com/Azure-Samples/ms-identity-macOS-swift-objc/master/images/iosintro-keychainShare.png)

Xcode UI displaying how the the keychain group should be set up
