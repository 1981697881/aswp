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
			final response = await HttpUtils.post(API.LOGIN_URL,data: map);
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
		this.context,
		this.kdsvcSessionId,
		this.formId,
		this.redirectFormParam,
		this.formInputObject,
		this.errorStackTrace,
		this.lcid,
		this.accessToken,
		this.kdAccessResult,
		this.isSuccessByApi,
	});

	dynamic message;
	String messageCode;
	int loginResultType;
	Context context;
	String kdsvcSessionId;
	dynamic formId;
	dynamic redirectFormParam;
	dynamic formInputObject;
	dynamic errorStackTrace;
	int lcid;
	dynamic accessToken;
	dynamic kdAccessResult;
	bool isSuccessByApi;

	factory LoginEntity.fromJson(Map<String, dynamic> json) => LoginEntity(
		message: json["Message"],
		messageCode: json["MessageCode"],
		loginResultType: json["LoginResultType"],
		context: Context.fromJson(json["Context"]),
		kdsvcSessionId: json["KDSVCSessionId"],
		formId: json["FormId"],
		redirectFormParam: json["RedirectFormParam"],
		formInputObject: json["FormInputObject"],
		errorStackTrace: json["ErrorStackTrace"],
		lcid: json["Lcid"],
		accessToken: json["AccessToken"],
		kdAccessResult: json["KdAccessResult"],
		isSuccessByApi: json["IsSuccessByAPI"],
	);

	Map<String, dynamic> toJson() => {
		"Message": message,
		"MessageCode": messageCode,
		"LoginResultType": loginResultType,
		"Context": context.toJson(),
		"KDSVCSessionId": kdsvcSessionId,
		"FormId": formId,
		"RedirectFormParam": redirectFormParam,
		"FormInputObject": formInputObject,
		"ErrorStackTrace": errorStackTrace,
		"Lcid": lcid,
		"AccessToken": accessToken,
		"KdAccessResult": kdAccessResult,
		"IsSuccessByAPI": isSuccessByApi,
	};
}

class Context {
	Context({
		this.userLocale,
		this.logLocale,
		this.dBid,
		this.databaseType,
		this.sessionId,
		this.useLanguages,
		this.userId,
		this.userName,
		this.customName,
		this.displayVersion,
		this.dataCenterName,
		this.userToken,
		this.currentOrganizationInfo,
		this.isChZhAutoTrans,
		this.clientType,
		this.weiboAuthInfo,
		this.uTimeZone,
		this.sTimeZone,
		this.gdcid,
		this.gsid,
		this.trLevel,
		this.productEdition,
		this.dataCenterNumber,
	});

	String userLocale;
	String logLocale;
	String dBid;
	int databaseType;
	String sessionId;
	List<UseLanguage> useLanguages;
	int userId;
	String userName;
	String customName;
	String displayVersion;
	String dataCenterName;
	String userToken;
	CurrentOrganizationInfo currentOrganizationInfo;
	bool isChZhAutoTrans;
	int clientType;
	WeiboAuthInfo weiboAuthInfo;
	TimeZone uTimeZone;
	TimeZone sTimeZone;
	String gdcid;
	dynamic gsid;
	int trLevel;
	int productEdition;
	String dataCenterNumber;

	factory Context.fromJson(Map<String, dynamic> json) => Context(
		userLocale: json["UserLocale"],
		logLocale: json["LogLocale"],
		dBid: json["DBid"],
		databaseType: json["DatabaseType"],
		sessionId: json["SessionId"],
		useLanguages: List<UseLanguage>.from(json["UseLanguages"].map((x) => UseLanguage.fromJson(x))),
		userId: json["UserId"],
		userName: json["UserName"],
		customName: json["CustomName"],
		displayVersion: json["DisplayVersion"],
		dataCenterName: json["DataCenterName"],
		userToken: json["UserToken"],
		currentOrganizationInfo: CurrentOrganizationInfo.fromJson(json["CurrentOrganizationInfo"]),
		isChZhAutoTrans: json["IsCH_ZH_AutoTrans"],
		clientType: json["ClientType"],
		weiboAuthInfo: WeiboAuthInfo.fromJson(json["WeiboAuthInfo"]),
		uTimeZone: TimeZone.fromJson(json["UTimeZone"]),
		sTimeZone: TimeZone.fromJson(json["STimeZone"]),
		gdcid: json["GDCID"],
		gsid: json["Gsid"],
		trLevel: json["TRLevel"],
		productEdition: json["ProductEdition"],
		dataCenterNumber: json["DataCenterNumber"],
	);

