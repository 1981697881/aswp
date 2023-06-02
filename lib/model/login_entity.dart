// To parse this JSON data, do
//
//     final loginEntity = loginEntityFromJson(jsonString);

import 'dart:convert';
import 'package:aswp/server/api.dart';
import 'package:dio/dio.dart';
import 'package:aswp/http/api_response.dart';
import 'package:aswp/http/httpUtils.dart';
LoginEntity loginEntityFromJson(String str) => LoginEntity.fromJson(json.decode(str));
String loginEntityToJson(LoginEntity data) => json.encode(data.toJson());
class LoginEntity {
	static Future<ApiResponse<LoginEntity>> login(Map<String, dynamic> map) async {
		try {
			API api = new API();
			final response = await HttpUtils.post(await api.LOGIN_URL(),data: map);
			final res = json.decode(response) as Map<String, dynamic>;
			var data = LoginEntity.fromJson(res);
			return ApiResponse.completed(data);
		} on DioError catch (e) {
			return ApiResponse.error(e.error);
		}
	}
	LoginEntity({
		this.message,
		this.messageCode,
		this.loginResultType,
	});

	dynamic message;
	String messageCode;
	int loginResultType;

	factory LoginEntity.fromJson(Map<String, dynamic> json) => LoginEntity(
		message: json["Message"],
		messageCode: json["MessageCode"],
		loginResultType: json["LoginResultType"],
	);

	Map<String, dynamic> toJson() => {
		"Message": message,
		"MessageCode": messageCode,
		"LoginResultType": loginResultType,
	};
}
