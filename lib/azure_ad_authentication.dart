import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';

import 'exeption.dart';
import 'model/config.dart';
import 'model/request.dart';
import 'model/user_ad.dart';

class AzureAdAuthentication {
  static const MethodChannel _channel =
      MethodChannel('azure_ad_authentication');
      late MsalConfig _config;
  // late String? _clientId, _authority;

  AzureAdAuthentication._create(
      {required MsalConfig config}) {
    _config = config;
  }

  ///initialize client application
  ///```
  /// param required String clientId
  /// param required String authority
  /// return AzureAdAuthentication
  /// ```
  static Future<AzureAdAuthentication> createPublicClientApplication(
      {required MsalConfig config}) async {
    var res =
        AzureAdAuthentication._create(config: config);
    await res._initialize();

    return res;
  }

  /// Acquire a token interactively for the given [scopes]
  /// return [UserAdModel] contains user information but token and expiration date
  Future<UserAdModel?> acquireToken({
    required List<String> scopes,
    bool fetchUserModel = false,
  }) async {
    var res = <String, dynamic>{'scopes': scopes};
    try {
      final result = await _channel.invokeMapMethod<String, dynamic>('acquireToken', res);
      UserAdModel userAdModel = UserAdModel.fromJson(result!);
      return fetchUserModel ? await _getUserModel(userAdModel) : userAdModel;
    } on PlatformException catch (e) {
      throw _convertException(e);
    }
  }

  Future<UserAdModel?> _getUserModel(UserAdModel userAdModel) async {
    if (userAdModel.accessToken != null) {
      UserAdModel? user = (await Request.post(token: userAdModel.accessToken!));
      if (user != null) {
        return user.copyWith(
          identifier: userAdModel.identifier,
          accessToken: userAdModel.accessToken,
          expiresOn: userAdModel.expiresOn,
        );
      }
    }
    return userAdModel;
  }

  /// Acquire a token silently, with no user interaction, for the given [scopes]
  /// return [UserAdModel] contains user information but token and expiration date
  Future<UserAdModel?> acquireTokenSilent({
    required List<String> scopes,
    bool fetchUserModel = false,
  }) async {
    var res = <String, dynamic>{'scopes': scopes};
    try {
      if (Platform.isAndroid) {
        await _channel.invokeMethod('loadAccounts');
      }
      final result =
          await _channel.invokeMapMethod<String, dynamic>('acquireTokenSilent', res);
      UserAdModel userAdModel = UserAdModel.fromJson(result!);
      return fetchUserModel ? await _getUserModel(userAdModel) : userAdModel;
    } on PlatformException catch (e) {
      throw _convertException(e);
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
      throw _convertException(e);
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
    try {
      await _channel.invokeMethod('initialize', {
        'config': _config.toMap(),
      });
    } on PlatformException catch (e) {
      throw _convertException(e);
    }
  }
}
