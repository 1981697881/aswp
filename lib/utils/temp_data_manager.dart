import 'dart:convert';
import 'package:flutter/material.dart';
import 'database_helper.dart';

// 单据类型常量
class FormType {
  static const String PURCHASE_WAREHOUSING = 'purchase_warehousing';
  static const String ALLOCATION_ORDER = 'allocation_order';
// 可以添加更多单据类型
}

class TempDataManager {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // 单例模式
  static final TempDataManager _instance = TempDataManager._internal();
  factory TempDataManager() => _instance;
  TempDataManager._internal();

  /// 保存采购入库单暂存数据
  Future<int> savePurchaseWarehousing({
    required String billNo,
    required Map<String, dynamic> data,
  }) async {
    return await _dbHelper.saveTempData(
      formType: FormType.PURCHASE_WAREHOUSING,
      billNo: billNo,
      data: data,
    );
  }

  /// 获取采购入库单暂存数据
  Future<Map<String, dynamic>?> getPurchaseWarehousing(String billNo) async {
    return await _dbHelper.getTempData(
      formType: FormType.PURCHASE_WAREHOUSING,
      billNo: billNo,
    );
  }

  /// 删除采购入库单暂存数据
  Future<int> deletePurchaseWarehousing(String billNo) async {
    return await _dbHelper.deleteTempData(
      formType: FormType.PURCHASE_WAREHOUSING,
      billNo: billNo,
    );
  }

  /// 获取所有采购入库单暂存数据
  Future<List<Map<String, dynamic>>> getAllPurchaseWarehousing() async {
    return await _dbHelper.getTempDataByFormType(FormType.PURCHASE_WAREHOUSING);
  }

  /// 保存直接调拨单暂存数据
  Future<int> saveAllocationOrder({
    required String billNo,
    required Map<String, dynamic> data,
  }) async {
    return await _dbHelper.saveTempData(
      formType: FormType.ALLOCATION_ORDER,
      billNo: billNo,
      data: data,
    );
  }

  /// 获取直接调拨单暂存数据
  Future<Map<String, dynamic>?> getAllocationOrder(String billNo) async {
    return await _dbHelper.getTempData(
      formType: FormType.ALLOCATION_ORDER,
      billNo: billNo,
    );
  }
  /// 删除直接调拨单暂存数据
  Future<int> deleteAllocationOrder(String billNo) async {
    return await _dbHelper.deleteTempData(
      formType: FormType.ALLOCATION_ORDER,
      billNo: billNo,
    );
  }
  /// 显示加载缓存的对话框
  static Future<bool?> showLoadTempDataDialog(
      BuildContext context, {
        required String title,
        required String content,
      }) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              child: Text('删除'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('加载'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  /// 显示退出确认对话框
  static Future<bool?> showExitConfirmDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("提示"),
          content: Text("当前有未保存的数据，是否暂存？"),
          actions: <Widget>[
            TextButton(
              child: Text('不保存'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('暂存'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
            TextButton(
              child: Text('取消'),
              onPressed: () {
                Navigator.of(context).pop(null);
              },
            ),
          ],
        );
      },
    );
  }

  /// 检查是否有未保存的数据
  static bool hasUnsavedData(List<dynamic> hobby) {
    for (var item in hobby) {
      if (item[3]['value']['value'] != '0' && item[3]['value']['value'] != '') {
        return true;
      }
    }
    return false;
  }
}