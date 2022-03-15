import 'dart:convert';
import 'package:aswp/server/api.dart';
import 'package:dio/dio.dart';
import 'package:aswp/http/api_response.dart';
import 'package:aswp/http/httpUtils.dart';
List<List<dynamic>> submitEntityFromJson(String str) => List<List<dynamic>>.from(json.decode(str).map((x) => List<dynamic>.from(x.map((x) => x))));

String submitEntityToJson(List<List<dynamic>> data) => json.encode(List<dynamic>.from(data.map((x) => List<dynamic>.from(x.map((x) => x)))));

class SubmitEntity {
  static  Future<List<Response>> dblSubmit(
      String map1,String map2) async {
    try {
      final response = await HttpUtils.dblPost(API.SUBMIT_URL,API.SUBMIT_URL, data1: map1,data2: map2);
      return response;
    } on DioError catch (e) {
      return e.error;
    }
  }
  static Future<String> save(
      Map<String, dynamic> map) async {
    try {
      final response = await HttpUtils.post(API.SAVE_URL, data: map);
      return response;
    } on DioError catch (e) {
      print(e);
      return e.error;
    }
  }
  static Future<String> submit(
    Map<String, dynamic> map) async {
    try {
      final response = await HttpUtils.post(API.SUBMIT_URL, data: map);
      return response;
    } on DioError catch (e) {
      print(e);
      return e.error;
    }
  }
 /* static Future<String> pushDown(
      List<Object> map) async {
    try {
      final response = await HttpUtils.post(API.DOWN_URL, data: map);
      return response;
    } on DioError catch (e) {
      return e.error;
    }
  }*/
  static  Future<List<Response>> dalPushDown(
      Map<String, dynamic> map1,Map<String, dynamic> map2) async {
    try {
      final response = await HttpUtils.dblPost(API.DOWN_URL,API.DOWN_URL,data1: map1,data2: map2);
      return response;
    } on DioError catch (e) {
      return e.error;
    }
  }
  static Future<String> pushDown(
      Map<String, dynamic> map) async {
    try {
      final response = await HttpUtils.post(API.DOWN_URL, data: map);
      return response;
    } on DioError catch (e) {
      return e.error;
    }
  }
  static Future<String> alterStatus(
      Map<String, dynamic> map) async {
    try {
      final response = await HttpUtils.post(API.STATUS_URL, data: map);
      return response;
    } on DioError catch (e) {
      return e.error;
    }
  }
  static Future<String> audit(
      Map<String, dynamic> map) async {
    try {
      final response = await HttpUtils.post(API.AUDIT_URL, data: map);
      return response;
    } on DioError catch (e) {
      return e.error;
    }
  }static Future<String> unAudit(
      Map<String, dynamic> map) async {
    try {
      final response = await HttpUtils.post(API.UNAUDIT_URL, data: map);
      return response;
    } on DioError catch (e) {
      return e.error;
    }
  }static Future<String> delete(
      Map<String, dynamic> map) async {
    try {
      final response = await HttpUtils.post(API.DELETE_URL, data: map);
      return response;
    } on DioError catch (e) {
      return e.error;
    }
  }
}