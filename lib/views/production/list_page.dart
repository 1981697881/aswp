import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';
import 'package:aswp/http/api_response.dart';
import 'package:aswp/model/currency_entity.dart';
import 'package:aswp/model/submit_entity.dart';
import 'package:aswp/model/version_entity.dart';
import 'package:aswp/utils/toast_util.dart';
import 'package:aswp/views/login/login_page.dart';
import 'package:aswp/views/production/picking_detail.dart';
import 'package:aswp/views/production/replenishment_detail.dart';
import 'package:aswp/views/production/return_detail.dart';
import 'package:aswp/views/report/report_page.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:open_file/open_file.dart';
import 'package:package_info/package_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:shared_preferences/shared_preferences.dart';

final String _fontFamily = Platform.isWindows ? "Roboto" : "";

class ListPage extends StatefulWidget {
  ListPage({Key key}) : super(key: key);

  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  //搜索字段
  String keyWord = '';
  String startDate = '';
  String endDate = '';
  final divider = Divider(height: 1, indent: 20);
  final rightIcon = Icon(Icons.keyboard_arrow_right);
  final scanIcon = Icon(Icons.filter_center_focus);

  static const scannerPlugin =
  const EventChannel('com.shinow.pda_scanner/plugin');
  StreamSubscription _subscription;
  var _code;

  //生产车间
  String FName = '';
  String FNumber = '';
  String username = '';

  //自动更新字段
  String serviceVersionCode = '';
  String downloadUrl = '';
  String buildVersion = '';
  String buildUpdateDescription = '';
  ProgressDialog pr;
  String apkName = 'aswp.apk';
  String appPath = '';
  ReceivePort _port = ReceivePort();

