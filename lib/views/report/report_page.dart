import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_pickers/pickers.dart';
import 'package:flutter_pickers/more_pickers/init_data.dart';
import 'package:flutter_pickers/style/default_style.dart';
import 'package:flutter_pickers/style/picker_style.dart';
import 'package:flutter_pickers/time_picker/model/date_mode.dart';
import 'package:flutter_pickers/time_picker/model/pduration.dart';
import 'package:flutter_pickers/time_picker/model/suffix.dart';
import 'dart:io';
import 'package:flutter_pickers/utils/check.dart';
import 'package:flutter/cupertino.dart';
import 'package:aswp/views/report/my_text.dart';

final String _fontFamily = Platform.isWindows ? "Roboto" : "";

class ReportPage extends StatefulWidget {
  ReportPage({Key key}) : super(key: key);

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  String selectSex = 'Go';
  var selectData = {
    DateMode.YMD: '2021-9-1',
  };
  final divider = Divider(height: 1, indent: 20);
  final rightIcon = Icon(Icons.keyboard_arrow_right);
  final scanIcon = Icon(Icons.filter_center_focus);
  static const scannerPlugin =
      const EventChannel('com.shinow.pda_scanner/plugin');
  StreamSubscription _subscription;
  var _code;

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

  void _onEvent(Object event) {
    setState(() {
      _code = event;
      print("ChannelPage: $event");
    });
  }

  void _onError(Object error) {
    setState(() {
      _code = "扫描异常";
      print(error);
    });
  }

  // 用户的爱好集合
  List hobby = [
    {"title": "物料字码", "value": ""},
    {"title": "生产车间", "value": ""},
    {"title": "预测批号", "value": ""},
    {"title": "需生产数量", "value": ""},
    {"title": "良品数量", "value": ""},
    {"title": "良品仓库", "value": ""},
    {"title": "不合格数量", "value": ""},
    {"title": "不合格仓库", "value": ""},
  ];
  List<Widget> _getHobby() {
    List<Widget> tempList = [];
    for (int i = 0; i < 3; i++) {
      List<Widget> comList = [];
      for (int j = 0; j < this.hobby.length; j++) {
        if (j == 5) {
          comList.add(
            _item(this.hobby[j]["title"], ['PHP', 'JAVA', 'C++', 'Dart', 'Python', 'Go'],
                this.hobby[j]["value"]),
          );
        } else if (j == 7) {
          comList.add(
            _item(this.hobby[j]["title"], ['PHP', 'JAVA', 'C++', 'Dart', 'Python', 'Go'],
                this.hobby[j]["value"]),
          );
        } else {
          comList.add(
            Column(children: [
              Container(
                color: Colors.white,
                child: ListTile(
                  title: Text(this.hobby[j]["title"] + '：'),
                  trailing:
                      Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    MyText(this.hobby[j]["value"],
                        color: Colors.grey, rightpadding: 18),
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
              MyText(
                  PicketUtil.strEmpty(selectData[model])
                      ? '暂无'
                      : selectData[model],
                  color: Colors.grey,
                  rightpadding: 18),
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

      // selectDate: PDuration(hour: 18, minute: 36, second: 36),
      // minDate: PDuration(hour: 12, minute: 38, second: 3),
      // maxDate: PDuration(hour: 12, minute: 40, second: 36),
      onConfirm: (p) {
        print('longer >>> 返回数据：$p');
        setState(() {
          switch (model) {
            case DateMode.YMD:
              selectData[model] = '${p.year}-${p.month}-${p.day}';
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
            selectSex = p;
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
          appBar: AppBar(
            title: Text("汇报"),
            centerTitle: true,
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
                          title: Text('生产单号：'),
                          trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                IconButton(
                                  icon: new Icon(Icons.filter_center_focus),
                                  tooltip: 'Increase volume by 10%',
                                  onPressed: () {
                                    print('点击黄色按钮事件');
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
                          title: Text('来源单号：'),
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
                  _item('生产车间', ['PHP', 'JAVA', 'C++', 'Dart', 'Python', 'Go'], selectSex),
                  // _item('Laber', [123, 23,235,3,14545,15,123163,18548,9646,1313], 235, label: 'kg')
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
                          print(this.hobby);
                        },
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
