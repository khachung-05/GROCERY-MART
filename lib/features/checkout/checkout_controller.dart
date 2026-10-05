import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/storage/local_storage.dart';
import '../../core/utils/formatters.dart';
import '../../data/datasource/mock_data.dart';
import '../../data/models/order_model.dart';
import '../../data/models/voucher_model.dart';
import '../../data/repositories/order_repository.dart';
import '../admin/admin_controller.dart';
import '../cart/cart_controller.dart';
import '../notification/notification_controller.dart';
import '../order/order_controller.dart';
import '../order/order_success_screen.dart';

class CheckoutController extends GetxController {
  final OrderRepository _orderRepo = OrderRepository();
  final CartController _cartController = Get.find<CartController>();

  // Khai báo các biến phản ứng
  final RxDouble shippingFee = 15000.0.obs;
  final RxString shippingMethod = 'Giao hàng tiêu chuẩn'.obs;
  final RxString paymentMethod = 'COD - Thanh toán khi nhận hàng'.obs;
  final RxBool isLoading = false.obs;

  final RxString receiverName = 'Phạm Khắc Hùng'.obs;
  final RxString receiverPhone = '0123456789'.obs;
  final RxString shippingAddress = 'Vĩnh Tuy 2, Mạo Khê, Uông Bí, Quảng Ninh'.obs;

