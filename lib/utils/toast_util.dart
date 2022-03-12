import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastUtil{

  static void showInfo(String  str)async {
    Fluttertoast.showToast(
        msg: str,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 5,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }
  //错误信息弹窗
  static void errorDialog(BuildContext context,String  str)async {
    showDialog<Widget>(
      context: context,
      builder: (BuildContext context) => Padding(
        padding: EdgeInsets.all(16),
        child:Container(
        height: MediaQuery.of(context).size.height*0.1,
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child:Container(
            height: MediaQuery.of(context).size.height*0.1,
            alignment: Alignment.center,
            color: Colors.black54,
            child: Text("上的飞机啊少了几分 阿拉斯加发 爱上帝就发阿拉斯加发距离首府阿三酱豆腐 ；阿拉斯加发拉萨了案例就是就爱上了啊啊123131dsssssssssssssssssssssssssssssssssssssssssss",style: TextStyle(
              fontSize: 15,
              decoration: TextDecoration.none,
              // 文字颜色
              color: Colors.white,
            )),
          ),
        ),
      ),
      ),
    ).then((val) {
      print(val);
    });
  }
}
