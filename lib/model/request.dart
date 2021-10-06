import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'user_ad.dart';

class Request {
  ///Get inforamtion for User Ad param: [token] return UserAdModel or null
  static Future<UserAdModel?> post({required String token}) async {
    HttpClient client = HttpClient();
    Uri uri = Uri.parse('https://graph.microsoft.com/v1.0/me/');

    HttpClientRequest request = await client.getUrl(uri);
    request.headers.set('Authorization', 'Bearer $token');
    request.headers.set('Content-Type', 'application/json');
    try {
      HttpClientResponse result = await request.close();
      if (result.statusCode == 200) {
        var s = jsonDecode(await result.transform(utf8.decoder).join());
        UserAdModel adModel = UserAdModel.fromJson(s);
        return adModel;
      } else {
        var s = jsonDecode(await result.transform(utf8.decoder).join());
        log("Msal Error: ${result.statusCode} $s");
      }
    } catch (onError) {
      log("Msal Error: ${onError.toString()}");
    }
    return null;
  }
}