  // VOUCHER / MÃ GIẢM GIÁ
  final Rx<VoucherModel?> selectedVoucher = Rx<VoucherModel?>(null);
  final RxDouble discountAmount = 0.0.obs;
  final RxList<VoucherModel> availableVouchers = <VoucherModel>[].obs;
  final TextEditingController voucherCodeInputCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadAddress();
    loadVouchers();
  }

  void loadVouchers() {
    final List<VoucherModel> list = List<VoucherModel>.from(MockData.mockVouchers);

    // Đồng bộ với AdminController nếu có tạo thêm voucher
    if (Get.isRegistered<AdminController>()) {
      final adminCtrl = Get.find<AdminController>();
      for (final av in adminCtrl.vouchers) {
        if (!list.any((v) => v.code.toUpperCase() == av.code.toUpperCase())) {
          list.add(VoucherModel(
            id: av.id,
            code: av.code,
            title: av.title,
            discountType: av.discountType,
            discountValue: av.discountValue,
            minOrderValue: av.minOrderValue,
            maxDiscount: av.maxDiscount,
            expiryDate: av.expiryDate,
            description: 'Khuyến mãi đặc quyền từ hệ thống',
            isActive: av.isActive,
          ));
        }
      }
    }

    availableVouchers.assignAll(list.where((v) => v.isActive).toList());
  }

  Future<void> loadAddress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawJson = prefs.getString('user_saved_addresses');
      if (rawJson != null && rawJson.isNotEmpty) {
        final List decoded = jsonDecode(rawJson);
        final defaultAddr = decoded.firstWhere(
          (item) => item is Map && (item['isDefault'] == true || item['isDefault'] == 1),
          orElse: () => decoded.first,
        );
        if (defaultAddr is Map) {
          String name = defaultAddr['name']?.toString() ?? receiverName.value;
          if (name == 'Nguyễn Anh Quân') name = 'Phạm Khắc Hùng';
          receiverName.value = name;
          receiverPhone.value = defaultAddr['phone']?.toString() ?? receiverPhone.value;
          shippingAddress.value = (defaultAddr['address'] ?? defaultAddr['fullAddress'])?.toString() ?? shippingAddress.value;
        }
      }
    } catch (_) {}
  }

  void updateAddress(String name, String phone, String address) {
    receiverName.value = name;
    receiverPhone.value = phone;
    shippingAddress.value = address;
  }

  double get subtotal => _cartController.subtotal;
  double get totalAmount {
    final t = subtotal + shippingFee.value - discountAmount.value;
    return t > 0 ? t : 0.0;
  }

  void selectShipping(String method, double fee) {
    shippingMethod.value = method;
    shippingFee.value = fee;
    if (selectedVoucher.value != null) {
      discountAmount.value = selectedVoucher.value!.calculateDiscount(subtotal, shippingFee.value);
    }
  }

  void applyVoucher(VoucherModel voucher) {
    if (subtotal < voucher.minOrderValue) {
      final diff = voucher.minOrderValue - subtotal;
      Get.snackbar(
        'Chưa đủ điều kiện',
        'Mua thêm ${Formatters.formatCurrency(diff)} để áp dụng mã "${voucher.code}"',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFFD97706),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    selectedVoucher.value = voucher;
    discountAmount.value = voucher.calculateDiscount(subtotal, shippingFee.value);

    Get.snackbar(
      'Áp dụng mã thành công! 🎉',
      'Đã giảm ${Formatters.formatCurrency(discountAmount.value)} vào tổng thanh toán.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF059669),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void applyVoucherByCode(String code) {
    final trimmed = code.trim().toUpperCase();
    if (trimmed.isEmpty) {
      Get.snackbar(
        'Thông báo',
        'Vui lòng nhập mã giảm giá',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    final found = availableVouchers.firstWhereOrNull((v) => v.code.toUpperCase() == trimmed);
    if (found == null) {
      Get.snackbar(
        'Mã không tồn tại',
        'Mã "$trimmed" không hợp lệ hoặc đã hết hạn sử dụng.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    applyVoucher(found);
  }

  void removeVoucher() {
    selectedVoucher.value = null;
    discountAmount.value = 0.0;
    Get.snackbar(
      'Đã gỡ mã giảm giá',
      'Mã khuyến mãi đã được hủy bỏ khỏi đơn hàng.',
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void onClose() {
    voucherCodeInputCtrl.dispose();
    super.onClose();
  }

  dynamic _safeRead(dynamic target, String key) {
    if (target == null) return null;
    if (target is Map) return target[key];
    try {
      final json = target.toJson();
      if (json is Map && json.containsKey(key)) return json[key];
    } catch (_) {}
    return null;
  }

  Future<void> submitOrder() async {
    final List cartList = _cartController.cartItems.isNotEmpty
        ? _cartController.cartItems
        : _cartController.items;

    if (cartList.isEmpty) {
      Get.snackbar(
        'Thông báo',
        'Giỏ hàng của bạn đang trống!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      final orderId = 'ORD${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

      final List<OrderItemModel> orderItems = cartList.map<OrderItemModel>((dynamic cartItem) {
        dynamic prod;
        try {
          prod = cartItem.product;
        } catch (_) {
          prod = _safeRead(cartItem, 'product');
        }

        String pName = 'Sản phẩm';
        try {
          if (prod != null) {
            pName = (prod.name ?? prod.title ?? _safeRead(prod, 'name') ?? _safeRead(prod, 'title') ?? 'Sản phẩm').toString();
          }
        } catch (_) {
          pName = (_safeRead(prod, 'name') ?? _safeRead(prod, 'title') ?? 'Sản phẩm').toString();
        }
        if (pName == 'Sản phẩm') {
          pName = (_safeRead(cartItem, 'name') ?? _safeRead(cartItem, 'productName') ?? 'Sản phẩm').toString();
        }

        String pId = '';
        try {
          if (prod != null) {
            pId = (prod.id ?? _safeRead(prod, 'id') ?? '').toString();
          }
        } catch (_) {
          pId = (_safeRead(prod, 'id') ?? '').toString();
        }
        if (pId.isEmpty) {
          pId = (_safeRead(cartItem, 'productId') ?? _safeRead(cartItem, 'id') ?? '').toString();
        }

        String pImage = '';
        try {
          if (prod != null) {
            pImage = (prod.image ?? prod.imageUrl ?? _safeRead(prod, 'image') ?? _safeRead(prod, 'imageUrl') ?? '').toString();
          }
        } catch (_) {
          pImage = (_safeRead(prod, 'image') ?? _safeRead(prod, 'imageUrl') ?? '').toString();
        }
        if (pImage.isEmpty) {
          pImage = (_safeRead(cartItem, 'image') ?? _safeRead(cartItem, 'productImage') ?? '').toString();
        }

        double pPrice = 0.0;
        try {
          if (prod != null && prod.price != null) {
            pPrice = (prod.price as num).toDouble();
          }
        } catch (_) {
          final val = _safeRead(prod, 'price');
          if (val is num) pPrice = val.toDouble();
        }
        if (pPrice == 0.0) {
          final val = _safeRead(cartItem, 'price');
          if (val is num) pPrice = val.toDouble();
        }

        int pQuantity = 1;
        try {
          pQuantity = (cartItem.quantity as num).toInt();
        } catch (_) {
          final val = _safeRead(cartItem, 'quantity');
          if (val is num) pQuantity = val.toInt();
        }

        String pUnit = 'kg';
        try {
          if (prod != null && prod.unit != null) {
            pUnit = prod.unit.toString();
          }
        } catch (_) {
          pUnit = (_safeRead(prod, 'unit') ?? 'kg').toString();
        }
        if (pUnit == 'kg') {
          pUnit = (_safeRead(cartItem, 'unit') ?? 'kg').toString();
        }

        return OrderItemModel(
          productId: pId,
          productName: pName,
          productImage: pImage,
          price: pPrice,
          quantity: pQuantity,
          unit: pUnit,
        );
      }).toList();

      final newOrder = OrderModel(
        id: orderId,
        userId: LocalStorage.currentUserId ?? 'guest',
        items: orderItems,
        subtotal: subtotal,
        shippingFee: shippingFee.value,
        totalAmount: totalAmount,
        shippingAddress: shippingAddress.value,
        receiverName: receiverName.value,
        receiverPhone: receiverPhone.value,
        paymentMethod: paymentMethod.value,
        status: 'Chờ xác nhận',
        orderDate: DateTime.now().toString().split('.')[0],
        discountAmount: discountAmount.value,
        voucherCode: selectedVoucher.value?.code,
      );

      // Lưu đơn hàng và làm sạch giỏ hàng cục bộ
      await _orderRepo.saveOrder(newOrder);
      if (Get.isRegistered<OrderController>()) {
        await Get.find<OrderController>().loadOrders();
      } else {
        Get.put(OrderController()).loadOrders();
      }
      if (Get.isRegistered<NotificationController>()) {
        Get.find<NotificationController>().loadNotifications();
      }
      await _cartController.clearCart();

      // Chuyển thẳng tới màn hình Đặt hàng thành công
      Get.off(() => const OrderSuccessScreen(), arguments: newOrder);
    } catch (e) {
      Get.snackbar('Lỗi đặt hàng', '$e', backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}