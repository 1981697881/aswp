import 'package:aswp/entity/login_entity.dart';

loginEntityFromJson(LoginEntity data, Map<String, dynamic> json) {
	if (json['Message'] != null) {
		data.message = json['Message'];
	}
	if (json['MessageCode'] != null) {
		data.messageCode = json['MessageCode'].toString();
	}
	if (json['LoginResultType'] != null) {
		data.loginResultType = json['LoginResultType'] is String
				? int.tryParse(json['LoginResultType'])
				: json['LoginResultType'].toInt();
	}
	if (json['Context'] != null) {
		data.context = LoginContext().fromJson(json['Context']);
	}
	if (json['KDSVCSessionId'] != null) {
		data.kDSVCSessionId = json['KDSVCSessionId'].toString();
	}
	if (json['FormId'] != null) {
		data.formId = json['FormId'];
	}
	if (json['RedirectFormParam'] != null) {
		data.redirectFormParam = json['RedirectFormParam'];
	}
	if (json['FormInputObject'] != null) {
		data.formInputObject = json['FormInputObject'];
	}
	if (json['ErrorStackTrace'] != null) {
		data.errorStackTrace = json['ErrorStackTrace'];
	}
	if (json['Lcid'] != null) {
		data.lcid = json['Lcid'] is String
				? int.tryParse(json['Lcid'])
				: json['Lcid'].toInt();
	}
	if (json['AccessToken'] != null) {
		data.accessToken = json['AccessToken'];
	}
	if (json['KdAccessResult'] != null) {
		data.kdAccessResult = json['KdAccessResult'];
	}
	if (json['IsSuccessByAPI'] != null) {
		data.isSuccessByAPI = json['IsSuccessByAPI'];
	}
	return data;
}

Map<String, dynamic> loginEntityToJson(LoginEntity entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['Message'] = entity.message;
	data['MessageCode'] = entity.messageCode;
	data['LoginResultType'] = entity.loginResultType;
	data['Context'] = entity.context?.toJson();
	data['KDSVCSessionId'] = entity.kDSVCSessionId;
	data['FormId'] = entity.formId;
	data['RedirectFormParam'] = entity.redirectFormParam;
	data['FormInputObject'] = entity.formInputObject;
	data['ErrorStackTrace'] = entity.errorStackTrace;
	data['Lcid'] = entity.lcid;
	data['AccessToken'] = entity.accessToken;
	data['KdAccessResult'] = entity.kdAccessResult;
	data['IsSuccessByAPI'] = entity.isSuccessByAPI;
	return data;
}

loginContextFromJson(LoginContext data, Map<String, dynamic> json) {
	if (json['UserLocale'] != null) {
		data.userLocale = json['UserLocale'].toString();
	}
	if (json['LogLocale'] != null) {
		data.logLocale = json['LogLocale'].toString();
	}
	if (json['DBid'] != null) {
		data.dBid = json['DBid'].toString();
	}
	if (json['DatabaseType'] != null) {
		data.databaseType = json['DatabaseType'] is String
				? int.tryParse(json['DatabaseType'])
				: json['DatabaseType'].toInt();
	}
	if (json['SessionId'] != null) {
		data.sessionId = json['SessionId'].toString();
	}
	if (json['UseLanguages'] != null) {
		data.useLanguages = (json['UseLanguages'] as List).map((v) => LoginContextUseLanguages().fromJson(v)).toList();
	}
	if (json['UserId'] != null) {
		data.userId = json['UserId'] is String
				? int.tryParse(json['UserId'])
				: json['UserId'].toInt();
	}
	if (json['UserName'] != null) {
		data.userName = json['UserName'].toString();
	}
	if (json['CustomName'] != null) {
		data.customName = json['CustomName'].toString();
	}
	if (json['DisplayVersion'] != null) {
		data.displayVersion = json['DisplayVersion'].toString();
	}
	if (json['DataCenterName'] != null) {
		data.dataCenterName = json['DataCenterName'].toString();
	}
	if (json['UserToken'] != null) {
		data.userToken = json['UserToken'].toString();
	}
	if (json['CurrentOrganizationInfo'] != null) {
		data.currentOrganizationInfo = LoginContextCurrentOrganizationInfo().fromJson(json['CurrentOrganizationInfo']);
	}
	if (json['IsCH_ZH_AutoTrans'] != null) {
		data.ischZhAutotrans = json['IsCH_ZH_AutoTrans'];
	}
	if (json['ClientType'] != null) {
		data.clientType = json['ClientType'] is String
				? int.tryParse(json['ClientType'])
				: json['ClientType'].toInt();
	}
	if (json['WeiboAuthInfo'] != null) {
		data.weiboAuthInfo = LoginContextWeiboAuthInfo().fromJson(json['WeiboAuthInfo']);
	}
	if (json['UTimeZone'] != null) {
		data.uTimeZone = LoginContextUTimeZone().fromJson(json['UTimeZone']);
	}
	if (json['STimeZone'] != null) {
		data.sTimeZone = LoginContextSTimeZone().fromJson(json['STimeZone']);
	}
	if (json['GDCID'] != null) {
		data.gDCID = json['GDCID'].toString();
	}
	if (json['Gsid'] != null) {
		data.gsid = json['Gsid'];
	}
	if (json['TRLevel'] != null) {
		data.tRLevel = json['TRLevel'] is String
				? int.tryParse(json['TRLevel'])
				: json['TRLevel'].toInt();
	}
	if (json['ProductEdition'] != null) {
		data.productEdition = json['ProductEdition'] is String
				? int.tryParse(json['ProductEdition'])
				: json['ProductEdition'].toInt();
	}
	if (json['DataCenterNumber'] != null) {
		data.dataCenterNumber = json['DataCenterNumber'].toString();
	}
	return data;
}

