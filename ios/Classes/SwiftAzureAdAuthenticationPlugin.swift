import Flutter
import UIKit
import MSAL



enum MsalErrors : Error {
    case noAccountId
    case noValidOs(sdkVersion: String)
    case noActiveAccount
}

public class SwiftAzureAdAuthenticationPlugin: NSObject, FlutterPlugin {
    
    //static fields as initialization isn't really required
    static var config : AzureAdConfig?
    //static var authority : String = ""
    static let kCurrentAccountIdentifier = "MSALCurrentAccountIdentifier"
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "azure_ad_authentication", binaryMessenger: registrar.messenger())
        let instance = SwiftAzureAdAuthenticationPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult)
    {
        //get the arguments as a dictionary
        let dict = call.arguments! as! NSDictionary
        let scopes = dict["scopes"] as? [String] ?? [String]()
        let config = dict["config"] as? [String: Any] ?? [:]
        let accountId = dict["accountId"] as? String
        
        switch( call.method ){
        case "initialize": initialize(configMap: config, result: result)
        case "acquireToken": acquireToken(scopes: scopes, accountId: accountId, result: result)
        case "acquireTokenSilent": acquireTokenSilent(scopes: scopes, accountId: accountId, result: result)
        case "logout": logout(result: result)
        default: result(FlutterError(code:"INVALID_METHOD", message: "The method called is invalid", details: nil))
        }
    }
    
    
    fileprivate func getResultLogin(_ authResult: MSALResult) -> [String: Any] {
        // Get access token from result
        return [
            "accessToken": authResult.accessToken,
            "identifier": authResult.account.identifier ?? "",
            "expiresOn": "\(String(describing: authResult.expiresOn))"
        ];
    }
    
    private func initialize(configMap: [String: Any], result: @escaping FlutterResult)
    {
        if let config = try? AzureAdConfig(jsonObject: configMap) {
            SwiftAzureAdAuthenticationPlugin.config = config
            result(true)
        } else {
            result(FlutterError(code:"NO_CONFIG", message: "Call must include a valid config", details: nil))
        }
        
    }
    
    
}
//MARK: - Get token
extension SwiftAzureAdAuthenticationPlugin {
    
    private func acquireToken(scopes: [String], accountId: String?, result: @escaping FlutterResult)
    {
        if let application = getApplication(result: result){
            
            // If we allready have an account we should use it to pre-populate the login
            try? currentAccount(result: result, accountId: accountId) { account, previousAccount, error in
            
                let viewController: UIViewController = UIApplication.shared.keyWindow!.rootViewController!
                let webviewParameters = MSALWebviewParameters(authPresentationViewController: viewController)
                if #available(iOS 13.0, *) {
                    webviewParameters.prefersEphemeralWebBrowserSession = true
                }
                webviewParameters.webviewType = .default

                let interactiveParameters = MSALInteractiveTokenParameters(
                    scopes: scopes,
                    webviewParameters: webviewParameters
                )
                
                interactiveParameters.account = account

                application.acquireToken(with: interactiveParameters, completionBlock: { (msalresult, error) in
                    guard let authResult = msalresult, error == nil else {
                        result(FlutterError(code: "AUTH_ERROR", message: "Authentication error", details: error!.localizedDescription))
                        return
                    }
                    
                    result(self.getResultLogin(authResult))
                })
            }
        }
        else {
            return
        }
        
    }
}
//MARK: - Get token silent
extension SwiftAzureAdAuthenticationPlugin {
    
    private func acquireTokenSilent(scopes: [String], accountId: String?, result: @escaping FlutterResult)
    {
        if let application = getApplication(result: result){
                       
            try? currentAccount(result: result, accountId: accountId) { account, previousAccount, error in
                
                if (account == nil) {
                    result(FlutterError(code: "NO_ACCOUNT", message: "No account is available to acquire token silently for", details: nil))
                    return
                }
                
                let silentParameters = MSALSilentTokenParameters(scopes: scopes, account: account!)

                application.acquireTokenSilent(with: silentParameters, completionBlock: { (msalresult, error) in
                    
                    guard let authResult = msalresult, error == nil else {
                        result(FlutterError(code: "AUTH_ERROR", message: "Authentication error", details: nil))
                        return
                    }
                    
                    result(self.getResultLogin(authResult))
                })
            }
        }
    }
}
//MARK: - Get logout remove or count cachedAccounts
extension SwiftAzureAdAuthenticationPlugin {
    fileprivate func signOut(_ application: MSALPublicClientApplication, _ account: MSALAccount, result: @escaping FlutterResult) {
        let viewController: UIViewController = UIApplication.shared.keyWindow!.rootViewController!
        let webviewParameters = MSALWebviewParameters(authPresentationViewController: viewController)
        webviewParameters.webviewType = .default
        
        let signoutParameters = MSALSignoutParameters(webviewParameters: webviewParameters)
        signoutParameters.signoutFromBrowser = false
        
        application.signout(with: account, signoutParameters: signoutParameters, completionBlock: {(success, error) in
            
            if error != nil {
                result(FlutterError(code: "Signout failed", message: "Signout failed", details: nil))
                return
            }
            // Sign out completed successfully
            result(true)
        })
    }
    
