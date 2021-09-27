# azure_ad_authentication

Login Azure Ad package Msal.

## Register your App
This app comes pre-configured for testing. If you would like to register your own app, please follow the steps below.

To Register an app:


Sign in to the [Azure portal](https://github.com/Azure-Samples/ms-identity-macOS-swift-objc#:~:text=in%20to%20the-,Azure%20portal,-using%20either%20a) using either a work or school account.
In the left-hand navigation pane, select the Azure Active Directory blade, and then select App registrations.
Click on the New registration button at the top left of the page.

# Android configs
* Version msal 2.0.2
- https://github.com/AzureAD/microsoft-authentication-library-for-android

- Note don't forget to add your Keystore folder to your App folder on android
with keystore key

For Andriod

* YOUR_BASE64_ENCODED_PACKAGE_SIGNATURE
```
$ keytool -exportcert -alias androiddebugkey -keystore "C:\Documents and  Settings\Administrator.android\debug.keystore" | "C:\OpenSSL\bin\openssl" sha1 -binary |"C:\OpenSSL\bin\openssl" base64
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



# iOs configs
* Version msal 1.0.7
- https://github.com/AzureAD/microsoft-authentication-library-for-objc



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


# MacOs configs
* Version msal 1.0.7
- https://github.com/Azure-Samples/ms-identity-macOS-swift-objc

- Step 1: Configure your application Info.plist
> Add URI scheme in the Info.plist. Redirect URI scheme follows the format msauth.[app_bundle_id]. Make sure to substitute [app_bundle_id] with the Bundle Identifier for your application.
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
