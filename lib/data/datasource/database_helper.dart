import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/category_model.dart';
import '../models/product_model.dart';
import 'mock_data.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('grocery_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    String path;
    if (kIsWeb) {
      // Trên Web truyền thẳng tên file, databaseFactoryFfiWeb sẽ tự map vào IndexedDB
      path = filePath;
    } else {
      final dbPath = await getDatabasesPath();
      path = p.join(dbPath, filePath);
    }

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onOpen: _onOpenDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Tạo bảng Danh mục nếu chưa có
    await db.execute('''
      CREATE TABLE IF NOT EXISTS categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        icon TEXT,
        image TEXT,
        description TEXT
      )
    ''');

    // 2. Tạo bảng Sản phẩm chuẩn theo Model nếu chưa có
    await db.execute('''
      CREATE TABLE IF NOT EXISTS products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        price REAL NOT NULL,
        originalPrice REAL,
        image TEXT,
        categoryId TEXT,
        unit TEXT,
        isFavorite INTEGER DEFAULT 0,
        rating REAL,
        stock INTEGER,
        isHidden INTEGER DEFAULT 0,
        variants TEXT,
        tags TEXT,
        brand TEXT
      )
    ''');

    // 3. Nạp dữ liệu ban đầu
    await _seedInitialData(db);
  }

  Future<void> _onOpenDB(Database db) async {
    // Đảm bảo dữ liệu mẫu chỉ được nạp nếu cơ sở dữ liệu trống hoàn toàn
    await _seedInitialData(db);
  }

  Future<void> _seedInitialData(Database db) async {
    try {
      // Kiểm tra xem bảng products đã có dữ liệu chưa
      final existingProducts = await db.query('products', limit: 1);
      if (existingProducts.isEmpty) {
        for (var cat in MockData.categories) {
          await db.insert(
            'categories',
            cat.toMap(),
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }

        for (var prod in MockData.products) {
          await db.insert(
            'products',
            prod.toMap(),
            conflictAlgorithm: ConflictAlgorithm.ignore,
          );
        }
      }
    } catch (e) {
      debugPrint('Lỗi seed dữ liệu ban đầu: $e');
    }
  }

  // ================= CÁC THAO TÁC SẢN PHẨM =================
  Future<List<ProductModel>> getProducts() async {
    final db = await instance.database;
    final result = await db.query('products');
    return result.map((json) => ProductModel.fromMap(json)).toList();
  }

  Future<List<ProductModel>> getProductsByCategory(String categoryId) async {
    final db = await instance.database;
    final result = await db.query(
      'products',
      where: 'categoryId = ?',
      whereArgs: [categoryId],
    );
    return result.map((json) => ProductModel.fromMap(json)).toList();
  }

  // 1. THÊM SẢN PHẨM MỚI VÀO SQLITE
  Future<int> insertProduct(ProductModel product) async {
    final db = await instance.database;
    return await db.insert(
      'products',
      product.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // 2. CẬP NHẬT / SỬA THÔNG TIN SẢN PHẨM
  Future<int> updateProduct(ProductModel product) async {
    final db = await instance.database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  // 3. XÓA SẢN PHẨM THEO ID
  Future<int> deleteProduct(String id) async {
    final db = await instance.database;
    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> toggleFavorite(String id, bool isFavorite) async {
    final db = await instance.database;
    return await db.update(
      'products',
      {'isFavorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ================= CÁC THAO TÁC DANH MỤC =================
  Future<List<CategoryModel>> getCategories() async {
    final db = await instance.database;
    final result = await db.query('categories');
    return result.map((json) => CategoryModel.fromMap(json)).toList();
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  Future<void> debugPrintDatabase() async {
    final db = await database;
    final products = await db.query('products');
    debugPrint(
        '=== DANH SÁCH SẢN PHẨM TRONG SQLITE (${products.length} mục) ===');
    for (var p in products) {
      debugPrint(
          'ID: ${p['id']} | Tên: ${p['name']} | Giá: ${p['price']} | Tồn kho: ${p['stock']}');
    }
  }
}
