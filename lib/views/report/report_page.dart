import 'dart:convert';
import 'package:aswp/model/currency_entity.dart';
import 'package:aswp/model/submit_entity.dart';
import 'package:aswp/utils/refresh_widget.dart';
import 'package:aswp/utils/text.dart';
import 'package:aswp/utils/toast_util.dart';
import 'package:aswp/views/login/login_page.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_pickers/pickers.dart';
import 'package:flutter_pickers/more_pickers/init_data.dart';
import 'package:flutter_pickers/style/default_style.dart';
import 'package:flutter_pickers/time_picker/model/date_mode.dart';
import 'package:flutter_pickers/time_picker/model/pduration.dart';
import 'package:flutter_pickers/time_picker/model/suffix.dart';
import 'dart:io';
import 'package:flutter_pickers/utils/check.dart';
import 'package:flutter/cupertino.dart';
import 'package:aswp/views/report/my_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

final String _fontFamily = Platform.isWindows ? "Roboto" : "";

class ReportPage extends StatefulWidget {
  var FBillNo;
  var FSeq;
  var FEntryId;
  var FID;
  var f_wk_xh;
  var FBarcode;

  ReportPage({Key key,  @required this.FBillNo,
    @required this.FSeq,
    @required this.FEntryId,
    @required this.FID,
    @required this.FBarcode,
    @required this.f_wk_xh}) : super(key: key);

  @override
  _ReportPageState createState() => _ReportPageState(FBillNo, FSeq, FEntryId, FID, f_wk_xh,FBarcode);
}

class _ReportPageState extends State<ReportPage> {
  var _remarkContent = new TextEditingController();
  GlobalKey<TextWidgetState> textKey = GlobalKey();
  GlobalKey<TextWidgetState> FBillNoKey = GlobalKey();
  GlobalKey<TextWidgetState> FSaleOrderNoKey = GlobalKey();
  GlobalKey<PartRefreshWidgetState> globalKey = GlobalKey();
  GlobalKey<PartRefreshWidgetState> FPrdOrgIdKey = GlobalKey();

  final _textNumber = TextEditingController();
  var checkItem;
  String FBillNo = '';
  String FSaleOrderNo = '';
  String FName = '';
  String FNumber = '';
  String FDate = '';
  var show = false;
  var isScanWork = false;
  var isSubmit = false;
  var checkData;
  var checkDataChild;
  var selectData = {
    DateMode.YMDHMS: '',
  };
  List<dynamic> orderDate = [];
  final divider = Divider(height: 1, indent: 20);
  final rightIcon = Icon(Icons.keyboard_arrow_right);
  final scanIcon = Icon(Icons.filter_center_focus);
  static const scannerPlugin =
      const EventChannel('com.shinow.pda_scanner/plugin');
  StreamSubscription _subscription;
  var _code;
  var _FNumber;
  var FSeq;
  var fBillNo;
  var fEntryId;
  var fid;
  var f_wk_xh;
  var FBarcode;
  _ReportPageState(fBillNo, FSeq, fEntryId, fid, f_wk_xh,FBarcode) {
    this.FBillNo = fBillNo['value'];
    this.FSeq = FSeq['value'];
    this.fEntryId = fEntryId['value'];
    this.fid = fid['value'];
    this.f_wk_xh = f_wk_xh['value'];
    this.FBarcode = FBarcode;
    this.getWorkShop();
  }

  @override
  void initState() {
    super.initState();

    /// ????????????
    if (_subscription == null) {
      _subscription = scannerPlugin
          .receiveBroadcastStream()
          .listen(_onEvent, onError: _onError);
    }
  }