Map<String, dynamic> loginContextToJson(LoginContext entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['UserLocale'] = entity.userLocale;
	data['LogLocale'] = entity.logLocale;
	data['DBid'] = entity.dBid;
	data['DatabaseType'] = entity.databaseType;
	data['SessionId'] = entity.sessionId;
	data['UseLanguages'] =  entity.useLanguages?.map((v) => v.toJson())?.toList();
	data['UserId'] = entity.userId;
	data['UserName'] = entity.userName;
	data['CustomName'] = entity.customName;
	data['DisplayVersion'] = entity.displayVersion;
	data['DataCenterName'] = entity.dataCenterName;
	data['UserToken'] = entity.userToken;
	data['CurrentOrganizationInfo'] = entity.currentOrganizationInfo?.toJson();
	data['IsCH_ZH_AutoTrans'] = entity.ischZhAutotrans;
	data['ClientType'] = entity.clientType;
	data['WeiboAuthInfo'] = entity.weiboAuthInfo?.toJson();
	data['UTimeZone'] = entity.uTimeZone?.toJson();
	data['STimeZone'] = entity.sTimeZone?.toJson();
	data['GDCID'] = entity.gDCID;
	data['Gsid'] = entity.gsid;
	data['TRLevel'] = entity.tRLevel;
	data['ProductEdition'] = entity.productEdition;
	data['DataCenterNumber'] = entity.dataCenterNumber;
	return data;
}

loginContextUseLanguagesFromJson(LoginContextUseLanguages data, Map<String, dynamic> json) {
	if (json['LocaleId'] != null) {
		data.localeId = json['LocaleId'] is String
				? int.tryParse(json['LocaleId'])
				: json['LocaleId'].toInt();
	}
	if (json['LocaleName'] != null) {
		data.localeName = json['LocaleName'].toString();
	}
	if (json['Alias'] != null) {
		data.alias = json['Alias'].toString();
	}
	return data;
}

Map<String, dynamic> loginContextUseLanguagesToJson(LoginContextUseLanguages entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['LocaleId'] = entity.localeId;
	data['LocaleName'] = entity.localeName;
	data['Alias'] = entity.alias;
	return data;
}

loginContextCurrentOrganizationInfoFromJson(LoginContextCurrentOrganizationInfo data, Map<String, dynamic> json) {
	if (json['ID'] != null) {
		data.iD = json['ID'] is String
				? int.tryParse(json['ID'])
				: json['ID'].toInt();
	}
	if (json['AcctOrgType'] != null) {
		data.acctOrgType = json['AcctOrgType'].toString();
	}
	if (json['Name'] != null) {
		data.name = json['Name'].toString();
	}
	if (json['FunctionIds'] != null) {
		data.functionIds = (json['FunctionIds'] as List).map((v) => v is String
				? int.tryParse(v)
				: v.toInt()).toList().cast<int>();
	}
	return data;
}

Map<String, dynamic> loginContextCurrentOrganizationInfoToJson(LoginContextCurrentOrganizationInfo entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['ID'] = entity.iD;
	data['AcctOrgType'] = entity.acctOrgType;
	data['Name'] = entity.name;
	data['FunctionIds'] = entity.functionIds;
	return data;
}

