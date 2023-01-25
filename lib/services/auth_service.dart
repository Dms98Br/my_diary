import 'dart:convert';
import 'dart:io';

import 'package:flutter_webapi_first_course/services/webcliente.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  String url = WebClient.url;
  static const String resource = "users/";
  http.Client client = WebClient().client;

  String getUrl() {
    return "$url$resource";
  }

  Future<bool> login({required String email, required String password}) async {
    http.Response response = await client.post(Uri.parse('${url}login'),
        body: {'email': email, 'password': password});
    if (response.statusCode != 200) {
      String content = json.decode(response.body);
      switch (content) {
        case "Cannot find user":
          throw UserNotFindException();
      }
      throw HttpException(response.body);
    }

    await saveUserInfos(accessToken: response.body, email: email);
    return true;
  }

  Future<bool> register({
    required String email,
    required String password,
  }) async {
    http.Response response = await client.post(
      Uri.parse('${url}register'),
      body: {'email': email, 'password': password},
    );
    if (response.statusCode != 201) {
      throw HttpException(response.body);
    }
    await saveUserInfos(accessToken: response.body, email: email);
    return true;
  }

  getUserId({required String accessToken, required String email}) async {
    http.Response response = await client.get(
      Uri.parse(getUrl()),
      headers: {
        "Authorization": "Bearer $accessToken",
      },
    );

    List<dynamic> listDynamic = json.decode(response.body);

    for (var jsonMap in listDynamic) {
      if (jsonMap != null && jsonMap['email'] == email) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("accessToken", accessToken);
        prefs.setString("email", email);
        prefs.setInt('id', jsonMap['id']);
      }
    }
    return true;
  }

  saveUserInfos({
    required String accessToken,
    required String email,
  }) async {
    Map<String, dynamic> map = json.decode(accessToken);
    String token = map["accessToken"];
    await getUserId(accessToken: token, email: email);
  }
}

class UserNotFindException implements Exception {}
