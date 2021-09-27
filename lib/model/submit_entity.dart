import 'dart:convert';
import 'package:aswp/server/api.dart';
import 'package:dio/dio.dart';
import 'package:aswp/http/api_response.dart';
import 'package:aswp/http/httpUtils.dart';
List<List<dynamic>> submitEntityFromJson(String str) => List<List<dynamic>>.from(json.decode(str).map((x) => List<dynamic>.from(x.map((x) => x))));

String submitEntityToJson(List<List<dynamic>> data) => json.encode(List<dynamic>.from(data.map((x) => List<dynamic>.from(x.map((x) => x)))));

class SubmitEntity {
  static Future<String> submit(
      Map<String, dynamic> map) async {
    try {
      final response = await HttpUtils.post(API.SUBMIT_URL, data: map);
      return response;
    } on DioError catch (e) {
      return e.error;
    }
  }
}