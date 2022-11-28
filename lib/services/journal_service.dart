import 'dart:convert';
import 'dart:io';

import 'package:webapi_journal_flutter/models/journal.dart';
import 'package:webapi_journal_flutter/services/web_client.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class JournalService {
  static const resource = "journals/";
  String url = WebClient.url;
  http.Client client = WebClient().client;

  String getURL() {
    return "$url$resource";
  }

  Uri getUri() {
    return Uri.parse(getURL());
  }

  // converte os dados do objeto em json
  Future<bool> register(Journal journal) async {
    String jsonJournal = json.encode(journal.toMap());

    String token = await getToken();

    http.Response response = await client.post(
      getUri(),
      body: jsonJournal,
      headers: {
        "Content-type": "application/json",
        "Authorization": "Bearer $token"
      },
    );
    // status de criacao com sucesso
    if (response.statusCode != 201) {
      verifyException(json.decode(response.body));
    }
    return true;
  }

  // editar texto
  Future<bool> edit(String id, Journal journal) async {
    // atualiza data
    journal.updatedAt = DateTime.now();
    String token = await getToken();
    String jsonJournal = json.encode(journal.toMap());

    http.Response response = await client.put(
      Uri.parse("${getURL()}$id"),
      body: jsonJournal,
      headers: {
        "Content-type": "application/json",
        "Authorization": "Bearer $token"
      },
    );
    // status de editado com sucesso

    if (response.statusCode != 200) {
      verifyException(json.decode(response.body));
    }
    return true;
  }

  Future<List<Journal>> getAll({required String id}) async {
    String token = await getToken();
    // recebe todos os elementos do banco
    http.Response response = await client.get(
      Uri.parse("${url}users/$id/$resource"),
      headers: {
        'Content-type': 'application/json',
        "Authorization": "Bearer $token"
      },
    );

    if (response.statusCode != 200) {
      verifyException(json.decode(response.body));
    }

    List<Journal> list = [];

    List<dynamic> listDynamic = json.decode(response.body);

    for (var jsonMap in listDynamic) {
      list.add(Journal.fromMap(jsonMap));
    }

    return list;
  }

  Future<bool> delete(String id) async {
    String token = await getToken();
    http.Response response = await http.delete(Uri.parse("${getURL()}$id"),
        headers: {
          'Content-type': 'application/json',
          "Authorization": "Bearer $token"
        });

    if (response.statusCode != 200) {
      verifyException(json.decode(response.body));
    }

    return true;
  }

  Future<String> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('accessToken');
    if (token != null) {
      return token;
    }
    return '';
  }

  verifyException(String error) {
    switch (error) {
      case 'jwt expired':
        throw TokenExpiredException();
    }

    throw HttpException(error);
  }
}

class TokenExpiredException implements Exception {}
