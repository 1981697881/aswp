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
import 'package:intl/intl.dart';

final String _fontFamily = Platform.isWindows ? "Roboto" : "";

class ReportPage extends StatefulWidget {
  ReportPage({Key key}) : super(key: key);

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  GlobalKey<TextWidgetState> textKey = GlobalKey();
  GlobalKey<TextWidgetState> FBillNoKey = GlobalKey();
  GlobalKey<TextWidgetState> FSaleOrderNoKey = GlobalKey();
  GlobalKey<PartRefreshWidgetState> globalKey = GlobalKey();
  GlobalKey<PartRefreshWidgetState> FPrdOrgIdKey = GlobalKey();

  var checkItem;
  String FBillNo = '';
  String FSaleOrderNo = '';
  String FName = '';
  String FNumber = '';
  var show = false;
  String FDate = '';
  var checkData;
  var checkDataChild;
  var selectData = {
    DateMode.YMD: '',
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

  @override
  void initState() {
    super.initState();

    /// 开启监听
    if (_subscription == null) {
      _subscription = scannerPlugin
          .receiveBroadcastStream()
          .listen(_onEvent, onError: _onError);
    }
  }

  @override
  void dispose() {
    super.dispose();

    /// 取消监听
    if (_subscription != null) {
      _subscription.cancel();
    }
  }

  // 用户的爱好集合
  List hobby = [];

  getOrderList() async {
    if (FNumber != '' && FBillNo != '') {
      Map<String, dynamic> userMap = Map();
      if (FDate != '') {
        userMap['FilterString'] =
            "FBillNo='$FBillNo' and FWorkShopID.FNumber='$FNumber' and FDate='$FDate'";
      } else {
        userMap['FilterString'] =
            "FBillNo='$FBillNo' and FWorkShopID.FNumber='$FNumber'";
      }
      userMap['FormId'] = 'PRD_MO';
      userMap['FieldKeys'] =
          'FBillNo,FPrdOrgId.FNumber,FPrdOrgId.FName,FDate,FSaleOrderNo,FTreeEntity_FEntryId,FMaterialId.FNumber,FMaterialId.FName,FMaterialId.FSpecification,FWorkShopID.FNumber,FWorkShopID.FName,FUnitId.FNumber,FUnitId.FName,FQty,FPlanStartDate,FPlanFinishDate,FSrcBillNo,FNoStockInQty';
      Map<String, dynamic> dataMap = Map();
      dataMap['data'] = userMap;
      String order = await CurrencyEntity.polling(dataMap);
      orderDate = [];
      orderDate = jsonDecode(order);
      FDate = orderDate[0][3].substring(0, 10);
      selectData[DateMode.YMD] = orderDate[0][3].substring(0, 10);
      FSaleOrderNo = orderDate[0][4];
      globalKey.currentState.update();
      /*FBillNoKey.currentState.onPressed(orderDate[0][0]);
    FSaleOrderNoKey.currentState.onPressed(orderDate[0][4]);*/
      hobby = [];
      orderDate.forEach((value) {
        List arr = [];
        arr.add({
          "title": "物料子码",
          "name": "FMaterialId",
          "value": {"label": value[6], "value": value[6]}
        });
        arr.add({
          "title": "生产车间",
          "name": "FWorkShopID",
          "value": {"label": value[10], "value": value[9]}
        });
        arr.add({
          "title": "预测批号",
          "name": "",
          "value": {"label": "", "value": ""}
        });
        arr.add({
          "title": "需生产数量",
          "name": "FQty",
          "value": {"label": value[13], "value": value[13]}
        });
        arr.add({
          "title": "良品数量",
          "name": "goodProductNumber",
          "value": {"label": "", "value": ""}
        });
        arr.add({
          "title": "良品仓库",
          "name": "goodProductStock",
          "value": {"label": "主仓", "value": "CK101001"}
        });
        arr.add({
          "title": "不合格数量",
          "name": "rejectsNumber",
          "value": {"label": "", "value": ""}
        });
        arr.add({
          "title": "不合格仓库",
          "name": "rejectsStock",
          "value": {"label": "次品仓", "value": "CK101004"}
        });
        hobby.add(arr);
      });
      checkItem = '';
      setState(() {
        EasyLoading.dismiss();
        this._getHobby();
      });
    } else {
      EasyLoading.dismiss();
      _code = '';
      textKey.currentState.onPressed(_code);
      if (FNumber == '') {
        checkItem = 'FPrdOrgId';
        ToastUtil.showInfo('请扫描生产车间');
      } else if (FBillNo == '') {
        checkItem = 'FBillNo';
        ToastUtil.showInfo('请扫描生产单号');
      }
      scanDialog();
    }
  }

  void _onEvent(Object event) async {
    /*  setState(() {*/
    _code = event;
    if (textKey.currentState != null) {
      textKey.currentState.onPressed(_code);
      EasyLoading.show(status: 'loading...');
      switch (checkItem) {
        case 'FBillNo':
          Navigator.pop(context);
          FBillNo = _code;
          await getOrderList();
          break;
        case 'FPrdOrgId':
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
            this.hobby[checkData][checkDataChild]["value"]['label'] =  _code.split(',')[1];
            this.hobby[checkData][checkDataChild]['value']["value"] =  _code.split(',')[0];
          });
          break;
      }
    } else {
      ToastUtil.showInfo('请点击扫描行扫描图标');
    }
    print("ChannelPage: $event");
    /*});*/
  }

  void _onError(Object error) {
    setState(() {
      _code = "扫描异常";
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
              MyText(selectData.toString() ?? '暂无',
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
                //2、使用 创建一个widget
                return MyText(
                    PicketUtil.strEmpty(selectData[model])
                        ? '暂无'
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
      selectDate: PDuration.parse(DateTime.parse(FDate)),
      //selectDate: PDuration(year: 2020, month: 2, day: 10),
      // minDate: PDuration(hour: 12, minute: 38, second: 3),
      // maxDate: PDuration(hour: 12, minute: 40, second: 36),
      onConfirm: (p) {
        print('longer >>> 返回数据：$p');
        setState(() async {
          switch (model) {
            case DateMode.YMD:
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
        print('longer >>> 返回数据：$p');
        print('longer >>> 返回数据类型：${p.runtimeType}');
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
              title: new Text('系统设置'),
              centerTitle: true,
            ),
            body: new ListView(padding: EdgeInsets.all(10), children: <Widget>[
              ListTile(
                leading: Icon(Icons.search),
                title: Text('版本信息'),
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
                        '：' +
                        this.hobby[i][j]["value"]["label"].toString()),
                    trailing:
                    Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                      IconButton(
                        icon: new Icon(Icons.filter_center_focus),
                        tooltip: '点击扫描',
                        onPressed: () {
                          this._FNumber = 0;
                          checkItem = 'FNumber';
                          this.show = false;
                          checkData = i;
                          if(this.hobby[i][j]["value"]["label"] != 0){
                            this._FNumber = this.hobby[i][j]["value"]["label"];
                          }
                          checkDataChild = j;
                          scanDialog();
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
                        '：' +
                        this.hobby[i][j]["value"]["label"].toString()),
                    trailing:
                    Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                      IconButton(
                        icon: new Icon(Icons.filter_center_focus),
                        tooltip: '点击扫描',
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
                      '：' +
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
  //调出弹窗 扫码
  void scanDialog() {
    checkData = -1;
    checkDataChild = -1;
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
                    child: Text('扫描',
                        style: TextStyle(
                            fontSize: 16, decoration: TextDecoration.none)),
                  ),
                  if (show)
                    Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Card(
                            child: Column(children: <Widget>[
                          TextField(
                            style: TextStyle(color: Colors.black87),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(hintText: "输入或者扫描数量"),
                            onChanged: (value) {
                              setState(() {
                                print(value);
                                this._FNumber = value;
                              });
                            },
                          ),
                        ]))),
                  if (!show)
                    Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: TextWidget(textKey, ''),
                    ),
                  Padding(
                    padding: EdgeInsets.only(top: 15, bottom: 8),
                    child: FlatButton(
                        color: Colors.grey[100],
                        onPressed: () {
                          // 关闭 Dialog
                          Navigator.pop(context);
                          if(checkItem == 'FNumber'){
                            setState(() {
                              this.hobby[checkData][checkDataChild]["value"]["label"] = _FNumber;
                              this.hobby[checkData][checkDataChild]['value']["value"] = _FNumber;
                            });
                          }
                        },
                        child: Text(
                          '确定',
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
  submitOder() async{
    print(this.hobby);
    Map<String, dynamic> dataMap = Map();
    dataMap['formid'] = '';
    Map<String, dynamic> itemMap = Map();
    this.hobby.forEach((element) {

    });
    dataMap['data'] = '';
    String order = await SubmitEntity.submit(dataMap);
    var res = jsonDecode(order);
    if(res){
      setState(() {
        ToastUtil.showInfo('提交成功');
      });
    }else{
      ToastUtil.showInfo(res.msg);
    }
  }
  @override
  Widget build(BuildContext context) {
    return FlutterEasyLoading(
        child: MaterialApp(
      title: "loging",
      home: Scaffold(
          appBar: AppBar(
            title: Text("汇报"),
            centerTitle: true,
            actions: <Widget>[
              new IconButton(
                  icon: new Icon(Icons.settings), onPressed: _pushSaved),
            ],
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
                          /* title: TextWidget(FBillNoKey, '生产订单：'),*/
                          title: Text("生产订单：$FBillNo"),
                          trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                IconButton(
                                  icon: new Icon(Icons.filter_center_focus),
                                  tooltip: '点击扫描',
                                  onPressed: () {
                                    checkItem = 'FBillNo';
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
                          title: Text("来源单号：$FSaleOrderNo"),
                          /*title: TextWidget(FSaleOrderNoKey, '来源单号：'),*/
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
                          title: Text('客户名称：'),
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
                  _dateItem('生产日期：', DateMode.YMD),
                  /* _item('生产车间', ['PHP', 'JAVA', 'C++', 'Dart', 'Python', 'Go'], selectSex),*/
                  // _item('Laber', [123, 23,235,3,14545,15,123163,18548,9646,1313], 235, label: 'kg')
                  Column(
                    children: [
                      Container(
                        color: Colors.white,
                        child: ListTile(
                          title: PartRefreshWidget(FPrdOrgIdKey, () {
                            //2、使用 创建一个widget
                            return Text('生产车间：$FName');
                          }),
                          trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                IconButton(
                                  icon: new Icon(Icons.filter_center_focus),
                                  tooltip: '点击扫描',
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
                          title: Text('生产详细信息：'),
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
                padding: const EdgeInsets.only(top: 28.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: RaisedButton(
                        padding: EdgeInsets.all(15.0),
                        child: Text("保存"),
                        color: Theme.of(context).primaryColor,
                        textColor: Colors.white,
                        onPressed: () async {
                          submitOder();
                        },
                      ),
                    ),
                  ],
                ),
              )
            ],
          )),
    ));
  }
}
