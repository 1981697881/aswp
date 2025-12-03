import 'dart:convert';
import 'dart:ui';
import 'package:date_format/date_format.dart';
import 'package:decimal/decimal.dart';
import 'package:aswp/model/currency_entity.dart';
import 'package:aswp/model/submit_entity.dart';
import 'package:aswp/utils/handler_order.dart';
import 'package:aswp/utils/refresh_widget.dart';
import 'package:aswp/utils/text.dart';
import 'package:aswp/utils/toast_util.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_pickers/pickers.dart';
import 'package:flutter_pickers/style/default_style.dart';
import 'package:flutter_pickers/time_picker/model/date_mode.dart';
import 'package:flutter_pickers/time_picker/model/pduration.dart';
import 'package:flutter_pickers/time_picker/model/suffix.dart';
import 'dart:io';
import 'package:flutter_pickers/utils/check.dart';
import 'package:flutter/cupertino.dart';
import 'package:aswp/components/my_text.dart';
import 'package:intl/intl.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:shared_preferences/shared_preferences.dart';

final String _fontFamily = Platform.isWindows ? "Roboto" : "";

class AllocationWarehouseDetail extends StatefulWidget {
  var FBillNo;
  var FStockOrgInId;

  AllocationWarehouseDetail({Key? key, @required this.FBillNo, @required this.FStockOrgInId}) : super(key: key);

  @override
  _RetrievalDetailState createState() => _RetrievalDetailState(FBillNo,FStockOrgInId);
}

class _RetrievalDetailState extends State<AllocationWarehouseDetail> {
  var _remarkContent = new TextEditingController();
  GlobalKey<PartRefreshWidgetState> globalKey = GlobalKey();
  GlobalKey<TextWidgetState> textKey = GlobalKey();
  final _textNumber = TextEditingController();
  var checkItem;
  String FBillNo = '';
  String keyWord = '';
  String FName = '';
  String FNumber = '';
  String FDate = '';
  String newBillNo='';
  var isSubmit = false;
  var show = false;
  var isScanWork = false;
  var checkData;
  var fOrgID;
  var checkDataChild;
  var selectData = {
    DateMode.YMD: '',
  };
  var organizationsName;
  var organizationsNumber;
  var storehouseName;
  var storehouseNumber;
  var storehouseNameT;
  var storehouseNumberT;
  var showPosition = false;
  var showPositionT = false;
  var storingLocationName;
  var storingLocationNumber;
  var fBarCodeList;
  var stockList = [];
  var searchStockList = [];
  List<dynamic> stockListObj = [];
  var stockListT = [];
  var searchStockListT = [];
  List<dynamic> stockListObjT = [];
  var organizationsList = [];
  List<dynamic> organizationsListObj = [];
  List<dynamic> orderDate = [];
  List<dynamic> materialDate = [];
  final divider = Divider(height: 1, indent: 20);
  final rightIcon = Icon(Icons.keyboard_arrow_right, color: Colors.blue);
  final scanIcon = Icon(Icons.filter_center_focus, color: Colors.blue);
  static const scannerPlugin =
  const EventChannel('com.shinow.pda_scanner/plugin');
  StreamSubscription? _subscription;
  var _code;
  var _FNumber;
  var fBillNo;
  var organizationsName1;
  var organizationsNumber1;
  var organizationsName2;
  var organizationsNumber2;
  final controller = TextEditingController();
  List<TextEditingController> _textNumber3 = [];
  List<FocusNode> focusNodes = [];
  _RetrievalDetailState(FBillNo, FStockOrgInId) {
    if (FBillNo != null) {
      this.fBillNo = FBillNo['value'];
      if(FStockOrgInId != null){
        this.organizationsNumber2 = FStockOrgInId['value'];
        this.getStockListT();
      }else{
        this.getOrderList();
      }
      isScanWork = true;
    } else {
      isScanWork = false;
      this.fBillNo = '';
      FDate = formatDate(DateTime.now(), [
        yyyy,
        "-",
        mm,
        "-",
        dd,
      ]);
      selectData[DateMode.YMD] = formatDate(DateTime.now(), [
        yyyy,
        "-",
        mm,
        "-",
        dd,
      ]);
      getOrganizationsList();
    }
  }

