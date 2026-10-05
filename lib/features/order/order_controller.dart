import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/storage/local_storage.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';

class OrderController extends GetxController {
  final OrderRepository _orderRepo = OrderRepository();
  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  Future<void> loadOrders() async {
    isLoading.value = true;
    try {
      final currentUserId = LocalStorage.currentUserId ?? 'guest';
      var list = await _orderRepo.getOrdersForUser(currentUserId);
      orders.assignAll(list);
    } catch (e) {
      debugPrint('Lỗi tải danh sách đơn: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
