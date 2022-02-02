class AzureAdResponse {
  AzureAdResponse({
    required this.identifier,
    required this.accessToken,
    required this.expiresOn,
  });

  final String identifier;
  final String accessToken;
  final String expiresOn;

  factory AzureAdResponse.fromJson(Map<String, dynamic> json) {
    return AzureAdResponse(
      identifier: json['identifier'],
      accessToken: json['accessToken'],
      expiresOn: json["expiresOn"],
    );
  }
  Map<String, dynamic>? toJson() => {
        'identifier': identifier,
        'accessToken': accessToken,
        'expiresOn': expiresOn,
      };
}

class UserAdModel {
  final String? odataContext;
  /// A composite key created by the userId (oid) and tenantId (tid) used
  /// internally in MSAL as a caching key
  final String? identifier;
  final String? id;
  final String? displayName;
  final String? givenName;
  final String? surname;
  final String? userPrincipalName;
  final String? mail;
  final List<String>? businessPhones;
  final String? jobTitle;
  final String? mobilePhone;
  final String? officeLocation;
  final String? preferredLanguage;
  final String? accessToken;
  final String? expiresOn;

  UserAdModel({
    this.id,
    this.identifier,
    this.displayName,
    this.givenName,
    this.surname,
    this.userPrincipalName,
    this.mail,
    this.accessToken,
    this.expiresOn,
    this.businessPhones,
    this.odataContext,
    this.jobTitle,
    this.mobilePhone,
    this.officeLocation,
    this.preferredLanguage,
  });

  /// model user ad return model inf
  /// ```
  /// @odata.context
  /// id
  /// displayName
  /// givenName
  /// surname
  /// userPrincipalName
  /// mail
  /// businessPhones
  /// jobTitle
  /// mobilePhone
  /// officeLocation
  /// preferredLanguage
  /// accessToken -> token user
  /// expiresOn -> date time of expiration
  /// ```
  factory UserAdModel.fromJson(Map<String, dynamic> json) {
    return UserAdModel(
      odataContext: json['@odata.context'],
      id: json['id'],
      identifier: json['identifier'],
      displayName: json['displayName'],
      givenName: json['givenName'],
      surname: json['surname'],
      userPrincipalName: (json["userPrincipalName"] != null)
          ? json['userPrincipalName'].toString().toLowerCase()
          : 'N/D',
      mail:
          (json['mail'] != null) ? json['mail'].toString().toLowerCase() : null,
      accessToken: json['accessToken'],
      expiresOn: json["expiresOn"],
      businessPhones: (json["businessPhones"] != null)
          ? json["businessPhones"].cast<String>()
          : null,
      jobTitle: json['jobTitle'],
      mobilePhone: json['mobilePhone'],
      officeLocation: json['officeLocation'],
      preferredLanguage: json['preferredLanguage'],
    );
  }

  Map<String, dynamic>? toJson() => {
        'id': id,
        "identifier": identifier,
        'displayName': displayName,
        'givenName': givenName,
        'surname': surname,
        'userPrincipalName': userPrincipalName,
        'mail': mail,
        'businessPhones': businessPhones,
        'jobTitle': jobTitle,
        'officeLocation': officeLocation,
        'preferredLanguage': preferredLanguage,
        'accessToken': accessToken,
        'expiresOn': expiresOn,
      };


  UserAdModel copyWith({
    String? odataContext,
    String? identifier,
    String? id,
    String? displayName,
    String? givenName,
    String? surname,
    String? userPrincipalName,
    String? mail,
    List<String>? businessPhones,
    String? jobTitle,
    String? mobilePhone,
    String? officeLocation,
    String? preferredLanguage,
    String? accessToken,
    String? expiresOn,

  }) => UserAdModel(
    odataContext: odataContext ?? this.odataContext,
    identifier: identifier ?? this.identifier,
    id: id ?? this.id,
    displayName: displayName ?? this.displayName,
    givenName: givenName ?? this.givenName,
    surname: surname ?? this.surname,
    userPrincipalName: userPrincipalName ?? this.userPrincipalName,
    mail: mail ?? this.mail,
    businessPhones: businessPhones ?? this.businessPhones,
    jobTitle: jobTitle ?? this.jobTitle,
    mobilePhone: mobilePhone ?? this.mobilePhone,
    officeLocation: officeLocation ?? this.officeLocation,
    preferredLanguage: preferredLanguage ?? this.preferredLanguage,
    accessToken: accessToken ?? this.accessToken,
    expiresOn: expiresOn ?? this.expiresOn,
  );
}