  @override
  void initState() {
    super.initState();
    // 开启监听
    if (_subscription == null) {
      _subscription = scannerPlugin
          .receiveBroadcastStream()
          .listen(_onEvent, onError: _onError);
    }
    /*getWorkShop();*/

    EasyLoading.dismiss();
  }
  void _setupListener(int index) {
    focusNodes[index].addListener(() {
      if (!focusNodes[index].hasFocus) { // 检查是否失去焦点
        print(_textNumber3[index].text[_textNumber3[index].text.length - 1]==".");
        if(_textNumber3[index].text[_textNumber3[index].text.length - 1]=="."){
          _textNumber3[index].text = _textNumber3[index].text + "0";
        }
      }
    });
  }
  //获取仓库
  getStockList() async {
    stockList = [];
    Map<String, dynamic> userMap = Map();
    userMap['FormId'] = 'BD_STOCK';
    userMap['FieldKeys'] = 'FStockID,FName,FNumber,FIsOpenLocation,FFlexNumber';
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var menuData = sharedPreferences.getString('MenuPermissions');
    var deptData = jsonDecode(menuData)[0];
    if(this.organizationsNumber1 != null){
      userMap['FilterString'] = "FForbidStatus = 'A' and FDocumentStatus = 'C' and FUseOrgId.FNumber='"+this.organizationsNumber1+"'";
    }else{
      userMap['FilterString'] = "FForbidStatus = 'A' and FDocumentStatus = 'C'";
    }
    Map<String, dynamic> dataMap = Map();
    dataMap['data'] = userMap;
    String res = await CurrencyEntity.polling(dataMap);
    stockListObj = jsonDecode(res);
    stockListObj.forEach((element) {
      stockList.add(element[1]);
    });
  }
  //获取仓库
  getStockListT() async {
    stockListT = [];
    Map<String, dynamic> userMap = Map();
    userMap['FormId'] = 'BD_STOCK';
    userMap['FieldKeys'] = 'FStockID,FName,FNumber,FIsOpenLocation,FFlexNumber';
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var menuData = sharedPreferences.getString('MenuPermissions');
    var deptData = jsonDecode(menuData)[0];
    if(this.organizationsNumber2 != null){
      userMap['FilterString'] = "FForbidStatus = 'A' and FDocumentStatus = 'C' and FUseOrgId.FNumber='"+this.organizationsNumber2+"'";
    }else{
      userMap['FilterString'] = "FForbidStatus = 'A' and FDocumentStatus = 'C'";
    }
    Map<String, dynamic> dataMap = Map();
    dataMap['data'] = userMap;
    String res = await CurrencyEntity.polling(dataMap);
    stockListObjT = jsonDecode(res);
    stockListObjT.forEach((element) {
      stockListT.add(element[1]);
    });
    if(this.fBillNo != null && this.fBillNo != ''){
      this.getOrderList();
    }
  }
  //获取组织
  getOrganizationsList() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      if(this.organizationsNumber1 == '' || this.organizationsNumber1 == null){
        this.organizationsNumber1 = sharedPreferences.getString('tissue');
        this.organizationsName1 = sharedPreferences.getString('tissueName');
      }
      if(this.organizationsNumber2 == '' || this.organizationsNumber2 == null){
        this.organizationsNumber2 = sharedPreferences.getString('tissue');
        this.organizationsName2 = sharedPreferences.getString('tissueName');
      }
      this.getStockList();
      if(this.fBillNo == null || this.fBillNo == ''){
        this.getStockListT();
      }
    });
    Map<String, dynamic> userMap = Map();
    userMap['FormId'] = 'ORG_Organizations';
    userMap['FieldKeys'] = 'FForbidStatus,FName,FNumber,FDocumentStatus';
    userMap['FilterString'] = "FForbidStatus = 'A' and FDocumentStatus = 'C'";
    Map<String, dynamic> dataMap = Map();
    dataMap['data'] = userMap;
    String res = await CurrencyEntity.polling(dataMap);
    organizationsListObj = jsonDecode(res);
    organizationsListObj.forEach((element) {
      organizationsList.add(element[1]);
    });

  }

  void getWorkShop() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      if (sharedPreferences.getString('FWorkShopName') != null) {
        FName = sharedPreferences.getString('FWorkShopName');
        FNumber = sharedPreferences.getString('FWorkShopNumber');
        isScanWork = true;
      } else {
        isScanWork = false;
      }
    });
  }

  @override
  void dispose() {
    this._textNumber.dispose();
    // 释放所有 Controller 和 FocusNode
    for (var controller in _textNumber3) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();

    /// 取消监听
    if (_subscription != null) {
      _subscription!.cancel();
    }
  }

  // 查询数据集合
  List hobby = [];
  List fNumber = [];
  getInventoryList() async{
    Map<String, dynamic> userMap = Map();
    if(this.keyWord != '' && this.organizationsNumber1 != null){
      userMap['FilterString'] =
          "(FMaterialId.FNumber like '%"+keyWord+"%' or FMaterialId.FName like '%"+keyWord+"%') and FBaseQty>0 and FStockOrgId.FNumber='${this.organizationsNumber1}'";
    }else{
      if(this.keyWord == ""){
        ToastUtil.showInfo('请输入查询信息');
        return;
      }
      if(this.organizationsNumber1 == null){
        ToastUtil.showInfo('请选择调出货主');
        return;
      }
    }
    userMap['FormId'] = 'STK_Inventory';
    userMap['FieldKeys'] =
    'FStockOrgId.FNumber,FStockId.FNumber';
    userMap['Limit'] = '50';
    Map<String, dynamic> stockMap = Map();
    stockMap['data'] = userMap;
    String stockRes = await CurrencyEntity.polling(stockMap);
    var stockFlex = jsonDecode(stockRes);
    String order = "";
    if (stockFlex.length > 0) {
      var stockFlexRes = [];
      for(var item in stockFlex){
        Map<String, dynamic> stockMap = Map();
        stockMap['FormId'] = 'BD_STOCK';
        stockMap['FieldKeys'] =
        'FStockID,FName,FNumber,FIsOpenLocation,FFlexNumber';
        stockMap['FilterString'] = "FNumber = '" +
            item[1] +
            "' and FUseOrgId.FNumber = '" +
            item[0] +
            "'";
        Map<String, dynamic> stockDataMap = Map();
        stockDataMap['data'] = stockMap;
        String res = await CurrencyEntity.polling(stockDataMap);
        if (jsonDecode(res).length > 0) {
          if(stockFlexRes.indexOf(jsonDecode(res)[0][4]) == -1 && jsonDecode(res)[0][4] != null){
            stockFlexRes.add(jsonDecode(res)[0][4]);
          }
        }
      }
      List stockData = [];
      userMap['FieldKeys'] ='FMaterialId.FNumber,FMaterialId.FName,FMaterialId.FSpecification,FStockId.FName,FStockId.FNumber,FBaseUnitId.FNumber,FBaseUnitId.FName,FBaseQty,FLot.FNumber,FOwnerId.FNumber,FMaterialId.FIsBatchManage,FProduceDate,FExpiryDate,FMaterialId.FIsKFPeriod,FID,FStockId.FIsOpenLocation';
      for(var item in stockFlexRes){
        if(item != null){
          userMap['FieldKeys'] += ',FStockLocId.'+item +'.FName';
        }
      }
      Map<String, dynamic> dataMap = Map();
      dataMap['data'] = userMap;
      order = await CurrencyEntity.polling(dataMap);
      var orderRes = jsonDecode(order);
      if (orderRes.length > 0) {
        stockData.addAll(orderRes);
      }
      setState(() {
        EasyLoading.dismiss();
      });
      if(stockData.length>0){
        await _showMultiChoiceModalBottomSheet(context, stockData, stockFlexRes);
      }else{
        ToastUtil.showInfo('无库存数量');
      }
    } else {
      setState(() {
        EasyLoading.dismiss();
      });
      ToastUtil.showInfo('无数据');
    }
  }
  getInventoryDataList(data,stockDataList) async {
    EasyLoading.show(status: 'loading...');
    FDate = formatDate(DateTime.now(), [
      yyyy,
      "-",
      mm,
      "-",
      dd,
    ]);
    selectData[DateMode.YMD] = formatDate(DateTime.now(), [
      yyyy,
      "-",
      mm,
      "-",
      dd,
    ]);
    if (data.length > 0) {
      this.fOrgID = data[0][10];
      this.storehouseNumber = data[0][4];
      this.storehouseName = data[0][3];
      this.showPosition = data[0][15];
      // hobby = [];
      data.forEach((value) {
        List arr = [];
        arr.add({
          "title": "物料名称",
          "name": "FMaterial",
          "isHide": false,
          "value": {
            "label": value[1] + "- (" + value[0] + ")",
            "value": value[0],
            "fid": value[14],
            "barcode": []
          }
        });
        arr.add({
          "title": "规格型号",
          "name": "FMaterialIdFSpecification",
          "isHide": true,
          "value": {"label": value[2], "value": value[2]}
        });
        arr.add({
          "title": "单位名称",
          "name": "FUnitId",
          "isHide": false,
          "value": {"label": value[6], "value": value[5]}
        });
        arr.add({
          "title": "调拨数量",
          "name": "FBaseQty",
          "isHide": false,
          "value": {"label": "", "value": "0"}
        });
        arr.add({
          "title": "申请数量",
          "name": "FRemainOutQty",
          "isHide": true,
          "value": {"label": "", "value": "0"}
        });
        arr.add({
          "title": "批号",
          "name": "FLot",
          "isHide": value[10] != true,
          "value": {"label": value[8], "value": value[8]}
        });
        arr.add({
          "title": "调出仓库",
          "name": "FStockId",
          "isHide": false,
          "value": {"label": value[3], "value": value[4], 'dimension': ''}
        });

        var floc = '';
        if(stockDataList.length>0){
          for(var i = 0; i< stockDataList.length;i++){
            if(value[16+i] != null && value[16+i] != ''){
              floc = value[16+i];
              break;
            }
          }
        }
        arr.add({
          "title": "调出仓位",
          "name": "FStockLocID",
          "isHide": false,
          "value": {"label": floc==null|| floc ==''?'':floc, "value": floc==null|| floc ==''?'':floc, "hide": value[15]}
        });
        arr.add({
          "title": "调入仓库",
          "name": "FStockId",
          "isHide": false,
          "value": {"label": "", "value": ""}
        });
        arr.add({
          "title": "调入仓位",
          "name": "FStockLocID",
          "isHide": false,
          "value": {"label": "", "value": "", 'hide': false}
        });
        arr.add({
          "title": "最后扫描数量",
          "name": "FLastQty",
          "isHide": true,
          "value": {"label": "0", "value": "0"}
        });
        arr.add({
          "title": "生产日期",
          "name": "FProduceDate",
          "isHide": value[13] != true,
          "value": {
            "label": value[11] == null ? '' : value[11].substring(0, 10),
            "value": value[11] == null ? '' : value[11].substring(0, 10)
          }
        });
        arr.add({
          "title": "有效期至",
          "name": "FExpiryDate",
          "isHide": value[13] != true,
          "value": {
            "label": value[12] == null ? '' : value[12].substring(0, 10),
            "value": value[12] == null ? '' : value[12].substring(0, 10)
          }
        });
        arr.add({
          "title": "操作",
          "name": "",
          "isHide": false,
          "value": {"label": "", "value": ""}
        });
        hobby.add(arr);
      });
      setState(() {
        EasyLoading.dismiss();
        this._getHobby();
      });
    } else {
      setState(() {
        EasyLoading.dismiss();
        this._getHobby();
      });
      ToastUtil.showInfo('无数据');
    }
    FocusScope.of(context).requestFocus(FocusNode());
  }
  getOrderList() async {
    Map<String, dynamic> userMap = Map();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var tissue = sharedPreferences.getString('tissue');
    var fStockIds = jsonDecode(sharedPreferences.getString('FStockIds'));
    userMap['FilterString'] = "FBillNo='$fBillNo' FQty>0";
    userMap['FormId'] = 'STK_TRANSFERAPPLY';
    userMap['OrderString'] = 'FMaterialId.FNumber ASC';
    userMap['FieldKeys'] =
    'FBillNo,FAPPORGID.FNumber,FAPPORGID.FName,FDate,FEntity_FEntryId,FMATERIALID.FNumber,FMATERIALID.FName,FMATERIALID.FSpecification,FOwnerTypeInIdHead,FOwnerTypeIdHead,FUNITID.FNumber,FUNITID.FName,FQty,FAPPROVEDATE,FNote,FID,FStockId.FNumber,FStockInId.FNumber,FBillTypeID.FNUMBER,FEntity_FSeq,FMaterialId.FIsKFPeriod,FMaterialId.FExpPeriod,FMaterialId.FIsBatchManage,FLot.FNumber,FProduceDate,FExpiryDate,FStockID.FIsOpenLocation,FStockInId.FIsOpenLocation,FStockOrgId.FNumber,FStockOrgId.FName,FStockOrgInId.FNumber,FStockOrgInId.FName,FStockId.FName,FStockInId.FName';
    if(fStockIds.length>0){
      for(var flex in fStockIds){
        userMap['FieldKeys'] += ",FStockLocId."+flex[4]+".FNumber";
      }
    }
    if(stockListObjT.length>0){
      for(var flex in stockListObjT){
        if(flex[4] != null && flex[4] != ''){
          userMap['FieldKeys'] += ",FStockLocInId."+flex[4]+".FNumber";
        }
      }
    }
    Map<String, dynamic> dataMap = Map();
    dataMap['data'] = userMap;
    String order = await CurrencyEntity.polling(dataMap);
    orderDate = [];
    orderDate = jsonDecode(order);
    FDate = formatDate(DateTime.now(), [
      yyyy,
      "-",
      mm,
      "-",
      dd,
    ]);
    selectData[DateMode.YMD] = formatDate(DateTime.now(), [
      yyyy,
      "-",
      mm,
      "-",
      dd,
    ]);
    hobby = [];
    if (orderDate.length > 0) {
      this.storehouseNumber = orderDate[0][16];
      this.storehouseName = orderDate[0][32];
      this.showPosition = orderDate[0][26];
      this.organizationsNumber1 = orderDate[0][28];
      this.organizationsName1 = orderDate[0][29];
      if(orderDate[0][30] != null && orderDate[0][30] !='' ){
        this.organizationsNumber2 = orderDate[0][30];
        this.organizationsName2 = orderDate[0][31];
      }
      if(orderDate[0][17] != null && orderDate[0][17] != ''){
        this.storehouseNumberT = orderDate[0][17];
        this.storehouseNameT = orderDate[0][33];
        this.showPositionT = orderDate[0][27];
      }
      hobby = [];
      for(var value in orderDate){
        fNumber.add(value[5]);
        List arr = [];
        arr.add({
          "title": "物料名称",
          "name": "FMaterial",
          "isHide": false,
          "FID": value[15],
          "FEntryId": value[4],
          "value": {
            "label": value[6] + "- (" + value[5] + ")",
            "value": value[5],
            "barcode": [],
            "kingDeeCode": [],
            "scanCode": [],
            "surplus": value[12],
            "codeList": []
          }
        });
        arr.add({
          "title": "规格型号",
          "isHide": false,
          "name": "FMaterialIdFSpecification",
          "value": {"label": value[7], "value": value[7]}
        });
        arr.add({
          "title": "计量单位",
          "name": "FUnitId",
          "isHide": false,
          "value": {"label": value[11], "value": value[10]}
        });
        arr.add({
          "title": "调拨数量",
          "name": "FBaseQty",
          "isHide": false,
          "value": {"label": "", "value": "0"}
        });
        arr.add({
          "title": "申请数量",
          "name": "FRealQty",
          "isHide": false,
          /*value[12]*/
          "value": {
            "label": value[12],
            "value": value[12]
          }
        });
        arr.add({
          "title": "批号",
          "name": "FSupplyBatchNo",
          "isHide": value[22] != true,
          "value": { "label": value[23], "value": value[23]}
        });
        arr.add({
          "title": "调出仓库",
          "name": "FStockId",
          "isHide": false,
          "value": {"label": value[32], "value": value[16], 'dimension': ""}
        });
        var floc = '';
        if(fStockIds.length>0){
          for(var i = 0; i< fStockIds.length;i++){
            if(value[34+i] != null && value[34+i] != ''){
              floc = value[34+i];
              break;
            }
          }
        }
        arr.add({
          "title": "调出仓位",
          "name": "FStockLocID",
          "isHide": false,
          "value": {"label": floc==null|| floc ==''?'':floc, "value": floc==null|| floc ==''?'':floc, "hide": value[26]}
        });
        arr.add({
          "title": "调入仓库",
          "name": "FStockId",
          "isHide": false,
          "value": {"label": value[33], "value": value[33]}
        });
        var fIntloc = '';
        int count = stockListObjT.where((list) => list.length > 4 && list[4] != null).length;
        if(count>0){
          for(var i = 0; i< count;i++){
            print(34+i+fStockIds.length);
            if(value[34+i+fStockIds.length] != null && value[34+i+fStockIds.length] != ''){
              fIntloc = value[34+i+fStockIds.length];
              break;
            }
          }
        }
        arr.add({
          "title": "调入仓位",
          "name": "FStockLocID",
          "isHide": false,
          "value": {"label": fIntloc==null|| fIntloc ==''?'':fIntloc, "value": fIntloc==null|| fIntloc ==''?'':fIntloc, "hide": value[27]}
        });
        arr.add({
          "title": "最后扫描数量",
          "name": "FLastQty",
          "isHide": true,
          "value": {"label": "0", "value": "0", "remainder": "0", "representativeQuantity": "0"}
        });
        arr.add({
          "title": "生产日期",
          "name": "FProduceDate",
          "isHide": value[20] != true,
          "value": {
            "label": value[24] == null ? '' : value[24].substring(0, 10),
            "value": value[24] == null ? '' : value[24].substring(0, 10)
          }
        });
        arr.add({
          "title": "有效期至",
          "name": "FExpiryDate",
          "isHide": value[20] != true,
          "value": {
            "label": value[25] == null ? '' : value[25].substring(0, 10),
            "value": value[25] == null ? '' : value[25].substring(0, 10)
          }
        });
        arr.add({
          "title": "操作",
          "name": "",
          "isHide": false,
          "value": {"label": "", "value": ""}
        });
        if(fStockIds.length>0){
          Map<String, dynamic> inventoryMap = Map();
          inventoryMap['FormId'] = 'STK_Inventory';
          inventoryMap['FilterString'] =
              "FMaterialId.FNumber='" + value[5] + "' and FBaseQty >0 and FStockOrgID.FNumber = '" +tissue + "'";
          inventoryMap['Limit'] = '50';
          inventoryMap['OrderString'] = 'FLot.FNumber DESC, FProduceDate DESC';
          inventoryMap['FieldKeys'] =
          'FMaterialId.FNumber,FMaterialId.FName,FMaterialId.FSpecification,FStockId.FName,FBaseQty,FLot.FNumber,FAuxPropId,FProduceDate,FExpiryDate';
          for(var flex in fStockIds){
            inventoryMap['FieldKeys'] += ",FStockLocId."+flex[4]+".FNumber";
          }
          Map<String, dynamic> inventoryDataMap = Map();
          inventoryDataMap['data'] = inventoryMap;
          String res = await CurrencyEntity.polling(inventoryDataMap);
          var stocks = jsonDecode(res);
          if (stocks.length > 0) {
            arr.add({
              "title": "库存",
              "name": "FLot",
              "isHide": false,
              "value": {"label": '', "value": '', "fLotList": stocks}
            });
          } else {
            arr.add({
              "title": "库存",
              "name": "FLot",
              "isHide": false,
              "value": {"label": '', "value": '', "fLotList": []}
            });
          }
        }else{
          Map<String, dynamic> inventoryMap = Map();
          inventoryMap['FormId'] = 'STK_Inventory';
          inventoryMap['FilterString'] =
              "FMaterialId.FNumber='" + value[5] + "' and FBaseQty >0 and FStockOrgID.FNumber = '" +tissue + "'";
          inventoryMap['Limit'] = '50';
          inventoryMap['OrderString'] = 'FLot.FNumber DESC, FProduceDate DESC';
          inventoryMap['FieldKeys'] =
          'FMaterialId.FNumber,FMaterialId.FName,FMaterialId.FSpecification,FStockId.FName,FBaseQty,FLot.FNumber,FAuxPropId,FProduceDate,FExpiryDate';
          Map<String, dynamic> inventoryDataMap = Map();
          inventoryDataMap['data'] = inventoryMap;
          String res = await CurrencyEntity.polling(inventoryDataMap);
          var stocks = jsonDecode(res);
          if (stocks.length > 0) {
            arr.add({
              "title": "库存",
              "name": "FLot",
              "isHide": false,
              "value": {"label": '', "value": '', "fLotList": stocks}
            });
          } else {
            arr.add({
              "title": "库存",
              "name": "FLot",
              "isHide": false,
              "value": {"label": '', "value": '', "fLotList": []}
            });
          }
        }
        hobby.add(arr);
      };
      setState(() {
        EasyLoading.dismiss();
        this._getHobby();
      });
    } else {
      setState(() {
        EasyLoading.dismiss();
        this._getHobby();
      });
      ToastUtil.showInfo('无数据');
    }
    this.getOrganizationsList();
  }
  void _onEvent(event) async {
    if (checkItem == 'FLoc' || checkItem == 'HPoc') {
      _FNumber = event.trim();
      this._textNumber.value = _textNumber.value.copyWith(
        text: event.trim(),
      );
    } else {
      SharedPreferences sharedPreferences =
      await SharedPreferences.getInstance();
      var deptData = sharedPreferences.getString('menuList');
      var menuList = new Map<dynamic, dynamic>.from(jsonDecode(deptData));
      fBarCodeList = menuList['FBarCodeList'];
      if (event == "") {
        return;
      }
      if (fBarCodeList == 1) {
        var barcodeList = [];
        if(event.split(';').length>1){
          barcodeList = [[event]];
        }else{
          Map<String, dynamic> barcodeMap = Map();
          barcodeMap['FilterString'] = "FPackageNo='" + event + "' and FBarCodeEn!='" + event + "'";
          barcodeMap['FormId'] = 'QDEP_Cust_BarCodeList';
          barcodeMap['FieldKeys'] =
          'FBarCodeEn';
          Map<String, dynamic> dataMap = Map();
          dataMap['data'] = barcodeMap;
          String order = await CurrencyEntity.polling(dataMap);
          var barcodeData = jsonDecode(order);
          if (barcodeData.length > 0) {
            barcodeList = barcodeData;
          } else {
            barcodeList = [[event]];
          }
        }
        for(var item in barcodeList){
          Map<String, dynamic> barcodeMap = Map();
          barcodeMap['FilterString'] = "FBarCodeEn='"+item[0]+"'";
          barcodeMap['FormId'] = 'QDEP_Cust_BarCodeList';
          barcodeMap['FieldKeys'] =
          'FID,FInQtyTotal,FOutQtyTotal,FEntity_FEntryId,FRemainQty,FBarCodeQty,FStockID.FNumber,FMATERIALID.FIsBatchManage,FMATERIALID.FNUMBER,FOwnerID.FNumber,FBarCode,FSN,FProduceDate,FExpiryDate,FBatchNo,FStockOrgID.FNumber,FPackageSpec,FStockLocNumberH,FStockID.FIsOpenLocation,FStockID.FName';
          Map<String, dynamic> dataMap = Map();
          dataMap['data'] = barcodeMap;
          String order = await CurrencyEntity.polling(dataMap);
          var barcodeData = jsonDecode(order);
          if (barcodeData.length > 0) {
            var msg = "";
            var orderIndex = 0;
            for (var value in orderDate) {
              if (value[5] == barcodeData[0][8]) {
                msg = "";
                if (fNumber.lastIndexOf(barcodeData[0][8]) == orderIndex) {
                  break;
                }
              } else {
                msg = '条码不在单据物料中';
              }
              orderIndex++;
            }
            if(this.fBillNo == null){
              if(this.storehouseNumber == null && this.hobby.length == 0){
                this.storehouseNumber = barcodeData[0][6];
                this.storehouseName = barcodeData[0][19];
                this.showPosition = barcodeData[0][18];
              }else{
                if(this.storehouseNumber != barcodeData[0][6]){
                  msg = '调出仓库与条码仓库不一致,请检查';
                }
              }
            }else{
              if(this.storehouseNumber == null){
                this.storehouseNumber = barcodeData[0][6];
                this.storehouseName = barcodeData[0][19];
                this.showPosition = barcodeData[0][18];
              }else{
                if(this.storehouseNumber != barcodeData[0][6]){
                  msg = '调出仓库与条码仓库不一致,请检查';
                }
              }
            }
            if (msg == "") {
              _code = event;
              this.fOrgID = barcodeData[0][15];
              this.getMaterialList(
                  barcodeData,
                  barcodeData[0][10],
                  barcodeData[0][11],
                  barcodeData[0][12].substring(0, 10),
                  barcodeData[0][13].substring(0, 10),
                  barcodeData[0][14],
                  barcodeData[0][17].trim(),
                  barcodeData[0][18]);
              print("ChannelPage: $event");
            } else {
              ToastUtil.showInfo(msg);
            }
          } else {
            ToastUtil.showInfo('条码不在条码清单中');
          }
        }
      } else {
        _code = event;
        if(this.fBillNo == '' || this.fBillNo == null){
          this.getMaterialListT("", _code, '', '', '', '', '', false);
        }else{
          ToastUtil.showInfo('无需扫码，请手工录入调拨数量');
        }
        print("ChannelPage: $event");
      }
    }
    print("ChannelPage: $event");
  }

  void _onError(Object error) {
    setState(() {
      _code = "扫描异常";
    });
  }

  getMaterialList(barcodeData, code, fsn, fProduceDate, fExpiryDate, fBatchNo, fLoc, fIsOpenLocation) async {
    Map<String, dynamic> userMap = Map();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var menuData = sharedPreferences.getString('MenuPermissions');
    var tissue = sharedPreferences.getString('tissue');
    var fStockIds = jsonDecode(sharedPreferences.getString('FStockIds'));
    var scanCode = code.split(";");
    Map<String, dynamic> stockMap = Map();
    stockMap['FormId'] = 'BD_STOCK';
    stockMap['FieldKeys'] =
    'FStockID,FName,FNumber,FIsOpenLocation,FFlexNumber';
    stockMap['FilterString'] = "FNumber = '" +
        barcodeData[0][6].split('/')[0] +
        "' and FUseOrgId.FNumber = '" +
        this.organizationsNumber1 +
        "'";
    Map<String, dynamic> stockDataMap = Map();
    stockDataMap['data'] = stockMap;
    String res = await CurrencyEntity.polling(stockDataMap);
    var stocks = jsonDecode(res);
    if (stocks.length > 0) {
      userMap['FilterString'] = "FMaterialId.FNumber='" +
          barcodeData[0][8] +
          "' and FStockID.FNumber='" +
          barcodeData[0][6].split('/')[0] +
          /*"' and FUseOrgId.FNumber = '" +
            deptData[1] +*/
          "'";
      if(barcodeData[0][7]){
        userMap['FilterString'] += " and FLot.FNumber = '" +
            fBatchNo +
            "' and FBaseQty > 0";
      }
      if (stocks[0][4] != null && barcodeData[0][17] != 0 ) {
        var position = barcodeData[0][17].split(".");
        userMap['FilterString'] += " and FStockLocId." +
            stocks[0][4] +
            ".FNumber = '" +
            position[0] +
            "'";
      }
    } else {
      ToastUtil.showInfo('条码仓库组织与调出组织不一致，请检查');
      return;
      /*userMap['FilterString'] = "FMaterialId.FNumber='" +
          barcodeData[0][8] +
          "' and FStockID.FNumber='" +
          barcodeData[0][6].split('/')[0] +
          *//*"' and FUseOrgId.FNumber = '" +
          deptData[1] +*//*
          "' and FLot.FNumber = '" +
          fBatchNo +
          "' and FBaseQty > 0";*/
    }
    userMap['FormId'] = 'STK_Inventory';
    userMap['FieldKeys'] =
    'FMATERIALID.FName,FMATERIALID.FNumber,FMATERIALID.FSpecification,FBaseUnitId.FName,FBaseUnitId.FNumber,FMATERIALID.FIsBatchManage,FLot.FNumber,FStockID.FNumber,FStockID.FName,FStockLocID,FStockLocID,FBaseQty,FProduceDate,FExpiryDate,FMATERIALID.FIsKFPeriod,FAuxPropId,FStockID.FIsOpenLocation';
    Map<String, dynamic> dataMap = Map();
    dataMap['data'] = userMap;
    String order = await CurrencyEntity.polling(dataMap);
    materialDate = [];
    materialDate = jsonDecode(order);

    if (materialDate.length > 0) {
      var number = 0;
      var barCodeScan;
      if (fBarCodeList == 1) {
        barCodeScan = barcodeData[0];
        barCodeScan[4] = barCodeScan[4].toString();
      } else {
        barCodeScan = scanCode;
      }
      var barcodeNum = barCodeScan[4];
      var barcodeQuantity = barCodeScan[4];
      var residue = double.parse(barCodeScan[4]);
      var hobbyIndex = 0;
      var errorTitle = "";
      for (var element in hobby) {
        var entryIndex;
        hobbyIndex++;
        print(entryIndex);
        //判断是否启用批号
        if (element[5]['isHide']) {
          //不启用  && element[4]['value']['value'] == barCodeScan[6]
          if (element[0]['value']['value'] == scanCode[0]) {
            if (element[0]['value']['barcode'].indexOf(code) == -1) {
              if (scanCode.length > 4) {
                element[0]['value']['barcode'].add(code);
              }

              if (scanCode[5] == "N") {
                if (element[0]['value']['scanCode'].indexOf(code) == -1) {
                  if (element[6]['value']['value'] == "") {
                    element[6]['value']['label'] = this.storehouseName == null? "":this.storehouseName;
                    element[6]['value']['value'] =this.storehouseNumber == null? "":this.storehouseNumber;
                  }
                  if(this.showPosition){
                    element[7]['value']['hide'] = this.showPosition;
                    if (element[7]['value']['value'] == "") {
                      element[7]['value']['label'] = fLoc == null? "":fLoc;
                      element[7]['value']['value'] = fLoc == null? "":fLoc;
                    }
                  }
                  if (element[11]['value']['value'] == "") {
                    element[11]['value']['label'] = fProduceDate == null? "":fProduceDate;
                    element[11]['value']['value'] =fProduceDate == null? "":fProduceDate;
                    element[12]['value']['label'] =fExpiryDate == null? "":fExpiryDate;
                    element[12]['value']['value'] =fExpiryDate == null? "":fExpiryDate;
                  }
                  //判断是否启用保质期
                  if (!element[11]['isHide']) {
                    if (element[11]['value']['value'] == fProduceDate &&
                        element[12]['value']['value'] == fExpiryDate) {
                      errorTitle = "";
                    } else {
                      errorTitle = "保质期不一致";
                      continue;
                    }
                  }
                  //判断是否启用仓位
                  if (element[7]['value']['hide']) {
                    if (element[7]['value']['label'] == fLoc) {
                      errorTitle = "";
                    } else {
                      errorTitle = "仓位不一致";
                      continue;
                    }
                  }

                  element[3]['value']['value'] =
                      (double.parse(element[3]['value']['value']) +
                          double.parse(barcodeNum))
                          .toString();
                  element[3]['value']['label'] = element[3]['value']['value'];
                  var item =
                      barCodeScan[0].toString() + "-" + barcodeNum + "-" + fsn;
                  element[0]['value']['kingDeeCode'].add(item);
                  element[0]['value']['scanCode'].add(code);
                  element[10]['value']['label'] = barcodeNum.toString();
                  element[10]['value']['value'] = barcodeNum.toString();
                  element[10]['value']['remainder'] = "0";
                  element[10]['value']['representativeQuantity'] = barcodeQuantity;
                  barcodeNum =
                      (double.parse(barcodeNum) - double.parse(barcodeNum))
                          .toString();
                }
                number++;
                break;
              }
              //判断扫描数量是否大于单据数量
              if (double.parse(element[3]['value']['value']) >=
                  element[4]['value']['label']) {
                continue;
              } else {
                //判断条码数量
                if ((double.parse(element[3]['value']['value']) + residue) >
                    0 &&
                    residue > 0) {
                  //判断条码是否重复
                  if (element[0]['value']['scanCode'].indexOf(code) == -1) {
                    if (element[6]['value']['value'] == "") {
                      element[6]['value']['label'] = this.storehouseName == null? "":this.storehouseName;
                      element[6]['value']['value'] =this.storehouseNumber == null? "":this.storehouseNumber;
                    }
                    if(this.showPosition){
                      element[7]['value']['hide'] = this.showPosition;
                      if (element[7]['value']['value'] == "") {
                        element[7]['value']['label'] = fLoc == null? "":fLoc;
                        element[7]['value']['value'] = fLoc == null? "":fLoc;
                      }
                    }
                    if (element[11]['value']['value'] == "") {
                      element[11]['value']['label'] = fProduceDate == null? "":fProduceDate;
                      element[11]['value']['value'] =fProduceDate == null? "":fProduceDate;
                      element[12]['value']['label'] =fExpiryDate == null? "":fExpiryDate;
                      element[12]['value']['value'] =fExpiryDate == null? "":fExpiryDate;
                    }
                    //判断是否启用保质期
                    if (!element[11]['isHide']) {
                      if (element[11]['value']['value'] == fProduceDate &&
                          element[12]['value']['value'] == fExpiryDate) {
                        errorTitle = "";
                      } else {
                        errorTitle = "保质期不一致";
                        continue;
                      }
                    }
                    //判断是否启用仓位
                    if (element[7]['value']['hide']) {
                      if (element[7]['value']['label'] == fLoc) {
                        errorTitle = "";
                      } else {
                        errorTitle = "仓位不一致";
                        continue;
                      }
                    }

                    //判断末尾
                    /*if (fNumber.lastIndexOf(
                            element[0]['value']['value'].toString()) ==
                        (hobbyIndex - 1)) {
                      var item = barCodeScan[0].toString() +
                          "-" +
                          residue.toString() +
                          "-" +
                          fsn;
                      element[10]['value']['label'] = residue.toString();
                      element[10]['value']['value'] = residue.toString();
                      element[3]['value']['label'] =
                          (double.parse(element[3]['value']['value']) + residue)
                              .toString();
                      element[3]['value']['value'] =
                          element[3]['value']['label'];
                      residue = (residue * 100 -
                              double.parse(element[10]['value']['value']) *
                                  100) /
                          100;
                      element[0]['value']['surplus'] =
                          (element[4]['value']['value'] * 100 -
                                  double.parse(element[3]['value']['value']) *
                                      100) /
                              100;
                      element[0]['value']['kingDeeCode'].add(item);
                      element[0]['value']['scanCode'].add(code);
                    } else {*/
                    //判断剩余数量是否大于扫码数量
                    if (element[0]['value']['surplus'] >= residue) {
                      var item = barCodeScan[0].toString() +
                          "-" +
                          residue.toString() +
                          "-" +
                          fsn;
                      element[10]['value']['label'] = residue.toString();
                      element[10]['value']['value'] = residue.toString();
                      element[10]['value']['remainder'] = "0";
                      element[10]['value']['representativeQuantity'] = barcodeQuantity;
                      element[3]['value']['label'] =
                          (double.parse(element[3]['value']['value']) +
                              residue)
                              .toString();
                      element[3]['value']['value'] =
                      element[3]['value']['label'];
                      residue = 0.0;
                      element[0]['value']['surplus'] =
                          (element[4]['value']['value'] * 100 -
                              double.parse(element[3]['value']['value']) *
                                  100) /
                              100;
                      element[0]['value']['kingDeeCode'].add(item);
                      element[0]['value']['scanCode'].add(code);
                      number++;
                      break;
                    } else {
                      var item = barCodeScan[0].toString() +
                          "-" +
                          element[0]['value']['surplus'].toString() +
                          "-" +
                          fsn;
                      element[10]['value']['label'] =
                          element[0]['value']['surplus'].toString();
                      element[10]['value']['value'] =
                          element[0]['value']['surplus'].toString();

                      element[3]['value']['label'] = (element[0]['value']['surplus'] +
                          double.parse(element[3]['value']['value']))
                          .toString();
                      element[3]['value']['value'] =
                      element[3]['value']['label'];
                      residue = (residue * 100 -
                          double.parse(element[10]['value']['value']) *
                              100) /
                          100;
                      element[0]['value']['surplus'] =
                          (element[4]['value']['value'] * 100 -
                              double.parse(element[3]['value']['value']) *
                                  100) /
                              100;
                      element[10]['value']['remainder'] = residue.toString();
                      element[10]['value']['representativeQuantity'] = barcodeQuantity;
                      element[0]['value']['kingDeeCode'].add(item);
                      element[0]['value']['scanCode'].add(code);
                      number++;
                    }
                    // }
                  }
                }
              }
            } else {
              ToastUtil.showInfo('该标签已扫描');
              number++;
              break;
            }
          }
        } else {
          //启用批号 && element[4]['value']['value'] == barCodeScan[6]
          if (element[0]['value']['value'] == scanCode[0]) {
            if (element[0]['value']['barcode'].indexOf(code) == -1) {
              if (scanCode.length > 4) {
                element[0]['value']['barcode'].add(code);
              }
              if (scanCode[5] == "N") {
                if (element[0]['value']['scanCode'].indexOf(code) == -1) {
                  if (element[6]['value']['value'] == "") {
                    element[6]['value']['label'] = this.storehouseName == null? "":this.storehouseName;
                    element[6]['value']['value'] =this.storehouseNumber == null? "":this.storehouseNumber;
                  }
                  if(this.showPosition){
                    element[7]['value']['hide'] = this.showPosition;
                    if (element[7]['value']['value'] == "") {
                      element[7]['value']['label'] = fLoc == null? "":fLoc;
                      element[7]['value']['value'] = fLoc == null? "":fLoc;
                    }
                  }
                  if (element[11]['value']['value'] == "") {
                    element[11]['value']['label'] = fProduceDate == null? "":fProduceDate;
                    element[11]['value']['value'] =fProduceDate == null? "":fProduceDate;
                    element[12]['value']['label'] =fExpiryDate == null? "":fExpiryDate;
                    element[12]['value']['value'] =fExpiryDate == null? "":fExpiryDate;
                  }
                  //判断是否启用保质期
                  if (!element[11]['isHide']) {
                    if (element[11]['value']['value'] == fProduceDate &&
                        element[12]['value']['value'] == fExpiryDate) {
                      errorTitle = "";
                    } else {
                      errorTitle = "保质期不一致";
                      continue;
                    }
                  }
                  //判断是否启用仓位
                  if (element[7]['value']['hide']) {
                    if (element[7]['value']['label'] == fLoc) {
                      errorTitle = "";
                    } else {
                      errorTitle = "仓位不一致";
                      continue;
                    }
                  }

                  element[3]['value']['value'] =
                      (double.parse(element[3]['value']['value']) +
                          double.parse(barcodeNum))
                          .toString();
                  element[3]['value']['label'] = element[3]['value']['value'];
                  var item =
                      barCodeScan[0].toString() + "-" + barcodeNum + "-" + fsn;
                  element[0]['value']['kingDeeCode'].add(item);
                  element[0]['value']['scanCode'].add(code);
                  element[10]['value']['label'] = barcodeNum.toString();
                  element[10]['value']['value'] = barcodeNum.toString();
                  element[10]['value']['remainder'] = "0";
                  element[10]['value']['representativeQuantity'] = barcodeQuantity;
                  barcodeNum =
                      (double.parse(barcodeNum) - double.parse(barcodeNum))
                          .toString();
                }
                number++;
                break;
              }
              if (element[5]['value']['value'] == scanCode[1]) {
                //判断扫描数量是否大于单据数量
                if (double.parse(element[3]['value']['value']) >=
                    element[4]['value']['label']) {
                  continue;
                } else {
                  //判断条码数量
                  if ((double.parse(element[3]['value']['value']) + residue) >
                      0 &&
                      residue > 0) {

                    //判断条码是否重复
                    if (element[0]['value']['scanCode'].indexOf(code) == -1) {
                      if (element[6]['value']['value'] == "") {
                        element[6]['value']['label'] = this.storehouseName == null? "":this.storehouseName;
                        element[6]['value']['value'] =this.storehouseNumber == null? "":this.storehouseNumber;
                      }
                      if(this.showPosition){
                        element[7]['value']['hide'] = this.showPosition;
                        if (element[7]['value']['value'] == "") {
                          element[7]['value']['label'] = fLoc == null? "":fLoc;
                          element[7]['value']['value'] = fLoc == null? "":fLoc;
                        }
                      }
                      if (element[11]['value']['value'] == "") {
                        element[11]['value']['label'] = fProduceDate == null? "":fProduceDate;
                        element[11]['value']['value'] =fProduceDate == null? "":fProduceDate;
                        element[12]['value']['label'] =fExpiryDate == null? "":fExpiryDate;
                        element[12]['value']['value'] =fExpiryDate == null? "":fExpiryDate;
                      }
                      //判断是否启用保质期
                      if (!element[11]['isHide']) {
                        if (element[11]['value']['value'] == fProduceDate &&
                            element[12]['value']['value'] == fExpiryDate) {
                          errorTitle = "";
                        } else {
                          errorTitle = "保质期不一致";
                          continue;
                        }
                      }
                      //判断是否启用仓位
                      if (element[7]['value']['hide']) {
                        if (element[7]['value']['label'] == fLoc) {
                          errorTitle = "";
                        } else {
                          errorTitle = "仓位不一致";
                          continue;
                        }
                      }

                      //判断末尾
                      /*if (fNumber.lastIndexOf(
                              element[0]['value']['value'].toString()) ==
                          (hobbyIndex - 1)) {
                        var item = barCodeScan[0].toString() +
                            "-" +
                            residue.toString() +
                            "-" +
                            fsn;
                        element[10]['value']['label'] = residue.toString();
                        element[10]['value']['value'] = residue.toString();
                        element[3]['value']['label'] =
                            (double.parse(element[3]['value']['value']) +
                                    residue)
                                .toString();
                        element[3]['value']['value'] =
                            element[3]['value']['label'];
                        residue = (residue * 100 -
                                double.parse(element[10]['value']['value']) *
                                    100) /
                            100;
                        element[0]['value']['surplus'] =
                            (element[4]['value']['value'] * 100 -
                                    double.parse(element[3]['value']['value']) *
                                        100) /
                                100;
                        ;
                        element[0]['value']['kingDeeCode'].add(item);
                        element[0]['value']['scanCode'].add(code);
                      } else {*/
                      //判断剩余数量是否大于扫码数量
                      if (element[0]['value']['surplus'] >= residue) {
                        var item = barCodeScan[0].toString() +
                            "-" +
                            residue.toString() +
                            "-" +
                            fsn;
                        element[10]['value']['label'] = residue.toString();
                        element[10]['value']['value'] = residue.toString();
                        element[10]['value']['remainder'] = "0";
                        element[10]['value']['representativeQuantity'] = barcodeQuantity;
                        element[3]['value']['label'] =
                            (double.parse(element[3]['value']['value']) +
                                residue)
                                .toString();
                        element[3]['value']['value'] =
                        element[3]['value']['label'];
                        residue = 0.0;
                        element[0]['value']['surplus'] = (element[4]['value']
                        ['value'] *
                            100 -
                            double.parse(element[3]['value']['value']) *
                                100) /
                            100;
                        element[0]['value']['kingDeeCode'].add(item);
                        element[0]['value']['scanCode'].add(code);
                        number++;
                        break;
                      } else {
                        var item = barCodeScan[0].toString() +
                            "-" +
                            element[0]['value']['surplus'].toString() +
                            "-" +
                            fsn;
                        element[10]['value']['label'] =
                            element[0]['value']['surplus'].toString();
                        element[10]['value']['value'] =
                            element[0]['value']['surplus'].toString();
                        element[3]['value']['label'] = (element[0]['value']['surplus'] +
                            double.parse(element[3]['value']['value']))
                            .toString();
                        element[3]['value']['value'] =
                        element[3]['value']['label'];
                        residue = (residue * 100 -
                            double.parse(element[10]['value']['value']) *
                                100) /
                            100;
                        element[0]['value']['surplus'] = (element[4]['value']
                        ['value'] *
                            100 -
                            double.parse(element[3]['value']['value']) *
                                100) /
                            100;
                        element[10]['value']['remainder'] = residue.toString();
                        element[10]['value']['representativeQuantity'] = barcodeQuantity;
                        element[0]['value']['kingDeeCode'].add(item);
                        element[0]['value']['scanCode'].add(code);
                        number++;
                      }
                      //}
                    }
                  }
                }
              } else {
                if (element[5]['value']['value'] == "") {
                  element[5]['value']['label'] = scanCode[1];
                  element[5]['value']['value'] = scanCode[1];
                  //判断扫描数量是否大于单据数量
                  if (double.parse(element[3]['value']['value']) >=
                      element[4]['value']['label']) {
                    continue;
                  } else {
                    //判断条码数量
                    if ((double.parse(element[3]['value']['value']) + residue) >
                        0 &&
                        residue > 0) {

                      //判断条码是否重复
                      if (element[0]['value']['scanCode'].indexOf(code) == -1) {
                        if (element[6]['value']['value'] == "") {
                          element[6]['value']['label'] = this.storehouseName == null? "":this.storehouseName;
                          element[6]['value']['value'] =this.storehouseNumber == null? "":this.storehouseNumber;
                        }
                        if(this.showPosition){
                          element[7]['value']['hide'] = this.showPosition;
                          if (element[7]['value']['value'] == "") {
                            element[7]['value']['label'] = fLoc == null? "":fLoc;
                            element[7]['value']['value'] = fLoc == null? "":fLoc;
                          }
                        }
                        if (element[11]['value']['value'] == "") {
                          element[11]['value']['label'] = fProduceDate == null? "":fProduceDate;
                          element[11]['value']['value'] =fProduceDate == null? "":fProduceDate;
                          element[12]['value']['label'] =fExpiryDate == null? "":fExpiryDate;
                          element[12]['value']['value'] =fExpiryDate == null? "":fExpiryDate;
                        }
                        //判断是否启用保质期
                        if (!element[11]['isHide']) {
                          if (element[11]['value']['value'] == fProduceDate &&
                              element[12]['value']['value'] == fExpiryDate) {
                            errorTitle = "";
                          } else {
                            errorTitle = "保质期不一致";
                            continue;
                          }
                        }
                        //判断是否启用仓位
                        if (element[7]['value']['hide']) {
                          if (element[7]['value']['label'] == fLoc) {
                            errorTitle = "";
                          } else {
                            errorTitle = "仓位不一致";
                            continue;
                          }
                        }

                        //判断末尾
                        /* if (fNumber.lastIndexOf(
                                element[0]['value']['value'].toString()) ==
                            (hobbyIndex - 1)) {
                          var item = barCodeScan[0].toString() +
                              "-" +
                              residue.toString() +
                              "-" +
                              fsn;
                          element[10]['value']['label'] = residue.toString();
                          element[10]['value']['value'] = residue.toString();
                          element[3]['value']['label'] =
                              (double.parse(element[3]['value']['value']) +
                                      residue)
                                  .toString();
                          element[3]['value']['value'] =
                              element[3]['value']['label'];
                          residue = (residue * 100 -
                                  double.parse(element[10]['value']['value']) *
                                      100) /
                              100;
                          element[0]['value']['surplus'] = (element[4]['value']
                                          ['value'] *
                                      100 -
                                  double.parse(element[3]['value']['value']) *
                                      100) /
                              100;
                          ;
                          element[0]['value']['kingDeeCode'].add(item);
                          element[0]['value']['scanCode'].add(code);
                        } else {*/
                        //判断剩余数量是否大于扫码数量
                        if (element[0]['value']['surplus'] >= residue) {
                          var item = barCodeScan[0].toString() +
                              "-" +
                              residue.toString() +
                              "-" +
                              fsn;
                          element[10]['value']['label'] = residue.toString();
                          element[10]['value']['value'] = residue.toString();
                          element[10]['value']['remainder'] = "0";
                          element[10]['value']['representativeQuantity'] = barcodeQuantity;
                          element[3]['value']['label'] =
                              (double.parse(element[3]['value']['value']) +
                                  residue)
                                  .toString();
                          element[3]['value']['value'] =
                          element[3]['value']['label'];
                          residue = 0.0;
                          element[0]['value']['surplus'] = (element[4]
                          ['value']['value'] *
                              100 -
                              double.parse(element[3]['value']['value']) *
                                  100) /
                              100;
                          element[0]['value']['kingDeeCode'].add(item);
                          element[0]['value']['scanCode'].add(code);
                          number++;
                          break;
                        } else {
                          var item = barCodeScan[0].toString() +
                              "-" +
                              element[0]['value']['surplus'].toString() +
                              "-" +
                              fsn;
                          element[10]['value']['label'] =
                              element[0]['value']['surplus'].toString();
                          element[10]['value']['value'] =
                              element[0]['value']['surplus'].toString();

                          element[3]['value']['label'] = (element[0]['value']['surplus'] +
                              double.parse(element[3]['value']['value']))
                              .toString();
                          element[3]['value']['value'] =
                          element[3]['value']['label'];
                          residue = (residue * 100 -
                              double.parse(
                                  element[10]['value']['value']) *
                                  100) /
                              100;
                          element[0]['value']['surplus'] = (element[4]
                          ['value']['value'] *
                              100 -
                              double.parse(element[3]['value']['value']) *
                                  100) /
                              100;
                          element[10]['value']['remainder'] = residue.toString();
                          element[10]['value']['representativeQuantity'] = barcodeQuantity;
                          element[0]['value']['kingDeeCode'].add(item);
                          element[0]['value']['scanCode'].add(code);
                          number++;
                        }
                        //}
                      }
                    }
                  }
                }
              }
            } else {
              ToastUtil.showInfo('该标签已扫描');
              number++;
              break;
            }
          }
        }
      }
      setState(() {
        EasyLoading.dismiss();
      });
      if (number == 0 && this.fBillNo == "") {
        for (var value in materialDate) {
          List arr = [];
          arr.add({
            "title": "物料名称",
            "name": "FMaterial",
            "isHide": false,
            "value": {
              "label": value[0] + "- (" + value[1] + ")",
              "value": value[1],
              "barcode": [code],
              "kingDeeCode": [barCodeScan[0].toString()+"-"+barcodeNum.toString()+"-"+fsn],"scanCode": [barCodeScan[0].toString()+"-"+barcodeNum.toString()],
              "codeList": []
            }
          });
          arr.add({
            "title": "规格型号",
            "isHide": false,
            "name": "FMaterialIdFSpecification",
            "value": {"label": value[2], "value": value[2]}
          });
          arr.add({
            "title": "单位名称",
            "name": "FUnitId",
            "isHide": false,
            "value": {"label": value[3], "value": value[4]}
          });
          arr.add({
            "title": "调拨数量",
            "name": "FRemainOutQty",
            "isHide": false,
            "value": {"label": barcodeNum, "value": barcodeNum}
          });
          arr.add({
            "title": "申请数量",
            "name": "FRealQty",
            "isHide": false,
            "value": {"label": double.parse(barcodeNum), "value": double.parse(barcodeNum)}
          });
          arr.add({
            "title": "批号",
            "name": "FLot",
            "isHide": value[5] != true,
            "value": {"label": value[6], "value": value[6]}
          });
          arr.add({
            "title": "调出仓库",
            "name": "FStockID",
            "isHide": false,
            "value": {"label": value[8], "value": value[7], 'dimension': ""}
          });
          arr.add({
            "title": "调出仓位",
            "name": "FStockLocID",
            "isHide": false,
            "value": {"label": barcodeData[0][17], "value": barcodeData[0][17], "hide": value[16]}
          });
          arr.add({
            "title": "调入仓库",
            "name": "FStockID",
            "isHide": false,
            "value": {"label": this.storehouseName == null? "":this.storehouseName, "value": this.storehouseNumber == null? "":this.storehouseNumber, "dimension": stocks[0][4]}
          });
          arr.add({
            "title": "调入仓位",
            "name": "FStockLocID",
            "isHide": false,
            "value": {"label": this.storingLocationName == null? "":this.storingLocationName, "value": this.storingLocationNumber == null? "":this.storingLocationNumber, "hide": showPosition}
          });
          arr.add({
            "title": "最后扫描数量",
            "name": "FLastQty",
            "isHide": false,
            "value": {
              "label": barcodeNum.toString(),
              "value": barcodeNum.toString(),"remainder": "0","representativeQuantity": barCodeScan[4].toString()
            }
          });
          arr.add({
            "title": "生产日期",
            "name": "FProduceDate",
            "isHide": value[14] != true,
            "value": {
              "label": value[12] == null ? '' : value[12].substring(0, 10),
              "value": value[12] == null ? '' : value[12].substring(0, 10)
            }
          });
          arr.add({
            "title": "有效期至",
            "name": "FExpiryDate",
            "isHide": value[14] != true,
            "value": {
              "label": value[13] == null ? '' : value[13].substring(0, 10),
              "value": value[13] == null ? '' : value[13].substring(0, 10)
            }
          });
          arr.add({
            "title": "操作",
            "name": "",
            "isHide": false,
            "value": {"label": "", "value": ""}
          });
          if(fStockIds.length>0){
            Map<String, dynamic> inventoryMap = Map();
            inventoryMap['FormId'] = 'STK_Inventory';
            inventoryMap['FilterString'] =
                "FMaterialId.FNumber='" + value[1] + "' and FBaseQty >0 and FStockOrgID.FNumber = '" +tissue + "'";
            inventoryMap['Limit'] = '50';
            inventoryMap['OrderString'] = 'FLot.FNumber DESC, FProduceDate DESC';
            inventoryMap['FieldKeys'] =
            'FMaterialId.FNumber,FMaterialId.FName,FMaterialId.FSpecification,FStockId.FName,FBaseQty,FLot.FNumber,FAuxPropId,FProduceDate,FExpiryDate';
            for(var flex in fStockIds){
              inventoryMap['FieldKeys'] += ",FStockLocId."+flex[4]+".FNumber";
            }
            Map<String, dynamic> inventoryDataMap = Map();
            inventoryDataMap['data'] = inventoryMap;
            String res = await CurrencyEntity.polling(inventoryDataMap);
            var stocks = jsonDecode(res);
            if (stocks.length > 0) {
              arr.add({
                "title": "库存",
                "name": "FLot",
                "isHide": false,
                "value": {"label": '', "value": '', "fLotList": stocks}
              });
            } else {
              arr.add({
                "title": "库存",
                "name": "FLot",
                "isHide": false,
                "value": {"label": '', "value": '', "fLotList": []}
              });
            }
          }else{
            Map<String, dynamic> inventoryMap = Map();
            inventoryMap['FormId'] = 'STK_Inventory';
            inventoryMap['FilterString'] =
                "FMaterialId.FNumber='" + value[1] + "' and FBaseQty >0 and FStockOrgID.FNumber = '" +tissue + "'";
            inventoryMap['Limit'] = '50';
            inventoryMap['OrderString'] = 'FLot.FNumber DESC, FProduceDate DESC';
            inventoryMap['FieldKeys'] =
            'FMaterialId.FNumber,FMaterialId.FName,FMaterialId.FSpecification,FStockId.FName,FBaseQty,FLot.FNumber,FAuxPropId,FProduceDate,FExpiryDate';
            Map<String, dynamic> inventoryDataMap = Map();
            inventoryDataMap['data'] = inventoryMap;
            String res = await CurrencyEntity.polling(inventoryDataMap);
            var stocks = jsonDecode(res);
            if (stocks.length > 0) {
              arr.add({
                "title": "库存",
                "name": "FLot",
                "isHide": false,
                "value": {"label": '', "value": '', "fLotList": stocks}
              });
            } else {
              arr.add({
                "title": "库存",
                "name": "FLot",
                "isHide": false,
                "value": {"label": '', "value": '', "fLotList": []}
              });
            }
          }
          hobby.add(arr);
        };
      }
      setState(() {
        EasyLoading.dismiss();
        this._getHobby();
      });
    } else {
      setState(() {
        EasyLoading.dismiss();
        this._getHobby();
      });
      ToastUtil.showInfo('无数据');
    }
  }
  getMaterialListT(barcodeData, code, fsn, fProduceDate, fExpiryDate, fBatchNo, fLoc, fIsOpenLocation) async {
    Map<String, dynamic> userMap = Map();
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var tissue = sharedPreferences.getString('tissue');
    var fStockIds = jsonDecode(sharedPreferences.getString('FStockIds'));
    var scanCode = code.split(";");
    userMap['FilterString'] = "FNumber='" + scanCode[0] + "' and FForbidStatus = 'A' and FUseOrgId.FNumber = '"+tissue+"'";
    userMap['FormId'] = 'BD_MATERIAL';
    userMap['FieldKeys'] =
    'FMATERIALID,FName,FNumber,FSpecification,FBaseUnitId.FName,FBaseUnitId.FNumber,FIsBatchManage,FIsKFPeriod';
    Map<String, dynamic> dataMap = Map();
    dataMap['data'] = userMap;
    String order = await CurrencyEntity.polling(dataMap);
    materialDate = [];
    materialDate = jsonDecode(order);
    if (materialDate.length > 0) {
      var number = 0;
      var barCodeScan;
      if (fBarCodeList == 1) {
        barCodeScan = barcodeData[0];
        barCodeScan[4] = barCodeScan[4].toString();
      } else {
        barCodeScan = scanCode;
      }
      setState(() {
        EasyLoading.dismiss();
      });
      if (number == 0 && this.fBillNo == "") {
        for (var value in materialDate) {
          List arr = [];
          arr.add({
            "title": "物料名称",
            "name": "FMaterial",
            "isHide": false,
            "value": {
              "label": value[1] + "- (" + value[2] + ")",
              "value": value[2],
              "barcode": [code],
              "kingDeeCode": [barCodeScan[0].toString()+"-"+number.toString()+"-"+fsn],"scanCode": [barCodeScan[0].toString()+"-"+number.toString()],
              "codeList": []
            }
          });
          arr.add({
            "title": "规格型号",
            "isHide": false,
            "name": "FMaterialIdFSpecification",
            "value": {"label": value[3], "value": value[3]}
          });
          arr.add({
            "title": "单位名称",
            "name": "FUnitId",
            "isHide": false,
            "value": {"label": value[4], "value": value[5]}
          });
          arr.add({
            "title": "调拨数量",
            "name": "FRemainOutQty",
            "isHide": false,
            "value": {"label": "0", "value": "0"}
          });
          arr.add({
            "title": "申请数量",
            "name": "FRealQty",
            "isHide": true,
            "value": {"label": 0, "value": 0}
          });
          arr.add({
            "title": "批号",
            "name": "FLot",
            "isHide": value[6] != true,
            "value": {"label": "", "value": ""}
          });
          arr.add({
            "title": "调出仓库",
            "name": "FStockID",
            "isHide": false,
            "value": {"label": this.storehouseName == null? "":this.storehouseName, "value": this.storehouseNumber == null? "":this.storehouseNumber, "dimension": ""}
          });
          arr.add({
            "title": "调出仓位",
            "name": "FStockLocID",
            "isHide": false,
            "value": {"label": "", "value": "", "hide": showPosition}
          });
          arr.add({
            "title": "调入仓库",
            "name": "FStockID",
            "isHide": false,
            "value": {"label": this.storehouseNameT == null? "":this.storehouseNameT, "value": this.storehouseNumberT == null? "":this.storehouseNumberT, "dimension": ""}
          });
          arr.add({
            "title": "调入仓位",
            "name": "FStockLocID",
            "isHide": false,
            "value": {"label": "", "value": "", "hide": showPositionT}
          });
          arr.add({
            "title": "最后扫描数量",
            "name": "FLastQty",
            "isHide": true,
            "value": {
              "label": "0",
              "value": "0","remainder": "0","representativeQuantity": "0"
            }
          });
          arr.add({
            "title": "生产日期",
            "name": "FProduceDate",
            "isHide": value[7] != true,
            "value": {
              "label": '',
              "value": ''
            }
          });
          arr.add({
            "title": "有效期至",
            "name": "FExpiryDate",
            "isHide": value[7] != true,
            "value": {
              "label": '',
              "value": ''
            }
          });
          arr.add({
            "title": "操作",
            "name": "",
            "isHide": false,
            "value": {"label": "", "value": ""}
          });
          if(fStockIds.length>0){
            Map<String, dynamic> inventoryMap = Map();
            inventoryMap['FormId'] = 'STK_Inventory';
            inventoryMap['FilterString'] =
                "FMaterialId.FNumber='" + value[2] + "' and FBaseQty >0 and FStockOrgID.FNumber = '" +tissue + "'";
            inventoryMap['Limit'] = '50';
            inventoryMap['OrderString'] = 'FLot.FNumber DESC, FProduceDate DESC';
            inventoryMap['FieldKeys'] =
            'FMaterialId.FNumber,FMaterialId.FName,FMaterialId.FSpecification,FStockId.FName,FBaseQty,FLot.FNumber,FAuxPropId,FProduceDate,FExpiryDate';
            for(var flex in fStockIds){
              inventoryMap['FieldKeys'] += ",FStockLocId."+flex[4]+".FNumber";
            }
            Map<String, dynamic> inventoryDataMap = Map();
            inventoryDataMap['data'] = inventoryMap;
            String res = await CurrencyEntity.polling(inventoryDataMap);
            var stocks = jsonDecode(res);
            if (stocks.length > 0) {
              arr.add({
                "title": "库存",
                "name": "FLot",
                "isHide": false,
                "value": {"label": '', "value": '', "fLotList": stocks}
              });
            } else {
              arr.add({
                "title": "库存",
                "name": "FLot",
                "isHide": false,
                "value": {"label": '', "value": '', "fLotList": []}
              });
            }
          }else{
            Map<String, dynamic> inventoryMap = Map();
            inventoryMap['FormId'] = 'STK_Inventory';
            inventoryMap['FilterString'] =
                "FMaterialId.FNumber='" + value[2] + "' and FBaseQty >0 and FStockOrgID.FNumber = '" +tissue + "'";
            inventoryMap['Limit'] = '50';
            inventoryMap['OrderString'] = 'FLot.FNumber DESC, FProduceDate DESC';
            inventoryMap['FieldKeys'] =
            'FMaterialId.FNumber,FMaterialId.FName,FMaterialId.FSpecification,FStockId.FName,FBaseQty,FLot.FNumber,FAuxPropId,FProduceDate,FExpiryDate';
            Map<String, dynamic> inventoryDataMap = Map();
            inventoryDataMap['data'] = inventoryMap;
            String res = await CurrencyEntity.polling(inventoryDataMap);
            var stocks = jsonDecode(res);
            if (stocks.length > 0) {
              arr.add({
                "title": "库存",
                "name": "FLot",
                "isHide": false,
                "value": {"label": '', "value": '', "fLotList": stocks}
              });
            } else {
              arr.add({
                "title": "库存",
                "name": "FLot",
                "isHide": false,
                "value": {"label": '', "value": '', "fLotList": []}
              });
            }
          }
          hobby.add(arr);
        };
      }
      setState(() {
        EasyLoading.dismiss();
        this._getHobby();
      });
    } else {
      setState(() {
        EasyLoading.dismiss();
        this._getHobby();
      });
      ToastUtil.showInfo('无数据');
    }
  }

  Widget _item(title, var data, selectData, hobby, {String? label, var stock}) {
    if (selectData == null) {
      selectData = "";
    }
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: ListTile(
            title: Text(title),
            onTap: () => data.length > 0
                ? _onClickItem(data, selectData, hobby,
                label: label, stock: stock)
                : {ToastUtil.showInfo('无数据')},
            trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
              MyText(selectData.toString() == "" ? '暂无' : selectData.toString(),
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
                    (PicketUtil.strEmpty(selectData[model])
                        ? '暂无'
                        : selectData[model])!,
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
        print('longer >>> 返回数据：$p');
        setState(() {
          switch (model) {
            case DateMode.YMD:
              selectData[model] = formatDate(
                  DateFormat('yyyy-MM-dd')
                      .parse('${p.year}-${p.month}-${p.day}'),
                  [
                    yyyy,
                    "-",
                    mm,
                    "-",
                    dd,
                  ]);
              FDate = formatDate(
                  DateFormat('yyyy-MM-dd')
                      .parse('${p.year}-${p.month}-${p.day}'),
                  [
                    yyyy,
                    "-",
                    mm,
                    "-",
                    dd,
                  ]);
              break;
          }
        });
      },
      // onChanged: (p) => print(p),
    );
  }
  // 1. 分离对话框显示逻辑
  void _showConfirmationDialog(type, name, number, isLoc) {
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      final result = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: new Text(
                "当前不支持同一张单不同调入或调出仓库调拨，仓库切换将清空已存在列表，是否确定！"),
            actions: <Widget>[
              new FlatButton(
                child: new Text('不了'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: new Text('确定'),
                onPressed: () {
                  if(type == 2){
                    storehouseNameT = name;
                    storehouseNumberT = number;
                    showPositionT = isLoc;
                    for(var hItem in this.hobby){
                      hItem[8]['value']['label'] = storehouseNameT;
                      hItem[8]['value']['value'] = storehouseNumberT;
                      hItem[9]['value']['label'] = "";
                      hItem[9]['value']['value'] = "";
                      hItem[9]['value']['hide'] = showPositionT;
                    }
                  }else{
                    storehouseName = name;
                    storehouseNumber = number;
                    showPosition = isLoc;
                    for(var hItem in this.hobby){
                      hItem[6]['value']['label'] = storehouseName;
                      hItem[6]['value']['value'] = storehouseNumber;
                      hItem[7]['value']['label'] = "";
                      hItem[7]['value']['value'] = "";
                      hItem[7]['value']['hide'] = showPosition;
                    }
                  }
                  //提交清空页面
                  setState(() {
                    Navigator.of(context).pop();
                  });
                },
              )
            ],
          )
      );
    });
  }
  void _onClickItem(var data, var selectData, hobby,
      {String? label, var stock}) {
    Pickers.showSinglePicker(
      context,
      data: data,
      selectData: selectData,
      pickerStyle: DefaultPickerStyle(),
      suffix: label,
      onConfirm: (p) {
        print('longer >>> 返回数据：$p');
        print('longer >>> 返回数据类型：${p.runtimeType}');
        if (hobby == 'organizations1') {
          organizationsName1 = p;
          var elementIndex = 0;
          data.forEach((element) {
            if (element == p) {
              organizationsNumber1 = organizationsListObj[elementIndex][2];
            }
            elementIndex++;
          });
          print(1);
          print(organizationsNumber1);
        } else if (hobby == 'organizations2') {
          organizationsName2 = p;
          var elementIndex = 0;
          data.forEach((element) {
            if (element == p) {
              organizationsNumber2 = organizationsListObj[elementIndex][2];
            }
            elementIndex++;
          });
          this.getStockListT();
          print(2);
          print(organizationsNumber2);
        }else if (hobby == 'storehouse') {

          var elementIndex = 0;
          for(var element in data){
            if (element == p) {
              if(storehouseNumber != stockListObj[elementIndex][2] && storehouseNumber != null){
                _showConfirmationDialog(1, p, stockListObj[elementIndex][2], stockListObj[elementIndex][3]);
                return;
              }else{
                storehouseName = p;
                storehouseNumber = stockListObj[elementIndex][2];
                showPosition = stockListObj[elementIndex][3];
                this.storingLocationName = "";
                this.storingLocationNumber = "";
                for(var hItem in this.hobby){
                  if(hItem[6]['value']['value'] == ""){
                    hItem[6]['value']['label'] = storehouseName;
                    hItem[6]['value']['value'] = storehouseNumber;
                    hItem[7]['value']['hide'] = showPosition;
                  }
                }
              }
            }
            elementIndex++;
          }
        }else if (hobby == 'storehouseT') {
          var elementIndex = 0;
          for(var element in data){
            if (element == p) {
              if(storehouseNumberT != stockListObjT[elementIndex][2] && storehouseNumberT != null){
                _showConfirmationDialog(2, p, stockListObjT[elementIndex][2], stockListObjT[elementIndex][3]);
                return;
              }else{
                storehouseNameT = p;
                storehouseNumberT = stockListObjT[elementIndex][2];
                showPositionT = stockListObjT[elementIndex][3];
                for(var hItem in this.hobby){
                  if(hItem[8]['value']['value'] == ""){
                    hItem[8]['value']['label'] = storehouseNameT;
                    hItem[8]['value']['value'] = storehouseNumberT;
                    hItem[9]['value']['hide'] = showPositionT;
                  }
                }
              }
            }
            elementIndex++;
          }
        } else if(hobby['title']=="调出仓库"){
          hobby['value']['label'] = p;
          var elementIndex = 0;
          print(data);
          data.forEach((element) {
            if (element == p) {
              hobby['value']['value'] = stockListObj[elementIndex][2];
              stock[7]['value']['hide'] = stockListObj[elementIndex][3];
              stock[7]['value']['value'] = "";
              stock[7]['value']['label'] = "";
              //hobby['value']['dimension'] = stockListObj[elementIndex][4];
            }
            elementIndex++;
          });
        }else{
          hobby['value']['label'] = p;
          var elementIndex = 0;
          print(data);
          data.forEach((element) {
            if (element == p) {
              hobby['value']['value'] = stockListObjT[elementIndex][2];
              stock[9]['value']['hide'] = stockListObjT[elementIndex][3];
              stock[9]['value']['value'] = "";
              stock[9]['value']['label'] = "";
              //hobby['value']['dimension'] = stockListObj[elementIndex][4];
            }
            elementIndex++;
          });
        }
        setState(() {
        });
      },
    );
  }
  setClickData(List<dynamic> dataItem, int type) async{
    setState(() {
      if(type == 1){
        if(storehouseNumber != dataItem[2] && storehouseNumber != null){
          _showConfirmationDialog(1, dataItem[1], dataItem[2], dataItem[3]);
          return;
        }else{
          storehouseName = dataItem[1];
          storehouseNumber =dataItem[2];
          showPosition = dataItem[3];
          this.storingLocationName = "";
          this.storingLocationNumber = "";
          for(var hItem in this.hobby){
            if(hItem[6]['value']['value'] == ""){
              hItem[6]['value']['label'] = storehouseName;
              hItem[6]['value']['value'] = storehouseNumber;
              hItem[7]['value']['hide'] = showPosition;
            }
          }
        }
      }else{
        if(storehouseNumberT != dataItem[2] && storehouseNumberT != null){
          _showConfirmationDialog(2, dataItem[1], dataItem[2], dataItem[3]);
          return;
        }else{
          storehouseNameT = dataItem[1];
          storehouseNumberT = dataItem[2];
          showPositionT = dataItem[3];
          for(var hItem in this.hobby){
            if(hItem[8]['value']['value'] == ""){
              hItem[8]['value']['label'] = storehouseNameT;
              hItem[8]['value']['value'] = storehouseNumberT;
              hItem[9]['value']['hide'] = showPositionT;
            }
          }
        }
      }
    });
  }

  Future<List<int>?> _showChoiceModalBottomSheet(
      BuildContext context, List<dynamic> options, int type, List<dynamic> stockList) async {
    List selected = [];
    return showModalBottomSheet<List<int>?>(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context1, setState) {
          return Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20.0),
                topRight: const Radius.circular(20.0),
              ),
            ),
            height: MediaQuery.of(context).size.height / 2.0,
            child: Column(children: [
              Row(
                crossAxisAlignment:
                CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    width: 6.0,
                  ),
                  Icon(
                    Icons.search,
                    color: Colors.grey,
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(top: 10.0,left: 10.0),
                      alignment: Alignment.center,
                      child: TextField(
                        controller: this.controller,
                        decoration: new InputDecoration(
                            contentPadding:
                            EdgeInsets.only(
                                bottom: 12.0),
                            hintText: '输入关键字',
                            border: InputBorder.none),
                        onSubmitted: (value){
                          options = [];
                          options = stockList;
                          setState(() {
                            options = options.where((item) => item[1].contains(value)).toList();
                            //options = options.where((item) => item.contains(value)).toList()..sort((a,b)=> double.parse(a.toString().replaceAll('kg', '')).compareTo(double.parse(b.toString().replaceAll('kg', ''))));
                            print(options);
                          });
                        },
                        // onChanged: onSearchTextChanged,
                      ),
                    ),
                  ),
                ],
              ),

              Divider(height: 1.0),
              Expanded(
                child: ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      title: new Row(children: <Widget>[Text(options[index][1],
                      )
                      ], mainAxisAlignment: MainAxisAlignment.center,),
                      onTap: () async{
                        await this.setClickData(options[index], type);
                        Navigator.of(context).pop();
                      },
                    );
                  },
                  itemCount: options.length,
                ),
              ),
            ]),
          );
        });
      },
    );
  }
  void _moveCursorToEnd(controller) {
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.text.length),
    );
  }
  Future<List<int>?> _showModalBottomSheet(
      BuildContext context, List<dynamic> options, Map<dynamic,dynamic> dataItem) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return showModalBottomSheet<List<int>?>(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context1, setState) {
          return Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(10.0),
                topRight: const Radius.circular(10.0),
              ),
            ),
            height: MediaQuery.of(context).size.height / 2.0,
            child: Column(children: [
              Expanded(
                child: ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    var fStockIds = jsonDecode(sharedPreferences.getString('FStockIds'));
                    var floc = '';
                    if(fStockIds.length>0){
                      for(var i = 0; i< fStockIds.length;i++){
                        if(options[index][9+i] != null && options[index][9+i] != ''){
                          floc = options[index][9+i];
                          break;
                        }
                      }
                    }
                    return Column(
                      children: <Widget>[
                        ListTile(
                          title: Text((options[index][5]==null?'':'批号:'+options[index][5]+';')+'仓库:'+options[index][3]+(floc==''?'':';仓位:'+floc+';')+';数量:'+options[index][4].toString()+(options[index][7]==null?'':';生产日期:'+options[index][7]+';')+(options[index][8]==null?'':';有效期至:'+options[index][8]+';')),//+';仓库:'+options[index][3]+';数量:'+options[index][4].toString()+';包装规格:'+options[index][6]
                        ),
                        Divider(height: 1.0),
                      ],
                    );
                  },
                  itemCount: options.length,
                ),
              ),
            ]),
          );
        });
      },
    );
  }
  List<Widget> _getHobby() {
    List<Widget> tempList = [];
    for (int i = 0; i < this.hobby.length; i++) {
      List<Widget> comList = [];
      _textNumber3.add(TextEditingController());
      focusNodes.add(FocusNode());
      // 可选：添加监听（需注意内存管理）
      _setupListener(i);
      for (int j = 0; j < this.hobby[i].length; j++) {
        if (!this.hobby[i][j]['isHide']) {
          if (j == 3) {
            comList.add(
              Column(children: [
                Container(
                  color: Colors.white,
                  child: ListTile(
                      title: Text(this.hobby[i][j]["title"] +
                          '：' +
                          this.hobby[i][j]["value"]["label"].toString()),
                      trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            IconButton(
                              icon: new Icon(Icons.filter_center_focus, color: Colors.blue),
                              iconSize: 30,
                              tooltip: '点击扫描',
                              onPressed: () {
                                this._textNumber.text =
                                this.hobby[i][j]["value"]["label"];
                                this._FNumber =
                                this.hobby[i][j]["value"]["label"];
                                checkData = i;
                                checkDataChild = j;
                                checkItem = 'FNumber';
                                scanDialog();
                                if (this.hobby[i][j]["value"]["label"] != 0) {
                                  this._textNumber.value =
                                      _textNumber.value.copyWith(
                                        text: this.hobby[i][j]["value"]["label"],
                                      );
                                }
                              },
                            ),
                          ])),
                ),
                divider,
              ]),
            );
          }  /*else if (j == 6) {
            comList.add(
              _item('调出仓库:', stockList, this.hobby[i][j]['value']['label'],
                  this.hobby[i][j],
                  stock: this.hobby[i]),
            );
          }else if (j == 8) {
            comList.add(
              _item('调入仓库:', stockListT, this.hobby[i][j]['value']['label'],
                  this.hobby[i][j],
                  stock: this.hobby[i]),
            );
          }*/else if (j == 10) {
            comList.add(
              Column(children: [
                Container(
                  color: Colors.white,
                  child: ListTile(
                      title: Text(this.hobby[i][j]["title"] +
                          '：' +
                          this.hobby[i][j]["value"]["label"].toString()),
                      trailing:
                      Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            SizedBox(
                              width: 100,  // 设置固定宽度
                              child: TextField(
                                controller: _textNumber3[i], // 文本控制器
                                focusNode: focusNodes[i],
                                keyboardType: TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')), // 允许小数和数字
                                ],
                                onChanged: (value) {
                                  if(value[0]=="0" && value.length>1){
                                    if(!value.contains('.')){
                                      value = value.substring(1);
                                      this._textNumber3[i].text = value;
                                      // 移动光标到末尾
                                      _moveCursorToEnd(this._textNumber3[i]);
                                    }
                                  }
                                  // 提交前检查并处理
                                  if (value.endsWith('.')) {
                                    value = value.substring(0, value.length - 1);
                                  }
                                  print(value);
                                  print(this.hobby[i][j]["value"]['representativeQuantity']);
                                  if(double.parse(value) <= double.parse(this.hobby[i][j]["value"]['representativeQuantity'])){
                                    if(double.parse(value) <= this.hobby[i][4]["value"]['value']){
                                      if (this.hobby[i][0]['value']['kingDeeCode'].length > 0) {
                                        var kingDeeCode = this.hobby[i][0]['value']['kingDeeCode'][this.hobby[i][0]['value']['kingDeeCode'].length - 1].split("-");
                                        var realQty = 0.0;
                                        this.hobby[i][0]['value']['kingDeeCode'].forEach((item) {
                                          var qty = item.split("-")[1];
                                          realQty += double.parse(qty);
                                        });
                                        realQty = (realQty * 100 - double.parse(this.hobby[i][10]["value"]["label"]) * 100) / 100;
                                        realQty = (realQty * 100 + double.parse(value) * 100) / 100;
                                        this.hobby[i][10]["value"]["remainder"] = (Decimal.parse(this.hobby[i][10]["value"]["representativeQuantity"]) - Decimal.parse(value)).toString();
                                        this.hobby[i][3]["value"]["value"] = realQty.toString();
                                        this.hobby[i][3]["value"]["label"] = realQty.toString();
                                        this.hobby[i][j]["value"]["label"] = value;
                                        this.hobby[i][j]['value']["value"] = value;
                                        this.hobby[i][0]['value']['kingDeeCode'][this.hobby[i][0]['value']['kingDeeCode'].length - 1] = kingDeeCode[0] + "-" + value + "-" + kingDeeCode[2];
                                      } else {
                                        this._textNumber3[i].text = this.hobby[i][j]["value"]["value"];
                                        // 移动光标到末尾
                                        _moveCursorToEnd(this._textNumber3[i]);
                                        ToastUtil.showInfo('无条码信息，输入失败');
                                      }
                                    }else{
                                      this._textNumber3[i].text = this.hobby[i][j]["value"]["value"];
                                      // 移动光标到末尾
                                      _moveCursorToEnd(this._textNumber3[i]);
                                      ToastUtil.showInfo('输入数量大于可用数量');
                                    }
                                  }else{
                                    this._textNumber3[i].text = this.hobby[i][j]["value"]["value"];
                                    // 移动光标到末尾
                                    _moveCursorToEnd(this._textNumber3[i]);
                                    ToastUtil.showInfo('输入数量大于条码可用数量');
                                  }

                                  setState(() {

                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: '请输入',
                                  contentPadding: EdgeInsets.all(0),
                                ),
                              ),
                            ),
                          ])),
                ),
                divider,
              ]),
            );

          }else if (j == 9) {
            comList.add(
              Visibility(
                maintainSize: false,
                maintainState: false,
                maintainAnimation: false,
                visible: this.hobby[i][j]["value"]["hide"],
                child: Column(children: [
                  Container(
                    color: Colors.white,
                    child: ListTile(
                        title: Text(this.hobby[i][j]["title"] +
                            '：' +
                            this.hobby[i][j]["value"]["label"].toString()),
                        trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              IconButton(
                                icon: new Icon(Icons.filter_center_focus, color: Colors.blue),
                              iconSize: 30,
                                tooltip: '点击扫描',
                                onPressed: () {
                                  this._textNumber.text = this
                                      .hobby[i][j]["value"]["label"]
                                      .toString();
                                  this._FNumber = this
                                      .hobby[i][j]["value"]["label"]
                                      .toString();
                                  checkItem = 'FLoc';
                                  this.show = false;
                                  checkData = i;
                                  checkDataChild = j;
                                  scanDialog();

                                  print(this.hobby[i][j]["value"]["label"]);
                                  if (this.hobby[i][j]["value"]["label"] != 0) {
                                    this._textNumber.value =
                                        _textNumber.value.copyWith(
                                          text: this
                                              .hobby[i][j]["value"]["label"]
                                              .toString(),
                                        );
                                  }
                                },
                              ),
                            ])),
                  ),
                  divider,
                ]),
              ),
            );
          }else if (j == 7) {
            comList.add(
              Visibility(
                maintainSize: false,
                maintainState: false,
                maintainAnimation: false,
                visible: this.hobby[i][j]["value"]["hide"],
                child: Column(children: [
                  Container(
                    color: Colors.white,
                    child: ListTile(
                        title: Text(this.hobby[i][j]["title"] +
                            '：' +
                            this.hobby[i][j]["value"]["label"].toString()),
                        trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              IconButton(
                                icon: new Icon(Icons.filter_center_focus, color: Colors.blue),
                              iconSize: 30,
                                tooltip: '点击扫描',
                                onPressed: () {
                                  this._textNumber.text = this
                                      .hobby[i][j]["value"]["label"]
                                      .toString();
                                  this._FNumber = this
                                      .hobby[i][j]["value"]["label"]
                                      .toString();
                                  checkItem = 'FLoc';
                                  this.show = false;
                                  checkData = i;
                                  checkDataChild = j;
                                  scanDialog();

                                  print(this.hobby[i][j]["value"]["label"]);
                                  if (this.hobby[i][j]["value"]["label"] != 0) {
                                    this._textNumber.value =
                                        _textNumber.value.copyWith(
                                          text: this
                                              .hobby[i][j]["value"]["label"]
                                              .toString(),
                                        );
                                  }
                                },
                              ),
                            ])),
                  ),
                  divider,
                ]),
              ),
            );
          } else if (j == 13) {
            comList.add(
              Column(children: [
                Container(
                  color: Colors.white,
                  child: ListTile(
                      title: Text(this.hobby[i][j]["title"] +
                          '：' +
                          this.hobby[i][j]["value"]["label"].toString()),
                      trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            new MaterialButton(
                              color: Colors.red,
                              textColor: Colors.white,
                              child: new Text('删除'),
                              onPressed: () {
                                this.hobby.removeAt(i);
                                setState(() {});
                              },
                            ),
                          ])),
                ),
                divider,
              ]),
            );
          }else if (j == 14) {
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
                        new MaterialButton(
                          color: Colors.blue,
                          textColor: Colors.white,
                          child: new Text('查看'),
                          onPressed: () async {
                            if(this.hobby[i][j]["value"]["fLotList"] != null && this.hobby[i][j]["value"]["fLotList"].length>0){
                              await _showModalBottomSheet(
                                  context, this.hobby[i][j]["value"]["fLotList"],this.hobby[i][j]["value"]);
                            }else{
                              ToastUtil.showInfo('无相关库存信息');
                            }
                            setState(() {});
                          },
                        ),
                      ])),
                ),
                divider,
              ]),
            );
          } else if (j == 5 && this.fBillNo == '') {
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
                          icon: new Icon(Icons.filter_center_focus, color: Colors.blue),
                              iconSize: 30,
                          tooltip: '点击扫描',
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
      }
      tempList.add(
        SizedBox(height: 5,
          child: Container(
            color: Colors.grey, // 设置颜色
          ),
        ),
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
                  /*  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text('输入数量',
                        style: TextStyle(
                            fontSize: 16, decoration: TextDecoration.none)),
                  ),*/
                  Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Card(
                          child: Column(children: <Widget>[
                            TextField(
                              style: TextStyle(color: Colors.black87),
                              keyboardType: checkItem == "FLoc"?TextInputType.text:TextInputType.number,
                              controller: this._textNumber,
                              decoration: InputDecoration(hintText: "输入"),
                              onChanged: (value) {
                                setState(() {
                                  this._FNumber = value;
                                });
                              },
                            ),
                          ]))),
                  Padding(
                    padding: EdgeInsets.only(top: 15, bottom: 8),
                    child: FlatButton(
                        color: Colors.grey[100],
                        onPressed: () {
                          // 关闭 Dialog
                          Navigator.pop(context);
                          setState(() {
                            print(checkItem);
                            if(_FNumber == ''){
                              checkItem = '';
                              return;
                            }
                            if (checkItem == "FLastQty") {
                              if(double.parse(_FNumber) <= double.parse(this.hobby[checkData][checkDataChild]["value"]['representativeQuantity'])){
                                if (this.hobby[checkData][0]['value']['kingDeeCode'].length > 0) {
                                  var kingDeeCode = this.hobby[checkData][0]['value']['kingDeeCode'][this.hobby[checkData][0]['value']['kingDeeCode'].length - 1].split("-");
                                  var realQty = 0.0;
                                  this.hobby[checkData][0]['value']['kingDeeCode'].forEach((item) {
                                    var qty = item.split("-")[1];
                                    realQty += double.parse(qty);
                                  });
                                  realQty = (realQty * 100 - double.parse(this.hobby[checkData][10]["value"]["label"]) * 100) / 100;
                                  realQty = (realQty * 100 + double.parse(_FNumber) * 100) / 100;
                                  this.hobby[checkData][10]["value"]["remainder"] = (Decimal.parse(this.hobby[checkData][10]["value"]["representativeQuantity"]) - Decimal.parse(_FNumber)).toString();
                                  this.hobby[checkData][3]["value"]["value"] = realQty.toString();
                                  this.hobby[checkData][3]["value"]["label"] = realQty.toString();
                                  this.hobby[checkData][checkDataChild]["value"]["label"] = _FNumber;
                                  this.hobby[checkData][checkDataChild]['value']["value"] = _FNumber;
                                  this.hobby[checkData][0]['value']['kingDeeCode'][this.hobby[checkData][0]['value']['kingDeeCode'].length - 1] = kingDeeCode[0] + "-" + _FNumber + "-";
                                } else {
                                  ToastUtil.showInfo('无条码信息，输入失败');
                                }
                              }else{
                                ToastUtil.showInfo('输入数量大于条码可用数量');
                              }
                            }else if(checkItem == "FLoc"){
                              this.hobby[checkData][checkDataChild]["value"]
                              ["label"] = _FNumber;
                              this.hobby[checkData][checkDataChild]['value']
                              ["value"] = _FNumber;
                            }else{
                              if(this.fBillNo != '' && this.fBillNo != null){
                                if((double.parse(_FNumber)<=this.hobby[checkData][4]["value"]["label"])){
                                  this.hobby[checkData][checkDataChild]["value"]
                                  ["label"] = _FNumber;
                                  this.hobby[checkData][checkDataChild]['value']
                                  ["value"] = _FNumber;
                                }else{
                                  ToastUtil.showInfo('调拨数量不能大于申请数量');
                                }
                              }else{
                                this.hobby[checkData][checkDataChild]["value"]
                                ["label"] = _FNumber;
                                this.hobby[checkData][checkDataChild]['value']
                                ["value"] = _FNumber;
                              }
                            }
                            checkItem = '';
                          });
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

  Widget _getModalSheetHeaderWithConfirm(String title,
      {required Function onCancel, required Function onConfirm}) {
    return SizedBox(
      height: 50,
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              onCancel();
            },
          ),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0),
              ),
            ),
          ),
          IconButton(
              icon: Icon(
                Icons.check,
                color: Colors.blue,
              ),
              onPressed: () {
                onConfirm();
              }),
        ],
      ),
    );
  }

  Future<List<int>?> _showMultiChoiceModalBottomSheet(
      BuildContext context, List<dynamic> options, List<dynamic> stockDataList) async {
    List selected = [];
    var selectList = this.hobby;
    for (var select in selectList) {
      for(var item in options){
        if (select[0]['fid'] == item[15]) {
          selected.add(item);
        } else {
          selected.remove(item);
        }
      }
    }
    // print(options);
    // print(selected);
    return showModalBottomSheet<List<int>?>(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context1, setState) {
          return Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20.0),
                topRight: const Radius.circular(20.0),
              ),
            ),
            height: MediaQuery.of(context).size.height / 2.0,
            child: Column(children: [
              _getModalSheetHeaderWithConfirm(
                options[0][1],
                onCancel: () {
                  Navigator.of(context).pop();
                },
                onConfirm: () {
                  var itemList = [];
                  for (var select in selectList) {
                    for(var item in selected){
                      if (select[0]['value']['fid'] != item[15]) {
                        itemList.add(item);
                      }
                    }
                  }
                  if(selectList.length == 0){
                    this.getInventoryDataList(selected,stockDataList);
                  }else{
                    this.getInventoryDataList(itemList,stockDataList);
                  }
                  Navigator.of(context).pop();
                },
              ),
              Divider(height: 1.0),
              Expanded(
                child: ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    var floc = null;
                    if(stockDataList.length>0){
                      for(var i = 0; i< stockDataList.length;i++){
                        if(options[index][16+i] != null && options[index][16+i] != ''){
                          floc = options[index][16+i];
                          break;
                        }
                      }
                    }
                    return ListTile(
                      trailing: Icon(
                          selected.contains(options[index])
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          color: Theme.of(context).primaryColor),
                      title: Text('仓库:'+options[index][3]+';仓位:'+(floc==null?'无':floc)+';数量:'+options[index][7].toString()),
                      onTap: () {
                        setState(() {
                          if (selected.contains(options[index])) {
                            selected.remove(options[index]);
                          } else {
                            var number = 0;
                            for (var element in hobby) {
                              if (element[0]['value']['fid'] == options[index][14]) {
                                number++;
                              }
                            }
                            if(number==0){
                              selected.add(options[index]);
                            }else{
                              ToastUtil.showInfo('库存已存在');
                            }
                          }
                          print(selected);
                        });
                      },
                    );
                  },
                  itemCount: options.length,
                ),
              ),
            ]),
          );
        });
      },
    );
  }

  //保存
  saveOrder() async {
    if (this.hobby.length > 0) {
      setState(() {
        this.isSubmit = true;
      });
      Map<String, dynamic> dataMap = Map();
      dataMap['formid'] = 'STK_TransferDirect';
      Map<String, dynamic> orderMap = Map();
      orderMap['NeedReturnFields'] = ['FBillNo'];
      orderMap['IsDeleteEntry'] = true;
      Map<String, dynamic> Model = Map();
      Model['FID'] = 0;
      Model['FBillTypeID'] = {"FNUMBER": "ZJDB01_SYS"};
      Model['FDate'] = FDate;

      //获取登录信息
      SharedPreferences sharedPreferences =
      await SharedPreferences.getInstance();
      var menuData = sharedPreferences.getString('MenuPermissions');
      var deptData = jsonDecode(menuData)[0];
      Model['F_MSD_PDA_CREATORID'] = {"FStaffNumber": deptData[0]};
      Model['F_MSD_PDA_CreateDate'] = FDate;
      Model['F_MSD_PDA_APPROVERID'] = {"FStaffNumber": deptData[0]};
      Model['F_MSD_PDA_APPROVEDATE'] = FDate;
      Model['FStockOutOrgId'] = {"FNumber": this.organizationsNumber1};
      Model['FStockOrgId'] = {"FNumber": this.organizationsNumber2};
      Model['FOwnerTypeIdHead'] = "BD_OwnerOrg";
      if(organizationsNumber1 == organizationsNumber2){
        Model['FTransferBizType'] = "InnerOrgTransfer";
      }else{
        Model['FTransferBizType'] = "OverOrgTransfer";
      }
      Model['FOwnerTypeOutIdHead'] = "BD_OwnerOrg";
      Model['FTransferDirect'] = "GENERAL";
      Model['FBizType'] = "GENERAL";
      Model['FOwnerOutIdHead'] = {"FNumber": this.organizationsNumber1};
      Model['FOwnerIdHead'] = {"FNumber": this.organizationsNumber2};
      Model['F_MSD_Base'] = {"FNUMBER": this.storehouseNumber};
      Model['F_MSD_Base1'] = {"FNUMBER": this.storehouseNumberT};
      var FEntity = [];
      var hobbyIndex = 0;
      print(materialDate);
      for (var element in this.hobby) {
        if (element[3]['value']['value'] != '0' && element[3]['value']['value'] != '' && element[3]['value']['value'] != 0 && element[8]['value']['value'] != '') {
          Map<String, dynamic> FEntityItem = Map();

          /*FEntityItem['FReturnType'] = 1;*/
          FEntityItem['FOwnerTypeId'] = "BD_OwnerOrg";
          FEntityItem['FOwnerId'] = {"FNumber": this.organizationsNumber2};
          FEntityItem['FOwnerTypeOutId'] = "BD_OwnerOrg";
          FEntityItem['FOwnerOutId'] = {"FNumber": this.organizationsNumber1};
          FEntityItem['FKeeperTypeId'] = "BD_KeeperOrg";
          FEntityItem['FKeeperId'] = {"FNumber": this.organizationsNumber2};

          FEntityItem['FMaterialId'] = {
            "FNumber": element[0]['value']['value']
          };
          FEntityItem['FKeeperTypeOutId'] = "BD_KeeperOrg";
          FEntityItem['FKeeperOutId'] = {"FNumber": this.organizationsNumber1};
          FEntityItem['FUnitID'] = {"FNumber": element[2]['value']['value']};
          FEntityItem['FBaseUnitId'] = {
            "FNumber": element[2]['value']['value']
          };
          FEntityItem['FSrcStockId'] = {
            "FNumber": element[6]['value']['value']
          };
          if (element[7]['value']['hide']) {
            Map<String, dynamic> stockMap = Map();
            stockMap['FormId'] = 'BD_STOCK';
            stockMap['FieldKeys'] =
            'FFlexNumber';
            stockMap['FilterString'] = "FNumber = '" +
                element[6]['value']['value'] +
                "'";
            Map<String, dynamic> stockDataMap = Map();
            stockDataMap['data'] = stockMap;
            String res = await CurrencyEntity.polling(stockDataMap);
            var stockRes = jsonDecode(res);
            if (stockRes.length > 0) {
              var postionList = element[7]['value']['value'].split(".");
              FEntityItem['FSrcStockLocId'] = {};
              var positonIndex = 0;
              for(var dimension in postionList){
                FEntityItem['FSrcStockLocId']["FSRCSTOCKLOCID__" + stockRes[positonIndex][0]] = {
                  "FNumber": dimension
                };
                positonIndex++;
              }
            }
          }
          FEntityItem['FDestStockId'] = {
            "FNumber": element[8]['value']['value']
          };
          if (element[9]['value']['hide']) {
            Map<String, dynamic> stockMap = Map();
            stockMap['FormId'] = 'BD_STOCK';
            stockMap['FieldKeys'] =
            'FFlexNumber';
            stockMap['FilterString'] = "FNumber = '" +
                element[8]['value']['value'] +
                "'";
            Map<String, dynamic> stockDataMap = Map();
            stockDataMap['data'] = stockMap;
            String res = await CurrencyEntity.polling(stockDataMap);
            var stockRes = jsonDecode(res);
            if (stockRes.length > 0) {
              var postionList = element[9]['value']['value'].split(".");
              FEntityItem['FDestStockLocId'] = {};
              var positonIndex = 0;
              for(var dimension in postionList){
                FEntityItem['FDestStockLocId']["FDESTSTOCKLOCID__" + stockRes[positonIndex][0]] = {
                  "FNumber": dimension
                };
                positonIndex++;
              }
            }
          }

          FEntityItem['FQty'] = element[3]['value']['value'];
          FEntityItem['FBaseQty'] = element[3]['value']['value'];
          if(isScanWork){
            FEntityItem['FBillEntry_Link'] = [
              {
                "FBillEntry_Link_FRuleId": "StkTransferApply-StkTransferDirect",
                "FBillEntry_Link_FSTableName": "T_STK_STKTRANSFERAPPENTRY",
                "FBillEntry_Link_FSBillId": orderDate[hobbyIndex][15],
                "FBillEntry_Link_FSId": orderDate[hobbyIndex][4],
                "FBillEntry_Link_FSALBASEQTY": element[8]['value']['value'],
                "FBillEntry_Link_FBaseQty": element[8]['value']['value']
              }
            ];
          }
          FEntity.add(FEntityItem);
        }
        hobbyIndex++;
      };
      if (FEntity.length == 0) {
        this.isSubmit = false;
        ToastUtil.showInfo('请输入数量,仓库');
        return;
      }
      Model['FBillEntry'] = FEntity;
      orderMap['Model'] = Model;
      dataMap['data'] = orderMap;
      print(jsonEncode(dataMap));
      var saveData = jsonEncode(dataMap);
      String order = await SubmitEntity.save(dataMap);
      var res = jsonDecode(order);
      print(res);
      if (res['Result']['ResponseStatus']['IsSuccess']) {
        var returnData = res['Result']['NeedReturnData'];
        newBillNo=returnData[0]['FBillNo'];
        Map<String, dynamic> submitMap = Map();
        submitMap = {
          "formid": "STK_TransferDirect",
          "data": {
            'Ids': res['Result']['ResponseStatus']['SuccessEntitys'][0]['Id']
          }
        };
        //提交
        HandlerOrder.orderHandler(context, submitMap, 1, "STK_TransferDirect",
            SubmitEntity.submit(submitMap))
            .then((submitResult) async{
          if (submitResult) {
            //审核
            HandlerOrder.orderHandler(context, submitMap, 1,
                "STK_TransferDirect", SubmitEntity.audit(submitMap))
                .then((auditResult) async {
              if (auditResult) {
                var errorMsg = "";
                if (fBarCodeList == 1) {
                  for (int i = 0; i < this.hobby.length; i++) {
                    if (this.hobby[i][3]['value']['value'] != '0') {
                      var kingDeeCode =
                      this.hobby[i][0]['value']['kingDeeCode'];
                      for (int j = 0; j < kingDeeCode.length; j++) {
                        Map<String, dynamic> dataCodeMap = Map();
                        dataCodeMap['formid'] = 'QDEP_Cust_BarCodeList';
                        Map<String, dynamic> orderCodeMap = Map();
                        orderCodeMap['NeedReturnFields'] = [];
                        orderCodeMap['IsDeleteEntry'] = false;
                        Map<String, dynamic> codeModel = Map();
                        var itemCode = kingDeeCode[j].split("-");
                        codeModel['FID'] = itemCode[0];
                        for (var j = 0; j < 2; j++) {
                          if (j == 0) {
                            /*codeModel['FLastCheckTime'] = formatDate(DateTime.now(), [yyyy, "-", mm, "-", dd,]);*/
                            Map<String, dynamic> codeFEntityItem = Map();
                            codeFEntityItem['FBillDate'] = FDate;
                            codeFEntityItem['FOutQty'] = itemCode[1];
                            codeFEntityItem['FEntryBillNo'] = returnData[0]['FBillNo'];
                            codeFEntityItem['FEntryStockID'] = {
                              "FNUMBER": this.hobby[i][6]['value']['value']
                            };
                            if (this.hobby[i][7]['value']['hide']) {
                              Map<String, dynamic> stockMap = Map();
                              stockMap['FormId'] = 'BD_STOCK';
                              stockMap['FieldKeys'] =
                              'FFlexNumber';
                              stockMap['FilterString'] = "FNumber = '" +
                                  this.hobby[i][6]['value']['value'] +
                                  "'";
                              Map<String, dynamic> stockDataMap = Map();
                              stockDataMap['data'] = stockMap;
                              String res = await CurrencyEntity.polling(stockDataMap);
                              var stockRes = jsonDecode(res);
                              if (stockRes.length > 0) {
                                var postionList = this.hobby[i][7]['value']['value'].split(".");
                                codeFEntityItem['FStockLocID'] = {};
                                codeFEntityItem['FStockLocNumber'] = this.hobby[i][7]['value']['value'];
                                var positonIndex = 0;
                                for(var dimension in postionList){
                                  codeFEntityItem['FStockLocID']["FSTOCKLOCID__" + stockRes[positonIndex][0]] = {
                                    "FNumber": dimension
                                  };
                                  positonIndex++;
                                }
                              }
                            }

                            var codeFEntity = [codeFEntityItem];
                            codeModel['FEntity'] = codeFEntity;
                            orderCodeMap['Model'] = codeModel;
                            dataCodeMap['data'] = orderCodeMap;
                            print(dataCodeMap);
                            String codeRes =
                            await SubmitEntity.save(dataCodeMap);
                            var barcodeRes = jsonDecode(codeRes);
                            if (!barcodeRes['Result']['ResponseStatus']
                            ['IsSuccess']) {
                              errorMsg += "错误反馈：" +
                                  itemCode[1] +
                                  ":" +
                                  barcodeRes['Result']['ResponseStatus']
                                  ['Errors'][0]['Message'];
                            }
                            print(codeRes);
                          } else {
                            codeModel['FOwnerID'] = {
                              "FNUMBER": this.organizationsNumber2
                            };
                            codeModel['FStockOrgID'] = {
                              "FNUMBER": this.organizationsNumber2
                            };
                            codeModel['FStockID'] = {
                              "FNUMBER": this.hobby[i][8]['value']['value']
                            };
                            /*codeModel['FLastCheckTime'] = formatDate(DateTime.now(), [yyyy, "-", mm, "-", dd,]);*/
                            Map<String, dynamic> codeFEntityItem = Map();
                            codeFEntityItem['FBillDate'] = FDate;
                            codeFEntityItem['FInQty'] = itemCode[1];
                            codeFEntityItem['FEntryBillNo'] = returnData[0]['FBillNo'];
                            //codeFEntityItem['FEntryBillNo'] = orderDate[i][0];
                            codeFEntityItem['FEntryStockID'] = {
                              "FNUMBER": this.hobby[i][8]['value']['value']
                            };
                            if (this.hobby[i][9]['value']['hide']) {
                              codeModel['FStockLocNumberH'] = this.hobby[i][9]['value']['value'];
                              codeFEntityItem['FStockLocNumber'] = this.hobby[i][9]['value']['value'];
                              Map<String, dynamic> stockMap = Map();
                              stockMap['FormId'] = 'BD_STOCK';
                              stockMap['FieldKeys'] =
                              'FFlexNumber';
                              stockMap['FilterString'] = "FNumber = '" +
                                  this.hobby[i][8]['value']['value'] +
                                  "'";
                              Map<String, dynamic> stockDataMap = Map();
                              stockDataMap['data'] = stockMap;
                              String res = await CurrencyEntity.polling(stockDataMap);
                              var stockRes = jsonDecode(res);
                              if (stockRes.length > 0) {
                                var postionList = this.hobby[i][9]['value']['value'].split(".");
                                codeModel['FStockLocIDH'] = {};
                                codeFEntityItem['FStockLocID'] = {};
                                var positonIndex = 0;
                                for(var dimension in postionList){
                                  codeModel['FStockLocIDH']["FSTOCKLOCIDH__" + stockRes[positonIndex][0]] = {
                                    "FNumber": dimension
                                  };
                                  codeFEntityItem['FStockLocID']["FSTOCKLOCID__" + stockRes[positonIndex][0]] = {
                                    "FNumber": dimension
                                  };
                                  positonIndex++;
                                }
                              }
                            }
                            var codeFEntity = [codeFEntityItem];
                            codeModel['FEntity'] = codeFEntity;
                            orderCodeMap['Model'] = codeModel;
                            dataCodeMap['data'] = orderCodeMap;
                            print(dataCodeMap);
                            var paramsvalve=jsonEncode(dataCodeMap);
                            String codeRes =
                            await SubmitEntity.save(dataCodeMap);
                            var barcodeRes = jsonDecode(codeRes);
                            if (!barcodeRes['Result']['ResponseStatus']
                            ['IsSuccess']) {
                              errorMsg += "错误反馈：" +
                                  itemCode[1] +
                                  ":" +
                                  barcodeRes['Result']['ResponseStatus']
                                  ['Errors'][0]['Message'];
                            }
                            print(codeRes);
                          }
                        }
                      }
                    }
                  }
                }
                if (errorMsg != "") {
                  ToastUtil.errorDialog(context, errorMsg);
                  this.isSubmit = false;
                }
                //提交清空页面
                setState(() {
                  this.hobby = [];
                  this.orderDate = [];
                  this.FBillNo = '';
                  EasyLoading.dismiss();
                  _showSaveedDialog(newBillNo);
                });
              } else {
                //失败后反审
                HandlerOrder.orderHandler(context, submitMap, 0,
                    "STK_TransferDirect", SubmitEntity.unAudit(submitMap))
                    .then((unAuditResult) {
                  if (unAuditResult) {
                    this.isSubmit = false;
                  } else {
                    this.isSubmit = false;
                  }
                });
              }
            });
          } else {
            this.isSubmit = false;
          }
        });
      } else {
        setState(() {
          this.isSubmit = false;
          ToastUtil.errorDialog(
              context, res['Result']['ResponseStatus']['Errors'][0]['Message']);
        });
      }
    } else {
      ToastUtil.showInfo('无提交数据');
    }
  }
  /// 保存成功提示框
  Future<void> _showSaveedDialog(String billNo) async {
    String checkQtyResult="";
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("保存成功，生成单据号："+billNo,style: TextStyle(fontSize: 16, color: Colors.black)),
            actions: <Widget>[
              new ElevatedButton(
                child: new Text('确定'),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(context).pop("refresh");
                },
              )
            ],
          );
        });
  }
  /// 确认提交提示对话框
  Future<void> _showSumbitDialog() async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("是否提交"),
            actions: <Widget>[
              new FlatButton(
                child: new Text('不了'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: new Text('确定'),
                onPressed: () {
                  Navigator.of(context).pop();
                  saveOrder();
                },
              )
            ],
          );
        });
  }

  //扫码函数,最简单的那种
  Future scan() async {
    String cameraScanResult = await scanner.scan(); //通过扫码获取二维码中的数据
    getScan(cameraScanResult); //将获取到的参数通过HTTP请求发送到服务器
    print(cameraScanResult); //在控制台打印
  }

