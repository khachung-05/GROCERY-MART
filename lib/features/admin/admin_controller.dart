import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/storage/local_storage.dart';
import '../../core/utils/app_notification.dart';
import '../../data/models/order_model.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/order_repository.dart';
import '../../data/repositories/product_repository.dart';
import '../notification/notification_controller.dart';
import 'models/admin_models.dart';
import '../home/home_controller.dart';

class AdminController extends GetxController {
  final ProductRepository _productRepo = ProductRepository();
  final OrderRepository _orderRepo = OrderRepository();

  // Core Data
  final RxList<ProductModel> products = <ProductModel>[].obs;
  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxBool isLoading = false.obs;

  // Module 1: Inventory Logs
  final RxList<InventoryLogModel> inventoryLogs = <InventoryLogModel>[].obs;

  // Module 3: CRM & Reviews
  final RxList<CustomerModel> customers = <CustomerModel>[].obs;
  final RxList<ReviewModerationModel> reviews = <ReviewModerationModel>[].obs;
  final RxString customerSearchQuery = ''.obs;
  final RxString customerTierFilter = 'ALL'.obs;

  // Module 4: Promotions & Flash Sales
  final RxList<AdminVoucherModel> vouchers = <AdminVoucherModel>[].obs;
  final RxList<FlashSaleCampaignModel> flashSales =
      <FlashSaleCampaignModel>[].obs;

  // Module 6: RBAC Staff
  final RxList<StaffMemberModel> staffMembers = <StaffMemberModel>[].obs;

  // Cài đặt gian hàng & hệ thống
  final RxString storeName = ''.obs;
  final RxString storeHotline = ''.obs;
  final RxString storeAddress = ''.obs;
  final RxDouble storeShippingFee = 15000.0.obs;
  final RxBool autoAcceptOrders = true.obs;
  final RxBool soundNotification = true.obs;

  // Cổng thanh toán
  final RxBool enableCOD = true.obs;
  final RxBool enableVNPay = true.obs;
  final RxBool enableMoMo = true.obs;
  final RxBool enableZaloPay = false.obs;

  // Search & Filter state for Products
  final RxString productSearchQuery = ''.obs;
  final RxString selectedCategoryFilter =
      'ALL'.obs; // ALL, fruit, veg, meat, seafood, LOW_STOCK

  // Search & Filter state for Orders
  final RxString orderSearchQuery = ''.obs;
  final RxString selectedOrderStatusFilter = 'ALL'
      .obs; // ALL, Chờ xác nhận, Chờ xử lý, Đang giao, Đã giao, Đã hủy, Đổi trả

  @override
  void onInit() {
    super.onInit();
    loadStoreSettings();
    _seedEnterpriseMockData();
    fetchData(); // Gọi nạp trực tiếp từ MySQL qua Node.js Server
  }

  void loadStoreSettings() {
    storeName.value = LocalStorage.storeName;
    storeHotline.value = LocalStorage.storeHotline;
    storeAddress.value = LocalStorage.storeAddress;
    storeShippingFee.value = LocalStorage.storeShippingFee;
    autoAcceptOrders.value = LocalStorage.autoAcceptOrders;
    soundNotification.value = LocalStorage.soundNotification;
  }