    private func logout(result: @escaping FlutterResult)
    {
        do{
            if let application = getApplication(result: result) {
                try currentAccount(result: result, accountId: nil, completionBlock: { account, previousAccount, error in
                    
                    guard let account = account else {
                        result(FlutterError(code: "NO_ACCOUNT", message: "no account to logout", details: nil))
                        return
                    }
                    
                    self.signOut(application, account, result: result)
                    
                })
            }
        } catch {
            result(FlutterError(code: "CONFIG_ERROR", message: "Unable get remove accounts", details: nil))
            return
        }
    }

    func currentAccount(result: @escaping FlutterResult, accountId: String?, completionBlock: @escaping MSALCurrentAccountCompletionBlock) throws -> Void {
        if (SwiftAzureAdAuthenticationPlugin.config?.accountMode == .SINGLE) {
            let msalParameters = MSALParameters()
            msalParameters.completionBlockQueue = DispatchQueue.main
                    
            getApplication(result: result)?.getCurrentAccount(with: msalParameters, completionBlock: completionBlock)
        } else {
            
            guard let accountId = accountId else {
                completionBlock(nil, nil, MsalErrors.noAccountId)
                return
            }
            
            guard #available(iOS 11.0, macOS 10.15, *) else {
                completionBlock(nil, nil, MsalErrors.noValidOs(sdkVersion: UIDevice.current.systemVersion))
                return
            }
            let parameters = MSALAccountEnumerationParameters(identifier:accountId)
            getApplication(result: result)?.accountsFromDevice(for: parameters)  { accounts, error in
                if let error = error {
                    completionBlock(nil, nil, error)
                    return
                    //Handle error
                }
                guard let accountObjs = accounts else {
                    completionBlock(nil, nil, MsalErrors.noActiveAccount)
                    return
                }
                
                completionBlock(accountObjs[0], nil, nil)
            }
        }

    }
}
//MARK: - get Application config
extension SwiftAzureAdAuthenticationPlugin {
    
    
    private func buildAuthorityUrl(config: AzureAdConfig) -> URL? {
        if let authority = config.authorities?.first {
            if let authorityUrl = authority.authorityUrl {
                return URL(string: authorityUrl)
            }
            
            if (authority.type == AuthorityType.AAD) {
                switch (authority.audience.type) {
                case .AzureADMultipleOrgs:
                    return URL(string: "https://login.microsoftonline.com/organizations")
                case .AzureADMyOrg:
                    return URL(string: "https://login.microsoftonline.com/\(authority.audience.tenantId ?? "common")")
                case .AzureADandPersonalMicrosoftAccount:
                    return URL(string: "https://login.microsoftonline.com/common")
                case .PersonalMicrosoftAccount:
                    return URL(string: "https://login.microsoftonline.com/consumers")
                }
            }
        }
        return nil
    }
    
    private func getApplication(result: @escaping FlutterResult) -> MSALPublicClientApplication?
    {
        if let config = SwiftAzureAdAuthenticationPlugin.config {
            if(config.clientId.isEmpty){
                result(FlutterError(code: "NO_CLIENT", message: "Client must be initialized before attempting to acquire a token.", details: nil))
                return nil
            }
            
            var appConfig: MSALPublicClientApplicationConfig
            
            var authority: MSALAuthority? = nil
            
            if let authorityUrl = buildAuthorityUrl(config:config) {
                authority = try? MSALAADAuthority(url: authorityUrl)
            }

            //setup the config, using authority if it is set, or defaulting to msal's own implementation if it's not
            appConfig = MSALPublicClientApplicationConfig(
                clientId: config.clientId,
                redirectUri: config.redirectUri,
                authority: authority
            )
            
            appConfig.multipleCloudsSupported = config.multipleCloudsSupported
            
            
            MSALGlobalConfig.loggerConfig.logLevel = config.logging.logLevel.toMSALLogLevel()
            MSALGlobalConfig.loggerConfig.logMaskingLevel = config.logging.piiEnabled
                ? .settingsMaskSecretsOnly
                : .settingsMaskAllPII
            
            MSALGlobalConfig.httpConfig.timeoutIntervalForRequest = TimeInterval(Double(config.http.readTimeout) / 100)
            
            var application: MSALPublicClientApplication?
            
            do {
                application = try MSALPublicClientApplication(configuration: appConfig)

                return application
            } catch {
                print("failed to create client application \(error)")
                result(FlutterError(code: "CONFIG_ERROR", message: "Unable to create MSALPublicClientApplication", details: nil))
                return nil
            }
        }
        return nil
    }
}
