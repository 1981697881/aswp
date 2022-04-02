class API {
  /*static const String API_PREFIX = 'http://192.168.31.211/K3Cloud';
  static const String ACCT_ID = '614c1ba7c39b80';*/
  static const String API_PREFIX = 'http://120.25.26.68/K3Cloud';
  static const String ACCT_ID = '62459b76dce892';
  static const String lcid = '2052';
  static const String LOGIN_URL = API_PREFIX + '/Kingdee.BOS.WebApi.ServicesStub.AuthService.ValidateUser.common.kdsvc';
  //通用查询
  static const String CURRENCY_URL = API_PREFIX + '/Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.ExecuteBillQuery.common.kdsvc';
  //提交
  static const String SAVE_URL = API_PREFIX + '/Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.Save.common.kdsvc';
  //保存
  static const String SUBMIT_URL = API_PREFIX + '/Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.Submit.common.kdsvc';
  //下推
  static const String DOWN_URL = API_PREFIX + '/Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.Push.common.kdsvc';
  //审核
  static const String AUDIT_URL = API_PREFIX + '/Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.Audit.common.kdsvc';
  //反审核
  static const String UNAUDIT_URL = API_PREFIX + '/Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.UnAudit.common.kdsvc';
  //删除
  static const String DELETE_URL = API_PREFIX + '/Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.Delete.common.kdsvc';
  //修改状态
  static const String STATUS_URL = API_PREFIX + '/Kingdee.BOS.WebApi.ServicesStub.DynamicFormService.ExcuteOperation.common.kdsvc';
  //版本查询
  static const String VERSION_URL = 'https://www.pgyer.com/apiv2/app/check?_api_key=dd6926b00c3c3f22a0ee4204f8aaad88&appKey=67ac3a97b22599962eb366acbb508cd5';
}