	Map<String, dynamic> toJson() => {
		"UserLocale": userLocale,
		"LogLocale": logLocale,
		"DBid": dBid,
		"DatabaseType": databaseType,
		"SessionId": sessionId,
		"UseLanguages": List<dynamic>.from(useLanguages.map((x) => x.toJson())),
		"UserId": userId,
		"UserName": userName,
		"CustomName": customName,
		"DisplayVersion": displayVersion,
		"DataCenterName": dataCenterName,
		"UserToken": userToken,
		"CurrentOrganizationInfo": currentOrganizationInfo.toJson(),
		"IsCH_ZH_AutoTrans": isChZhAutoTrans,
		"ClientType": clientType,
		"WeiboAuthInfo": weiboAuthInfo.toJson(),
		"UTimeZone": uTimeZone.toJson(),
		"STimeZone": sTimeZone.toJson(),
		"GDCID": gdcid,
		"Gsid": gsid,
		"TRLevel": trLevel,
		"ProductEdition": productEdition,
		"DataCenterNumber": dataCenterNumber,
	};
}

class CurrentOrganizationInfo {
	CurrentOrganizationInfo({
		this.id,
		this.acctOrgType,
		this.name,
		this.functionIds,
	});

	int id;
	String acctOrgType;
	String name;
	List<int> functionIds;

	factory CurrentOrganizationInfo.fromJson(Map<String, dynamic> json) => CurrentOrganizationInfo(
		id: json["ID"],
		acctOrgType: json["AcctOrgType"],
		name: json["Name"],
		functionIds: List<int>.from(json["FunctionIds"].map((x) => x)),
	);

	Map<String, dynamic> toJson() => {
		"ID": id,
		"AcctOrgType": acctOrgType,
		"Name": name,
		"FunctionIds": List<dynamic>.from(functionIds.map((x) => x)),
	};
}

class TimeZone {
	TimeZone({
		this.offsetTicks,
		this.standardName,
		this.id,
		this.number,
		this.canBeUsed,
	});

	int offsetTicks;
	String standardName;
	int id;
	String number;
	bool canBeUsed;

	factory TimeZone.fromJson(Map<String, dynamic> json) => TimeZone(
		offsetTicks: json["OffsetTicks"],
		standardName: json["StandardName"],
		id: json["Id"],
		number: json["Number"],
		canBeUsed: json["CanBeUsed"],
	);

	Map<String, dynamic> toJson() => {
		"OffsetTicks": offsetTicks,
		"StandardName": standardName,
		"Id": id,
		"Number": number,
		"CanBeUsed": canBeUsed,
	};
}

class UseLanguage {
	UseLanguage({
		this.localeId,
		this.localeName,
		this.alias,
	});

	int localeId;
	String localeName;
	String alias;

	factory UseLanguage.fromJson(Map<String, dynamic> json) => UseLanguage(
		localeId: json["LocaleId"],
		localeName: json["LocaleName"],
		alias: json["Alias"],
	);

	Map<String, dynamic> toJson() => {
		"LocaleId": localeId,
		"LocaleName": localeName,
		"Alias": alias,
	};
}

class WeiboAuthInfo {
	WeiboAuthInfo({
		this.weiboUrl,
		this.netWorkId,
		this.companyNetworkId,
		this.account,
		this.appKey,
		this.appSecret,
		this.tokenKey,
		this.tokenSecret,
		this.verify,
		this.callbackUrl,
		this.userId,
		this.charset,
	});

	dynamic weiboUrl;
	dynamic netWorkId;
	dynamic companyNetworkId;
	String account;
	String appKey;
	String appSecret;
	String tokenKey;
	String tokenSecret;
	dynamic verify;
	dynamic callbackUrl;
	String userId;
	Charset charset;

