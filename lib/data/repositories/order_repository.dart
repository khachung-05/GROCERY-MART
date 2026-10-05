import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order_model.dart';
import '../../core/storage/local_storage.dart';

class OrderRepository {
  static const String baseUrl = 'http://localhost:3000/api/orders';

  Future<void> saveOrder(OrderModel order) async {
    final token = LocalStorage.token ?? '';
    try {
      final body = {
        'id': order.id,
        'user_id': order.userId,
        'receiver_name': order.receiverName,
        'receiver_phone': order.receiverPhone,
        'delivery_address': order.shippingAddress,
        'shipping_address': order.shippingAddress,
        'subtotal': order.subtotal,
        'total_amount': order.totalAmount,
        'shipping_fee': order.shippingFee,
        'payment_method': order.paymentMethod,
        'note': order.orderNote,
        'items': order.items.map((i) => {
          'id': i.productId,
          'product_id': i.productId,
          'product_name': i.productName,
          'product_image': i.productImage,
          'quantity': i.quantity,
          'price': i.price,
          'unit': i.unit,
        }).toList(),
      };

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Lỗi tạo đơn hàng: ${response.body}');
      }
    } catch (e) {
      print('Lỗi lưu OrderRepository: $e');
      rethrow;
    }
  }

  Future<List<OrderModel>> loadOrders([String? userId]) async {
    if (userId != null && userId.isNotEmpty) {
      return getOrdersForUser(userId);
    }
    return getOrders();
  }

  Future<List<OrderModel>> getOrdersForUser(String userId) async {
    final token = LocalStorage.token ?? '';
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => OrderModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Lỗi lấy đơn hàng cho user: $e');
      return [];
    }
  }

  Future<List<OrderModel>> getOrders() async {
    final token = LocalStorage.token ?? '';
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => OrderModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Lỗi đọc OrderRepository: $e');
      return [];
    }
  }

  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    final token = LocalStorage.token ?? '';
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$orderId/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'status': newStatus}),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Lỗi cập nhật trạng thái đơn hàng: $e');
      return false;
    }
  }
}