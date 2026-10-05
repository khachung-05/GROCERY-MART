import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_routes.dart';
import '../../core/storage/local_storage.dart';
import '../../data/datasource/mock_data.dart';
import '../../data/repositories/order_repository.dart';
import '../../data/models/order_model.dart';
import '../home/main_controller.dart';

class NotificationItem {
  final String id;
  final String category; // 'promo', 'order', 'news'
  final String categoryLabel;
  final Color categoryColor;
  final Gradient iconGradient;
  final IconData icon;
  final String title;
  final String description;
  final String time;
  final String section; // 'Hôm nay', 'Trước đó'
  final String? code;
  final String? discountLabel;
  final String? orderId;
  final String? orderStatus;
  final String? actionLabel;
  final String? actionType; // 'category', 'orders', 'register'
  bool isUnread;

  NotificationItem({
    required this.id,
    required this.category,
    required this.categoryLabel,
    required this.categoryColor,
    required this.iconGradient,
    required this.icon,
    required this.title,
    required this.description,
    required this.time,
    required this.section,
    this.code,
    this.discountLabel,
    this.orderId,
    this.orderStatus,
    this.actionLabel,
    this.actionType,
    this.isUnread = false,
  });
}

class NotificationController extends GetxController {
  final RxList<NotificationItem> notifications = <NotificationItem>[].obs;
  final RxString selectedTab = 'all'.obs;
  final RxSet<String> copiedCodes = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  NotificationItem _mapOrderToNotification(OrderModel order) {
    final status = order.status.trim();
    final isDelivered = status.contains('Đã giao') ||
        status.contains('thành công') ||
        status == 'Hoàn thành';
    final isShipping = status.contains('Đang giao') || status.contains('vận chuyển');
    final isProcessing = status.contains('Chờ xử lý') || status.contains('đóng gói');
    final isCancelled = status.contains('Đã hủy') || status.contains('hủy');

    final Color categoryColor;
    final Gradient iconGradient;
    final IconData icon;
    final String title;
    final String description;
    final String orderStatusLabel;
    final String actionLabel;

    if (isDelivered) {
      categoryColor = const Color(0xFF059669);
      iconGradient = const LinearGradient(
        colors: [Color(0xFF10B981), Color(0xFF047857)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
      icon = Icons.check_circle_rounded;
      title = 'Đơn hàng #${order.id} đã giao thành công 🎉';
      final summary = order.items.isNotEmpty
          ? order.items.map((e) => e.productName).take(2).join(', ')
          : 'Thực phẩm sạch';
      description =
          'Kiện hàng "$summary" đã được giao an toàn đến bạn. Cảm ơn bạn đã tin tưởng mua sắm tại Grocery Mart!';
      orderStatusLabel = 'Đã giao hàng';
      actionLabel = 'Xem chi tiết đơn ➔';
    } else if (isShipping) {
      categoryColor = const Color(0xFF0284C7);
      iconGradient = const LinearGradient(
        colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
      icon = Icons.local_shipping_rounded;
      title = 'Đơn hàng #${order.id} đang trên đường giao 🚚';
      description = order.carrier != null && order.trackingCode != null
          ? 'Đơn đang vận chuyển bởi ${order.carrier} (Mã: ${order.trackingCode}). Shipper sẽ sớm liên hệ bạn.'
          : 'Tài xế đang vận chuyển nông sản tươi ngon đến địa chỉ của bạn. Dự kiến giao sớm.';
      orderStatusLabel = 'Đang giao hàng';
      actionLabel = 'Xem hành trình ➔';
    } else if (isProcessing) {
      categoryColor = const Color(0xFFD97706);
      iconGradient = const LinearGradient(
        colors: [Color(0xFFFBBF24), Color(0xFFD97706)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
      icon = Icons.inventory_2_rounded;
      title = 'Đơn hàng #${order.id} đang được đóng gói 📦';
      description =
          'Cửa hàng đang kiểm tra và đóng gói nông sản tươi sạch để bàn giao cho đơn vị vận chuyển.';
      orderStatusLabel = 'Đang đóng gói';
      actionLabel = 'Xem chi tiết đơn ➔';
    } else if (isCancelled) {
      categoryColor = const Color(0xFFDC2626);
      iconGradient = const LinearGradient(
        colors: [Color(0xFFF87171), Color(0xFFDC2626)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
      icon = Icons.cancel_rounded;
      title = 'Đơn hàng #${order.id} đã bị hủy ❌';
      description = order.refundReason != null && order.refundReason!.isNotEmpty
          ? 'Đơn hàng đã hủy. Lý do: ${order.refundReason}.'
          : 'Đơn hàng #${order.id} đã được hủy thành công theo yêu cầu.';
      orderStatusLabel = 'Đã hủy đơn';
      actionLabel = 'Xem chi tiết đơn ➔';
    } else {
      categoryColor = const Color(0xFFEA580C);
      iconGradient = const LinearGradient(
        colors: [Color(0xFFFB923C), Color(0xFFEA580C)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
      icon = Icons.hourglass_top_rounded;
      title = 'Đơn hàng #${order.id} đã đặt, chờ xác nhận ⏳';
      description =
          'Grocery Mart đã tiếp nhận đơn đặt hàng của bạn. Cửa hàng sẽ sớm kiểm tra và xác nhận đơn.';
      orderStatusLabel = 'Chờ xác nhận';
      actionLabel = 'Xem chi tiết đơn ➔';
    }

    String timeDisplay = 'Vừa xong';
    String section = 'Hôm nay';
    try {
      final dt = DateTime.tryParse(order.orderDate);
      if (dt != null) {
        final now = DateTime.now();
        final diff = now.difference(dt);
        if (diff.inMinutes < 60) {
          timeDisplay = diff.inMinutes <= 1 ? 'Vừa xong' : '${diff.inMinutes} phút trước';
          section = 'Hôm nay';
        } else if (diff.inHours < 24 && dt.day == now.day) {
          timeDisplay = '${diff.inHours} giờ trước';
          section = 'Hôm nay';
        } else if (diff.inDays <= 1 || dt.day == now.subtract(const Duration(days: 1)).day) {
          timeDisplay = 'Hôm qua';
          section = 'Trước đó';
        } else {
          timeDisplay = '${dt.day}/${dt.month}/${dt.year}';
          section = 'Trước đó';
        }
      }
    } catch (_) {}

    final notifId = order.id == 'ORD-8821' ? 'notif_101' : 'notif_order_${order.id}';

    return NotificationItem(
      id: notifId,
      category: 'order',
      categoryLabel: 'ĐƠN HÀNG',
      categoryColor: categoryColor,
      iconGradient: iconGradient,
      icon: icon,
      title: title,
      description: description,
      time: timeDisplay,
      section: section,
      orderId: order.id,
      orderStatus: orderStatusLabel,
      actionLabel: actionLabel,
      actionType: 'orders',
      isUnread: true,
    );
  }

  Future<void> loadNotifications() async {
    final isLoggedIn = LocalStorage.isLoggedIn;
    final currentUserId = LocalStorage.currentUserId ?? (isLoggedIn ? 'user_001' : 'guest');
    final readIds = LocalStorage.getReadNotificationIds().toSet();
    final deletedIds = LocalStorage.getDeletedNotificationIds().toSet();

    List<OrderModel> ordersToDisplay = [];
    try {
      final repoOrders = await OrderRepository().getOrders();
      if (isLoggedIn) {
        // Lấy tất cả đơn của user đang đăng nhập (hoặc user_001 mặc định demo)
        ordersToDisplay = repoOrders
            .where((o) =>
                o.userId == currentUserId ||
                (currentUserId == 'user_001' && (o.userId.isEmpty || o.userId == 'user_001')))
            .toList();
        if (ordersToDisplay.isEmpty) {
          ordersToDisplay = repoOrders;
        }
      } else {
        // Khách vãng lai: hiển thị đơn guest nếu có
        ordersToDisplay = repoOrders.where((o) => o.userId == 'guest').toList();
      }
    } catch (_) {
      if (isLoggedIn) {
        ordersToDisplay = MockData.orders;
      }
    }

    final List<NotificationItem> orderNotifItems =
        ordersToDisplay.map((order) => _mapOrderToNotification(order)).toList();

    List<NotificationItem> rawItems;

    if (!isLoggedIn) {
      // Dành cho Khách vãng lai
      rawItems = [
        ...orderNotifItems,
        NotificationItem(
          id: 'notif_001',
          category: 'promo',
          categoryLabel: 'ƯU ĐÃI',
          categoryColor: const Color(0xFFEA580C),
          iconGradient: const LinearGradient(
            colors: [Color(0xFFFF7A00), Color(0xFFFF3E3E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          icon: Icons.local_activity_rounded,
          title: 'Tặng mã 20.000đ cho đơn hàng đầu tiên 🎉',
          description:
              'Chào mừng bạn đến với Grocery App! Áp dụng cho đơn hàng nông sản, rau củ hữu cơ từ 100.000đ.',
          time: '10 phút trước',
          section: 'Hôm nay',
          code: 'FRESH20',
          discountLabel: 'Giảm 20.000đ',
          actionLabel: 'Dùng ngay ➔',
          actionType: 'category',
          isUnread: true,
        ),
        NotificationItem(
          id: 'notif_002',
          category: 'promo',
          categoryLabel: 'THÀNH VIÊN',
          categoryColor: const Color(0xFF2563EB),
          iconGradient: const LinearGradient(
            colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          icon: Icons.stars_rounded,
          title: 'Đăng ký thành viên nhận quà chào mừng ⭐',
          description:
              'Đăng ký chỉ mất 30 giây để tích điểm thành viên, miễn phí vận chuyển và nhận ưu đãi riêng vào thứ 6 hàng tuần.',
          time: '1 giờ trước',
          section: 'Hôm nay',
          discountLabel: 'Tặng 50 Xu',
          actionLabel: 'Đăng ký ngay ➔',
          actionType: 'register',
          isUnread: true,
        ),
        NotificationItem(
          id: 'notif_003',
          category: 'news',
          categoryLabel: 'NÔNG SẢN SẠCH',
          categoryColor: const Color(0xFF059669),
          iconGradient: const LinearGradient(
            colors: [Color(0xFF10B981), Color(0xFF047857)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          icon: Icons.eco_rounded,
          title: 'Nông sản VietGAP tươi ngon vừa về kho 🍎',
          description:
              'Xoài Cát Hòa Lộc, Táo Envy New Zealand và Cam Sành Tiền Giang vừa được nhập mới chuẩn tươi sáng nay.',
          time: 'Hôm qua',
          section: 'Trước đó',
          actionLabel: 'Xem sản phẩm ➔',
          actionType: 'category',
          isUnread: false,
        ),
      ];
    } else {
      // Dành cho Người dùng đã đăng nhập: toàn bộ đơn hàng + ưu đãi & tin tức
      rawItems = [
        ...orderNotifItems,
        NotificationItem(
          id: 'notif_102',
          category: 'promo',
          categoryLabel: 'ƯU ĐÃI',
          categoryColor: const Color(0xFFEA580C),
          iconGradient: const LinearGradient(
            colors: [Color(0xFFFF7A00), Color(0xFFFF3E3E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          icon: Icons.local_offer_rounded,
          title: 'Ưu đãi hoàn xu 10% ngày vàng 🎁',
          description:
              'Áp dụng cho toàn bộ danh mục Rau củ hữu cơ và Trái cây nhập khẩu khi mua từ 2kg trở lên trong tuần này.',
          time: '2 giờ trước',
          section: 'Hôm nay',
          code: 'HOANXU10',
          discountLabel: 'Hoàn 10% xu',
          actionLabel: 'Mua sắm ngay ➔',
          actionType: 'category',
          isUnread: true,
        ),
        NotificationItem(
          id: 'notif_103',
          category: 'news',
          categoryLabel: 'NÔNG SẢN SẠCH',
          categoryColor: const Color(0xFF16A34A),
          iconGradient: const LinearGradient(
            colors: [Color(0xFF22C55E), Color(0xFF15803D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          icon: Icons.eco_rounded,
          title: 'Nông sản sạch vừa cập bến 🍎',
          description:
              'Xoài Cát Hòa Lộc, Táo Envy và Cam Sành Tiền Giang vừa được nhập mới chuẩn VietGAP.',
          time: 'Hôm qua',
          section: 'Trước đó',
          actionLabel: 'Xem sản phẩm ➔',
          actionType: 'category',
          isUnread: false,
        ),
      ];
    }

    // Lọc bỏ thông báo đã xóa và cập nhật trạng thái đã đọc từ LocalStorage
    final activeItems = rawItems.where((item) => !deletedIds.contains(item.id)).toList();
    for (var item in activeItems) {
      if (readIds.contains(item.id)) {
        item.isUnread = false;
      }
    }

    notifications.assignAll(activeItems);
  }

  int get unreadCount => notifications.where((n) => n.isUnread).length;

  int countByCategory(String cat) {
    if (cat == 'all') return notifications.length;
    return notifications.where((n) => n.category == cat).length;
  }

  List<NotificationItem> get filteredNotifications {
    if (selectedTab.value == 'all') return notifications;
    return notifications.where((n) => n.category == selectedTab.value).toList();
  }

  void markAllAsRead() {
    final readIds = LocalStorage.getReadNotificationIds().toSet();
    for (var item in notifications) {
      item.isUnread = false;
      readIds.add(item.id);
    }
    LocalStorage.saveReadNotificationIds(readIds.toList());
    notifications.refresh();
  }

  void markAsRead(String id) {
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1 && notifications[index].isUnread) {
      notifications[index].isUnread = false;
      final readIds = LocalStorage.getReadNotificationIds().toSet();
      readIds.add(id);
      LocalStorage.saveReadNotificationIds(readIds.toList());
      notifications.refresh();
    }
  }

  void deleteNotification(String id) {
    notifications.removeWhere((n) => n.id == id);
    final deletedIds = LocalStorage.getDeletedNotificationIds().toSet();
    deletedIds.add(id);
    LocalStorage.saveDeletedNotificationIds(deletedIds.toList());
  }

  Future<void> handleAction(NotificationItem item) async {
    markAsRead(item.id);

    if (item.actionType == 'register') {
      Get.toNamed(AppRoutes.register);
    } else if (item.actionType == 'orders') {
      if (item.orderId != null) {
        try {
          final allOrders = await OrderRepository().getOrders();
          final target = allOrders.firstWhereOrNull((o) => o.id == item.orderId) ??
              MockData.orders.firstWhereOrNull((o) => o.id == item.orderId);
          if (target != null) {
            Get.toNamed(AppRoutes.orderDetail, arguments: target);
            return;
          }
        } catch (_) {}
      }

      if (Get.isRegistered<MainController>()) {
        Get.find<MainController>().changeTab(3);
        Get.until((route) => route.settings.name == AppRoutes.main || route.isFirst);
      } else {
        Get.toNamed(AppRoutes.orders);
      }
    } else if (item.actionType == 'category') {
      if (Get.isRegistered<MainController>()) {
        Get.find<MainController>().changeTab(1);
        Get.until((route) => route.settings.name == AppRoutes.main || route.isFirst);
      } else {
        Get.toNamed(AppRoutes.category);
      }
    }
  }
}