loginContextWeiboAuthInfoFromJson(LoginContextWeiboAuthInfo data, Map<String, dynamic> json) {
	if (json['WeiboUrl'] != null) {
		data.weiboUrl = json['WeiboUrl'];
	}
	if (json['NetWorkID'] != null) {
		data.netWorkID = json['NetWorkID'];
	}
	if (json['CompanyNetworkID'] != null) {
		data.companyNetworkID = json['CompanyNetworkID'];
	}
	if (json['Account'] != null) {
		data.account = json['Account'].toString();
	}
	if (json['AppKey'] != null) {
		data.appKey = json['AppKey'].toString();
	}
	if (json['AppSecret'] != null) {
		data.appSecret = json['AppSecret'].toString();
	}
	if (json['TokenKey'] != null) {
		data.tokenKey = json['TokenKey'].toString();
	}
	if (json['TokenSecret'] != null) {
		data.tokenSecret = json['TokenSecret'].toString();
	}
	if (json['Verify'] != null) {
		data.verify = json['Verify'];
	}
	if (json['CallbackUrl'] != null) {
		data.callbackUrl = json['CallbackUrl'];
	}
	if (json['UserId'] != null) {
		data.userId = json['UserId'].toString();
	}
	if (json['Charset'] != null) {
		data.charset = LoginContextWeiboAuthInfoCharset().fromJson(json['Charset']);
	}
	return data;
}

Map<String, dynamic> loginContextWeiboAuthInfoToJson(LoginContextWeiboAuthInfo entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['WeiboUrl'] = entity.weiboUrl;
	data['NetWorkID'] = entity.netWorkID;
	data['CompanyNetworkID'] = entity.companyNetworkID;
	data['Account'] = entity.account;
	data['AppKey'] = entity.appKey;
	data['AppSecret'] = entity.appSecret;
	data['TokenKey'] = entity.tokenKey;
	data['TokenSecret'] = entity.tokenSecret;
	data['Verify'] = entity.verify;
	data['CallbackUrl'] = entity.callbackUrl;
	data['UserId'] = entity.userId;
	data['Charset'] = entity.charset?.toJson();
	return data;
}

loginContextWeiboAuthInfoCharsetFromJson(LoginContextWeiboAuthInfoCharset data, Map<String, dynamic> json) {
	if (json['BodyName'] != null) {
		data.bodyName = json['BodyName'].toString();
	}
	if (json['EncodingName'] != null) {
		data.encodingName = json['EncodingName'].toString();
	}
	if (json['HeaderName'] != null) {
		data.headerName = json['HeaderName'].toString();
	}
	if (json['WebName'] != null) {
		data.webName = json['WebName'].toString();
	}
	if (json['WindowsCodePage'] != null) {
		data.windowsCodePage = json['WindowsCodePage'] is String
				? int.tryParse(json['WindowsCodePage'])
				: json['WindowsCodePage'].toInt();
	}
	if (json['IsBrowserDisplay'] != null) {
		data.isBrowserDisplay = json['IsBrowserDisplay'];
	}
	if (json['IsBrowserSave'] != null) {
		data.isBrowserSave = json['IsBrowserSave'];
	}
	if (json['IsMailNewsDisplay'] != null) {
		data.isMailNewsDisplay = json['IsMailNewsDisplay'];
	}
	if (json['IsMailNewsSave'] != null) {
		data.isMailNewsSave = json['IsMailNewsSave'];
	}
	if (json['IsSingleByte'] != null) {
		data.isSingleByte = json['IsSingleByte'];
	}
	if (json['EncoderFallback'] != null) {
		data.encoderFallback = LoginContextWeiboAuthInfoCharsetEncoderFallback().fromJson(json['EncoderFallback']);
	}
	if (json['DecoderFallback'] != null) {
		data.decoderFallback = LoginContextWeiboAuthInfoCharsetDecoderFallback().fromJson(json['DecoderFallback']);
	}
	if (json['IsReadOnly'] != null) {
		data.isReadOnly = json['IsReadOnly'];
	}
	if (json['CodePage'] != null) {
		data.codePage = json['CodePage'] is String
				? int.tryParse(json['CodePage'])
				: json['CodePage'].toInt();
	}
	return data;
}