  List<dynamic> orderDate = [];
  final controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen(_updateDownLoadInfo);
    FlutterDownloader.registerCallback(_downLoadCallback);
    afterFirstLayout(context);
    this.getWorkShop();
    if (_subscription == null) {
      _subscription = scannerPlugin
          .receiveBroadcastStream()
          .listen(_onEvent, onError: _onError);
    }
  }

  _initState() {
    this.getOrderList();

    /// 开启监听
    _subscription = scannerPlugin
        .receiveBroadcastStream()
        .listen(_onEvent, onError: _onError);
  }

  @override
  void dispose() {
    print('关闭');
    this.controller.dispose();
    super.dispose();

    /// 取消监听
    if (_subscription != null) {
      _subscription.cancel();
    }
  }

  @override
  void afterFirstLayout(BuildContext context) {
    // 如果是android，则执行热更新
    if (Platform.isAndroid) {
      _getNewVersionAPP(context);
    }
  }

  /// 执行版本更新的网络请求
  _getNewVersionAPP(context) async {
    ApiResponse<VersionEntity> entity = await VersionEntity.getVersion();
    serviceVersionCode = entity.data.data.buildVersionNo;
    buildVersion = entity.data.data.buildVersion;
    buildUpdateDescription = entity.data.data.buildUpdateDescription;
    downloadUrl = entity.data.data.downloadUrl;
    _checkVersionCode();
  }

  /// 检查当前版本是否为最新，若不是，则更新
  void _checkVersionCode() {
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      var currentVersionCode = packageInfo.buildNumber;
      if (int.parse(serviceVersionCode) > int.parse(currentVersionCode)) {
        _showNewVersionAppDialog();
      }
    });
  }

  /// 版本更新提示对话框
  Future<void> _showNewVersionAppDialog() async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Row(
              children: <Widget>[
                new Padding(
                    padding: const EdgeInsets.fromLTRB(30.0, 0.0, 10.0, 0.0),
                    child: new Text("发现新版本"))
              ],
            ),
            content:
            new Text(buildUpdateDescription + "（" + buildVersion + ")"),
            actions: <Widget>[
              new FlatButton(
                child: new Text('下次再说'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: new Text('立即更新'),
                onPressed: () {
                  _doUpdate(context);
                },
              )
            ],
          );
        });
  }

  /// 执行更新操作
  _doUpdate(BuildContext context) async {
    Navigator.pop(context);
    _executeDownload(context);
  }

  /// 下载最新apk包
  Future<void> _executeDownload(BuildContext context) async {
    pr = new ProgressDialog(
      context,
      type: ProgressDialogType.Download,
      isDismissible: true,
      showLogs: true,
    );
    pr.style(message: '准备下载...');
    if (!pr.isShowing()) {
      pr.show();
    }

    final path = await _apkLocalPath;
    await FlutterDownloader.enqueue(
        url: downloadUrl,
        savedDir: path,
        fileName: apkName,
        showNotification: true,
        openFileFromNotification: true);
  }

  /// 下载进度回调函数
  static void _downLoadCallback(String id, DownloadTaskStatus status,
      int progress) {
    final SendPort send =
    IsolateNameServer.lookupPortByName('downloader_send_port');
    send.send([id, status, progress]);
  }

  /// 更新下载进度框
  _updateDownLoadInfo(dynamic data) {
    DownloadTaskStatus status = data[1];
    int progress = data[2];
    if (status == DownloadTaskStatus.running) {
      pr.update(
          progress: double.parse(progress.toString()), message: "下载中，请稍后…");
    }
    if (status == DownloadTaskStatus.failed) {
      if (pr.isShowing()) {
        pr.hide();
      }
    }

    if (status == DownloadTaskStatus.complete) {
      if (pr.isShowing()) {
        pr.hide();
      }
      _installApk();
    }
  }

  /// 安装apk
  Future<Null> _installApk() async {
    await OpenFile.open(appPath + '/' + apkName);
  }

  /// 获取apk存储位置
  Future<String> get _apkLocalPath async {
    final directory = await getExternalStorageDirectory();
    String path = directory.path + Platform.pathSeparator + 'Download';
    final savedDir = Directory(path);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      await savedDir.create();
    }
    this.setState(() {
      appPath = path;
    });
    return path;
  }

  // 集合
  List hobby = [];

  void getWorkShop() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      if (sharedPreferences.getString('FWorkShopName') != null) {
        username = sharedPreferences.getString('FStaffNumber');
        FName = sharedPreferences.getString('FWorkShopName');
        FNumber = sharedPreferences.getString('FWorkShopNumber');
      }
    });
  }

  getOrderList() async {
    setState(() {
      hobby = [];
      this._getHobby();
    });
    Map<String, dynamic> userMap = Map();
    userMap['FilterString'] = "FNoStockInQty>0";
    /*if (this._dateSelectText != "") {
      this.startDate = this._dateSelectText.substring(0, 10);
      this.endDate = this._dateSelectText.substring(26, 36);
      userMap['FilterString'] =
      "FNoStockInQty>0 and FDate>= '$startDate' and FDate <= '$endDate'";
    }*/
    if (this.keyWord != '') {
      userMap['FilterString'] =
      "FSaleOrderNo='$keyWord' and FStatus in (3,4) and FNoStockInQty>0 and FWorkShopID.FNumber='$FNumber' and FDate <= '2022-05-30'";
      userMap['FormId'] = 'PRD_MO';
      userMap['FieldKeys'] =
      'FBillNo,FPrdOrgId.FNumber,FPrdOrgId.FName,FDate,FTreeEntity_FEntryId,FMaterialId.FNumber,FMaterialId.FName,FMaterialId.FSpecification,FWorkShopID.FNumber,FWorkShopID.FName,FUnitId.FNumber,FUnitId.FName,FQty,FPlanStartDate,FPlanFinishDate,FSrcBillNo,FNoStockInQty,FID,f_wk_xh,FTreeEntity_FSeq,FStatus';
    }
    Map<String, dynamic> dataMap = Map();
    dataMap['data'] = userMap;
    String order = await CurrencyEntity.polling(dataMap);
    orderDate = [];
    orderDate = jsonDecode(order);
    print(orderDate);
    //获取当前的时间
    DateTime now = DateTime.now();
    DateTime start = DateTime(2022, 05, 30);
    final difference = start
        .difference(now)
        .inDays;
    if (orderDate.length > 0) {
      hobby = [];
      for (var value = 0; value < orderDate.length; value++) {
        /* orderDate.forEach((value) async {*/
        Map<String, dynamic> instockMap = Map();
        instockMap['FilterString'] =
        "FMoBillNo='${orderDate[value][0]}' and FDocumentStatus in ('A','B') and FMoEntrySeq='${orderDate[value][19]}'";
        instockMap['FormId'] = 'PRD_INSTOCK';
        instockMap['FieldKeys'] = 'FID,FDocumentStatus';
        Map<String, dynamic> dataMap1 = Map();
        dataMap1['data'] = instockMap;
        String order1 = await CurrencyEntity.polling(dataMap1);
        Map<String, dynamic> pickmtrlMap = Map();
        pickmtrlMap['FilterString'] =
        "FMoBillNo ='${orderDate[value][0]}' and FDocumentStatus in ('A','B') and FMoEntrySeq='${orderDate[value][19]}'";
        pickmtrlMap['FormId'] = 'PRD_PickMtrl';
        pickmtrlMap['FieldKeys'] = 'FID,FDocumentStatus';
        Map<String, dynamic> dataMap2 = Map();
        dataMap2['data'] = pickmtrlMap;
        String order2 = await CurrencyEntity.polling(dataMap2);
        print(order1);
        print(order2);
        List arr = [];
        arr.add({
          "title": "单据编号",
          "name": "FBillNo",
          "isHide": false,
          "value": {"label": orderDate[value][0], "value": orderDate[value][0]}
        });
        arr.add({
          "title": "生产组织",
          "name": "FPrdOrgId",
          "isHide": true,
          "value": {"label": orderDate[value][2], "value": orderDate[value][1]}
        });
        arr.add({
          "title": "单据日期",
          "name": "FDate",
          "isHide": false,
          "value": {"label": orderDate[value][3], "value": orderDate[value][3]}
        });
        arr.add({
          "title": "物料名称",
          "name": "FMaterial",
          "isHide": false,
          "value": {"label": orderDate[value][5], "value": orderDate[value][4]}
        });
        arr.add({
          "title": "规格型号",
          "name": "FMaterialIdFSpecification",
          "isHide": false,
          "value": {"label": orderDate[value][6], "value": orderDate[value][6]}
        });
        arr.add({
          "title": "单位名称",
          "name": "FUnitId",
          "isHide": false,
          "value": {
            "label": orderDate[value][11],
            "value": orderDate[value][10]
          }
        });
        arr.add({
          "title": "数量",
          "name": "FBaseQty",
          "isHide": false,
          "value": {
            "label": orderDate[value][12],
            "value": orderDate[value][12]
          }
        });
        arr.add({
          "title": "生产序号",
          "name": "f_wk_xh",
          "isHide": false,
          "value": {
            "label": orderDate[value][18],
            "value": orderDate[value][18]
          }
        });
        arr.add({
          "title": "计划开工日期",
          "name": "FBaseQty",
          "isHide": true,
          "value": {
            "label": orderDate[value][13],
            "value": orderDate[value][13]
          }
        });
        arr.add({
          "title": "未入库数量",
          "name": "FBaseQty",
          "isHide": true,
          "value": {
            "label": orderDate[value][16],
            "value": orderDate[value][16]
          }
        });
        arr.add({
          "title": "行号",
          "name": "FSeq",
          "isHide": true,
          "value": {
            "label": orderDate[value][19],
            "value": orderDate[value][19]
          }
        });
        arr.add({
          "title": "分录内码",
          "name": "FEntryId",
          "isHide": true,
          "value": {"label": orderDate[value][4], "value": orderDate[value][4]}
        });
        arr.add({
          "title": "FID",
          "name": "FID",
          "isHide": true,
          "value": {
            "label": orderDate[value][17],
            "value": orderDate[value][17]
          }
        });
        arr.add({
          "title": "状态",
          "name": "FStatus",
          "isHide": false,
          "value": {
            "label": orderDate[value][20] == "3" ? "下达" : "开工",
            "value": orderDate[value][20]
          }
        });
        arr.add({
          "title": "checked",
          "name": "checked",
          "isHide": true,
          "value": false
        });
        var order1Date = jsonDecode(order1);
        var order2Date = jsonDecode(order2);
        if (order1Date.length > 0) {
          arr.add({
            "title": "入库单状态",
            "name": "PRD_INSTOCK",
            "isHide": false,
            "value": {
              "label": order1Date[0][1] == "A" ? "创建" : "审核中",
              "value": order1Date[0][0]
            }
          });
        }
        if (order2Date.length > 0) {
          arr.add({
            "title": "领料单状态",
            "name": "PRD_PickMtrl",
            "isHide": false,
            "value": {
              "label": order2Date[0][1] == "A" ? "创建" : "审核中",
              "value": order2Date[0][0]
            }
          });
        }
        hobby.add(arr);
      }
      /*)*/;
      print(hobby);
      setState(() {
        EasyLoading.dismiss();
        this._getHobby();
      });
    } else {
      setState(() {
        EasyLoading.dismiss();
        this._getHobby();
      });
      ToastUtil.showInfo('单据未下达或已入库');
    }
  }

  void _onEvent(Object event) async {
    /*  setState(() {*/
    _code = event;
    EasyLoading.show(status: 'loading...');
    keyWord = _code;
    print(_code);
    /*this.controller.text = _code;*/
    await getOrderList();
    /*});*/
  }

  void _onError(Object error) {
    setState(() {
      _code = "扫描异常";
    });
  }

  bool estState = false;

  List<Widget> _getHobby() {
    List<Widget> tempList = [];
    for (int i = 0; i < this.hobby.length; i++) {
      List<Widget> comList = [];
      for (int j = 0; j < this.hobby[i].length; j++) {
        if (!this.hobby[i][j]['isHide']) {
          if (j == 15 || j == 16 ) {
            comList.add(
              Column(children: [
                Container(
                  color: Colors.white,
                  child: ListTile(
                      title: Text(this.hobby[i][j]["title"] +
                          '：' +
                          this.hobby[i][j]["value"]["label"].toString()),
                      trailing: Row(
                          mainAxisSize: MainAxisSize.min, children: <Widget>[
                        new MaterialButton(
                          color: Colors.blue,
                          textColor: Colors.white,
                          child: new Text('审核'),
                          onPressed: () {
                            Map<String, dynamic> auditMap = Map();
                            auditMap = {
                              "formid": this.hobby[i][j]["name"],
                              "data": {
                                'Ids': this.hobby[i][j]["value"]["value"]
                              }
                            };
                            auditOrder(auditMap, '审核', this.hobby[i][j]["name"],dType: 1);
                          },
                        ),
                        new MaterialButton(
                          color: Colors.red,
                          textColor: Colors.white,
                          child: new Text('删除'),
                          onPressed: () {
                            Map<String, dynamic> deleteMap = Map();
                            deleteMap = {
                              "formid": this.hobby[i][j]["name"],
                              "data": {
                                'Ids': this.hobby[i][j]["value"]["value"]
                              }
                            };
                            deleteOrder(deleteMap, '删除',type:1);
                          },
                        )
                      ])
                  ),
                ),
                divider,
              ]),
            );
          } else {
            comList.add(
              Column(children: [
                Container(
                  color: Colors.white,
                  child: ListTile(
                    onTap: () {
                      showModalBottomSheet(
                          isScrollControlled: true,
                          context: context,
                          builder: (BuildContext context) {
                            return new Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                new ListTile(
                                  title: new Center(child: new Text("一键入库")),
                                  onTap: () async {
                                    var number = 0;
                                    var str = '';
                                    for (int i = 0; i < this.hobby.length; i++) {
                                      if (this.hobby[i][14]["value"] &&
                                          this.hobby[i][13]['value']['value'] ==
                                              "4") {
                                        Map<String, dynamic> pushMap = Map();
                                        pushMap['EntryIds'] =
                                        this.hobby[i][11]['value']['value'];
                                        pushMap['RuleId'] = "PRD_MO2INSTOCK";
                                        pushMap['TargetFormId'] = "PRD_INSTOCK";
                                        var res = await this.pushDown(
                                            pushMap,
                                            "PRD_MO",
                                            "PRD_INSTOCK",
                                            this
                                                .hobby[i][3]['value']['label'],
                                            id: this
                                                .hobby[i][12]['value']['value']
                                                .toString(),
                                            entryIds: this.hobby[i][11]
                                            ['value']['value'].toString(),
                                            fWkXh: this
                                                .hobby[i][7]['value']['value']);
                                        str = str + number.toString() +
                                            ':' +
                                            res.toString();
                                        number++;
                                      }
                                    }
                                    /*this.hobby.forEach((element) {*/

                                    /*});*/
                                    if (number == 0) {
                                      Navigator.pop(context);
                                      ToastUtil.showInfo('无选中或无符合数据');
                                    } else {
                                      Navigator.pop(context);
                                      setState(() {
                                        ToastUtil.errorDialog(
                                            context, str + "入库");
                                        this.getOrderList();
                                      });
                                    }
                                  },
                                ),
                                divider,
                                new ListTile(
                                  title: new Center(child: new Text("入库")),
                                  onTap: () async {
                                    if (this.hobby.length > 0) {
                                      Navigator.pop(context);
                                      if (this.hobby[i][13]['value']['value'] ==
                                          "4") {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) {
                                              return ReportPage(
                                                FBillNo: this
                                                    .hobby[i][0]['value'],
                                                FBarcode: _code,
                                                FSeq: this.hobby[i][10]['value'],
                                                FEntryId: this.hobby[i][11]
                                                ['value'],
                                                FID: this.hobby[i][12]['value'],
                                                f_wk_xh: this
                                                    .hobby[i][7]['value'],
                                                // 路由参数
                                              );
                                            },
                                          ),
                                        ).then((data) {
                                          //延时500毫秒执行
                                          Future.delayed(
                                              const Duration(milliseconds: 500),
                                                  () {
                                                setState(() {
                                                  //延时更新状态
                                                  this._initState();
                                                });
                                              });
                                        });
                                      } else {
                                        ToastUtil.showInfo('当前选中项不符合入库状态');
                                      }
                                    } else {
                                      ToastUtil.showInfo('无数据');
                                    }
                                  },
                                ),
                                divider,
                                new ListTile(
                                  title: new Center(child: new Text("一键领料")),
                                  onTap: () async {
                                    var number = 0;
                                    var str = "";
                                    for (int i = 0; i <
                                        this.hobby.length; i++) {
                                      if (this.hobby[i][14]["value"]) {
                                        Map<String, dynamic> ppbomMap = Map();
                                        var fMOBillNO = this
                                            .hobby[i][0]['value']['value'];
                                        var fMOEntrySeq = this
                                            .hobby[i][10]['value']['value'];
                                        ppbomMap['FilterString'] =
                                        "FNoPickedQty>0 and FMOBillNO='$fMOBillNO' and FMOEntrySeq = '$fMOEntrySeq'";
                                        ppbomMap['FormId'] = 'PRD_PPBOM';
                                        ppbomMap['FieldKeys'] = 'FID';
                                        Map<String, dynamic> dataMap = Map();
                                        dataMap['data'] = ppbomMap;
                                        String order = await CurrencyEntity
                                            .polling(dataMap);
                                        var resOrder = jsonDecode(order);
                                        print(resOrder);
                                        //判断成功
                                        if (resOrder.length > 0) {
                                          number++;
                                          Map<String, dynamic> pushMap = Map();
                                          pushMap['Ids'] = resOrder[0][0];
                                          pushMap['RuleId'] =
                                          "PRD_IssueMtrl2PickMtrl";
                                          pushMap['TargetFormId'] =
                                          "PRD_PickMtrl";
                                          var res = await this.pushDown(
                                              pushMap,
                                              "PRD_PPBOM", "PRD_PickMtrl",
                                              this
                                                  .hobby[i][3]['value']['label'],
                                              id: this
                                                  .hobby[i][12]['value']['value']
                                                  .toString(),
                                              entryIds: this.hobby[i][11]
                                              ['value']['value'].toString(),
                                              fWkXh: this
                                                  .hobby[i][7]['value']['value']);
                                          str = str + ',' + number.toString() +
                                              ':' +
                                              res.toString();
                                        }
                                      }
                                    };
                                    if (number == 0) {
                                      Navigator.pop(context);
                                      ToastUtil.showInfo('无领料数据');
                                    } else {
                                      Navigator.pop(context);
                                      setState(() {
                                        ToastUtil.errorDialog(
                                            context, str + "领料");
                                        this.getOrderList();
                                      });
                                    }
                                  },
                                ),
                                divider,
                                new ListTile(
                                  title: new Center(child: new Text("领料")),
                                  onTap: () async {
                                    if (this.hobby.length > 0) {
                                      Navigator.pop(context);
                                      print(this.hobby[i][11]);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return PickingDetail(
                                              FBillNo: this
                                                  .hobby[i][0]['value'],
                                              FBarcode: _code,
                                              FSeq: this.hobby[i][10]['value'],
                                              FEntryId: this.hobby[i][11]
                                              ['value'],
                                              FID: this.hobby[i][12]['value'],
                                              f_wk_xh: this
                                                  .hobby[i][7]['value'],
                                              // 路由参数
                                            );
                                          },
                                        ),
                                      ).then((data) {
                                        //延时500毫秒执行
                                        Future.delayed(
                                            const Duration(milliseconds: 500),
                                                () {
                                              setState(() {
                                                //延时更新状态
                                                this._initState();
                                              });
                                            });
                                      });
                                    } else {
                                      ToastUtil.showInfo('无数据');
                                    }
                                  },
                                ),
                                divider,
                                new ListTile(
                                  title: new Center(child: new Text("补料")),
                                  onTap: () async {
                                    if (this.hobby.length > 0) {
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return ReplenishmentDetail(
                                              FBillNo: this
                                                  .hobby[i][0]['value'],
                                              FSeq: this.hobby[i][10]['value'],
                                              // 路由参数
                                            );
                                          },
                                        ),
                                      ).then((data) {
                                        //延时500毫秒执行
                                        Future.delayed(
                                            const Duration(milliseconds: 500),
                                                () {
                                              setState(() {
                                                //延时更新状态
                                                this._initState();
                                              });
                                            });
                                      });
                                    } else {
                                      ToastUtil.showInfo('无数据');
                                    }
                                  },
                                ),
                                divider,
                                new ListTile(
                                  title: new Center(child: new Text("退料")),
                                  onTap: () async {
                                    if (this.hobby.length > 0) {
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) {
                                            return ReturnDetail(
                                              FBillNo: this
                                                  .hobby[i][0]['value'],
                                              FSeq: this.hobby[i][10]['value'],
                                              // 路由参数
                                            );
                                          },
                                        ),
                                      ).then((data) {
                                        //延时500毫秒执行
                                        Future.delayed(
                                            const Duration(milliseconds: 500),
                                                () {
                                              setState(() {
                                                //延时更新状态
                                                this._initState();
                                              });
                                            });
                                      });
                                    } else {
                                      ToastUtil.showInfo('无数据');
                                    }
                                  },
                                ),
                              ],
                            );
                          });
                    },
                    title: Text(this.hobby[i][j]["title"] +
                        '：' +
                        this.hobby[i][j]["value"]["label"].toString()),
                    trailing: j == 0
                        ? Row(
                        mainAxisSize: MainAxisSize.min, children: <Widget>[
                      Checkbox(
                        value: this.hobby[i][14]["value"],
                        activeColor: Colors.red,
                        checkColor: Colors.yellow,
                        onChanged: (bool value) {
                          setState(() {
                            this.hobby[i][14]["value"] = value;
                          });
                        },
                      ),
                    ])
                        : null,
                  ),
                ),
                divider,
              ]),
            );
          }
        }
      }
      tempList.add(
        SizedBox(height: 10),
      );
      tempList.add(
        Column(
          children: comList,
        ),
      );
    }
    return tempList;
  }

