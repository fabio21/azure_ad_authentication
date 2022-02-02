// ignore_for_file: constant_identifier_names

class MsalAudience {
  const MsalAudience(this.type, { this.tenantId });
  final AudienceType type;
  final String? tenantId;


  Map<String, dynamic> toMap() {
    return {
      'type': type.toString(),
      if(tenantId != null) 'tenant_id': tenantId,
    };
  }
}

class MsalAuthority {
  const MsalAuthority(this.type, this.audience, {
    bool isDefault = false,
    this.authorityUrl,
  }) : _default = isDefault;
  final AuthorityType type;
  final MsalAudience audience;
  final bool _default;
  final String? authorityUrl;

  Map<String, dynamic> toMap() {
    return {
      'type': type.toString(),
      if(authorityUrl != null) 'authority_url': authorityUrl,
      'audience': audience.toMap(),
      if (_default) 'default': _default,
    };
  }
}


class MsalHttpConfig {
  const MsalHttpConfig({
    this.connectTimeout = 10000,
    this.readTimeout = 30000,
  });
  final int connectTimeout;
  final int readTimeout;

  Map<String, dynamic> toMap() {
    return {
      'connect_timeout': connectTimeout,
      'read_timeout': readTimeout,
    };
  }
}

class MsalLoggingConfig {
  const MsalLoggingConfig({
    this.piiEnabled = false,
    this.logLevel,
    this.logcatEnabled = true,
  });

  final bool piiEnabled;
  final ErrorLevel? logLevel;

  // Android only
  final bool logcatEnabled;

  Map<String, dynamic> toMap() {
    return {
      'pii_enabled': piiEnabled,
      if(logLevel != null) 'log_level': logLevel.toString(),
      'logcat_enabled': logcatEnabled
    };
  }
}

const _defaultAuthorities = MsalAuthority(
  AuthorityType.AAD,
  MsalAudience(AudienceType.AzureADandPersonalMicrosoftAccount),
);


class AuthorizedUserAgent {
  const AuthorizedUserAgent._(this.index);
  final int index;

  static const DEFAULT = AuthorizedUserAgent._(0);
  static const BROWSER = AuthorizedUserAgent._(1);
  static const WEBVIEW = AuthorizedUserAgent._(2);

  @override
  String toString() {
    switch(this) {
      case DEFAULT:
      return 'DEFAULT';
      case BROWSER:
      return 'BROWSER';
      case WEBVIEW:
      return 'WEBVIEW';
    }
    throw Error();
  }
}

class AccountMode {
  const AccountMode._(this.index);
  final int index;

  static const MULTIPLE = AccountMode._(0);
  static const SINGLE = AccountMode._(1);

  @override
  String toString() {
    switch(this) {
      case MULTIPLE:
      return 'MULTIPLE';
      case SINGLE:
      return 'SINGLE';
    }
    throw Error();
  }
}

class AuthorityType {
  const AuthorityType._(this.index);
  final int index;

  static const AAD = AuthorityType._(0);
  static const B2C = AuthorityType._(1);

  @override
  String toString() {
    switch(this) {
      case AAD:
      return 'AAD';
      case B2C:
      return 'B2C';
    }
    throw Error();
  }
}


class AudienceType {
  const AudienceType._(this.index);
  final int index;

  static const AzureADandPersonalMicrosoftAccount = AudienceType._(0);
  static const AzureADMyOrg = AudienceType._(1);
  static const AzureADMultipleOrgs = AudienceType._(2);
  static const PersonalMicrosoftAccount = AudienceType._(3);

  @override
  String toString() {
    switch(this) {
      case AzureADandPersonalMicrosoftAccount:
      return 'AzureADandPersonalMicrosoftAccount';
      case AzureADMyOrg:
      return 'AzureADMyOrg';
      case AzureADMultipleOrgs:
      return 'AzureADMultipleOrgs';
      case PersonalMicrosoftAccount:
      return 'PersonalMicrosoftAccount';
    }
    throw Error();
  }
}

class ErrorLevel {
  const ErrorLevel._(this.index);
  final int index;
  static const ERROR = ErrorLevel._(0);
  static const WARNING = ErrorLevel._(1);
  static const INFO = ErrorLevel._(2);
  static const VERBOSE = ErrorLevel._(3);

  @override
  String toString() {
    switch(this) {
      case ERROR:
      return 'ERROR';
      case WARNING:
      return 'WARNING';
      case INFO:
      return 'INFO';
      case VERBOSE:
      return 'VERBOSE';
    }
    throw Error();
  }
}



class MsalConfig {
  MsalConfig({
    required this.clientId,
    required this.redirectUri,
    this.authorities = const [_defaultAuthorities],
    this.environment = 'Production',
    this.accountMode = AccountMode.SINGLE,
    this.sharedDeviceModeSupported = false,
    this.brokerRedirectUriRegistered = false,
    this.multipleCloudsSupported = false,
    this.authorizationUserAgent = AuthorizedUserAgent.DEFAULT,
    this.logging = const MsalLoggingConfig(),
    this.http = const MsalHttpConfig(),
  });

  factory MsalConfig.copy(MsalConfig config) => MsalConfig(
    clientId: config.clientId,
    redirectUri: config.redirectUri,
    authorities: config.authorities,
    environment: config.environment,
    accountMode: config.accountMode,
    sharedDeviceModeSupported: config.sharedDeviceModeSupported,
    brokerRedirectUriRegistered: config.brokerRedirectUriRegistered,
    authorizationUserAgent: config.authorizationUserAgent,
    http: config.http,
    logging: config.logging,
    multipleCloudsSupported: config.multipleCloudsSupported,
  );


  final String clientId;
  final String redirectUri;
  final AccountMode accountMode;
  final List<MsalAuthority> authorities;
  final bool multipleCloudsSupported;
  final MsalLoggingConfig logging;
  final MsalHttpConfig http;

  // Android specific
  final String environment;
  final bool sharedDeviceModeSupported;
  final bool brokerRedirectUriRegistered;
  final AuthorizedUserAgent authorizationUserAgent;

  Map<String, dynamic> toMap() {
    return {
      'client_id': clientId,
      'redirect_uri': redirectUri,
      'account_mode': accountMode.toString(),
      'authorities': authorities.map((a) => a.toMap()).toList(),
      'multiple_clouds_supported': multipleCloudsSupported,
      'logging': logging.toMap(),
      'http': http.toMap(),

      // Android specific
      'environment': environment,
      'shared_device_mode_supported': sharedDeviceModeSupported,
      'broker_redirect_uri_registered': brokerRedirectUriRegistered,
      'authorization_user_agent': authorizationUserAgent.toString(),
    };
  }
}