Map<String, dynamic> loginContextWeiboAuthInfoCharsetToJson(LoginContextWeiboAuthInfoCharset entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['BodyName'] = entity.bodyName;
	data['EncodingName'] = entity.encodingName;
	data['HeaderName'] = entity.headerName;
	data['WebName'] = entity.webName;
	data['WindowsCodePage'] = entity.windowsCodePage;
	data['IsBrowserDisplay'] = entity.isBrowserDisplay;
	data['IsBrowserSave'] = entity.isBrowserSave;
	data['IsMailNewsDisplay'] = entity.isMailNewsDisplay;
	data['IsMailNewsSave'] = entity.isMailNewsSave;
	data['IsSingleByte'] = entity.isSingleByte;
	data['EncoderFallback'] = entity.encoderFallback?.toJson();
	data['DecoderFallback'] = entity.decoderFallback?.toJson();
	data['IsReadOnly'] = entity.isReadOnly;
	data['CodePage'] = entity.codePage;
	return data;
}

loginContextWeiboAuthInfoCharsetEncoderFallbackFromJson(LoginContextWeiboAuthInfoCharsetEncoderFallback data, Map<String, dynamic> json) {
	if (json['DefaultString'] != null) {
		data.defaultString = json['DefaultString'].toString();
	}
	if (json['MaxCharCount'] != null) {
		data.maxCharCount = json['MaxCharCount'] is String
				? int.tryParse(json['MaxCharCount'])
				: json['MaxCharCount'].toInt();
	}
	return data;
}

Map<String, dynamic> loginContextWeiboAuthInfoCharsetEncoderFallbackToJson(LoginContextWeiboAuthInfoCharsetEncoderFallback entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['DefaultString'] = entity.defaultString;
	data['MaxCharCount'] = entity.maxCharCount;
	return data;
}

loginContextWeiboAuthInfoCharsetDecoderFallbackFromJson(LoginContextWeiboAuthInfoCharsetDecoderFallback data, Map<String, dynamic> json) {
	if (json['DefaultString'] != null) {
		data.defaultString = json['DefaultString'].toString();
	}
	if (json['MaxCharCount'] != null) {
		data.maxCharCount = json['MaxCharCount'] is String
				? int.tryParse(json['MaxCharCount'])
				: json['MaxCharCount'].toInt();
	}
	return data;
}

Map<String, dynamic> loginContextWeiboAuthInfoCharsetDecoderFallbackToJson(LoginContextWeiboAuthInfoCharsetDecoderFallback entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['DefaultString'] = entity.defaultString;
	data['MaxCharCount'] = entity.maxCharCount;
	return data;
}

loginContextUTimeZoneFromJson(LoginContextUTimeZone data, Map<String, dynamic> json) {
	if (json['OffsetTicks'] != null) {
		data.offsetTicks = json['OffsetTicks'] is String
				? int.tryParse(json['OffsetTicks'])
				: json['OffsetTicks'].toInt();
	}
	if (json['StandardName'] != null) {
		data.standardName = json['StandardName'].toString();
	}
	if (json['Id'] != null) {
		data.id = json['Id'] is String
				? int.tryParse(json['Id'])
				: json['Id'].toInt();
	}
	if (json['Number'] != null) {
		data.number = json['Number'].toString();
	}
	if (json['CanBeUsed'] != null) {
		data.canBeUsed = json['CanBeUsed'];
	}
	return data;
}

Map<String, dynamic> loginContextUTimeZoneToJson(LoginContextUTimeZone entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['OffsetTicks'] = entity.offsetTicks;
	data['StandardName'] = entity.standardName;
	data['Id'] = entity.id;
	data['Number'] = entity.number;
	data['CanBeUsed'] = entity.canBeUsed;
	return data;
}

loginContextSTimeZoneFromJson(LoginContextSTimeZone data, Map<String, dynamic> json) {
	if (json['OffsetTicks'] != null) {
		data.offsetTicks = json['OffsetTicks'] is String
				? int.tryParse(json['OffsetTicks'])
				: json['OffsetTicks'].toInt();
	}
	if (json['StandardName'] != null) {
		data.standardName = json['StandardName'].toString();
	}
	if (json['Id'] != null) {
		data.id = json['Id'] is String
				? int.tryParse(json['Id'])
				: json['Id'].toInt();
	}
	if (json['Number'] != null) {
		data.number = json['Number'].toString();
	}
	if (json['CanBeUsed'] != null) {
		data.canBeUsed = json['CanBeUsed'];
	}
	return data;
}

Map<String, dynamic> loginContextSTimeZoneToJson(LoginContextSTimeZone entity) {
	final Map<String, dynamic> data = new Map<String, dynamic>();
	data['OffsetTicks'] = entity.offsetTicks;
	data['StandardName'] = entity.standardName;
	data['Id'] = entity.id;
	data['Number'] = entity.number;
	data['CanBeUsed'] = entity.canBeUsed;
	return data;
}