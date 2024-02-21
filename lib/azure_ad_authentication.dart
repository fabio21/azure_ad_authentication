import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

import 'exeption.dart';
import 'model/request.dart';
import 'model/user_ad.dart';

enum WebViewType {
    safari,
    webView,
    authenticationSession,
}

class AzureAdAuthentication {
  static const MethodChannel _channel =
      MethodChannel('azure_ad_authentication');
  late String? _clientId, _authority, _redirectUri;
  bool? _privateSession;
  WebViewType? _webViewType;

  AzureAdAuthentication._create({
    required String clientId,
    required String authority,
    String? redirectUri,
    bool privateSession = true,
    WebViewType? webViewType = WebViewType.webView,
    
  }) {
    _clientId = clientId;
    _authority = authority;
    _redirectUri = redirectUri;
    _privateSession = privateSession;
    _webViewType = webViewType;
  }

  ///initialize client application
  ///```
  /// param required String clientId
  /// param required String authority
  /// param String? redirectUri (only for MacOs)
  /// return AzureAdAuthentication
  /// ```
  static Future<AzureAdAuthentication> createPublicClientApplication(
      {required String clientId, required String authority, String? redirectUri, bool privateSession = true, WebViewType? webViewType}) async {
    var res =
        AzureAdAuthentication._create(clientId: clientId, authority: authority,redirectUri: redirectUri, privateSession: privateSession, webViewType: webViewType);
    await res._initialize();

    return res;
  }

  /// Acquire a token interactively for the given [scopes]
  /// return [UserAdModel] contains user information but token and expiration date
  Future<UserAdModel?> acquireToken({required List<String> scopes}) async {
    var res = <String, dynamic>{'scopes': scopes};
    try {
      final String? json = await _channel.invokeMethod('acquireToken', res);
      UserAdModel userAdModel = UserAdModel.fromJson(jsonDecode(json!));
      return await _getUserModel(userAdModel);
    } on PlatformException catch (e) {
      throw _convertException(e);
    }
  }

  /// Acquire a token interactively for the given [scopes]
  /// return [String]  {accessToken": xxx,"expiresOn" : xxx}
  Future<String> acquireTokenString({required List<String> scopes}) async {
    var res = <String, dynamic>{'scopes': scopes};
    try {
      final String? json = await _channel.invokeMethod('acquireToken', res);
      return json ?? "Error";
    } on PlatformException catch (e) {
      throw _convertException(e);
    }
  }

  ///return UserAdModel info
  Future<UserAdModel?> _getUserModel(UserAdModel userAdModel) async {
    if (userAdModel.accessToken != null) {
      UserAdModel? user = (await Request.post(token: userAdModel.accessToken!));
      if (user != null) {
        user.accessToken = userAdModel.accessToken;
        user.expiresOn = userAdModel.expiresOn;
        return user;
      }
    }
    return userAdModel;
  }

  /// Acquire a token silently, with no user interaction, for the given [scopes]
  /// return [UserAdModel] contains user information but token and expiration date
  Future<UserAdModel?> acquireTokenSilent(
      {required List<String> scopes}) async {
    var res = <String, dynamic>{'scopes': scopes};
    try {
      if (Platform.isAndroid) {
        await _channel.invokeMethod('loadAccounts');
      }
      final String json =
          await _channel.invokeMethod('acquireTokenSilent', res);
      UserAdModel userAdModel = UserAdModel.fromJson(jsonDecode(json));
      return await _getUserModel(userAdModel);
    } on PlatformException catch (e) {
      throw _convertException(e).errorMessage;
    }
  }

  /// clear user input data
  Future logout() async {
    try {
      if (Platform.isAndroid) {
        await _channel.invokeMethod('loadAccounts');
      }
      await _channel.invokeMethod('logout', <String, dynamic>{});
    } on PlatformException catch (e) {
      throw _convertException(e).errorMessage;
    }
  }

  MsalException _convertException(PlatformException e) {
    switch (e.code) {
      case "CANCELLED":
        return MsalUserCancelledException();
      case "NO_SCOPE":
        return MsalInvalidScopeException();
      case "NO_ACCOUNT":
        return MsalNoAccountException();
      case "NO_CLIENTID":
        return MsalInvalidConfigurationException("Client Id not set");
      case "INVALID_AUTHORITY":
        return MsalInvalidConfigurationException("Invalid authroity set.");
      case "CONFIG_ERROR":
        return MsalInvalidConfigurationException(
            "Invalid configuration, please correct your settings and try again");
      case "NO_CLIENT":
        return MsalUninitializedException();
      case "CHANGED_CLIENTID":
        return MsalChangedClientIdException();
      case "INIT_ERROR":
        return MsalInitializationException();
      case "AUTH_ERROR":
      default:
        return MsalException("Authentication error");
    }
  }

  Future _initialize() async {
    var res = <String, dynamic>{'clientId': _clientId};
    if (_authority != null) {
      res["authority"] = _authority;
    }
    if(_redirectUri != null){
      res["redirectUri"] = _redirectUri;
    }
    res['privateSession'] = _privateSession;
    res['webViewType'] = _webViewType?.name;

    try {
      await _channel.invokeMethod('initialize', res);
    } on PlatformException catch (e) {
      throw _convertException(e).errorMessage;
    }
  }
}
