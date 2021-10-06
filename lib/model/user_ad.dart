class UserAdModel {
  final String? odataContext;
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
  String? accessToken;
  String? expiresOn;

  UserAdModel({
    this.id,
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
}