  void _seedEnterpriseMockData() {
    // 1. Seed Khách hàng CRM
    customers.assignAll([
      CustomerModel(
        id: 'CUST-001',
        name: 'Nguyễn Văn An',
        email: 'an.nguyen@gmail.com',
        phone: '0901234567',
        address: '123 Nguyễn Huệ, P. Bến Nghé, Q.1, TP.HCM',
        tier: 'Kim Cương',
        points: 850,
        totalSpent: 4850000,
        ordersCount: 16,
        joinedDate: DateTime.now().subtract(const Duration(days: 120)),
      ),
      CustomerModel(
        id: 'CUST-002',
        name: 'Trần Thị Mai',
        email: 'mai.tran@gmail.com',
        phone: '0912345678',
        address: '45 Lê Duẩn, P. Bến Nghé, Q.1, TP.HCM',
        tier: 'Vàng',
        points: 420,
        totalSpent: 2650000,
        ordersCount: 9,
        joinedDate: DateTime.now().subtract(const Duration(days: 75)),
      ),
      CustomerModel(
        id: 'CUST-003',
        name: 'Lê Hoàng Long',
        email: 'long.le@gmail.com',
        phone: '0987654321',
        address: '88 Nguyễn Đình Chiểu, Q.3, TP.HCM',
        tier: 'Bạc',
        points: 190,
        totalSpent: 1240000,
        ordersCount: 4,
        joinedDate: DateTime.now().subtract(const Duration(days: 40)),
      ),
      CustomerModel(
        id: 'CUST-004',
        name: 'Phạm Thu Hương',
        email: 'huong.pham@gmail.com',
        phone: '0934567890',
        address: '102 Nam Kỳ Khởi Nghĩa, Q.1, TP.HCM',
        tier: 'Đồng',
        points: 50,
        totalSpent: 350000,
        ordersCount: 1,
        joinedDate: DateTime.now().subtract(const Duration(days: 8)),
      ),
    ]);

    // 2. Seed Vouchers
    vouchers.assignAll([
      AdminVoucherModel(
        id: 'VOUCHER-01',
        code: 'FRESH20',
        title: 'Giảm 20.000đ cho đơn hàng đầu tiên',
        discountType: 'FIXED',
        discountValue: 20000,
        minOrderValue: 100000,
        usageLimit: 200,
        usedCount: 45,
        expiryDate: DateTime.now().add(const Duration(days: 30)),
      ),
      AdminVoucherModel(
        id: 'VOUCHER-02',
        code: 'HOANXU10',
        title: 'Hoàn 10% xu cho rau củ quả hữu cơ',
        discountType: 'PERCENT',
        discountValue: 10,
        minOrderValue: 150000,
        maxDiscount: 50000,
        usageLimit: 500,
        usedCount: 182,
        expiryDate: DateTime.now().add(const Duration(days: 15)),
      ),
      AdminVoucherModel(
        id: 'VOUCHER-03',
        code: 'FREESHIP50',
        title: 'Miễn phí giao hàng đơn từ 200k',
        discountType: 'FIXED',
        discountValue: 15000,
        minOrderValue: 200000,
        usageLimit: 1000,
        usedCount: 420,
        expiryDate: DateTime.now().add(const Duration(days: 60)),
      ),
    ]);

    // 3. Seed Flash Sale
    flashSales.assignAll([
      FlashSaleCampaignModel(
        id: 'FS-01',
        title: 'Khung Giờ Vàng 12h - 14h: Rau Củ Tươi Giảm 25%',
        discountPercent: 25,
        startTime: DateTime.now().subtract(const Duration(hours: 1)),
        endTime: DateTime.now().add(const Duration(hours: 3)),
        productIds: ['prod_01', 'prod_02', 'prod_03'],
      ),
      FlashSaleCampaignModel(
        id: 'FS-02',
        title: 'Siêu Hội Trái Cây Nhập Khẩu 20h Tối Nay',
        discountPercent: 15,
        startTime: DateTime.now().add(const Duration(hours: 6)),
        endTime: DateTime.now().add(const Duration(hours: 10)),
        productIds: ['prod_04', 'prod_05'],
        isActive: false,
      ),
    ]);

    // 4. Seed Inventory Logs
    inventoryLogs.assignAll([
      InventoryLogModel(
        id: 'LOG-001',
        productId: 'prod_01',
        productName: 'Táo Envy New Zealand',
        type: 'IN',
        quantity: 50,
        stockAfter: 75,
        note: 'Nhập lô hàng nhập khẩu từ nhà cung cấp FreshFruit',
        actor: 'Trần Văn Kho (Quản lý kho)',
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      InventoryLogModel(
        id: 'LOG-002',
        productId: 'prod_02',
        productName: 'Cam Sành Tiền Giang',
        type: 'OUT',
        quantity: 12,
        stockAfter: 38,
        note: 'Xuất kho cho 4 đơn hàng sáng nay',
        actor: 'Hệ thống tự động',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      InventoryLogModel(
        id: 'LOG-003',
        productId: 'prod_03',
        productName: 'Cà Chua Bi Hữu Cơ',
        type: 'ADJUST',
        quantity: -2,
        stockAfter: 8,
        note: 'Kiểm kê phát hiện dập nát hủy bỏ',
        actor: 'Lê Thủ Kho',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ]);

    // 5. Seed Đánh giá sản phẩm
    reviews.assignAll([
      ReviewModerationModel(
        id: 'REV-001',
        productId: 'prod_01',
        productName: 'Táo Envy New Zealand',
        productImage: 'assets/images/apple.png',
        customerName: 'Nguyễn Văn An',
        rating: 5.0,
        comment: 'Táo rất giòn ngọt và tươi mát! Đóng gói cực kỳ cẩn thận.',
        reply:
            'Cảm ơn anh An đã tin dùng nông sản chuẩn sạch của Grocery Mart ạ! ❤️',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      ReviewModerationModel(
        id: 'REV-002',
        productId: 'prod_02',
        productName: 'Cam Sành Tiền Giang',
        productImage: 'assets/images/orange.png',
        customerName: 'Trần Thị Mai',
        rating: 4.0,
        comment: 'Cam mọng nước, nhiều vitamin C, giao nhanh trong 30 phút.',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      ReviewModerationModel(
        id: 'REV-003',
        productId: 'prod_03',
        productName: 'Cà Chua Bi Hữu Cơ',
        productImage: 'assets/images/tomato.png',
        customerName: 'Lê Hoàng Long',
        rating: 3.0,
        comment:
            'Có 1-2 quả hơi mềm do vận chuyển trời nắng, mong shop rút kinh nghiệm.',
        reply:
            'Shop thành thật xin lỗi anh! Shop đã gửi tặng anh mã giảm 20k bù lại cho đơn sau ạ.',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ]);

    // 6. Seed Nhân sự RBAC
    staffMembers.assignAll([
      StaffMemberModel(
        id: 'ST-001',
        name: 'Hoàng Minh Admin',
        email: 'admin@grocery.com',
        phone: '0909999999',
        role: 'Super Admin',
        permissions: [
          'products',
          'orders',
          'crm',
          'promotions',
          'analytics',
          'settings'
        ],
        joinedDate: DateTime.now().subtract(const Duration(days: 365)),
      ),
      StaffMemberModel(
        id: 'ST-002',
        name: 'Trần Kho Vận',
        email: 'khovan@grocery.com',
        phone: '0908888888',
        role: 'Quản lý kho',
        permissions: ['products'],
        joinedDate: DateTime.now().subtract(const Duration(days: 180)),
      ),
      StaffMemberModel(
        id: 'ST-003',
        name: 'Lê Chăm Sóc KH',
        email: 'cskh@grocery.com',
        phone: '0907777777',
        role: 'CSKH & Đơn hàng',
        permissions: ['orders', 'crm'],
        joinedDate: DateTime.now().subtract(const Duration(days: 90)),
      ),
      StaffMemberModel(
        id: 'ST-004',
        name: 'Ngô Kế Toán',
        email: 'ketoan@grocery.com',
        phone: '0906666666',
        role: 'Kế toán',
        permissions: ['analytics'],
        joinedDate: DateTime.now().subtract(const Duration(days: 60)),
      ),
    ]);
  }

  // ==================== CÀI ĐẶT GIAN HÀNG ====================
  void updateStoreName(String name) {
    final trimmed = name.trim();
    if (trimmed.isNotEmpty) {
      storeName.value = trimmed;
      LocalStorage.setStoreName(trimmed);
      AppNotification.showSuccess(
        title: 'Cập nhật thành công',
        message: 'Đã đổi tên cửa hàng thành "$trimmed"',
      );
    }
  }

  void updateStoreHotline(String hotline) {
    final trimmed = hotline.trim();
    if (trimmed.isNotEmpty) {
      storeHotline.value = trimmed;
      LocalStorage.setStoreHotline(trimmed);
      AppNotification.showSuccess(
        title: 'Cập nhật thành công',
        message: 'Đã cập nhật Hotline: $trimmed',
      );
    }
  }

  void updateStoreAddress(String address) {
    final trimmed = address.trim();
    if (trimmed.isNotEmpty) {
      storeAddress.value = trimmed;
      LocalStorage.setStoreAddress(trimmed);
      AppNotification.showSuccess(
        title: 'Cập nhật thành công',
        message: 'Đã cập nhật địa chỉ trụ sở mới',
      );
    }
  }

  void updateStoreShippingFee(double fee) {
    if (fee >= 0) {
      storeShippingFee.value = fee;
      LocalStorage.setStoreShippingFee(fee);
      AppNotification.showSuccess(
        title: 'Cập nhật thành công',
        message: 'Đã đổi phí giao hàng mặc định',
      );
    }
  }

  void toggleAutoAcceptOrders(bool val) {
    autoAcceptOrders.value = val;
    LocalStorage.setAutoAcceptOrders(val);
  }

  void toggleSoundNotification(bool val) {
    soundNotification.value = val;
    LocalStorage.setSoundNotification(val);
  }

  // ==================== DỮ LIỆU SẢN PHẨM & ĐƠN HÀNG ====================
  Future<void> fetchData() async {
    isLoading.value = true;
    try {
      final dbList = await _productRepo.getProducts();
      products.assignAll(dbList);
      final fetchedOrders = await _orderRepo.getOrders();
      orders.assignAll(fetchedOrders);
    } catch (e) {
      debugPrint('Lỗi nạp dữ liệu AdminController: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== THỐNG KÊ (GETTERS) ====================
  double get totalRevenue => orders
      .where((o) => o.status != 'Đã hủy')
      .fold(0.0, (sum, o) => sum + o.totalAmount);

  double get todayRevenue {
    final today = DateTime.now();
    return orders.where((o) {
      if (o.status == 'Đã hủy') return false;
      final d = _parseOrderDate(o.orderDate);
      return d.year == today.year &&
          d.month == today.month &&
          d.day == today.day;
    }).fold(0.0, (sum, o) => sum + o.totalAmount);
  }

  double get thisWeekRevenue {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    return orders.where((o) {
      if (o.status == 'Đã hủy') return false;
      final d = _parseOrderDate(o.orderDate);
      return d.isAfter(weekStart.subtract(const Duration(seconds: 1)));
    }).fold(0.0, (sum, o) => sum + o.totalAmount);
  }

  double get thisMonthRevenue {
    final now = DateTime.now();
    return orders.where((o) {
      if (o.status == 'Đã hủy') return false;
      final d = _parseOrderDate(o.orderDate);
      return d.year == now.year && d.month == now.month;
    }).fold(0.0, (sum, o) => sum + o.totalAmount);
  }

  DateTime _parseOrderDate(dynamic date) {
    if (date is DateTime) return date;
    if (date is String) return DateTime.tryParse(date) ?? DateTime.now();
    return DateTime.now();
  }

  int get totalOrdersCount => orders.length;

  int get pendingOrdersCount => orders
      .where((o) => o.status == 'Chờ xác nhận' || o.status == 'Chờ xử lý')
      .length;

  int get shippingOrdersCount =>
      orders.where((o) => o.status == 'Đang giao').length;

  int get completedOrdersCount =>
      orders.where((o) => o.status == 'Đã giao').length;

  int get cancelledOrdersCount =>
      orders.where((o) => o.status == 'Đã hủy').length;

  int get refundOrdersCount => orders
      .where((o) => o.refundStatus != null && o.refundStatus != 'none')
      .length;

  int get totalProductsCount => products.length;

  int get lowStockCount => products.where((p) => p.stock <= 10).length;

  double get cancellationRate {
    if (orders.isEmpty) return 0.0;
    return (cancelledOrdersCount / orders.length) * 100;
  }

  // ==================== BỘ LỌC SẢN PHẨM ====================
  List<ProductModel> get filteredProducts {
    final query = productSearchQuery.value.trim().toLowerCase();
    final category = selectedCategoryFilter.value;

    return products.where((p) {
      if (category == 'LOW_STOCK' && p.stock > 10) {
        return false;
      }
      if (category != 'ALL' &&
          category != 'LOW_STOCK' &&
          p.categoryId != category) {
        return false;
      }

      if (query.isNotEmpty) {
        final nameMatch = p.name.toLowerCase().contains(query);
        final idMatch = p.id.toLowerCase().contains(query);
        final brandMatch = p.brand?.toLowerCase().contains(query) ?? false;
        return nameMatch || idMatch || brandMatch;
      }
      return true;
    }).toList();
  }

  void setProductCategoryFilter(String categoryId) {
    selectedCategoryFilter.value = categoryId;
  }

  void toggleProductVisibility(String productId) {
    final index = products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      final p = products[index];
      final updated = p.copyWith(isHidden: !p.isHidden);
      _productRepo.updateProduct(updated);
      products[index] = updated;
      AppNotification.showSuccess(
        title: updated.isHidden ? 'Đã ẩn sản phẩm' : 'Đã hiện sản phẩm',
        message:
            'Sản phẩm "${updated.name}" đã ${updated.isHidden ? 'ẩn khỏi' : 'hiển thị trên'} app khách',
      );
    }
  }

  void quickUpdateStock(String productId, int change) {
    final index = products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      final oldProduct = products[index];
      final previousStock = oldProduct.stock;
      final newStock = (previousStock + change).clamp(0, 9999);
      final updatedProduct = oldProduct.copyWith(stock: newStock);

      _productRepo.updateProduct(updatedProduct);
      products[index] = updatedProduct;

      // Log lịch sử kho
      inventoryLogs.insert(
        0,
        InventoryLogModel(
          id: 'LOG-${DateTime.now().millisecondsSinceEpoch}',
          productId: updatedProduct.id,
          productName: updatedProduct.name,
          type: change > 0 ? 'IN' : 'OUT',
          quantity: change.abs(),
          stockAfter: newStock,
          note: change > 0
              ? 'Thêm nhanh từ bảng điều khiển kho'
              : 'Trừ tồn kho kiểm kê',
          actor: 'Quản trị viên',
          timestamp: DateTime.now(),
        ),
      );

      AppNotification.showStockUpdate(
        product: updatedProduct,
        previousStock: previousStock,
        newStock: newStock,
        change: change,
      );
    }
  }

  // Lưu sản phẩm: Đã bọc try-catch, tự động đóng loading và cập nhật dữ liệu
  void saveProduct(ProductModel product, bool isEdit) async {
    isLoading.value = true;
    try {
      if (isEdit) {
        await _productRepo.updateProduct(product);
        AppNotification.showSuccess(
          title: 'Cập nhật thành công',
          message: 'Sản phẩm "${product.name}" đã được cập nhật',
        );
      } else {
        await _productRepo.addProduct(product);
        AppNotification.showSuccess(
          title: 'Thêm sản phẩm thành công',
          message: 'Đã thêm sản phẩm mới "${product.name}" vào hệ thống',
        );
      }

      // Đồng bộ lại danh sách sản phẩm mới từ MySQL
      await fetchData();

      // Cập nhật ngay sang trang chủ nếu đang chạy
      if (Get.isRegistered<HomeController>()) {
        await Get.find<HomeController>().loadHomeData();
      }
    } catch (e) {
      debugPrint('Lỗi lưu sản phẩm: $e');
      AppNotification.showError(
        title: 'Thao tác thất bại',
        message: 'Lỗi: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void deleteProduct(String productId) async {
    try {
      await _productRepo.deleteProduct(productId);
      await fetchData();
      AppNotification.showSuccess(
        title: 'Đã xóa sản phẩm',
        message: 'Sản phẩm đã được xóa khỏi hệ thống thành công',
      );
    } catch (e) {
      AppNotification.showError(
        title: 'Xóa thất bại',
        message: 'Lỗi: $e',
      );
    }
  }

  // ==================== BỘ LỌC ĐƠN HÀNG ====================
  List<OrderModel> get filteredOrders {
    final query = orderSearchQuery.value.trim().toLowerCase();
    final status = selectedOrderStatusFilter.value;

    return orders.where((o) {
      if (status == 'REFUND') {
        if (o.refundStatus == null || o.refundStatus == 'none') return false;
      } else if (status != 'ALL' &&
          o.status.trim().toLowerCase() != status.trim().toLowerCase()) {
        if (!o.status
            .trim()
            .toLowerCase()
            .contains(status.trim().toLowerCase())) {
          return false;
        }
      }

      if (query.isNotEmpty) {
        final idMatch = o.id.toLowerCase().contains(query);
        final nameMatch = o.receiverName.toLowerCase().contains(query);
        final phoneMatch = o.receiverPhone.toLowerCase().contains(query);
        final trackingMatch =
            o.trackingCode?.toLowerCase().contains(query) ?? false;
        return idMatch || nameMatch || phoneMatch || trackingMatch;
      }
      return true;
    }).toList();
  }

  Future<void> changeOrderStatus(String orderId, String newStatus) async {
    final index = orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      orders[index] = orders[index].copyWith(status: newStatus);
      orders.refresh();
    }

    final success = await _orderRepo.updateOrderStatus(orderId, newStatus);
    if (success) {
      fetchData();
      if (Get.isRegistered<NotificationController>()) {
        Get.find<NotificationController>().loadNotifications();
      }
      AppNotification.showSuccess(
        title: 'Cập nhật trạng thái',
        message: 'Đơn hàng #$orderId đã chuyển sang "$newStatus"',
      );
    } else {
      AppNotification.showError(
        title: 'Cập nhật thất bại',
        message: 'Không thể cập nhật trạng thái đơn hàng #$orderId',
      );
    }
  }

  Future<void> assignOrderTracking({
    required String orderId,
    required String carrier,
    required String trackingCode,
  }) async {
    final index = orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final updated = orders[index].copyWith(
        carrier: carrier,
        trackingCode: trackingCode,
        status: 'Đang giao',
      );
      orders[index] = updated;
      await _orderRepo.updateOrderStatus(orderId, 'Đang giao');
      if (Get.isRegistered<NotificationController>()) {
        Get.find<NotificationController>().loadNotifications();
      }
      AppNotification.showSuccess(
        title: 'Gán mã vận đơn thành công',
        message: 'Đơn #$orderId gán qua "$carrier" - Mã: $trackingCode',
      );
    }
  }

  Future<void> updateOrderNote(String orderId, String note) async {
    final index = orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      orders[index] = orders[index].copyWith(orderNote: note);
      AppNotification.showSuccess(
        title: 'Lưu ghi chú đơn',
        message: 'Đã cập nhật ghi chú nội bộ cho đơn #$orderId',
      );
    }
  }

  void handleRefund({
    required String orderId,
    required bool isApprove,
    String? reason,
  }) async {
    final index = orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final old = orders[index];
      orders[index] = old.copyWith(
        refundStatus: isApprove ? 'approved' : 'rejected',
        refundReason: reason ?? old.refundReason,
        status: isApprove ? 'Đã hủy' : old.status,
      );
      if (isApprove) {
        await _orderRepo.updateOrderStatus(orderId, 'Đang hủy');
        if (Get.isRegistered<NotificationController>()) {
          Get.find<NotificationController>().loadNotifications();
        }
      }
      AppNotification.showSuccess(
        title: isApprove
            ? 'Đã duyệt hoàn hàng & hoàn tiền'
            : 'Đã từ chối hoàn hàng',
        message:
            'Đơn hàng #$orderId: ${isApprove ? 'Đã hoàn kho & hoàn tiền cho khách' : 'Yêu cầu bị từ chối'}',
      );
    }
  }

  // ==================== MODULE 3: CRM & KHÁCH HÀNG ====================
  List<CustomerModel> get filteredCustomers {
    final q = customerSearchQuery.value.trim().toLowerCase();
    final tier = customerTierFilter.value;

    return customers.where((c) {
      if (tier != 'ALL' && c.tier != tier) return false;
      if (q.isNotEmpty) {
        final matchName = c.name.toLowerCase().contains(q);
        final matchEmail = c.email.toLowerCase().contains(q);
        final matchPhone = c.phone.contains(q);
        return matchName || matchEmail || matchPhone;
      }
      return true;
    }).toList();
  }

  void adjustCustomerPoints(String customerId, int deltaPoints) {
    final index = customers.indexWhere((c) => c.id == customerId);
    if (index != -1) {
      final old = customers[index];
      final newPoints = (old.points + deltaPoints).clamp(0, 99999);
      String newTier = old.tier;
      if (newPoints >= 800) {
        newTier = 'Kim Cương';
      } else if (newPoints >= 400) {
        newTier = 'Vàng';
      } else if (newPoints >= 150) {
        newTier = 'Bạc';
      } else {
        newTier = 'Đồng';
      }

      customers[index] = old.copyWith(points: newPoints, tier: newTier);
      AppNotification.showSuccess(
        title: 'Cập nhật điểm thưởng',
        message:
            'Khách hàng "${old.name}" hiện có $newPoints điểm (Hạng: $newTier)',
      );
    }
  }

  void toggleCustomerBlock(String customerId) {
    final index = customers.indexWhere((c) => c.id == customerId);
    if (index != -1) {
      final old = customers[index];
      customers[index] = old.copyWith(isBlocked: !old.isBlocked);
      AppNotification.showSuccess(
        title: customers[index].isBlocked ? 'Đã khóa tài khoản' : 'Đã mở khóa',
        message: 'Trạng thái khách hàng "${old.name}" đã thay đổi',
      );
    }
  }

  void toggleReviewVisibility(String reviewId) {
    final index = reviews.indexWhere((r) => r.id == reviewId);
    if (index != -1) {
      final r = reviews[index];
      reviews[index] = r.copyWith(isHidden: !r.isHidden);
      AppNotification.showSuccess(
        title: reviews[index].isHidden ? 'Đã ẩn đánh giá' : 'Đã hiện đánh giá',
        message: 'Đánh giá của "${r.customerName}" đã được cập nhật',
      );
    }
  }

  void replyToReview(String reviewId, String replyText) {
    final index = reviews.indexWhere((r) => r.id == reviewId);
    if (index != -1) {
      reviews[index] = reviews[index].copyWith(reply: replyText.trim());
      AppNotification.showSuccess(
        title: 'Đã gửi phản hồi',
        message: 'Phản hồi đánh giá đã được lưu và hiển thị cho khách hàng',
      );
    }
  }

  // ==================== MODULE 4: KHUYẾN MÃI & VOUCHERS ====================
  void saveVoucher(AdminVoucherModel voucher, bool isEdit) {
    if (isEdit) {
      final index = vouchers.indexWhere((v) => v.id == voucher.id);
      if (index != -1) vouchers[index] = voucher;
      AppNotification.showSuccess(
        title: 'Cập nhật Voucher',
        message: 'Mã giảm giá "${voucher.code}" đã được cập nhật',
      );
    } else {
      vouchers.insert(0, voucher);
      AppNotification.showSuccess(
        title: 'Tạo Voucher mới',
        message: 'Mã "${voucher.code}" đã được kích hoạt trên hệ thống',
      );
    }
  }

  void deleteVoucher(String voucherId) {
    vouchers.removeWhere((v) => v.id == voucherId);
    AppNotification.showSuccess(
      title: 'Đã xóa Voucher',
      message: 'Mã giảm giá đã được gỡ khỏi danh sách',
    );
  }

  void toggleFlashSale(String id) {
    final index = flashSales.indexWhere((f) => f.id == id);
    if (index != -1) {
      final current = flashSales[index];
      flashSales[index] = FlashSaleCampaignModel(
        id: current.id,
        title: current.title,
        discountPercent: current.discountPercent,
        startTime: current.startTime,
        endTime: current.endTime,
        productIds: current.productIds,
        isActive: !current.isActive,
      );
      AppNotification.showSuccess(
        title: flashSales[index].isActive
            ? 'Đã kích hoạt Flash Sale'
            : 'Đã tạm dừng Flash Sale',
        message: current.title,
      );
    }
  }

  /// Gửi thông báo đẩy trực tiếp vào App của người dùng
  void broadcastPushNotification({
    required String title,
    required String message,
    required String category, // 'promo', 'order', 'news'
    String? promoCode,
  }) {
    if (Get.isRegistered<NotificationController>()) {
      final notifCtrl = Get.find<NotificationController>();
      notifCtrl.notifications.insert(
        0,
        NotificationItem(
          id: 'admin_push_${DateTime.now().millisecondsSinceEpoch}',
          category: category,
          categoryLabel: category == 'promo' ? 'ƯU ĐÃI NÓNG' : 'TIN MỚI',
          categoryColor: category == 'promo'
              ? const Color(0xFFEA580C)
              : const Color(0xFF059669),
          iconGradient: LinearGradient(
            colors: category == 'promo'
                ? [const Color(0xFFFF7A00), const Color(0xFFFF3E3E)]
                : [const Color(0xFF10B981), const Color(0xFF047857)],
          ),
          icon: category == 'promo'
              ? Icons.local_offer_rounded
              : Icons.notifications_active_rounded,
          title: title,
          description: message,
          time: 'Vừa xong',
          section: 'Hôm nay',
          code: promoCode,
          isUnread: true,
          actionLabel: promoCode != null ? 'Dùng mã ngay ➔' : 'Xem chi tiết ➔',
          actionType: 'category',
        ),
      );
      notifCtrl.notifications.refresh();
    }

    AppNotification.showSuccess(
      title: 'Đã phát thông báo đẩy thành công 📢',
      message: 'Toàn bộ khách hàng đã nhận được thông báo mới',
    );
  }

  // ==================== MODULE 6: PHÂN QUYỀN RBAC ====================
  void saveStaff(StaffMemberModel staff, bool isEdit) {
    if (isEdit) {
      final index = staffMembers.indexWhere((s) => s.id == staff.id);
      if (index != -1) staffMembers[index] = staff;
      AppNotification.showSuccess(
        title: 'Cập nhật nhân viên',
        message: 'Đã phân lại vai trò cho "${staff.name}"',
      );
    } else {
      staffMembers.insert(0, staff);
      AppNotification.showSuccess(
        title: 'Thêm nhân sự mới',
        message: 'Đã cấp quyền tài khoản cho "${staff.name}"',
      );
    }
  }

  void toggleStaffStatus(String staffId) {
    final index = staffMembers.indexWhere((s) => s.id == staffId);
    if (index != -1) {
      final current = staffMembers[index];
      staffMembers[index] = current.copyWith(isActive: !current.isActive);
      AppNotification.showSuccess(
        title: staffMembers[index].isActive
            ? 'Đã kích hoạt tài khoản'
            : 'Đã vô hiệu hóa',
        message: 'Tài khoản nhân sự "${current.name}"',
      );
    }
  }

  void deleteStaff(String staffId) {
    staffMembers.removeWhere((s) => s.id == staffId);
    AppNotification.showSuccess(
      title: 'Đã xóa nhân viên',
      message: 'Tài khoản nhân sự đã được gỡ khỏi danh sách',
    );
  }

  void setExactStock(String productId, int targetStock, String reason) {
    final index = products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      final oldProduct = products[index];
      final previousStock = oldProduct.stock;
      final newStock = targetStock.clamp(0, 99999);
      final change = newStock - previousStock;
      final updatedProduct = oldProduct.copyWith(stock: newStock);

      _productRepo.updateProduct(updatedProduct);
      products[index] = updatedProduct;

      inventoryLogs.insert(
        0,
        InventoryLogModel(
          id: 'LOG-${DateTime.now().millisecondsSinceEpoch}',
          productId: updatedProduct.id,
          productName: updatedProduct.name,
          type: change >= 0 ? 'IN' : 'ADJUST',
          quantity: change.abs(),
          stockAfter: newStock,
          note: reason.isNotEmpty ? reason : 'Điều chỉnh tồn kho trực tiếp',
          actor: 'Quản trị viên',
          timestamp: DateTime.now(),
        ),
      );

      AppNotification.showStockUpdate(
        product: updatedProduct,
        previousStock: previousStock,
        newStock: newStock,
        change: change,
      );
    }
  }

  void resetMockData() {
    _seedEnterpriseMockData();
    fetchData();
    AppNotification.showSuccess(
      title: 'Đã làm mới dữ liệu demo 🔄',
      message:
          'Toàn bộ danh mục, đơn hàng, khách hàng và cấu hình đã khôi phục trạng thái chuẩn.',
    );
  }

  void exportBackupData() {
    AppNotification.showSuccess(
      title: 'Đã sao lưu thành công 📦',
      message:
          'Đã xuất file "freshmarket_backup_${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}.json" (${products.length} sản phẩm, ${orders.length} đơn hàng, ${customers.length} khách hàng)',
    );
  }
}