//扫码函数,最简单的那种
  Future scan() async {
    String cameraScanResult = await scanner.scan(); //通过扫码获取二维码中的数据
    getScan(cameraScanResult); //将获取到的参数通过HTTP请求发送到服务器
    print(cameraScanResult); //在控制台打印
  }

//用于验证数据(也可以在控制台直接打印，但模拟器体验不好)
  void getScan(String scan) async {
    keyWord = scan;
    this.controller.text = scan;
    await getOrderList();
  }

  String _dateSelectText = "";

  void showDateSelect() async {
    //获取当前的时间
    DateTime now = DateTime.now();
    DateTime start = DateTime(now.year, now.month, now.day - 30);
    //在当前的时间上多添加4天
    DateTime end = DateTime(start.year, start.month, start.day + 4);
    print(DateTimeRange(start: start, end: end));
    //显示时间选择器
    DateTimeRange selectTimeRange = await showDateRangePicker(
      //语言环境
        locale: Locale("zh", "CH"),
        context: context,
        //开始时间
        firstDate: DateTime(2021, 1),
        //结束时间
        lastDate: DateTime(2022, 2),
        cancelText: "取消",
        confirmText: "确定",
        //初始的时间范围选择
        initialDateRange: DateTimeRange(start: start, end: end));
    //结果
    _dateSelectText = selectTimeRange.toString();
    //选择结果中的开始时间
    DateTime selectStart = selectTimeRange.start;
    //选择结果中的结束时间
    DateTime selectEnd = selectTimeRange.end;
    print(_dateSelectText);
    setState(() {});
  }

  void _pushSaved() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version; //版本号
    String buildNumber = packageInfo.buildNumber; //版本构建号
    Navigator.of(context).push(
      new MaterialPageRoute(
        builder: (context) {
          return new Scaffold(
            appBar: new AppBar(
              title: new Text('系统设置'),
              centerTitle: true,
            ),
            body: new ListView(padding: EdgeInsets.all(10), children: <Widget>[
              ListTile(
                leading: Icon(Icons.search),
                title: Text('版本信息（$version）'),
                onTap: () async {
                  afterFirstLayout(context);
                },
              ),
              Divider(
                height: 10.0,
                indent: 0.0,
                color: Colors.grey,
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('退出登录'),
                onTap: () async {
                  print("点击退出登录");
                  SharedPreferences prefs =
                  await SharedPreferences.getInstance();
                  prefs.clear();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return LoginPage();
                      },
                    ),
                  );
                },
              ),
              Divider(
                height: 10.0,
                indent: 0.0,
                color: Colors.grey,
              ),
            ]),
          );
        },
      ),
    );
  }

  //修改状态
  alterStatus(dataMap) async {
    var status = await SubmitEntity.alterStatus(dataMap);
    print(status);
    if (status != null) {
      var res = jsonDecode(status);
      print(res);
      if (res != null) {
        return res;
      }
    }
  }

  // 领料后操作
  handlerStatus(title, id, entryIds, fWkXh) async {
    //修改为开工状态
    Map<String, dynamic> dataMap = Map();
    var numbers = [];
    dataMap['formid'] = 'PRD_MO';
    dataMap['opNumber'] = 'toStart';
    Map<String, dynamic> entityMap = Map();
    entityMap['Id'] = id;
    entityMap['EntryIds'] = entryIds;
    numbers.add(entityMap);
    dataMap['data'] = {'PkEntryIds': numbers};
    var startRes = await this.alterStatus(dataMap);
    print(startRes);
    if (startRes['Result']['ResponseStatus']['IsSuccess']) {
      var serialNum = fWkXh.truncate();
      for (var i = serialNum; i <= 4; i++) {
        //查询生产订单
        Map<String, dynamic> userMap = Map();
        userMap['FilterString'] =
            "FSaleOrderNo='$_code' and f_wk_xh >= " + (i).toString() +
                " and f_wk_xh <" + (i + 1).toString();
        userMap['FormId'] = "PRD_MO";
        userMap['FieldKeys'] =
        'FBillNo,FTreeEntity_FEntryId,FID,f_wk_xh,FTreeEntity_FSeq';
        Map<String, dynamic> proMoDataMap = Map();
        proMoDataMap['data'] = userMap;
        String order = await CurrencyEntity.polling(proMoDataMap);
        var orderRes = jsonDecode(order);
        if (orderRes.length > 0) {
          break;
        }
      }
      //查询生产订单
      Map<String, dynamic> userMap = Map();
      userMap['FilterString'] =
          "FSaleOrderNo='$_code' and f_wk_xh >= " + (serialNum + 1).toString() +
              " and f_wk_xh <" + (serialNum + 2).toString();
      userMap['FormId'] = "PRD_MO";
      userMap['FieldKeys'] =
      'FBillNo,FTreeEntity_FEntryId,FID,f_wk_xh,FTreeEntity_FSeq';
      Map<String, dynamic> proMoDataMap = Map();
      proMoDataMap['data'] = userMap;
      String order = await CurrencyEntity.polling(proMoDataMap);
      var orderRes = jsonDecode(order);
      var resMsg = '';
      if (orderRes.length > 0) {
        for (int i = 0; i < orderRes.length; i++) {
          /* orderRes.forEach((element) async {*/
          //查询用料清单
          Map<String, dynamic> materialsMap = Map();
          var FMOEntrySeq = orderRes[i][4];
          var FMOBillNo = orderRes[i][0];
          materialsMap['FilterString'] = "FMOBillNO=" +
              FMOBillNo.toString() +
              " and FMOEntrySeq = " +
              FMOEntrySeq.toString();
          materialsMap['FormId'] = 'PRD_PPBOM';
          materialsMap['FieldKeys'] =
          'FID';
          Map<String, dynamic> materialsDataMap = Map();
          materialsDataMap['data'] = materialsMap;
          String materialsMapOrder =
          await CurrencyEntity.polling(materialsDataMap);
          //修改用料清单为审核状态
          Map<String, dynamic> auditDataMap = Map();
          auditDataMap = {
            "formid": "PRD_PPBOM",
            "data": {'Ids': jsonDecode(materialsMapOrder)[0][0]}
          };
          await SubmitEntity.submit(auditDataMap);
          var auditRes = await SubmitEntity.audit(auditDataMap);
          //修改为下达状态
          Map<String, dynamic> releaseDataMap = Map();
          var releaseNumbers = [];
          releaseDataMap['formid'] = 'PRD_MO';
          releaseDataMap['opNumber'] = 'ToRelease';
          Map<String, dynamic> releaseEntityMap = Map();
          releaseEntityMap['Id'] = orderRes[i][2];
          releaseEntityMap['EntryIds'] = orderRes[i][1];
          releaseNumbers.add(releaseEntityMap);
          releaseDataMap['data'] = {'PkEntryIds': releaseNumbers};
          var releaseRes = await this.alterStatus(releaseDataMap);
          if (releaseRes['Result']['ResponseStatus']['IsSuccess']) {
            resMsg += title.toString() + ':成功;';
          } else {
            resMsg += releaseRes['Result']['ResponseStatus']['Errors'][0]['Message']
                .toString() ;
          }
        };
        return resMsg;
      } else {
        return title.toString() + ':成功';
      }
    } else {
      return startRes['Result']['ResponseStatus']['Errors'][0]['Message']
          .toString();
    }
  }

  //删除
  deleteOrder(Map<String, dynamic> map, title,{var type}) async {
    var subData = await SubmitEntity.delete(map);
    print(subData);
    if (subData != null) {
      var res = jsonDecode(subData);
      if (res != null) {
        if (res['Result']['ResponseStatus']['IsSuccess']) {
          if(type == 1){
            ToastUtil.showInfo('删除成功');
            this.getOrderList();
          }
        } else {
          if(type == 1){
            setState(() {
              ToastUtil.errorDialog(context,
                  res['Result']['ResponseStatus']['Errors'][0]['Message']);
            });
          }
        }
      }
    }
  }

  //反审核
  unAuditOrder(Map<String, dynamic> map, title,{var type}) async {
    var subData = await SubmitEntity.unAudit(map);
    if (subData != null) {
      var res = jsonDecode(subData);
      if (res != null) {
        if (res['Result']['ResponseStatus']['IsSuccess']) {
          /*//提交清空页面
          Map<String, dynamic> deleteMap = Map();
          deleteMap = {
            "data": {
              'Ids': res['Result']['ResponseStatus']['SuccessEntitys'][0]['Id']
            }
          };*/
          deleteOrder(map, title,type:type);
        } else {
          /*setState(() {
            ToastUtil.errorDialog(context,
                res['Result']['ResponseStatus']['Errors'][0]['Message']);
          });*/
        }
      }
    }
  }

  //审核 id,entryIds,fWkXh
  auditOrder(Map<String, dynamic> auditMap, title, type,
      {String id, String entryIds, double fWkXh,var dType = 0}) async {
    await SubmitEntity.submit(auditMap);
    var subData = await SubmitEntity.audit(auditMap);
    if (subData != null) {
      var res = jsonDecode(subData);
      if (res != null) {
        if (res['Result']['ResponseStatus']['IsSuccess']) {
          //提交清空页面
          /*setState(() {
            ToastUtil.errorDialog(context,
               '提交成功');
          });*/
          if (type == "PRD_PickMtrl") {
            if(dType == 1){
              this.getOrderList();
              ToastUtil.showInfo('审核成功');
            }
            return title.toString() + ':成功';
          } else {
            if(dType == 1){
              this.getOrderList();
              ToastUtil.showInfo('审核成功');
            }
            return await handlerStatus(title, id, entryIds, fWkXh);
          }
        } else {
          await unAuditOrder(auditMap,
              res['Result']['ResponseStatus']['Errors'][0]['Message']
                  .toString(),type: dType);
          return res['Result']['ResponseStatus']['Errors'][0]['Message']
              .toString();
        }
      }
    }
  }

  pushDown(Map<String, dynamic> map, formid, pFormid, title,
      {String id, String entryIds, double fWkXh}) async {
    //下推
    Map<String, dynamic> pushMap = Map();
    var downData = await SubmitEntity.pushDown({"formid": formid, "data": map});
    var res = jsonDecode(downData);
    print(res);
    //判断成功
    if (res['Result']['ResponseStatus']['IsSuccess']) {
      Map<String, dynamic> auditMap = Map();
      auditMap = {
        "formid": pFormid,
        "data": {
          'Ids': res['Result']['ResponseStatus']['SuccessEntitys'][0]['Id']
        }
      };
      if (pFormid == "PRD_PickMtrl") {
        return await auditOrder(
            auditMap, title, pFormid, id: id, entryIds: entryIds, fWkXh: fWkXh);
      } else {
        return await auditOrder(auditMap, title, pFormid, id: id, entryIds: entryIds, fWkXh: fWkXh);
      }
    } else {
      return res['Result']['ResponseStatus']['Errors'][0]['Message'].toString();
      /*setState(() {
        ToastUtil.errorDialog(
            context, res['Result']['ResponseStatus']['Errors'][0]['Message']);
      });*/
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlutterEasyLoading(
        child: MaterialApp(
          title: "loging",
          home: Scaffold(
            /*floatingActionButton: FloatingActionButton(
            onPressed: scan,
            tooltip: 'Increment',
            child:Text("入库"),
          ),*/
            /*floatingActionButton: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              FloatingActionButton(
                onPressed: () {
                  if (this.hobby.length > 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return ReportPage(
                              FBillNo: this.hobby[0][0]['value']
                              // 路由参数
                              );
                        },
                      ),
                    );
                  } else {
                    ToastUtil.showInfo('无数据');
                  }
                },
                child: Text("入库"),
                heroTag: 'mapZoomIn',
              ),
              FloatingActionButton(
                onPressed: () {
                  if (this.hobby.length > 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return PickingDetail(FBillNo: this.hobby[0][0]['value']
                              // 路由参数
                              );
                        },
                      ),
                    );
                  } else {
                    ToastUtil.showInfo('无数据');
                  }
                },
                child: Text("补料"),
                heroTag: 'mapZoomOut',
              ),
              FloatingActionButton(
                onPressed: () {
                  if (this.hobby.length > 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return PickingDetail(FBillNo: this.hobby[0][0]['value']
                              // 路由参数
                              );
                        },
                      ),
                    );
                  } else {
                    ToastUtil.showInfo('无数据');
                  }
                },
                child: Text("退料"),
                heroTag: 'showUserLocation',
              ),
              FloatingActionButton(
                onPressed: () {
                  if (this.hobby.length > 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return PickingDetail(FBillNo: this.hobby[0][0]['value']
                              // 路由参数
                              );
                        },
                      ),
                    );
                  } else {
                    ToastUtil.showInfo('无数据');
                  }
                },
                child: Text("领料"),
                heroTag: 'mapGoToHome',
              ),
            ],
          ),*/
            //浮动按钮的位置
              floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
              appBar: AppBar(
                /* leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),*/
                title: Text("生产订单"),
                centerTitle: true,
                actions: <Widget>[
                  new IconButton(
                      icon: new Icon(Icons.settings), onPressed: _pushSaved),
                ],
              ),
              body: CustomScrollView(
                slivers: <Widget>[
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: StickyTabBarDelegate(
                      minHeight: 50, //收起的高度
                      maxHeight: 50, //展开的最大高度
                      child: Container(
                        color: Theme
                            .of(context)
                            .primaryColor,
                        child: Padding(
                          padding: EdgeInsets.only(top: 2.0),
                          child: Container(
                              height: 52.0,
                              child: new Card(
                                child: new Container(
                                  child: new Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.max,
                                    children: <Widget>[
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                            width: 50,
                                            height: 50,
                                            child: Center(
                                              child: Text(
                                                "用户：$username",
                                              ),
                                            )),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                            width: 50,
                                            height: 50,
                                            child: Center(
                                              child: Text(
                                                "车间：$FName",
                                              ),
                                            )),
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                        ),
                      ),
                    ),
                  ),
                  SliverFillRemaining(
                    child: ListView(children: <Widget>[
                      Column(
                        children: this._getHobby(),
                      ),
                    ]),
                  ),
                ],
              )),
        ));
  }
}

class StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Container child;
  final double minHeight;
  final double maxHeight;

  StickyTabBarDelegate({@required this.minHeight,
    @required this.maxHeight,
    @required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset,
      bool overlapsContent) {
    return this.child;
  }

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => max(maxHeight, minHeight);

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
