import 'dart:convert';
import 'dart:io';

import 'package:flutter_webapi_first_course/models/journal.dart';
import 'package:flutter_webapi_first_course/services/webcliente.dart';
import 'package:http/http.dart' as http;

class JournalService {
  String url = WebClient.url;
  static const String resource = "journals/";

  http.Client client = WebClient().client;

  String getUrl() {
    return "$url$resource";
  }

  Future<bool> register(Journal journal, String accessToken) async {
    String jsonJournal = json.encode(journal.toMap());
    http.Response response = await client.post(
      Uri.parse(getUrl()),
      headers: {
        'Content-type': 'application/json',
        "Authorization": "Bearer $accessToken",
      },
      body: jsonJournal,
    );
    if (response.statusCode != 201) {
      if (json.decode(response.body) == "jwr expired") {
        throw TokenNotValidException();
      }
      throw HttpException(response.body);
    }
    return true;
  }

  Future<List<Journal>> getAll(
      {required String id, required String accessToken}) async {
    http.Response response = await client.get(
      Uri.parse("${url}users/$id/journals"),
      headers: {
        "Authorization": "Bearer $accessToken",
      },
    );

    if (response.statusCode != 200) {
      if (json.decode(response.body) == "jwr expired") {
        throw TokenNotValidException();
      }
      throw HttpException(response.body);
    }

    List<Journal> list = [];

    List<dynamic> listDynamic = json.decode(response.body);

    for (var jsonMap in listDynamic) {
      list.add(Journal.fromMap(jsonMap));
    }

    return list;
  }

  Future<bool> edit(String id, Journal journal, String accessToken) async {
    String jsonJournal = json.encode(journal.toMap());
    journal.updatedAt = DateTime.now();
    http.Response response = await client.put(
      Uri.parse("${getUrl()}$id"),
      headers: {
        'Content-type': 'application/json',
        "Authorization": "Bearer $accessToken",
      },
      body: jsonJournal,
    );
    if (response.statusCode != 200) {
      if (json.decode(response.body) == "jwr expired") {
        throw TokenNotValidException();
      }
      throw HttpException(response.body);
    }
    return true;
  }

  Future<bool> delete(String id, String accessToken) async {
    http.Response response = await http.delete(
      Uri.parse("${getUrl()}$id"),
      headers: {
        "Authorization": "Bearer $accessToken",
      },
    );
    if (response.statusCode != 200) {
      if (json.decode(response.body) == "jwr expired") {
        throw TokenNotValidException();
      }
      throw HttpException(response.body);
    }
    return true;
  }
}

class TokenNotValidException implements Exception {}