  void getWorkShop() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      if (sharedPreferences.getString('FWorkShopName') != null) {
        FName = sharedPreferences.getString('FWorkShopName');
        FNumber = sharedPreferences.getString('FWorkShopNumber');
        isScanWork = true;
        this.getOrderList();
      } else {
        isScanWork = false;
      }
    });
  }

  @override
  void dispose() {
    this._textNumber.dispose();
    super.dispose();

    /// ????????????
    if (_subscription != null) {
      _subscription.cancel();
    }
  }

  // ?????????????????????
  List hobby = [];

  getOrderList() async {
    if (FNumber != '' && FBillNo != '') {
      Map<String, dynamic> userMap = Map();
      if (FDate != '') {
        userMap['FilterString'] =
            "FBillNo='$FBillNo' and FNoStockInQty>0 and FStatus in (4) and FWorkShopID.FNumber='$FNumber' and FDate='$FDate'";
      } else {
        userMap['FilterString'] =
            "FBillNo='$FBillNo' and FNoStockInQty>0 and FStatus in (4) and FWorkShopID.FNumber='$FNumber'";
      }
      userMap['FormId'] = 'PRD_MO';
      userMap['FieldKeys'] =
          'FBillNo,FPrdOrgId.FNumber,FPrdOrgId.FName,FDate,FSaleOrderNo,FTreeEntity_FEntryId,FMaterialId.FNumber,FMaterialId.FName,FMaterialId.FSpecification,FWorkShopID.FNumber,FWorkShopID.FName,FUnitId.FNumber,FUnitId.FName,FQty,FPlanStartDate,FPlanFinishDate,FSrcBillNo,FNoStockInQty,FID,FStatus,FStockId.FNumber,FStockId.FName,FRequestOrgId.FNumber';
      Map<String, dynamic> dataMap = Map();
      dataMap['data'] = userMap;
      String order = await CurrencyEntity.polling(dataMap);
      orderDate = [];
      orderDate = jsonDecode(order);
      if (orderDate.length > 0) {
        FDate = orderDate[0][3].substring(0, 10);
        selectData[DateMode.YMDHMS] = orderDate[0][3].substring(0, 10);
        FSaleOrderNo = orderDate[0][4];
        globalKey.currentState.update();
        /*FBillNoKey.currentState.onPressed(orderDate[0][0]);
    FSaleOrderNoKey.currentState.onPressed(orderDate[0][4]);*/
        hobby = [];
        orderDate.forEach((value) {
          List arr = [];
          arr.add({
            "title": "????????????",
            "name": "FMaterialId",
            "value": {"label": value[6], "value": value[6]}
          });
          arr.add({
            "title": "????????????",
            "name": "FWorkShopID",
            "value": {"label": value[10], "value": value[9]}
          });
          arr.add({
            "title": "????????????",
            "name": "",
            "value": {"label": "", "value": ""}
          });
          arr.add({
            "title": "???????????????",
            "name": "FQty",
            "value": {"label": value[13], "value": value[13]}
          });
          arr.add({
            "title": "????????????",
            "name": "goodProductNumber",
            "value": {"label": value[13], "value": value[13]}
          });
          arr.add({
            "title": "????????????",
            "name": "goodProductStock",
            "value": {"label": value[21], "value": value[20]}
          });
          arr.add({
            "title": "???????????????",
            "name": "rejectsNumber",
            "value": {"label": "0", "value": "0"}
          });
          arr.add({
            "title": "???????????????",
            "name": "rejectsStock",
            "value": {"label": "?????????", "value": "CK017"}
          });
          hobby.add(arr);
        });
        checkItem = '';
        setState(() {
          EasyLoading.dismiss();
          this._getHobby();
        });
      } else {
        setState(() {
          EasyLoading.dismiss();
          this._getHobby();
        });
        ToastUtil.showInfo('?????????');
      }
    } else {
      EasyLoading.dismiss();
      _code = '';
      textKey.currentState.onPressed(_code);
      if (FNumber == '') {
        checkItem = 'FPrdOrgId';
        ToastUtil.showInfo('?????????????????????');
      } else if (FBillNo == '') {
        checkItem = 'FBillNo';
        ToastUtil.showInfo('?????????????????????');
      }
      scanDialog();
    }
  }

  void _onEvent(Object event) async {
    /*  setState(() {*/
    _code = event;
    if (textKey.currentState != null) {
      textKey.currentState.onPressed(_code);
      switch (checkItem) {
        case 'FBillNo':
          EasyLoading.show(status: 'loading...');
          Navigator.pop(context);
          FBillNo = _code;
          await getOrderList();
          break;
        case 'FPrdOrgId':
          EasyLoading.show(status: 'loading...');
          Navigator.pop(context);
          FName = _code.split(',')[1];
          FNumber = _code.split(',')[0];
          await getOrderList();
          break;
        case 'FNumber':
          Navigator.pop(context);
          setState(() {
            this.hobby[checkData][checkDataChild]["value"]["label"] = _FNumber;
            this.hobby[checkData][checkDataChild]['value']["value"] = _FNumber;
          });
          break;
        case 'FStock':
          Navigator.pop(context);
          setState(() {
            this.hobby[checkData][checkDataChild]["value"]['label'] =
                _code.split(',')[1];
            this.hobby[checkData][checkDataChild]['value']["value"] =
                _code.split(',')[0];
          });
          break;
      }
    } else {
      ToastUtil.showInfo('??????????????????????????????');
    }
    print("ChannelPage: $event");
    /*});*/
  }

  void _onError(Object error) {
    setState(() {
      _code = "????????????";
    });
  }

  Widget _item(title, var data, var selectData, {String label}) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: ListTile(
            title: Text(title),
            onTap: () => _onClickItem(data, selectData, label: label),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
              MyText(selectData.toString() ?? '??????',
                  color: Colors.grey, rightpadding: 18),
              rightIcon
            ]),
          ),
        ),
        divider,
      ],
    );
  }

  Widget _dateItem(title, model) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: ListTile(
            title: Text(title),
            onTap: () {
              _onDateClickItem(model);
            },
            trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
              PartRefreshWidget(globalKey, () {
                //2????????? ????????????widget
                return MyText(
                    PicketUtil.strEmpty(selectData[model])
                        ? '??????'
                        : selectData[model],
                    color: Colors.grey,
                    rightpadding: 18);
              }),
              rightIcon
            ]),
          ),
        ),
        divider,
      ],
    );
  }

  void _onDateClickItem(model) {
    Pickers.showDatePicker(
      context,
      mode: model,
      suffix: Suffix.normal(),
      // selectDate: PDuration(month: 2),
      minDate: PDuration(year: 2020, month: 2, day: 10),
      maxDate: PDuration(second: 22),
      selectDate: (FDate == '' || FDate == null
          ? PDuration(year: 2021, month: 2, day: 10)
          : PDuration.parse(DateTime.parse(FDate))),
      // minDate: PDuration(hour: 12, minute: 38, second: 3),
      // maxDate: PDuration(hour: 12, minute: 40, second: 36),
      onConfirm: (p) {
        print('longer >>> ???????????????$p');
        setState(() async {
          switch (model) {
            case DateMode.YMDHMS:
              Map<String, dynamic> userMap = Map();
              selectData[model] = '${p.year}-${p.month}-${p.day}';
              FDate = '${p.year}-${p.month}-${p.day}';
              await getOrderList();
              break;
          }
        });
      },
      // onChanged: (p) => print(p),
    );
  }

  void _onClickItem(var data, var selectData, {String label}) {
    Pickers.showSinglePicker(
      context,
      data: data,
      selectData: selectData,
      pickerStyle: DefaultPickerStyle(),
      suffix: label,
      onConfirm: (p) {
        print('longer >>> ???????????????$p');
        print('longer >>> ?????????????????????${p.runtimeType}');
        setState(() {
          if (data == PickerDataType.sex) {
            /* FDate = p;*/
          }
        });
      },
    );
  }

  void _pushSaved() {
    Navigator.of(context).push(
      new MaterialPageRoute(
        builder: (context) {
          return new Scaffold(
            appBar: new AppBar(
              title: new Text('????????????'),
              centerTitle: true,
            ),
            body: new ListView(padding: EdgeInsets.all(10), children: <Widget>[
              /* ListTile(
                leading: Icon(Icons.search),
                title: Text('????????????'),
              ),
              Divider(
                height: 10.0,
                indent: 0.0,
                color: Colors.grey,
              ),*/
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('????????????'),
                onTap: () async {
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

  List<Widget> _getHobby() {
    List<Widget> tempList = [];
    for (int i = 0; i < this.hobby.length; i++) {
      List<Widget> comList = [];
      for (int j = 0; j < this.hobby[i].length; j++) {
        if (j == 4 || j == 6) {
          /*comList.add(
            _item(this.hobby[j]["title"], ['PHP', 'JAVA', 'C++', 'Dart', 'Python', 'Go'],
                this.hobby[j]["value"]),
          );*/
          comList.add(
            Column(children: [
              Container(
                color: Colors.white,
                child: ListTile(
                    title: Text(this.hobby[i][j]["title"] +
                        '???' +
                        this.hobby[i][j]["value"]["label"].toString()),
                    trailing:
                        Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                      IconButton(
                        icon: new Icon(Icons.filter_center_focus),
                        tooltip: '????????????',
                        onPressed: () {
                          this._textNumber.text =
                              this.hobby[i][j]["value"]["label"].toString();
                          this._FNumber =
                              this.hobby[i][j]["value"]["label"].toString();
                          checkItem = 'FNumber';
                          this.show = false;
                          checkData = i;
                          checkDataChild = j;
                          scanDialog();
                          print(this.hobby[i][j]["value"]["label"]);
                          if (this.hobby[i][j]["value"]["label"] != 0) {
                            this._textNumber.value = _textNumber.value.copyWith(
                              text:
                                  this.hobby[i][j]["value"]["label"].toString(),
                            );
                          }
                        },
                      ),
                    ])),
              ),
              divider,
            ]),
          );
        } else if (j == 5 || j == 7) {
          comList.add(
            Column(children: [
              Container(
                color: Colors.white,
                child: ListTile(
                    title: Text(this.hobby[i][j]["title"] +
                        '???' +
                        this.hobby[i][j]["value"]["label"].toString()),
                    trailing:
                        Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                      IconButton(
                        icon: new Icon(Icons.filter_center_focus),
                        tooltip: '????????????',
                        onPressed: () {
                          checkItem = 'FStock';
                          this.show = true;
                          checkData = i;
                          checkDataChild = j;
                          scanDialog();
                        },
                      ),
                    ])),
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
                  title: Text(this.hobby[i][j]["title"] +
                      '???' +
                      this.hobby[i][j]["value"]["label"].toString()),
                  trailing:
                      Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    /* MyText(orderDate[i][j],
                        color: Colors.grey, rightpadding: 18),*/
                  ]),
                ),
              ),
              divider,
            ]),
          );
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

  //???????????? ??????
  void scanDialog() {
    showDialog<Widget>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text('??????',
                        style: TextStyle(
                            fontSize: 16, decoration: TextDecoration.none)),
                  ),
                  if (!show)
                    Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Card(
                            child: Column(children: <Widget>[
                          TextField(
                            style: TextStyle(color: Colors.black87),
                            keyboardType: TextInputType.number,
                            controller: this._textNumber,
                            decoration: InputDecoration(hintText: "????????????????????????"),
                            onChanged: (value) {
                              setState(() {
                                this._FNumber = value;
                              });
                            },
                          ),
                        ]))),
                  if (show)
                    Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: TextWidget(textKey, ''),
                    ),
                  Padding(
                    padding: EdgeInsets.only(top: 15, bottom: 8),
                    child: FlatButton(
                        color: Colors.grey[100],
                        onPressed: () {
                          // ?????? Dialog
                          Navigator.pop(context);
                          if (checkItem == 'FNumber') {
                            setState(() {
                              this.hobby[checkData][checkDataChild]["value"]
                                  ["label"] = _FNumber;
                              this.hobby[checkData][checkDataChild]['value']
                                  ["value"] = _FNumber;
                            });
                          }
                        },
                        child: Text(
                          '??????',
                        )),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    ).then((val) {
      print(val);
    });
  }

  //??????
  deleteOrder(Map<String, dynamic> map,msg) async {
    var subData = await SubmitEntity.delete(map);
    print(subData);
    if (subData != null) {
      var res = jsonDecode(subData);
      if (res != null) {
        if (res['Result']['ResponseStatus']['IsSuccess']) {
          /* this.hobby = [];
          this.orderDate = [];
          this.FBillNo = '';
          ToastUtil.showInfo('????????????');
          Navigator.of(context).pop("refresh");*/
          setState(() {
            this.isSubmit = false;
            ToastUtil.errorDialog(context,
                msg);
          });
        } else {
          setState(() {
            this.isSubmit = false;
            ToastUtil.errorDialog(context,
                res['Result']['ResponseStatus']['Errors'][0]['Message']);
          });
        }
      }
    }
  }

  //?????????
  unAuditOrder(Map<String, dynamic> map,msg) async {
    var subData = await SubmitEntity.unAudit(map);
    print(subData);
    if (subData != null) {
      var res = jsonDecode(subData);
      if (res != null) {
        if (res['Result']['ResponseStatus']['IsSuccess']) {
          //??????????????????
          Map<String, dynamic> deleteMap = Map();
          deleteMap = {
            "formid": "PRD_INSTOCK",
            "data": {
              'Ids': res['Result']['ResponseStatus']['SuccessEntitys'][0]['Id']
            }
          };
          deleteOrder(deleteMap,msg);
        } else {
          setState(() {
            this.isSubmit = false;
            ToastUtil.errorDialog(context,
                res['Result']['ResponseStatus']['Errors'][0]['Message']);
          });
        }
      }
    }
  }
  //????????????
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
  // ???????????????
  handlerStatus() async {
    //?????????????????????
    Map<String, dynamic> dataMap = Map();
    var numbers = [];
    dataMap['formid'] = 'PRD_MO';
    dataMap['opNumber'] = 'toStart';
    Map<String, dynamic> entityMap = Map();
    entityMap['Id'] = fid;
    entityMap['EntryIds'] = fEntryId;
    numbers.add(entityMap);
    dataMap['data'] = {'PkEntryIds': numbers};
    var startRes = await this.alterStatus(dataMap);
    print(startRes);
    if (startRes['Result']['ResponseStatus']['IsSuccess']) {
      var serialNum = f_wk_xh.truncate();
      for(var i = serialNum;i<=4;i++){
        //??????????????????
        Map<String, dynamic> userMap = Map();
        userMap['FilterString'] = "FSaleOrderNo='$FBarcode' and FStatus in (2) and f_wk_xh >= " + (i).toString() + " and f_wk_xh <" + (i + 1).toString();
        userMap['FormId'] = "PRD_MO";
        userMap['FieldKeys'] =
        'FBillNo,FTreeEntity_FEntryId,FID,f_wk_xh,FTreeEntity_FSeq';
        Map<String, dynamic> proMoDataMap = Map();
        proMoDataMap['data'] = userMap;
        String order = await CurrencyEntity.polling(proMoDataMap);
        var orderRes = jsonDecode(order);
        serialNum = i;
        //????????????
        if(orderRes.length > 0){
          break;
        }
      }
      //??????????????????
      Map<String, dynamic> userMap = Map();
      userMap['FilterString'] = "FSaleOrderNo='$FBarcode' and f_wk_xh >= " + (serialNum).toString() + " and f_wk_xh <" + (serialNum + 1).toString();
      userMap['FormId'] = "PRD_MO";
      userMap['FieldKeys'] =
      'FBillNo,FTreeEntity_FEntryId,FID,f_wk_xh,FTreeEntity_FSeq';
      Map<String, dynamic> proMoDataMap = Map();
      proMoDataMap['data'] = userMap;
      String order = await CurrencyEntity.polling(proMoDataMap);
      var orderRes = jsonDecode(order);
      if(orderRes.length > 0){
        orderRes.forEach((element) async {
          //??????????????????
          Map<String, dynamic> materialsMap = Map();
          var FMOEntrySeq = element[4];
          var FMOBillNo = element[0];
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
          //?????????????????????????????????
          Map<String, dynamic> auditDataMap = Map();
          auditDataMap = {
            "formid": "PRD_PPBOM",
            "data": {'Ids': materialsMapOrder[0][0]}
          };
          await SubmitEntity.submit(auditDataMap);
          var auditRes = await SubmitEntity.audit(auditDataMap);
          //?????????????????????
          Map<String, dynamic> releaseDataMap = Map();
          var releaseNumbers = [];
          releaseDataMap['formid'] = 'PRD_MO';
          releaseDataMap['opNumber'] = 'ToRelease';
          Map<String, dynamic> releaseEntityMap = Map();
          releaseEntityMap['Id'] = element[2];
          releaseEntityMap['EntryIds'] = element[1];
          releaseNumbers.add(releaseEntityMap);
          releaseDataMap['data'] = {'PkEntryIds': releaseNumbers};
          var releaseRes = await this.alterStatus(releaseDataMap);
          if (releaseRes['Result']['ResponseStatus']['IsSuccess']) {
            this.hobby = [];
            this.orderDate = [];
            this.FBillNo = '';
            ToastUtil.showInfo('????????????');
            Navigator.of(context).pop("refresh");
          } else {
            setState(() {
              ToastUtil.showInfo(releaseRes['Result']['ResponseStatus']
              ['Errors'][0]['Message']);
            });
          }
        });
      }else{
        this.hobby = [];
        this.orderDate = [];
        this.FBillNo = '';
        ToastUtil.showInfo('????????????');
        Navigator.of(context).pop("refresh");
      }
    } else {
      setState(() {
        this.isSubmit = false;
        ToastUtil.errorDialog(context,
            startRes['Result']['ResponseStatus']['Errors'][0]['Message']);
      });

    }
  }
  //??????
  auditOrder(Map<String, dynamic> auditMap,index, bool type) async {
    await SubmitEntity.submit(auditMap);
    var subData = await SubmitEntity.audit(auditMap);
      var res = jsonDecode(subData);
      if (res != null) {
        if (res['Result']['ResponseStatus']['IsSuccess']) {
          if(type){
            if(index == 1){
             this.handlerStatus();
              /*setState(() {
                this.hobby = [];
                this.orderDate = [];
                this.FBillNo = '';
                this.FSaleOrderNo = '';
              });
              ToastUtil.showInfo('????????????');
              Navigator.of(context).pop("refresh");*/
            }
          }else{
            this.handlerStatus();
              /*setState(() {
                this.hobby = [];
                this.orderDate = [];
                this.FBillNo = '';
                this.FSaleOrderNo = '';
              });
              ToastUtil.showInfo('????????????');
              Navigator.of(context).pop("refresh");*/
          }
          //??????????????????
        } else {
          unAuditOrder(auditMap,res['Result']['ResponseStatus']['Errors'][0]['Message']);
          /*setState(() {
            ToastUtil.errorDialog(context,
                res['Result']['ResponseStatus']['Errors'][0]['Message']);
          });*/
        }
      }
  }

  pushDown(val, type) async {
    //??????
    Map<String, dynamic> pushMap = Map();
    pushMap['EntryIds'] = val;
    pushMap['RuleId'] = "MSD_MO2INSTOCK_PDA";
    pushMap['TargetFormId'] = "PRD_INSTOCK";
    pushMap['IsEnableDefaultRule'] = "false";
    pushMap['IsDraftWhenSaveFail'] = "false";
    print(pushMap);
    var downData =
        await SubmitEntity.pushDown({"formid": "PRD_MO", "data": pushMap});
    print(downData);
    var res = jsonDecode(downData);
    //????????????
    if (res['Result']['ResponseStatus']['IsSuccess']) {
      //???????????????
      var entitysNumber =
          res['Result']['ResponseStatus']['SuccessEntitys'][0]['Number'];
      Map<String, dynamic> inOrderMap = Map();
      inOrderMap['FormId'] = 'PRD_INSTOCK';
      inOrderMap['FilterString'] = "FBillNo='$entitysNumber'";
      inOrderMap['FieldKeys'] =
          'FEntity_FEntryId,FMaterialId.FNumber,FMaterialId.FName,FUnitId.FNumber,FMoBillNo';
      String order = await CurrencyEntity.polling({'data': inOrderMap});
      print(order);
      var resData = jsonDecode(order);
      //????????????
      Map<String, dynamic> dataMap = Map();
      dataMap['data'] = inOrderMap;
      Map<String, dynamic> orderMap = Map();
      orderMap['NeedUpDataFields'] = [
        'FStockStatusId',
        'FRealQty',
        'FInStockType'
      ];
      orderMap['IsDeleteEntry'] = false;
      orderMap['FDescription'] = this._remarkContent.text;
      Map<String, dynamic> Model = Map();
      Model['FID'] = res['Result']['ResponseStatus']['SuccessEntitys'][0]['Id'];
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      Model['F_MSD_Text1'] = sharedPreferences.getString('FName');
      // ignore: non_constant_identifier_names
      var FEntity = [];
      for (int entity = 0; entity < resData.length; entity++) {
        /*resData.forEach((entity) {*/
        for (int element = 0; element < this.hobby.length; element++) {
          /*this.hobby.forEach((element) {*/
          if (resData[entity][1].toString() ==
              this.hobby[element][0]['value']['value'].toString()) {
            // ignore: non_constant_identifier_names
            //???????????????????????????
            if (type == "defective") {
              Map<String, dynamic> FEntityItem = Map();
              FEntityItem['FEntryID'] = resData[entity][0];
              FEntityItem['FStockStatusId'] = {"FNumber": "KCZT01_SYS"};
              FEntityItem['FInStockType'] = '1';
              FEntityItem['FRealQty'] =
                  this.hobby[element][4]['value']['value'];
              FEntityItem['FStockId'] = {
                "FNumber": this.hobby[element][5]['value']['value']
              };
              FEntity.add(FEntityItem);
            } else {
              Map<String, dynamic> FEntityItem = Map();
              FEntityItem['FInStockType'] = '2';
              FEntityItem['FStockStatusId'] = {"FNumber": "KCZT01_SYS"};
              FEntityItem['FEntryID'] = resData[entity][0];
              FEntityItem['FRealQty'] =
                  this.hobby[element][6]['value']['value'];
              FEntityItem['FStockId'] = {
                "FNumber": this.hobby[element][7]['value']['value']
              };
              FEntity.add(FEntityItem);
            }
          }
        } /*);*/
      }
      /*);*/
      Model['FEntity'] = FEntity;
     /* Model['FStockOrgId'] = {"FNumber": orderDate[0][22]};
      Model['FPrdOrgId'] = {"FNumber": orderDate[0][22]};*/
      orderMap['Model'] = Model;
      dataMap = {"formid": "PRD_INSTOCK", "data": orderMap, "isBool": true};
      print(jsonEncode(dataMap));
      //??????????????????
      return dataMap;
    } else {
      Map<String, dynamic> errorMap = Map();
      errorMap = {
        "msg": res['Result']['ResponseStatus']['Errors'][0]['Message'],
        "isBool": false
      };
      return errorMap;
    }
  }

  //??????
  submitOder() async {
    if (this.hobby.length > 0) {
      setState(() {
        this.isSubmit = true;
      });
      var EntryIds1 = '';
      var EntryIds2 = '';
      //???????????????????????????????????????
      for (var i = 0; i < 2; i++) {
        var hobbyIndex = 0;
        this.hobby.forEach((element) {
          if (i == 0) {
            if (element[4]['value']['value'] is String) {
              if (double.parse(element[4]['value']['value']) > 0) {
                if (EntryIds1 == '') {
                  EntryIds1 = orderDate[hobbyIndex][5].toString();
                } else {
                  EntryIds1 =
                      EntryIds1 + ',' + orderDate[hobbyIndex][5].toString();
                }
              }
            } else {
              if (element[4]['value']['value'] > 0) {
                if (EntryIds1 == '') {
                  EntryIds1 = orderDate[hobbyIndex][5].toString();
                } else {
                  EntryIds1 =
                      EntryIds1 + ',' + orderDate[hobbyIndex][5].toString();
                }
              }
            }
          } else {
            if (element[6]['value']['value'] is String) {
              if (double.parse(element[6]['value']['value']) > 0) {
                if (EntryIds2 == '') {
                  EntryIds2 = orderDate[hobbyIndex][5].toString();
                } else {
                  EntryIds2 =
                      EntryIds2 + ',' + orderDate[hobbyIndex][5].toString();
                }
              }
            } else {
              if (element[6]['value']['value'] > 0) {
                if (EntryIds2 == '') {
                  EntryIds2 = orderDate[hobbyIndex][5].toString();
                } else {
                  EntryIds2 =
                      EntryIds2 + ',' + orderDate[hobbyIndex][5].toString();
                }
              }
            }
          }
          hobbyIndex++;
        });
      }
      //????????????????????????
      if (EntryIds1 == '' && EntryIds2 == '') {
        ToastUtil.showInfo('???????????????');
      } else {
        var checkList = [];
        //??????????????????
        for (var i = 0; i < 2; i++) {
          if (EntryIds1 != '' && i == 0) {
            checkList.add(EntryIds1);
            var resCheck = await this.pushDown(EntryIds1, 'defective');
            if (resCheck['isBool'] != false) {
              var subData = await SubmitEntity.save(resCheck);
                var res = jsonDecode(subData);
                if (res != null) {
                  if (res['Result']['ResponseStatus']['IsSuccess']) {
                    //??????????????????
                    Map<String, dynamic> auditMap = Map();
                    auditMap = {
                      "formid": "PRD_INSTOCK",
                      "data": {
                        'Ids': res['Result']['ResponseStatus']['SuccessEntitys']
                            [0]['Id']
                      }
                    };
                    if(EntryIds2 != ''){
                      if(i == 1){
                        this.handlerStatus();
                      }
                    }else{
                      this.handlerStatus();
                    }
                    /*await auditOrder(auditMap,i,EntryIds2 != '');*/
                  } else {
                    Map<String, dynamic> deleteMap = Map();
                    deleteMap = {
                      "formid": "PRD_INSTOCK",
                      "data": {'Ids': resCheck['data']["Model"]["FID"]}
                    };
                    deleteOrder(deleteMap,res['Result']['ResponseStatus']['Errors'][0]
                    ['Message']);
                  }
              }
            } else {
              setState(() {
                this.isSubmit = false;
                ToastUtil.errorDialog(context, resCheck['msg']);
              });
              break;
            }
          } else if (EntryIds2 != '' && i == 1) {
            checkList.add(EntryIds2);
            var resCheck = await this.pushDown(EntryIds2, 'nonDefective');
            if (resCheck['isBool'] != false) {
              var subData = await SubmitEntity.save(resCheck);
              print(subData);
              var res = jsonDecode(subData);
              if (res != null) {
                if (res['Result']['ResponseStatus']['IsSuccess']) {
                  //??????????????????
                  Map<String, dynamic> auditMap = Map();
                  auditMap = {
                    "formid": "PRD_INSTOCK",
                    "data": {
                      'Ids': res['Result']['ResponseStatus']['SuccessEntitys']
                          [0]['Id']
                    }
                  };
                  /*await auditOrder(auditMap,i,EntryIds1 != '');*/
                  if(EntryIds1 != ''){
                    if(i == 1){
                      this.handlerStatus();
                    }
                  }else{
                    this.handlerStatus();
                  }
                } else {
                  Map<String, dynamic> deleteMap = Map();
                  deleteMap = {
                    "formid": "PRD_INSTOCK",
                    "data": {'Ids': resCheck['data']["Model"]["FID"]}
                  };
                  deleteOrder(deleteMap,res['Result']['ResponseStatus']['Errors'][0]
                  ['Message']);
                }
              }
            } else {
              setState(() {
                this.isSubmit = false;
                ToastUtil.errorDialog(context, resCheck['msg']);
              });
              break;
            }
          }
        }

      }
    } else {
      ToastUtil.showInfo('???????????????');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlutterEasyLoading(
      child: Scaffold(
          appBar: AppBar(
            title: Text("??????"),
            centerTitle: true,
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop("refresh");
                }),
            /*actions: <Widget>[
              new IconButton(
                  icon: new Icon(Icons.settings), onPressed: _pushSaved),
            ],*/
          ),
          body: Column(
            children: <Widget>[
              Expanded(
                child: ListView(children: <Widget>[
                  Column(
                    children: [
                      Container(
                        color: Colors.white,
                        child: ListTile(
                          /* title: TextWidget(FBillNoKey, '???????????????'),*/
                          title: Text("???????????????$FBillNo"),
                          /*trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                IconButton(
                                  icon: new Icon(Icons.filter_center_focus),
                                  tooltip: '????????????',
                                  onPressed: () {
                                    checkItem = 'FBillNo';
                                    this.show = true;
                                    scanDialog();
                                  },
                                ),
                              ]),*/
                        ),
                      ),
                      divider,
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        color: Colors.white,
                        child: ListTile(
                          title: Text("???????????????$FSaleOrderNo"),
                          /*title: TextWidget(FSaleOrderNoKey, '???????????????'),*/
                          trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                MyText('',
                                    color: Colors.grey, rightpadding: 18),
                              ]),
                        ),
                      ),
                      divider,
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        color: Colors.white,
                        child: ListTile(
                          title: Text('???????????????'),
                          trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                MyText('',
                                    color: Colors.grey, rightpadding: 18),
                              ]),
                        ),
                      ),
                      divider,
                    ],
                  ),
                  _dateItem('???????????????', DateMode.YMDHMS),
                  /* _item('????????????', ['PHP', 'JAVA', 'C++', 'Dart', 'Python', 'Go'], selectSex),*/
                  // _item('Laber', [123, 23,235,3,14545,15,123163,18548,9646,1313], 235, label: 'kg')
                  Column(
                    children: [
                      Container(
                        color: Colors.white,
                        child: ListTile(
                          title: PartRefreshWidget(FPrdOrgIdKey, () {
                            //2????????? ????????????widget
                            return Text('???????????????$FName');
                          }),
                          trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                if (!isScanWork)
                                  IconButton(
                                    icon: new Icon(Icons.filter_center_focus),
                                    tooltip: '????????????',
                                    onPressed: () {
                                      checkItem = 'FPrdOrgId';
                                      this.show = true;
                                      scanDialog();
                                    },
                                  ),
                              ]),
                        ),
                      ),
                      divider,
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        color: Colors.white,
                        child: ListTile(
                          title: TextField(
                            //??????????????????
                            maxLines: 1,
                            decoration: InputDecoration(
                              hintText: "??????",
                              //?????????????????????
                              border: OutlineInputBorder(),
                            ),
                            controller: this._remarkContent,
                            //????????????
                            onChanged: (value) {
                              setState(() {
                                _remarkContent.value = TextEditingValue(
                                    text: value,
                                    selection: TextSelection.fromPosition(TextPosition(
                                        affinity: TextAffinity.downstream,
                                        offset: value.length)));
                              });
                            },
                          ),
                        ),
                      ),
                      divider,
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        color: Colors.white,
                        child: ListTile(
                          title: Text('?????????????????????'),
                        ),
                      ),
                      divider,
                    ],
                  ),
                  Column(
                    children: this._getHobby(),
                  ),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: RaisedButton(
                        padding: EdgeInsets.all(15.0),
                        child: Text("??????"),
                        color: this.isSubmit
                            ? Colors.grey
                            : Theme.of(context).primaryColor,
                        textColor: Colors.white,
                        onPressed: () async =>
                            this.isSubmit ? null : submitOder(),
                        /*onPressed: () async {
                          if(this.hobby.length>0){
                            setState(() {
                              this.isSubmit = true;
                            });
                            submitOder();
                           */ /* Map<String, dynamic> dataMap = Map();
                            var numbers = [];
                            dataMap['formid'] = 'PRD_MO';
                            dataMap['opNumber'] = 'toStart';
                            var hobbyIndex = 0;
                            this.hobby.forEach((list) {
                              Map<String, dynamic> entityMap = Map();
                              entityMap['Id'] = orderDate[hobbyIndex][18];
                              entityMap['EntryIds'] = orderDate[hobbyIndex][5];
                              numbers.add(entityMap);
                               hobbyIndex++;
                            });
                            dataMap['data'] = {'PkEntryIds':numbers};
                            var status = await SubmitEntity.alterStatus(dataMap);
                            print(status);
                            if(status != null){
                              var res = jsonDecode(status);
                              print(res);
                              if(res != null){
                                if(res['Result']['ResponseStatus']['IsSuccess']){
                                  submitOder();
                                }else{
                                  ToastUtil.showInfo(res['Result']['ResponseStatus']['Errors'][0]['Message']);
                                }
                              }
                            }*/ /*
                          }else{
                            ToastUtil.showInfo('???????????????');
                          }
                        },*/
                      ),
                    ),
                  ],
                ),
              )
            ],
          )),
    );
  }
}
