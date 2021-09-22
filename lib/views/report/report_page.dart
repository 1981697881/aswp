import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_pickers/pickers.dart';
import 'package:flutter_pickers/more_pickers/init_data.dart';
import 'package:flutter_pickers/style/default_style.dart';
import 'package:flutter_pickers/style/picker_style.dart';
import 'dart:convert';
import 'dart:io';
import 'package:aswp/views/report/my_app_bar.dart';
import 'package:aswp/views/report/my_text.dart';

final String _fontFamily = Platform.isWindows ? "Roboto" : "";

class ReportPage extends StatefulWidget {
  ReportPage({Key key}) : super(key: key);

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  String selectSex = '女';
  String selectEdu;
  String selectSubject;
  String selectConstellation;
  String selectZodiac = '龙';
  String selectHeight = '165';
  String selectEthnicity = '汉族';

  final divider = Divider(height: 1, indent: 20);
  final rightIcon = Icon(Icons.keyboard_arrow_right);
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

  String username;

  int sex = 1;

  // 用户的爱好集合
  List hobby = [
    {"checked": false, "title": "玩游戏"},
    {"checked": false, "title": "写代码"},
    {"checked": true, "title": "打豆豆"}
  ];
  String info = "";

  // 姓别选择的回调方法
  void _sexChange(value) {
    setState(() {
      this.sex = value;
    });
  }

  List<Widget> _getHobby() {
    List<Widget> tempList = [];
    for (int i = 0; i < this.hobby.length; i++) {
      tempList.add(Row(
        children: <Widget>[
          Text(this.hobby[i]["title"] + '：'),
          Checkbox(
            value: this.hobby[i]["checked"],
            onChanged: (value) {
              setState(() {
                this.hobby[i]["checked"] = value;
              });
            },
          )
        ],
      ));
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
            children: [
              Expanded(
                child: ListView(children: <Widget>[
                  Column(
                    children: <Widget>[
                      Row(children: <Widget>[
                        Text("生产单号："),
                        Expanded(
                          flex: 1,
                          child: new TextField(
                            decoration: InputDecoration(hintText: "请输入用户信息"),
                            onChanged: (value) {
                              setState(() {
                                this.username = value;
                              });
                            },
                          ),
                        ),
                        IconButton(
                          icon: new Icon(Icons.filter_center_focus),
                          tooltip: 'Increase volume by 10%',
                          onPressed: () {
                            print('点击黄色按钮事件');
                          },
                        ),
                      ]),
                      // 单行文本输入框
                      SizedBox(height: 10),
                      Row(children: <Widget>[
                        Text("生产单号："),
                        Expanded(
                          flex: 1,
                          child: new TextField(
                            decoration: InputDecoration(hintText: "请输入用户信息"),
                            onChanged: (value) {
                              setState(() {
                                this.username = value;
                              });
                            },
                          ),
                        ),
                        IconButton(
                          icon: new Icon(Icons.filter_center_focus),
                          tooltip: 'Increase volume by 10%',
                          onPressed: () {},
                        ),
                      ]),
                      // 单行文本输入框
                      SizedBox(height: 10),
                      // 单选按钮
                      Row(children: <Widget>[
                        Text('男'),
                        Radio(
                          value: 1,
                          onChanged: this._sexChange,
                          groupValue: this.sex,
                        ),
                        SizedBox(width: 20),
                        Text("女"),
                        Radio(
                          value: 2,
                          onChanged: this._sexChange,
                          groupValue: this.sex,
                        )
                      ]),
                      SizedBox(height: 10),
                      // 多选框
                      Column(
                        children: this._getHobby(),
                      ),
                      SizedBox(height: 10),
                      // 多行文本域
                      TextField(
                        maxLines: 4,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(), hintText: "请输入备注信息"),
                        onChanged: (value) {
                          setState(() {
                            this.info = value;
                          });
                        },
                      ),
                    ],
                  ),
                  _item('性别', PickerDataType.sex, selectSex),
                  _item('自定义数据 (单列)',
                      ['PHP', 'JAVA', 'C++', 'Dart', 'Python', 'Go'], "Dart"),
                  _item(
                      '身高',
                      List.generate(200, (index) => (50 + index).toString()),
                      "168",
                      label: 'cm'),
                  // _item('Laber', [123, 23,235,3,14545,15,123163,18548,9646,1313], 235, label: 'kg')
                  SizedBox(height: 80),
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
                          print(this.sex);
                          print(this.username);
                          print(this.hobby);
                          print(this.info);
                        },
                      ),
                    ),
                  ],
                ),
              )
            ],
            /*child: ListView(children: <Widget>[
              Column(
                children: <Widget>[
                  Row(
                      children:<Widget>[
                        Text("生产单号："),
                        Expanded(
                          flex: 1,
                          child: new TextField(
                            decoration: InputDecoration(
                                hintText: "请输入用户信息"
                            ),
                            onChanged: (value){
                              setState(() {
                                this.username = value;
                              });
                            },
                          ),
                        ),
                        IconButton(
                          icon: new Icon(Icons.filter_center_focus),
                          tooltip: 'Increase volume by 10%',
                          onPressed: () {
                            print('点击黄色按钮事件');
                          },
                        ),
                      ]
                  ),
                  // 单行文本输入框
                  SizedBox(height:10),
                  Row(
                      children:<Widget>[
                        Text("生产单号："),
                        Expanded(
                          flex: 1,
                          child: new TextField(
                            decoration: InputDecoration(
                                hintText: "请输入用户信息"
                            ),
                            onChanged: (value){
                              setState(() {
                                this.username = value;
                              });
                            },
                          ),
                        ),
                        IconButton(
                          icon: new Icon(Icons.filter_center_focus),
                          tooltip: 'Increase volume by 10%',
                          onPressed: () {

                          },
                        ),
                      ]
                  ),
                  // 单行文本输入框
                  SizedBox(height:10),
                  // 单选按钮
                  Row(
                      children:<Widget>[
                        Text('男'),
                        Radio(
                          value:1,
                          onChanged: this._sexChange,
                          groupValue: this.sex,
                        ),
                        SizedBox(width:20),
                        Text("女"),
                        Radio(
                          value:2,
                          onChanged:this._sexChange,
                          groupValue:this.sex,
                        )
                      ]
                  ),
                  SizedBox(height:10),
                  // 多选框
                  Column(
                    children:this._getHobby(),
                  ),
                  SizedBox(height:10),
                  // 多行文本域
                  TextField(
                    maxLines: 4,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "请输入备注信息"
                    ),
                    onChanged:(value){
                      setState(() {
                        this.info = value;
                      });
                    },
                  ),

                  SizedBox(height:10),
                  // 登录按钮
                  Container(
                      width:double.infinity,
                      height:40,
                      child:RaisedButton(
                          child: Text("登录"),
                          onPressed:(){
                            print(this.sex);
                            print(this.username);
                            print(this.hobby);
                            print(this.info);
                          },
                          color:Colors.blue,
                          textColor:Colors.white
                      )
                  )
                ],
              ),
              _item('性别', PickerDataType.sex, selectSex),
              _item(
                  '自定义数据 (单列)', ['PHP', 'JAVA', 'C++', 'Dart', 'Python', 'Go'],
                  "Dart"),
              _item(
                  '身高', List.generate(200, (index) => (50 + index).toString()),
                  "168",
                  label: 'cm'),
              // _item('Laber', [123, 23,235,3,14545,15,123163,18548,9646,1313], 235, label: 'kg')
              SizedBox(height: 80),

          ]),*/
          )),
    );
  }
}