	factory WeiboAuthInfo.fromJson(Map<String, dynamic> json) => WeiboAuthInfo(
		weiboUrl: json["WeiboUrl"],
		netWorkId: json["NetWorkID"],
		companyNetworkId: json["CompanyNetworkID"],
		account: json["Account"],
		appKey: json["AppKey"],
		appSecret: json["AppSecret"],
		tokenKey: json["TokenKey"],
		tokenSecret: json["TokenSecret"],
		verify: json["Verify"],
		callbackUrl: json["CallbackUrl"],
		userId: json["UserId"],
		charset: Charset.fromJson(json["Charset"]),
	);

	Map<String, dynamic> toJson() => {
		"WeiboUrl": weiboUrl,
		"NetWorkID": netWorkId,
		"CompanyNetworkID": companyNetworkId,
		"Account": account,
		"AppKey": appKey,
		"AppSecret": appSecret,
		"TokenKey": tokenKey,
		"TokenSecret": tokenSecret,
		"Verify": verify,
		"CallbackUrl": callbackUrl,
		"UserId": userId,
		"Charset": charset.toJson(),
	};
}

class Charset {
	Charset({
		this.bodyName,
		this.encodingName,
		this.headerName,
		this.webName,
		this.windowsCodePage,
		this.isBrowserDisplay,
		this.isBrowserSave,
		this.isMailNewsDisplay,
		this.isMailNewsSave,
		this.isSingleByte,
		this.encoderFallback,
		this.decoderFallback,
		this.isReadOnly,
		this.codePage,
	});

	String bodyName;
	String encodingName;
	String headerName;
	String webName;
	int windowsCodePage;
	bool isBrowserDisplay;
	bool isBrowserSave;
	bool isMailNewsDisplay;
	bool isMailNewsSave;
	bool isSingleByte;
	CoderFallback encoderFallback;
	CoderFallback decoderFallback;
	bool isReadOnly;
	int codePage;

	factory Charset.fromJson(Map<String, dynamic> json) => Charset(
		bodyName: json["BodyName"],
		encodingName: json["EncodingName"],
		headerName: json["HeaderName"],
		webName: json["WebName"],
		windowsCodePage: json["WindowsCodePage"],
		isBrowserDisplay: json["IsBrowserDisplay"],
		isBrowserSave: json["IsBrowserSave"],
		isMailNewsDisplay: json["IsMailNewsDisplay"],
		isMailNewsSave: json["IsMailNewsSave"],
		isSingleByte: json["IsSingleByte"],
		encoderFallback: CoderFallback.fromJson(json["EncoderFallback"]),
		decoderFallback: CoderFallback.fromJson(json["DecoderFallback"]),
		isReadOnly: json["IsReadOnly"],
		codePage: json["CodePage"],
	);

	Map<String, dynamic> toJson() => {
		"BodyName": bodyName,
		"EncodingName": encodingName,
		"HeaderName": headerName,
		"WebName": webName,
		"WindowsCodePage": windowsCodePage,
		"IsBrowserDisplay": isBrowserDisplay,
		"IsBrowserSave": isBrowserSave,
		"IsMailNewsDisplay": isMailNewsDisplay,
		"IsMailNewsSave": isMailNewsSave,
		"IsSingleByte": isSingleByte,
		"EncoderFallback": encoderFallback.toJson(),
		"DecoderFallback": decoderFallback.toJson(),
		"IsReadOnly": isReadOnly,
		"CodePage": codePage,
	};
}

class CoderFallback {
	CoderFallback({
		this.defaultString,
		this.maxCharCount,
	});

	String defaultString;
	int maxCharCount;

	factory CoderFallback.fromJson(Map<String, dynamic> json) => CoderFallback(
		defaultString: json["DefaultString"],
		maxCharCount: json["MaxCharCount"],
	);

	Map<String, dynamic> toJson() => {
		"DefaultString": defaultString,
		"MaxCharCount": maxCharCount,
	};
}
