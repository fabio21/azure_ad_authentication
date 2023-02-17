
import 'package:azure_ad_authentication/azure_ad_authentication.dart';
import 'package:azure_ad_authentication/exeption.dart';
import 'package:azure_ad_authentication/model/user_ad.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static const String _authority =
      "https://login.microsoftonline.com/organizations/oauth2/v2.0/authorize";

  static const String _clientId = "xxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx";

  String _output = 'NONE';
  static const List<String> kScopes = [
    "https://graph.microsoft.com/user.read",
    "https://graph.microsoft.com/Calendars.ReadWrite",
  ];

  Future<void> _acquireToken() async {
    await getResult();
  }

  Future<void> _acquireTokenSilently() async {
    await getResult(isAcquireToken: false);
  }

  /// example return "{accessToken": xxx,"expiresOn" : xxx}"
  Future<String> tokenString() async {
    AzureAdAuthentication pca = await intPca();
    return await pca.acquireTokenString(scopes: kScopes);
  }

  Future<String> getResult({bool isAcquireToken = true}) async {
    AzureAdAuthentication pca = await intPca();
    String? res;
    UserAdModel? userAdModel;
    try {
      if (isAcquireToken) {
        userAdModel = await pca.acquireToken(scopes: kScopes);
      } else {
        userAdModel = await pca.acquireTokenSilent(scopes: kScopes);
      }
    } on MsalUserCancelledException {
      res = "User cancelled";
    } on MsalNoAccountException {
      res = "no account";
    } on MsalInvalidConfigurationException {
      res = "invalid config";
    } on MsalInvalidScopeException {
      res = "Invalid scope";
    } on MsalException {
      res = "Error getting token. Unspecified reason";
    }

    setState(() {
      _output = (userAdModel?.toJson().toString() ?? res)!;
    });
    return (userAdModel?.toJson().toString() ?? res)!;
  }

  Future<AzureAdAuthentication> intPca() async {
    return await AzureAdAuthentication.createPublicClientApplication(
        clientId: _clientId, authority: _authority);
  }

  Future _logout() async {
    AzureAdAuthentication pca = await intPca();
    String res;
    try {
      await pca.logout();
      res = "Account removed";
    } on MsalException {
      res = "Error signing out";
    } on PlatformException catch (e) {
      res = "some other exception ${e.toString()}";
    }

    setState(() {
      _output = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: _acquireToken,
                    child: const Text('AcquireToken()'),
                  ),
                ),
                ElevatedButton(
                    onPressed: _acquireTokenSilently,
                    child: const Text('AcquireTokenSilently()')),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                      onPressed: _logout, child: const Text('Logout')),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _output
                        .replaceAll(",", ",\n")
                        .replaceAll("{", "{\n")
                        .replaceAll("}", "\n}"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
