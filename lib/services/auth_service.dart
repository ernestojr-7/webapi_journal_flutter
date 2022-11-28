import 'dart:convert';
import 'dart:io';

import 'package:webapi_journal_flutter/services/web_client.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  String url = WebClient.url;
  http.Client client = WebClient().client;

  Future<String> login(
      {required String email, required String password}) async {
    http.Response response = await client.post(
      Uri.parse('${url}login'),
      body: {'email': email, 'password': password},
    );

    if (response.statusCode != 200) {
      if (json.decode(response.body).toString() == "Cannot find user") {
        throw UserNotFoundException();
      }

      throw HttpException(response.body.toString());
    }
    return saveUserInfos(response.body);
  }

  // registra novo usuario
  Future<String> register(
      {required String email, required String password}) async {
    http.Response response = await client.post(
      Uri.parse('${url}register'),
      body: {'email': email, 'password': password},
    );

    if (response.statusCode != 201) {
      throw HttpException(response.body.toString());
    }

    return saveUserInfos(response.body);
  }

  // salva infos do usuario logado
  Future<String> saveUserInfos(String body) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    Map<String, dynamic> map = json.decode(body);

    sharedPreferences.setString("accessToken", map["accessToken"]);
    sharedPreferences.setString("id", map["user"]["id"].toString());
    sharedPreferences.setString("email", map["user"]["email"]);

    return map["accessToken"];
  }
}

class UserNotFoundException implements Exception {}
