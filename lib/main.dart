import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'app.dart';
import 'core/storage/local_storage.dart';
import 'data/datasource/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Kích hoạt SQLite chạy trên trình duyệt Web qua IndexedDB
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

  // 2. Khởi tạo SharedPreferences
  await LocalStorage.init();

  // 3. Khởi tạo và ép ghi/đọc bảng dữ liệu ngay lập tức vào IndexedDB
  final db = await DatabaseHelper.instance.database;
  await db.query('products');

  runApp(const GroceryApp());
}
