import 'package:shared_preferences/shared_preferences.dart';
class API {
  /*static const String API_PREFIX = 'http://192.168.31.211/K3Cloud';
  static const String ACCT_ID = '614c1ba7c39b80';*/
  /*static const String API_PREFIX = 'http://120.25.26.68/K3Cloud';
  static const String ACCT_ID = '62f8ff01e0b76e';
  static const String lcid = '2052';*/
  Future<String> LOGIN_URL() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
   return sharedPreferences.getString('url') +
        '/Kingdee.BOS.WebApi.ServicesStub.AuthService.ValidateUser.common.kdsvc';
  }
  //通用查询
  Future<String> CURRENCY_URL() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('url') +
        '/Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.ExecuteBillQuery.common.kdsvc';
  }
  //提交
  Future<String> SAVE_URL() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('url') +
        '/Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.Save.common.kdsvc';
  }
  //保存
  Future<String> SUBMIT_URL() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('url') +
        '/Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.Submit.common.kdsvc';
  }
  //下推
  Future<String> DOWN_URL() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('url') +
        '/Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.Push.common.kdsvc';
  }
  //审核
  Future<String> AUDIT_URL() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('url') +
        '/Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.Audit.common.kdsvc';
  }
  //反审核
  Future<String> UNAUDIT_URL() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('url') +
        '/Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.UnAudit.common.kdsvc';
  }
  //删除
  Future<String> DELETE_URL() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('url') +
        '/Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.Delete.common.kdsvc';
  }
  //修改状态
  Future<String> STATUS_URL() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('url') +
        '/Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.ExcuteOperation.common.kdsvc';
  }
  //版本查询
  static const String VERSION_URL =
      'https://www.pgyer.com/apiv2/app/check?_api_key=dd6926b00c3c3f22a0ee4204f8aaad88&appKey=67ac3a97b22599962eb366acbb508cd5';

  //授权查询 authorize
  static const String AUTHORIZE_URL =
      'http://14.29.254.232:50022/web/auth/findAuthMessage';
}
