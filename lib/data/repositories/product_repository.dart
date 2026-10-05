import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category_model.dart';
import '../models/product_model.dart';

class ProductRepository {
  // CẤU HÌNH ĐỊA CHỈ SERVER:
  // - Chạy trên Chrome (Web): dùng 'http://localhost:3000/api'
  // - Chạy trên Máy ảo Android (Emulator): dùng 'http://10.0.2.2:3000/api'
  // - Chạy trên Điện thoại thật: dùng IP mạng LAN của máy tính (ví dụ 'http://192.168.1.15:3000/api')
  static const String baseUrl = 'http://localhost:3000/api';

  /// 1. Lấy toàn bộ danh sách sản phẩm từ MySQL qua API
  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ProductModel.fromJson(json)).toList();
      } else {
        throw Exception('Lỗi lấy danh sách sản phẩm: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Không thể kết nối máy chủ: $e');
    }
  }

  /// 2. Lọc sản phẩm theo danh mục
  Future<List<ProductModel>> getProductsByCategory(String categoryId) async {
    final allProducts = await getProducts();
    return allProducts.where((p) => p.categoryId == categoryId).toList();
  }

  /// 3. Tìm kiếm sản phẩm theo từ khóa
  Future<List<ProductModel>> searchProducts(String query) async {
    final allProducts = await getProducts();
    final lower = query.toLowerCase().trim();
    if (lower.isEmpty) return [];
    return allProducts
        .where((p) => p.name.toLowerCase().contains(lower))
        .toList();
  }

  /// 4. Lấy danh sách danh mục từ MySQL qua API
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/categories'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => CategoryModel.fromJson(json)).toList();
      } else {
        throw Exception('Lỗi lấy danh mục: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Không thể kết nối máy chủ: $e');
    }
  }

  /// 5. Thêm sản phẩm mới (Admin)
  Future<void> addProduct(ProductModel product) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/products'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product.toJson()),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Lỗi thêm sản phẩm: ${response.body}');
    }
  }

  /// 6. Cập nhật sản phẩm (Admin)
  Future<void> updateProduct(ProductModel product) async {
    final response = await http.put(
      Uri.parse('$baseUrl/admin/products/${product.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Lỗi cập nhật sản phẩm: ${response.body}');
    }
  }

  /// 7. Xóa sản phẩm (Admin)
  Future<void> deleteProduct(String productId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/admin/products/$productId'),
    );
    if (response.statusCode != 200) {
      throw Exception('Lỗi xóa sản phẩm: ${response.body}');
    }
  }
}
