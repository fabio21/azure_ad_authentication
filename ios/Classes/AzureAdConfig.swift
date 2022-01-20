//
//  AzureAdConfig.swift
//  azure_ad_authentication
//
//  Created by Bjarte Bore on 20/01/2022.
//

import Foundation
import MSAL

public struct AzureAdConfig : Decodable {
    
    public let clientId: String
    public let redirectUri: String
    public let authorities: [Authority]?
    public let environment: String
    public let accountMode: AccountMode
    public let sharedDeviceModeSupported: Bool
    public let multipleCloudsSupported: Bool
    public let authorizationUserAgent: AuthorizedUserAgent
    public let logging: LoggingConfig
    public let http: HttpConfig
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ConfigCodingKeys.self)
        clientId = try container.decode(String.self, forKey: .clientId)
        redirectUri = try container.decode(String.self, forKey: .redirectUri)
        authorities = try container.decode([Authority].self, forKey: .authorities)
        environment = try container.decode(String.self, forKey: .environment)
        accountMode = try container.decode(AccountMode.self, forKey: .accountMode)
        sharedDeviceModeSupported = try container.decode(Bool.self, forKey: .sharedDeviceModeSupported)
        multipleCloudsSupported = try container.decode(Bool.self, forKey: .multipleCloudsSupported)
        authorizationUserAgent = try container.decode(AuthorizedUserAgent.self, forKey: .authorizationUserAgent)
        logging = try container.decode(LoggingConfig.self, forKey: .logging)
        http = try container.decode(HttpConfig.self, forKey: .http)

    }
    
    public init(jsonObject: [String: Any]) throws {
        let layerData = try JSONSerialization.data(withJSONObject: jsonObject)
        self = try JSONDecoder().decode(Self.self, from: layerData)
    }
    
}


public struct Authority : Decodable {
    public let type: AuthorityType
    public let audience: Audience
    public let isDefault: Bool
    public let authorityUrl: String?
    
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: AuthorityCodingKeys.self)
     
        type = try container.decode(AuthorityType.self, forKey: .type)
        audience = try container.decode(Audience.self, forKey: .audience)
        isDefault = {
            do {
                return try container.decode(Bool.self, forKey: .isDefault)
            } catch {
                return false
            }
        }()
        authorityUrl = try? container.decode(String.self, forKey: .authorityUrl)
    }
}

public struct Audience : Decodable {
    public let type: AudienceType
    public let tenantId: String?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: AudienceCodingKeys.self)
     
        type = try container.decode(AudienceType.self, forKey: .type)
        tenantId = try? container.decode(String.self, forKey: .tenantId)
    }
}

public struct LoggingConfig: Decodable {
    public let piiEnabled: Bool
    public let logLevel: LogLevel
    public let logcatEnabled: Bool
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: LoggingConfigCodingKeys.self)
        
        piiEnabled = try container.decode(Bool.self, forKey: .piiEnabled)
        logLevel = (try? container.decode(LogLevel.self, forKey: .logLevel)) ?? .NONE
        logcatEnabled = try container.decode(Bool.self, forKey: .logcatEnabled)
    }
}

public struct HttpConfig: Decodable {
    public let connectTimeout: Int
    public let readTimeout: Int
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: HttpConfigCodingKeys.self)
        
        connectTimeout = try container.decode(Int.self, forKey: .connectTimeout)
        readTimeout = try container.decode(Int.self, forKey: .readTimeout)
    }
}


enum ConfigCodingKeys: String, CodingKey {
  case clientId = "client_id"
  case redirectUri = "redirect_uri"
  case authorities = "authorities"
  case environment = "environment"
  case accountMode = "account_mode"
  case sharedDeviceModeSupported = "shared_device_mode_supported"
  case multipleCloudsSupported = "multiple_clouds_supported"
  case authorizationUserAgent = "authorization_user_agent"
  case logging = "logging"
  case http = "http"
}


enum AuthorityCodingKeys: String, CodingKey {
  case type = "type"
  case authorityUrl = "authority_url"
  case audience = "audience"
  case isDefault = "default"
}

enum AudienceCodingKeys: String, CodingKey {
  case type = "type"
  case tenantId = "tenant_id"
}

enum LoggingConfigCodingKeys: String, CodingKey {
    case piiEnabled = "pii_enabled"
    case logLevel = "log_level"
    case logcatEnabled = "logcat_enabled"
}

enum HttpConfigCodingKeys: String, CodingKey {
    case connectTimeout = "connect_timeout"
    case readTimeout = "read_timeout"
}


public enum AuthorizedUserAgent: String, Codable {
    case DEFAULT
    
    case BROWSER
    
    case WEBVIEW
}

public enum AccountMode: String, Codable {
    case MULTIPLE
    
    case SINGLE
}

public enum AuthorityType: String, Codable {
    case AAD
    
    case B2C
}

public enum AudienceType: String, Codable {
    case AzureADandPersonalMicrosoftAccount
    
    case AzureADMyOrg
    
    case AzureADMultipleOrgs
    
    case PersonalMicrosoftAccount
}


public enum LogLevel: String, Codable {
    case NONE
    
    case ERROR
    
    case WARNING
    
    case INFO
    
    case VERBOSE
    
    
    public func toMSALLogLevel() -> MSALLogLevel {
        switch(self) {
            case .ERROR:
                return .error
            case .INFO:
                return .info
            case .WARNING:
                return .warning
            case .VERBOSE:
                return .verbose
        case .NONE:
                return .nothing
        }
    }
    
}
