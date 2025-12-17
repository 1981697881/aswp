import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'app_temp_data.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 创建暂存数据表
    await db.execute('''
      CREATE TABLE temp_data(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        formType TEXT NOT NULL,    -- 单据类型，如：purchase_warehousing, production_issue, etc.
        billNo TEXT NOT NULL,      -- 单据号
        data TEXT,                 -- 暂存的数据（JSON格式）
        createTime TEXT,           -- 创建时间
        updateTime TEXT,           -- 更新时间
        UNIQUE(formType, billNo)   -- 确保同一单据类型和单据号只有一条记录
      )
    ''');

    // 创建索引以提高查询速度
    await db.execute('CREATE INDEX idx_formType_billNo ON temp_data(formType, billNo)');
  }

  // 保存暂存数据
  Future<int> saveTempData({
    required String formType,
    required String billNo,
    required Map<String, dynamic> data,
  }) async {
    final db = await database;

    // 检查是否已存在该单据的暂存数据
    final existing = await getTempData(formType: formType, billNo: billNo);
    if (existing != null) {
      // 更新现有记录
      return await db.update(
        'temp_data',
        {
          'data': jsonEncode(data),
          'updateTime': DateTime.now().toIso8601String(),
        },
        where: 'formType = ? AND billNo = ?',
        whereArgs: [formType, billNo],
      );
    } else {
      // 插入新记录
      return await db.insert(
        'temp_data',
        {
          'formType': formType,
          'billNo': billNo,
          'data': jsonEncode(data),
          'createTime': DateTime.now().toIso8601String(),
          'updateTime': DateTime.now().toIso8601String(),
        },
      );
    }
  }
  // 使用自定义的 JSON 编码/解码方法
  static Map<String, dynamic> _decodeJson(String jsonString) {
    try {
      final decoded = jsonDecode(jsonString);
      return _ensureMapIsMutable(decoded);
    } catch (e) {
      print('JSON 解码失败: $e');
      return {};
    }
  }

  static Map<String, dynamic> _ensureMapIsMutable(dynamic data) {
    if (data is Map) {
      final result = <String, dynamic>{};
      data.forEach((key, value) {
        final String stringKey = key.toString();
        if (value is Map) {
          result[stringKey] = _ensureMapIsMutable(value);
        } else if (value is List) {
          result[stringKey] = _ensureListIsMutable(value);
        } else {
          result[stringKey] = value;
        }
      });
      return result;
    }
    return {};
  }

  static List<dynamic> _ensureListIsMutable(List<dynamic> list) {
    final result = <dynamic>[];
    for (var item in list) {
      if (item is Map) {
        result.add(_ensureMapIsMutable(item));
      } else if (item is List) {
        result.add(_ensureListIsMutable(item));
      } else {
        result.add(item);
      }
    }
    return result;
  }

  // 获取暂存数据
  Future<Map<String, dynamic>?> getTempData({
    required String formType,
    required String billNo,
  }) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'temp_data',
      where: 'formType = ? AND billNo = ?',
      whereArgs: [formType, billNo],
    );

    if (maps.isNotEmpty) {
      final record = Map<String, dynamic>.from(maps.first);
      try {
        final dataString = record['data'] as String;
        record['data'] = _decodeJson(dataString);
      } catch (e) {
        print('解析缓存数据失败: $e');
        return null;
      }
      return record;
    }
    return null;
  }

  // 根据单据类型获取所有暂存数据
  Future<List<Map<String, dynamic>>> getTempDataByFormType(String formType) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'temp_data',
      where: 'formType = ?',
      whereArgs: [formType],
      orderBy: 'updateTime DESC',
    );

    for (var record in maps) {
      try {
        record['data'] = jsonDecode(record['data']);
      } catch (e) {
        print('解析缓存数据失败: $e');
        record['data'] = {};
      }
    }

    return maps;
  }

  // 删除暂存数据
  Future<int> deleteTempData({
    required String formType,
    required String billNo,
  }) async {
    final db = await database;
    return await db.delete(
      'temp_data',
      where: 'formType = ? AND billNo = ?',
      whereArgs: [formType, billNo],
    );
  }

  // 删除指定单据类型的所有暂存数据
  Future<int> deleteTempDataByFormType(String formType) async {
    final db = await database;
    return await db.delete(
      'temp_data',
      where: 'formType = ?',
      whereArgs: [formType],
    );
  }

  // 获取所有暂存数据
  Future<List<Map<String, dynamic>>> getAllTempData() async {
    final db = await database;
    return await db.query('temp_data', orderBy: 'updateTime DESC');
  }

  // 清理过期数据（比如超过30天的数据）
  Future<int> cleanExpiredData({int days = 30}) async {
    final db = await database;
    final cutoffDate = DateTime.now().subtract(Duration(days: days));

    return await db.delete(
      'temp_data',
      where: 'updateTime < ?',
      whereArgs: [cutoffDate.toIso8601String()],
    );
  }

  // 获取数据库大小（用于管理）
  Future<int> getDatabaseSize() async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT page_count * page_size as size FROM pragma_page_count(), pragma_page_size()'
    );
    return result.isNotEmpty ? result.first['size'] as int : 0;
  }

  // 关闭数据库
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}