//用于验证数据(也可以在控制台直接打印，但模拟器体验不好)
  void getScan(String scan) async {
    _onEvent(scan);
  }

  double hc_ScreenWidth() {
    return window.physicalSize.width / window.devicePixelRatio;
  }
  @override
  Widget build(BuildContext context) {
    return FlutterEasyLoading(
      child: Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: scan,
            tooltip: 'Increment',
            child: Icon(Icons.filter_center_focus),
          ),
          appBar: AppBar(
            title: Text("调拨入库"),
            centerTitle: true,
            leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop("refresh");
                }),
          ),
          body: Column(
            children: <Widget>[
              Expanded(
                child: ListView(children: <Widget>[

                  Visibility(
                    maintainSize: false,
                    maintainState: false,
                    maintainAnimation: false,
                    visible: this.fBillNo == '' || this.fBillNo == null,
                    child: Container(
                      height: 46.0,
                      child: new Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Row(children: [
                          Card(
                            child: new Container(
                                width: hc_ScreenWidth() - 80,
                                child: Row(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.center,
                                  children: <Widget>[
                                    SizedBox(
                                      width: 6.0,
                                    ),
                                    Icon(
                                      Icons.search,
                                      color: Colors.grey,
                                    ),
                                    Expanded(
                                      child: Container(
                                        alignment: Alignment.center,
                                        child: TextField(
                                          controller: this.controller,
                                          decoration: new InputDecoration(
                                              contentPadding:
                                              EdgeInsets.only(
                                                  bottom: 12.0),
                                              hintText: '物料编码',
                                              border: InputBorder.none),
                                          onSubmitted: (value) {
                                            setState(() {
                                              this.keyWord = value;
                                              this.getInventoryList();
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                    new IconButton(
                                      icon: new Icon(Icons.cancel),
                                      color: Colors.grey,
                                      iconSize: 18.0,
                                      onPressed: () {
                                        this.controller.clear();
                                      },
                                    ),
                                  ],
                                )),
                          ),
                          new SizedBox(
                            width: 60.0,
                            height: 30.0,
                            child: new RaisedButton(
                              color: Colors.lightBlueAccent,
                              child: new Text('搜索',style: TextStyle(fontSize: 14.0, color: Colors.white)),
                              onPressed: (){
                                setState(() {
                                  this.keyWord = this.controller.text;
                                  this.getInventoryList();
                                });
                              },
                            ),
                          ),
                        ]),
                      ),
                    ),
                  ),
                  _dateItem('日期：', DateMode.YMD),
                  /*_item('调出组织', this.organizationsList, this.organizationsName1,
                      'organizations1'),*/
                  Column(
                    children: [
                      Container(
                        color: Colors.white,
                        child: ListTile(
                          title: Text("调出组织：$organizationsName1"),
                        ),
                      ),
                      divider,
                    ],
                  ),
                  _item('调入组织', this.organizationsList, this.organizationsName2,
                      'organizations2'),
                  Visibility(
                    maintainSize: false,
                    maintainState: false,
                    maintainAnimation: false,
                    visible: this.fBillNo != '' && this.fBillNo != null,
                    child: Column(
                      children: [
                        Container(
                          color: Colors.white,
                          child: ListTile(
                            title: Text("调出仓库：${storehouseName==null?'':storehouseName}"),
                          ),
                        ),
                        divider,
                      ],
                    ),
                  ),
                  Visibility(
                    maintainSize: false,
                    maintainState: false,
                    maintainAnimation: false,
                    visible: this.fBillNo == '' || this.fBillNo == null,
                    child: Column(children: [
                      Container(
                        color: Colors.white,
                        child: ListTile(
                            title: Text('调出仓库：${storehouseName!=null ? storehouseName: "暂无"}'),
                            trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  IconButton(
                                    icon: new Icon(Icons.chevron_right, color: Colors.blue),
                                    onPressed: () {
                                      this.controller.clear();
                                      this.searchStockList = [];
                                      this.searchStockList = this.stockListObj;
                                      _showChoiceModalBottomSheet(context, this.searchStockList,1,this.stockListObj);
                                    },
                                  ),
                                ])),
                      ),
                      divider,
                    ]),
                  ),
                  Column(children: [
                    Container(
                      color: Colors.white,
                      child: ListTile(

                          title: Text('调入仓库：${storehouseNameT!=null ? storehouseNameT: "暂无"}'),
                          trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                IconButton(
                                  icon: new Icon(Icons.chevron_right, color: Colors.blue),
                                  onPressed: () {
                                    this.controller.clear();
                                    this.searchStockListT = [];
                                    this.searchStockListT = this.stockListObjT;
                                    _showChoiceModalBottomSheet(context, this.searchStockListT,0, this.stockListObjT);
                                  },
                                ),
                              ])),

                    ),
                    divider,
                  ]),
                  // _item('调入仓库', this.stockListT, this.storehouseName,
                  //     'storehouse'),
                  // Visibility(
                  //   maintainSize: false,
                  //   maintainState: false,
                  //   maintainAnimation: false,
                  //   visible: showPosition,
                  //   child: Column(children: [
                  //     Container(
                  //       color: Colors.white,
                  //       child: ListTile(
                  //           title: Text('调入仓位：' +
                  //               this.storingLocationName.toString()),
                  //           trailing: Row(
                  //               mainAxisSize: MainAxisSize.min,
                  //               children: <Widget>[
                  //                 IconButton(
                  //                   icon: new Icon(Icons.filter_center_focus, color: Colors.blue),
                  //                   tooltip: '点击扫描',
                  //                   onPressed: () {
                  //                     this._textNumber.text = this
                  //                         .storingLocationName
                  //                         .toString();
                  //                     this._FNumber = this
                  //                         .storingLocationName
                  //                         .toString();
                  //                     checkItem = 'HPoc';
                  //                     this.show = false;
                  //                     scanDialog();
                  //                     if (this.storingLocationName != "") {
                  //                       this._textNumber.value =
                  //                           _textNumber.value.copyWith(
                  //                             text: this
                  //                                 .storingLocationName
                  //                                 .toString(),
                  //                           );
                  //                     }
                  //                   },
                  //                 ),
                  //               ])),
                  //     ),
                  //     divider,
                  //   ]),
                  // ),
                  Column(
                    children: [
                      Container(
                        color: Colors.white,
                        child: ListTile(
                          dense: true,
                          visualDensity: VisualDensity(vertical: -4),
                          title: TextField(
                            //最多输入行数
                            maxLines: 1,
                            decoration: InputDecoration(
                              hintText: "备注",
                              //给文本框加边框
                              border: OutlineInputBorder(),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 10), // 可选：调整内边距
                            ),
                            controller: this._remarkContent,
                            //改变回调
                            onChanged: (value) {
                              setState(() {
                                _remarkContent.value = TextEditingValue(
                                    text: value,
                                    selection: TextSelection.fromPosition(
                                        TextPosition(
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
                        child: Text("保存"),
                        color: this.isSubmit
                            ? Colors.grey
                            : Theme.of(context).primaryColor,
                        textColor: Colors.white,
                        onPressed: () async =>
                        this.isSubmit ? null : _showSumbitDialog(),
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
