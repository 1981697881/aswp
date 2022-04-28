// To parse this JSON data, do
//
//     final authorizeEntity = authorizeEntityFromJson(jsonString);

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:aswp/http/api_response.dart';
import 'package:aswp/http/httpUtils.dart';
import 'package:aswp/server/api.dart';

AuthorizeEntity authorizeEntityFromJson(String str) => AuthorizeEntity.fromJson(json.decode(str));

String authorizeEntityToJson(AuthorizeEntity data) => json.encode(data.toJson());

class AuthorizeEntity {
  static Future<ApiResponse<AuthorizeEntity>> getAuthorize(Map<String, dynamic> map
      ) async {
    try {
      final response = await HttpUtils.post(API.AUTHORIZE_URL,data: map);
      final res = new Map<String, dynamic>.from(response);
      var data = AuthorizeEntity.fromJson(res);
      return ApiResponse.completed(data);
    } on DioError catch (e) {
      return ApiResponse.error(e.error);
    }
  }
  AuthorizeEntity({
    this.code,
    this.msg,
    this.success,
    this.data,
  });

  int code;
  dynamic msg;
  bool success;
  Data data;

  factory AuthorizeEntity.fromJson(Map<String, dynamic> json) => AuthorizeEntity(
    code: json["code"],
    msg: json["msg"],
    success: json["success"],
    data: Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "msg": msg,
    "success": success,
    "data": data.toJson(),
  };
}

class Data {
  Data({
    this.fid,
    this.fTargetKey,
    this.fSrvEDate,
    this.fCustName,
    this.fAuthList,
    this.fAuthSDate,
    this.furl,
    this.fCode,
    this.fPrjName,
    this.fPrjNo,
    this.fSrvPhone,
    this.fAuthEDate,
    this.fMessage,
    this.fPrjType,
    this.fAppSecret,
    this.fAppkey,
    this.fSrvSDate,
    this.fSupplier,
    this.fStatus,
  });

  int fid;
  String fTargetKey;
  DateTime fSrvEDate;
  String fCustName;
  String fAuthList;
  DateTime fAuthSDate;
  String furl;
  String fCode;
  String fPrjName;
  String fPrjNo;
  String fSrvPhone;
  DateTime fAuthEDate;
  String fMessage;
  String fPrjType;
  String fAppSecret;
  String fAppkey;
  DateTime fSrvSDate;
  String fSupplier;
  String fStatus;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    fid: json["FID"],
    fTargetKey: json["FTargetKey"],
    fSrvEDate: DateTime.parse(json["FSrvEDate"]),
    fCustName: json["FCustName"],
    fAuthList: json["FAuthList"],
    fAuthSDate: DateTime.parse(json["FAuthSDate"]),
    furl: json["FURL"],
    fCode: json["FCode"],
    fPrjName: json["FPrjName"],
    fPrjNo: json["FPrjNo"],
    fSrvPhone: json["FSrvPhone"],
    fAuthEDate: DateTime.parse(json["FAuthEDate"]),
    fMessage: json["FMessage"],
    fPrjType: json["FPrjType"],
    fAppSecret: json["FAppSecret"],
    fAppkey: json["FAppkey"],
    fSrvSDate: DateTime.parse(json["FSrvSDate"]),
    fSupplier: json["FSupplier"],
    fStatus: json["FStatus"],
  );

  Map<String, dynamic> toJson() => {
    "FID": fid,
    "FTargetKey": fTargetKey,
    "FSrvEDate": "${fSrvEDate.year.toString().padLeft(4, '0')}-${fSrvEDate.month.toString().padLeft(2, '0')}-${fSrvEDate.day.toString().padLeft(2, '0')}",
    "FCustName": fCustName,
    "FAuthList": fAuthList,
    "FAuthSDate": "${fAuthSDate.year.toString().padLeft(4, '0')}-${fAuthSDate.month.toString().padLeft(2, '0')}-${fAuthSDate.day.toString().padLeft(2, '0')}",
    "FURL": furl,
    "FCode": fCode,
    "FPrjName": fPrjName,
    "FPrjNo": fPrjNo,
    "FSrvPhone": fSrvPhone,
    "FAuthEDate": "${fAuthEDate.year.toString().padLeft(4, '0')}-${fAuthEDate.month.toString().padLeft(2, '0')}-${fAuthEDate.day.toString().padLeft(2, '0')}",
    "FMessage": fMessage,
    "FPrjType": fPrjType,
    "FAppSecret": fAppSecret,
    "FAppkey": fAppkey,
    "FSrvSDate": "${fSrvSDate.year.toString().padLeft(4, '0')}-${fSrvSDate.month.toString().padLeft(2, '0')}-${fSrvSDate.day.toString().padLeft(2, '0')}",
    "FSupplier": fSupplier,
    "FStatus": fStatus,
  };
}
