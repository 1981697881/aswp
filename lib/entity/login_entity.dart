import 'package:aswp/generated/json/base/json_convert_content.dart';
import 'package:aswp/generated/json/base/json_field.dart';

class LoginEntity with JsonConvert<LoginEntity> {
	@JSONField(name: "Message")
	dynamic message;
	@JSONField(name: "MessageCode")
	String messageCode;
	@JSONField(name: "LoginResultType")
	int loginResultType;
	@JSONField(name: "Context")
	LoginContext context;
	@JSONField(name: "KDSVCSessionId")
	String kDSVCSessionId;
	@JSONField(name: "FormId")
	dynamic formId;
	@JSONField(name: "RedirectFormParam")
	dynamic redirectFormParam;
	@JSONField(name: "FormInputObject")
	dynamic formInputObject;
	@JSONField(name: "ErrorStackTrace")
	dynamic errorStackTrace;
	@JSONField(name: "Lcid")
	int lcid;
	@JSONField(name: "AccessToken")
	dynamic accessToken;
	@JSONField(name: "KdAccessResult")
	dynamic kdAccessResult;
	@JSONField(name: "IsSuccessByAPI")
	bool isSuccessByAPI;
}

class LoginContext with JsonConvert<LoginContext> {
	@JSONField(name: "UserLocale")
	String userLocale;
	@JSONField(name: "LogLocale")
	String logLocale;
	@JSONField(name: "DBid")
	String dBid;
	@JSONField(name: "DatabaseType")
	int databaseType;
	@JSONField(name: "SessionId")
	String sessionId;
	@JSONField(name: "UseLanguages")
	List<LoginContextUseLanguages> useLanguages;
	@JSONField(name: "UserId")
	int userId;
	@JSONField(name: "UserName")
	String userName;
	@JSONField(name: "CustomName")
	String customName;
	@JSONField(name: "DisplayVersion")
	String displayVersion;
	@JSONField(name: "DataCenterName")
	String dataCenterName;
	@JSONField(name: "UserToken")
	String userToken;
	@JSONField(name: "CurrentOrganizationInfo")
	LoginContextCurrentOrganizationInfo currentOrganizationInfo;
	@JSONField(name: "IsCH_ZH_AutoTrans")
	bool ischZhAutotrans;
	@JSONField(name: "ClientType")
	int clientType;
	@JSONField(name: "WeiboAuthInfo")
	LoginContextWeiboAuthInfo weiboAuthInfo;
	@JSONField(name: "UTimeZone")
	LoginContextUTimeZone uTimeZone;
	@JSONField(name: "STimeZone")
	LoginContextSTimeZone sTimeZone;
	@JSONField(name: "GDCID")
	String gDCID;
	@JSONField(name: "Gsid")
	dynamic gsid;
	@JSONField(name: "TRLevel")
	int tRLevel;
	@JSONField(name: "ProductEdition")
	int productEdition;
	@JSONField(name: "DataCenterNumber")
	String dataCenterNumber;
}

class LoginContextUseLanguages with JsonConvert<LoginContextUseLanguages> {
	@JSONField(name: "LocaleId")
	int localeId;
	@JSONField(name: "LocaleName")
	String localeName;
	@JSONField(name: "Alias")
	String alias;
}

class LoginContextCurrentOrganizationInfo with JsonConvert<LoginContextCurrentOrganizationInfo> {
	@JSONField(name: "ID")
	int iD;
	@JSONField(name: "AcctOrgType")
	String acctOrgType;
	@JSONField(name: "Name")
	String name;
	@JSONField(name: "FunctionIds")
	List<int> functionIds;
}

class LoginContextWeiboAuthInfo with JsonConvert<LoginContextWeiboAuthInfo> {
	@JSONField(name: "WeiboUrl")
	dynamic weiboUrl;
	@JSONField(name: "NetWorkID")
	dynamic netWorkID;
	@JSONField(name: "CompanyNetworkID")
	dynamic companyNetworkID;
	@JSONField(name: "Account")
	String account;
	@JSONField(name: "AppKey")
	String appKey;
	@JSONField(name: "AppSecret")
	String appSecret;
	@JSONField(name: "TokenKey")
	String tokenKey;
	@JSONField(name: "TokenSecret")
	String tokenSecret;
	@JSONField(name: "Verify")
	dynamic verify;
	@JSONField(name: "CallbackUrl")
	dynamic callbackUrl;
	@JSONField(name: "UserId")
	String userId;
	@JSONField(name: "Charset")
	LoginContextWeiboAuthInfoCharset charset;
}

class LoginContextWeiboAuthInfoCharset with JsonConvert<LoginContextWeiboAuthInfoCharset> {
	@JSONField(name: "BodyName")
	String bodyName;
	@JSONField(name: "EncodingName")
	String encodingName;
	@JSONField(name: "HeaderName")
	String headerName;
	@JSONField(name: "WebName")
	String webName;
	@JSONField(name: "WindowsCodePage")
	int windowsCodePage;
	@JSONField(name: "IsBrowserDisplay")
	bool isBrowserDisplay;
	@JSONField(name: "IsBrowserSave")
	bool isBrowserSave;
	@JSONField(name: "IsMailNewsDisplay")
	bool isMailNewsDisplay;
	@JSONField(name: "IsMailNewsSave")
	bool isMailNewsSave;
	@JSONField(name: "IsSingleByte")
	bool isSingleByte;
	@JSONField(name: "EncoderFallback")
	LoginContextWeiboAuthInfoCharsetEncoderFallback encoderFallback;
	@JSONField(name: "DecoderFallback")
	LoginContextWeiboAuthInfoCharsetDecoderFallback decoderFallback;
	@JSONField(name: "IsReadOnly")
	bool isReadOnly;
	@JSONField(name: "CodePage")
	int codePage;
}

class LoginContextWeiboAuthInfoCharsetEncoderFallback with JsonConvert<LoginContextWeiboAuthInfoCharsetEncoderFallback> {
	@JSONField(name: "DefaultString")
	String defaultString;
	@JSONField(name: "MaxCharCount")
	int maxCharCount;
}

class LoginContextWeiboAuthInfoCharsetDecoderFallback with JsonConvert<LoginContextWeiboAuthInfoCharsetDecoderFallback> {
	@JSONField(name: "DefaultString")
	String defaultString;
	@JSONField(name: "MaxCharCount")
	int maxCharCount;
}

class LoginContextUTimeZone with JsonConvert<LoginContextUTimeZone> {
	@JSONField(name: "OffsetTicks")
	int offsetTicks;
	@JSONField(name: "StandardName")
	String standardName;
	@JSONField(name: "Id")
	int id;
	@JSONField(name: "Number")
	String number;
	@JSONField(name: "CanBeUsed")
	bool canBeUsed;
}

class LoginContextSTimeZone with JsonConvert<LoginContextSTimeZone> {
	@JSONField(name: "OffsetTicks")
	int offsetTicks;
	@JSONField(name: "StandardName")
	String standardName;
	@JSONField(name: "Id")
	int id;
	@JSONField(name: "Number")
	String number;
	@JSONField(name: "CanBeUsed")
	bool canBeUsed;
}
