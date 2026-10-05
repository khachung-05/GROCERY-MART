import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/utils/app_notification.dart';
import '../main_controller.dart';

class _NotificationModel {
  final String id;
  final String category; // 'promo', 'order', 'news'
  final String categoryLabel;
  final Color categoryColor;
  final Gradient iconGradient;
  final IconData icon;
  final String title;
  final String description;
  final String time;
  final String? code;
  final String? actionLabel;
  final VoidCallback? onAction;
  bool isUnread;

  _NotificationModel({
    required this.id,
    required this.category,
    required this.categoryLabel,
    required this.categoryColor,
    required this.iconGradient,
    required this.icon,
    required this.title,
    required this.description,
    required this.time,
    this.code,
    this.actionLabel,
    this.onAction,
    this.isUnread = false,
  });
}

class NotificationsBottomSheet extends StatefulWidget {
  const NotificationsBottomSheet({super.key});

  static void show(BuildContext context) {
    Get.bottomSheet(
      const NotificationsBottomSheet(),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  State<NotificationsBottomSheet> createState() =>
      _NotificationsBottomSheetState();
}

class _NotificationsBottomSheetState extends State<NotificationsBottomSheet> {
  String _selectedTab = 'all'; // 'all', 'promo', 'order', 'news'
  late List<_NotificationModel> _notifications;

  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  void _initNotifications() {
    final isLoggedIn = LocalStorage.isLoggedIn;

    if (!isLoggedIn) {
      // Dành cho Khách vãng lai (Chưa đăng nhập)
      _notifications = [
        _NotificationModel(
          id: 'notif_001',
          category: 'promo',
          categoryLabel: 'ƯU ĐÃI',
          categoryColor: const Color(0xFFEA580C),
          iconGradient: const LinearGradient(
            colors: [Color(0xFFFF7A00), Color(0xFFFF4848)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          icon: Icons.confirmation_num_rounded,
          title: 'Tặng mã 20.000đ cho đơn đầu tiên 🎉',
          description:
              'Chào mừng bạn đến với Grocery App! Áp dụng mã FRESH20 khi thanh toán đơn hàng thực phẩm từ 100.000đ.',
          time: '10 phút trước',
          code: 'FRESH20',
          actionLabel: 'Sao chép mã',
          isUnread: true,
          onAction: () {
            Clipboard.setData(const ClipboardData(text: 'FRESH20'));
            AppNotification.showSuccess(
              title: 'Đã sao chép mã ưu đãi',
              message: 'Mã FRESH20 đã được lưu vào bộ nhớ tạm để dùng khi thanh toán.',
            );
          },
        ),
        _NotificationModel(
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
          title: 'Đăng ký tài khoản nhận quà chào mừng ⭐',
          description:
              'Đăng ký chỉ mất 30 giây để tích điểm thành viên, lưu địa chỉ giao hàng và nhận nhiều ưu đãi độc quyền mỗi tuần.',
          time: 'Vừa xong',
          actionLabel: 'Đăng ký ngay ➔',
          isUnread: true,
          onAction: () {
            Get.back();
            Get.toNamed(AppRoutes.register);
          },
        ),
        _NotificationModel(
          id: 'notif_003',
          category: 'news',
          categoryLabel: 'NÔNG SẢN',
          categoryColor: const Color(0xFF16A34A),
          iconGradient: const LinearGradient(
            colors: [Color(0xFF10B981), Color(0xFF047857)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          icon: Icons.eco_rounded,
          title: 'Nông sản sạch chuẩn VietGAP vừa về kho 🍎',
          description:
              'Xoài Cát Hòa Lộc, Táo Envy New Zealand và Cam Sành Tiền Giang vừa được nhập mới tươi ngon sáng nay.',
          time: 'Hôm nay',
          actionLabel: 'Khám phá ngay ➔',
          isUnread: false,
          onAction: () {
            Get.back();
            if (Get.isRegistered<MainController>()) {
              Get.find<MainController>().changeTab(1);
            } else {
              Get.toNamed(AppRoutes.category);
            }
          },
        ),
      ];
    } else {
      // Dành cho Thành viên đã đăng nhập
      _notifications = [
        _NotificationModel(
          id: 'notif_101',
          category: 'order',
          categoryLabel: 'ĐƠN HÀNG',
          categoryColor: const Color(0xFF059669),
          iconGradient: const LinearGradient(
            colors: [Color(0xFF10B981), Color(0xFF047857)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          icon: Icons.check_circle_rounded,
          title: 'Đơn hàng ORD-8821 đã giao thành công 🎉',
          description:
              'Kiện hàng tươi ngon đã được giao đến tay bạn. Vui lòng kiểm tra và đánh giá trải nghiệm nhé!',
          time: 'Vừa xong',
          actionLabel: 'Xem chi tiết đơn ➔',
          isUnread: true,
          onAction: () {
            Get.back();
            if (Get.isRegistered<MainController>()) {
              Get.find<MainController>().changeTab(3);
            } else {
              Get.toNamed(AppRoutes.orders);
            }
          },
        ),
        _NotificationModel(
          id: 'notif_102',
          category: 'promo',
          categoryLabel: 'ƯU ĐÃI',
          categoryColor: const Color(0xFFEA580C),
          iconGradient: const LinearGradient(
            colors: [Color(0xFFFF7A00), Color(0xFFFF4848)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          icon: Icons.local_offer_rounded,
          title: 'Ưu đãi hoàn xu 10% ngày vàng 🎁',
          description:
              'Áp dụng cho toàn bộ danh mục Rau củ hữu cơ và Trái cây nhập khẩu khi mua từ 2kg trở lên trong tuần này.',
          time: '2 giờ trước',
          actionLabel: 'Mua sắm ngay ➔',
          isUnread: true,
          onAction: () {
            Get.back();
            if (Get.isRegistered<MainController>()) {
              Get.find<MainController>().changeTab(1);
            } else {
              Get.toNamed(AppRoutes.category);
            }
          },
        ),
        _NotificationModel(
          id: 'notif_103',
          category: 'news',
          categoryLabel: 'TIN MỚI',
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
          time: 'Hôm nay',
          actionLabel: 'Xem sản phẩm ➔',
          isUnread: false,
          onAction: () {
            Get.back();
            if (Get.isRegistered<MainController>()) {
              Get.find<MainController>().changeTab(1);
            } else {
              Get.toNamed(AppRoutes.category);
            }
          },
        ),
      ];
    }
  }

  void _markAllAsRead() {
    setState(() {
      for (var item in _notifications) {
        item.isUnread = false;
      }
    });
    AppNotification.showSuccess(
      title: 'Đã cập nhật',
      message: 'Tất cả thông báo đã được đánh dấu là đã đọc.',
      duration: const Duration(seconds: 2),
    );
  }

  List<_NotificationModel> get _filteredNotifications {
    if (_selectedTab == 'all') return _notifications;
    return _notifications.where((n) => n.category == _selectedTab).toList();
  }

  int get _unreadCount => _notifications.where((n) => n.isUnread).length;

  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredNotifications;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 25,
            offset: Offset(0, -4),
          ),
        ],
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.82,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Thanh gạt Drag Handle mềm mại
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 42,
              height: 4.5,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 2. Header: Tiêu đề + Nút Đã đọc tất cả + Nút Đóng
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.notifications_active_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Thông báo',
                  style: TextStyle(
                    fontSize: 18.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
                if (_unreadCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFFECDD3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '$_unreadCount mới',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFE11D48),
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                if (_unreadCount > 0)
                  TextButton.icon(
                    onPressed: _markAllAsRead,
                    icon: const Icon(Icons.done_all_rounded, size: 16),
                    label: const Text(
                      'Đã đọc',
                      style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                const SizedBox(width: 6),
                InkWell(
                  onTap: () => Get.back(),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 3. Thanh Tab Filter Chips (Tất cả, Khuyến mãi, Đơn hàng, Tin tức)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                _buildFilterChip('all', 'Tất cả (${_notifications.length})'),
                const SizedBox(width: 8),
                _buildFilterChip('promo', 'Ưu đãi & Quà tặng'),
                const SizedBox(width: 8),
                _buildFilterChip('order', 'Đơn hàng'),
                const SizedBox(width: 8),
                _buildFilterChip('news', 'Tin nông sản'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // 4. Danh sách các Card thông báo hiện đại
          Flexible(
            child: filteredList.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    itemCount: filteredList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      return _buildNotificationCard(item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Filter Chip phong cách hiện đại
  Widget _buildFilterChip(String key, String label) {
    final isSelected = _selectedTab == key;
    return InkWell(
      onTap: () => setState(() => _selectedTab = key),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : const Color(0xFFE2E8F0),
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  // Card thông báo phong cách hiện đại
  Widget _buildNotificationCard(_NotificationModel item) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 0,
      child: InkWell(
        onTap: () {
          setState(() => item.isUnread = false);
          if (item.onAction != null) {
            item.onAction!();
          }
        },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: item.isUnread ? const Color(0xFFFBFDFA) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: item.isUnread
                  ? AppColors.primary.withValues(alpha: 0.28)
                  : const Color(0xFFE2E8F0),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: item.isUnread
                    ? AppColors.primary.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Gradient khối vuông tròn bo góc
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: item.iconGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: item.categoryColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  item.icon,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),

              // Nội dung chi tiết thông báo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dòng Category Tag & Thời gian
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: item.categoryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.categoryLabel,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: item.categoryColor,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '• ${item.time}',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        if (item.isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE11D48),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x66E11D48),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Tiêu đề
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: item.isUnread
                            ? FontWeight.bold
                            : FontWeight.w600,
                        color: const Color(0xFF0F172A),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Nội dung tóm tắt
                    Text(
                      item.description,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF475569),
                        height: 1.45,
                      ),
                    ),

                    // Hộp mã voucher (nếu có)
                    if (item.code != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFFFEDD5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.confirmation_num_outlined,
                              size: 14,
                              color: Color(0xFFEA580C),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Mã: ${item.code}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFEA580C),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Nút Call To Action nhanh
                    if (item.actionLabel != null) ...[
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: () {
                          setState(() => item.isUnread = false);
                          if (item.onAction != null) {
                            item.onAction!();
                          }
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: item.categoryColor.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            item.actionLabel!,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: item.categoryColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Trạng thái trống khi tab không có thông báo
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 42,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Chưa có thông báo nào',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Các tin tức và ưu đãi mới nhất sẽ được cập nhật liên tục tại đây.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
