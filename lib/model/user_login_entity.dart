import 'dart:convert';
import 'package:aswp/server/api.dart';
import 'package:dio/dio.dart';
import 'package:aswp/http/api_response.dart';
import 'package:aswp/http/httpUtils.dart';
List<List<String>> userLoginEntityFromJson(String str) => List<List<String>>.from(json.decode(str).map((x) => List<String>.from(x.map((x) => x))));

String userLoginEntityToJson(List<List<String>> data) => json.encode(List<dynamic>.from(data.map((x) => List<dynamic>.from(x.map((x) => x)))));

class UserLoginEntity {
  static Future<String> login(
      Map<String, dynamic> map) async {
    try {
      final response = await HttpUtils.post(API.USER_LOGIN_URL, data: map);
      return response;
    } on DioError catch (e) {
      return e.error;
    }
  }
}