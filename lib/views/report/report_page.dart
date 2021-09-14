import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
class ReportPage extends StatefulWidget {
  ReportPage({Key key}) : super(key: key);
  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
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




  String username ;
  int sex=1;
  // 用户的爱好集合
  List hobby = [
    {
      "checked":false,
      "title":"玩游戏"
    },
    {
      "checked":false,
      "title":"写代码"
    },
    {
      "checked":true,
      "title":"打豆豆"
    }
  ];
  String info = "";
  // 姓别选择的回调方法
  void _sexChange(value){
    setState(() {
      this.sex = value;
    });
  }
  List<Widget> _getHobby(){
    List <Widget> tempList=[];
    for(int i =0;i<this.hobby.length;i++){
      tempList.add(
          Row(
            children: <Widget>[
              Text(this.hobby[i]["title"]+'：'),
              Checkbox(
                value:this.hobby[i]["checked"],
                onChanged:(value){
                  setState(() {
                    this.hobby[i]["checked"] = value;
                  });
                },
              )
            ],
          )
      );
    }
    return tempList;
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
          appBar: AppBar(
            title: Text("汇报"),
            centerTitle: true,
          ),
          body:Padding(padding:
          EdgeInsets.all(10),
              child: Column(
                children: <Widget>[
                  Row(
                      children:<Widget>[
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
              )
          )
      ),
    );
  }
}