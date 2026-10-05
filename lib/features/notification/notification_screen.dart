import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import 'notification_controller.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  void _copyCode(BuildContext context, NotificationController controller, String code) {
    Clipboard.setData(ClipboardData(text: code));
    controller.copiedCodes.add(code);
    Future.delayed(const Duration(seconds: 3), () {
      controller.copiedCodes.remove(code);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<NotificationController>()
        ? Get.find<NotificationController>()
        : Get.put(NotificationController());

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: _buildAppBar(context, controller),
      body: Column(
        children: [
          // Thanh danh mục bộ lọc dạng Segmented Tab
          _buildFilterTabs(controller),

          // Danh sách thông báo dạng nhóm ngày tháng
          Expanded(
            child: Obx(() {
              final filteredList = controller.filteredNotifications;

              // Phân nhóm theo Section ("Hôm nay", "Trước đó")
              final sections = <String, List<NotificationItem>>{};
              for (var item in filteredList) {
                sections.putIfAbsent(item.section, () => []).add(item);
              }

              return RefreshIndicator(
                color: AppColors.primary,
                backgroundColor: Colors.white,
                onRefresh: () async {
                  await Future.delayed(const Duration(milliseconds: 400));
                  controller.loadNotifications();
                },
                child: filteredList.isEmpty
                    ? SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.65,
                          child: _buildEmptyState(),
                        ),
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: sections.keys.length,
                        itemBuilder: (context, sectionIndex) {
                          final sectionTitle =
                              sections.keys.elementAt(sectionIndex);
                          final items = sections[sectionTitle]!;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Tiêu đề section
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 4,
                                  top: 16,
                                  bottom: 10,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 4,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      sectionTitle.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF64748B),
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '(${items.length})',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF94A3B8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Danh sách cards trong section
                              ...items.map((item) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _buildDismissibleCard(
                                      context, controller, item),
                                );
                              }),
                            ],
                          );
                        },
                      ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // AppBar phong cách phẳng, tinh gọn, hiện đại
  PreferredSizeWidget _buildAppBar(
      BuildContext context, NotificationController controller) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      centerTitle: false,
      automaticallyImplyLeading: false,
      leading: Navigator.canPop(context)
          ? Center(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Get.back(),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Color(0xFF0F172A),
                      size: 17,
                    ),
                  ),
                ),
              ),
            )
          : null,
      title: Obx(() {
        final unread = controller.unreadCount;
        return Row(
          children: [
            const Text(
              'Thông báo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: -0.4,
              ),
            ),
            if (unread > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.35),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '$unread mới',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        );
      }),
      actions: [
        Obx(() {
          if (controller.unreadCount <= 0) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: controller.markAllAsRead,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.done_all_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Đã đọc tất cả',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // Bộ lọc dạng Segmented Tabs
  Widget _buildFilterTabs(NotificationController controller) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Obx(() => Row(
              children: [
                _buildTabPill(
                  controller: controller,
                  key: 'all',
                  icon: Icons.all_inbox_rounded,
                  label: 'Tất cả',
                  count: controller.countByCategory('all'),
                ),
                const SizedBox(width: 8),
                _buildTabPill(
                  controller: controller,
                  key: 'promo',
                  icon: Icons.local_activity_outlined,
                  label: 'Ưu đãi & Quà',
                  count: controller.countByCategory('promo'),
                ),
                const SizedBox(width: 8),
                _buildTabPill(
                  controller: controller,
                  key: 'order',
                  icon: Icons.local_shipping_outlined,
                  label: 'Đơn hàng',
                  count: controller.countByCategory('order'),
                ),
                const SizedBox(width: 8),
                _buildTabPill(
                  controller: controller,
                  key: 'news',
                  icon: Icons.eco_outlined,
                  label: 'Tin nông sản',
                  count: controller.countByCategory('news'),
                ),
              ],
            )),
      ),
    );
  }

  Widget _buildTabPill({
    required NotificationController controller,
    required String key,
    required IconData icon,
    required String label,
    required int count,
  }) {
    final isSelected = controller.selectedTab.value == key;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => controller.selectedTab.value = key,
        borderRadius: BorderRadius.circular(30),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFF059669), Color(0xFF047857)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(30),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF059669).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF475569),
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.25)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color:
                          isSelected ? Colors.white : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Hỗ trợ vuốt để xóa thông báo
  Widget _buildDismissibleCard(BuildContext context,
      NotificationController controller, NotificationItem item) {
    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFFEE2E2),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_outline_rounded, color: Color(0xFFDC2626)),
            SizedBox(width: 6),
            Text(
              'Xóa',
              style: TextStyle(
                color: Color(0xFFDC2626),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
      onDismissed: (_) {
        controller.deleteNotification(item.id);
      },
      child: _buildNotificationCard(context, controller, item),
    );
  }

  // Card thông báo phong cách hiện đại
  Widget _buildNotificationCard(BuildContext context,
      NotificationController controller, NotificationItem item) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () {
          controller.handleAction(item);
        },
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            color: item.isUnread ? const Color(0xFFFDFEFE) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: item.isUnread
                  ? item.categoryColor.withValues(alpha: 0.3)
                  : const Color(0xFFE9EEF4),
              width: item.isUnread ? 1.3 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: item.isUnread
                    ? item.categoryColor.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.025),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thanh viền mỏng phía trên cho item chưa đọc
              if (item.isUnread)
                Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: item.categoryColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                  ),
                ),

              Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon Gradient sang trọng
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: item.iconGradient,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: item.categoryColor.withValues(alpha: 0.35),
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
                    const SizedBox(width: 13),

                    // Chi tiết nội dung
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header: Tag loại + Giờ + Dot chưa đọc
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      item.categoryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  item.categoryLabel,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: item.categoryColor,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                item.time,
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
                                    color: Color(0xFFEF4444),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0x66EF4444),
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 7),

                          // Tiêu đề
                          Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: item.isUnread
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: const Color(0xFF0F172A),
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 5),

                          // Mô tả
                          Text(
                            item.description,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF64748B),
                              height: 1.45,
                            ),
                          ),

                          // Banner Coupon tích hợp nút sao chép (nếu có mã giảm)
                          if (item.code != null) ...[
                            const SizedBox(height: 12),
                            _buildCouponTicket(context, controller, item.code!),
                          ],

                          // Banner đơn hàng đang giao (nếu là thông báo đơn hàng)
                          if (item.orderId != null) ...[
                            const SizedBox(height: 12),
                            _buildOrderProgressSnippet(
                              item.orderId!,
                              item.orderStatus ?? 'Đang vận chuyển',
                            ),
                          ],

                          // Footer CTA Button
                          if (item.actionLabel != null && item.code == null) ...[
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      controller.handleAction(item);
                                    },
                                    borderRadius: BorderRadius.circular(20),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 6.5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: item.categoryColor
                                            .withValues(alpha: 0.08),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: item.categoryColor
                                              .withValues(alpha: 0.2),
                                          width: 1,
                                        ),
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
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Coupon Ticket chuyên nghiệp
  Widget _buildCouponTicket(BuildContext context,
      NotificationController controller, String code) {
    return Obx(() {
      final isCopied = controller.copiedCodes.contains(code);

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF7ED),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFFFD8A8),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFEA580C).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.confirmation_num_rounded,
                size: 16,
                color: Color(0xFFEA580C),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'MÃ ƯU ĐÃI',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF9A3412),
                      letterSpacing: 0.6,
                    ),
                  ),
                  Text(
                    code,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFFEA580C),
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _copyCode(context, controller, code),
                borderRadius: BorderRadius.circular(8),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6.5),
                  decoration: BoxDecoration(
                    color: isCopied
                        ? const Color(0xFF059669)
                        : const Color(0xFFEA580C),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: (isCopied
                                ? const Color(0xFF059669)
                                : const Color(0xFFEA580C))
                            .withValues(alpha: 0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isCopied ? Icons.check_rounded : Icons.copy_rounded,
                        size: 13,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isCopied ? 'Đã chép' : 'Sao chép',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // Snippet tiến trình đơn hàng
  Widget _buildOrderProgressSnippet(String orderId, String status) {
    final isDelivered = status.contains('Đã giao') ||
        status.contains('thành công') ||
        status == 'Hoàn thành';
    final isShipping = status.contains('Đang giao') || status.contains('vận chuyển');
    final isProcessing = status.contains('Chờ xử lý') || status.contains('đóng gói') || status.contains('chuẩn bị');
    final isCancelled = status.contains('Đã hủy') || status.contains('hủy');

    final double progressValue;
    final Color mainColor;
    final Color bgColor;
    final Color borderColor;
    final Color progressBgColor;
    final IconData iconData;

    if (isDelivered) {
      progressValue = 1.0;
      mainColor = const Color(0xFF059669);
      bgColor = const Color(0xFFF0FDF4);
      borderColor = const Color(0xFFBBF7D0);
      progressBgColor = const Color(0xFFDCFCE7);
      iconData = Icons.check_circle_rounded;
    } else if (isShipping) {
      progressValue = 0.75;
      mainColor = const Color(0xFF0284C7);
      bgColor = const Color(0xFFF0F9FF);
      borderColor = const Color(0xFFBAE6FD);
      progressBgColor = const Color(0xFFE0F2FE);
      iconData = Icons.two_wheeler_rounded;
    } else if (isProcessing) {
      progressValue = 0.45;
      mainColor = const Color(0xFFD97706);
      bgColor = const Color(0xFFFFFBEB);
      borderColor = const Color(0xFFFDE68A);
      progressBgColor = const Color(0xFFFEF3C7);
      iconData = Icons.inventory_2_rounded;
    } else if (isCancelled) {
      progressValue = 1.0;
      mainColor = const Color(0xFFDC2626);
      bgColor = const Color(0xFFFEF2F2);
      borderColor = const Color(0xFFFECACA);
      progressBgColor = const Color(0xFFFEE2E2);
      iconData = Icons.cancel_rounded;
    } else {
      progressValue = 0.2;
      mainColor = const Color(0xFFEA580C);
      bgColor = const Color(0xFFFFF7ED);
      borderColor = const Color(0xFFFFEDD5);
      progressBgColor = const Color(0xFFFFEDD5);
      iconData = Icons.hourglass_top_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: mainColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  iconData,
                  size: 14,
                  color: mainColor,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Mã đơn: #$orderId',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: mainColor,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                decoration: BoxDecoration(
                  color: mainColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progressValue,
              backgroundColor: progressBgColor,
              valueColor: AlwaysStoppedAnimation<Color>(mainColor),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  // Trạng thái khi không có thông báo
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFF1F5F9),
                    const Color(0xFFE2E8F0).withValues(alpha: 0.5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_off_outlined,
                size: 38,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Không có thông báo nào',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Các ưu đãi giảm giá, trạng thái đơn hàng và tin tức nông sản mới sẽ hiển thị tại đây.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
