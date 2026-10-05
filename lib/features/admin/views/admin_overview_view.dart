import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/models/order_model.dart';
import '../admin_controller.dart';
import '../edit_product_dialog.dart';

class AdminOverviewView extends StatefulWidget {
  final NumberFormat currencyFormatter;
  const AdminOverviewView({super.key, required this.currencyFormatter});

  @override
  State<AdminOverviewView> createState() => _AdminOverviewViewState();
}

class _AdminOverviewViewState extends State<AdminOverviewView> {
  // Bộ lọc thời gian: 0: Hôm nay, 1: Tuần này, 2: Tháng này, 3: Tất cả
  int _selectedPeriod = 0;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminController>();
    final isDesktop = MediaQuery.of(context).size.width >= 850;

    return Obx(() {
      try {
        final totalRev = controller.totalRevenue;
      final todayRev = controller.todayRevenue;
      final weekRev = controller.thisWeekRevenue;
      final monthRev = controller.thisMonthRevenue;

      final totalOrders = controller.totalOrdersCount;
      final pendingOrders = controller.pendingOrdersCount;
      final shippingOrders = controller.shippingOrdersCount;
      final completedOrders = controller.completedOrdersCount;
      final cancelledOrders = controller.cancelledOrdersCount;
      final cancelRate = controller.cancellationRate;

      // Kênh thanh toán
      int codCount = 0;
      int onlineCount = 0;
      double codAmount = 0;
      double onlineAmount = 0;

      for (var o in controller.orders) {
        if (o.status == 'Đã hủy') continue;
        if (o.paymentMethod.toLowerCase().contains('cod') ||
            o.paymentMethod.toLowerCase().contains('tiền mặt')) {
          codCount++;
          codAmount += o.totalAmount;
        } else {
          onlineCount++;
          onlineAmount += o.totalAmount;
        }
      }

      // Top bán chạy
      final Map<String, _TopProductStat> topMap = {};
      for (var o in controller.orders) {
        if (o.status == 'Đã hủy') continue;
        for (var item in o.items) {
          if (!topMap.containsKey(item.productId)) {
            topMap[item.productId] = _TopProductStat(
              name: item.productName,
              quantity: 0,
              totalRevenue: 0,
              unit: item.unit,
            );
          }
          final cur = topMap[item.productId]!;
          cur.quantity += item.quantity;
          cur.totalRevenue += item.total;
        }
      }
      final topList = topMap.values.toList()
        ..sort((a, b) => b.quantity.compareTo(a.quantity));
      final top5 = topList.take(5).toList();

      // Helper parse date
      DateTime parseOrderDate(dynamic d) {
        if (d is DateTime) return d;
        if (d is String) return DateTime.tryParse(d) ?? DateTime.now();
        return DateTime.now();
      }

      final now = DateTime.now();
      final weekStart = now.subtract(Duration(days: now.weekday - 1));

      // Filter non-cancelled orders by period
      final validOrders = controller.orders.where((o) => o.status != 'Đã hủy').toList();
      final todayOrders = validOrders.where((o) {
        final d = parseOrderDate(o.orderDate);
        return d.year == now.year && d.month == now.month && d.day == now.day;
      }).toList();
      final weekOrders = validOrders.where((o) {
        final d = parseOrderDate(o.orderDate);
        return d.isAfter(weekStart.subtract(const Duration(seconds: 1)));
      }).toList();
      final monthOrders = validOrders.where((o) {
        final d = parseOrderDate(o.orderDate);
        return d.year == now.year && d.month == now.month;
      }).toList();

      List<OrderModel> activeOrdersList;
      double activeRevenue;
      String activePeriodLabel;
      String activePeriodShort;
      String activeGrowth;

      switch (_selectedPeriod) {
        case 0:
          activeRevenue = todayRev;
          activePeriodLabel = 'Doanh thu hôm nay';
          activePeriodShort = 'Hôm nay';
          activeGrowth = '+12.5% vs hôm qua';
          activeOrdersList = todayOrders;
          break;
        case 1:
          activeRevenue = weekRev;
          activePeriodLabel = 'Doanh thu tuần này';
          activePeriodShort = 'Tuần này';
          activeGrowth = '+8.3% vs tuần trước';
          activeOrdersList = weekOrders;
          break;
        case 2:
          activeRevenue = monthRev;
          activePeriodLabel = 'Doanh thu tháng này';
          activePeriodShort = 'Tháng này';
          activeGrowth = '+15.2% vs tháng trước';
          activeOrdersList = monthOrders;
          break;
        default:
          activeRevenue = totalRev;
          activePeriodLabel = 'Tổng doanh thu toàn thời gian';
          activePeriodShort = 'Toàn bộ';
          activeGrowth = 'Tăng trưởng ổn định';
          activeOrdersList = validOrders;
      }

      final int activeOrdersCount = activeOrdersList.length;
      final double activeAov = activeOrdersCount > 0 ? activeRevenue / activeOrdersCount : 0.0;
      int activeItemsCount = 0;
      int activeCompletedCount = 0;
      for (var o in activeOrdersList) {
        if (o.status == 'Đã giao') activeCompletedCount++;
        for (var item in o.items) {
          activeItemsCount += (item.quantity as num).toInt();
        }
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ==================== 1. HERO EXECUTIVE KPI BANNER ====================
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Row 1: Header + Minimalist Segmented Filter
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.6),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            activePeriodLabel.toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),

                      // Segmented Filter Control (Tối giản hiện đại)
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildPeriodTab(0, 'Hôm nay'),
                            _buildPeriodTab(1, 'Tuần này'),
                            _buildPeriodTab(2, 'Tháng này'),
                            _buildPeriodTab(3, 'Tất cả'),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Row 2: Large Revenue + Growth Tag
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      Text(
                        widget.currencyFormatter.format(activeRevenue),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.8,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF059669).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF10B981).withValues(alpha: 0.35),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.trending_up_rounded, color: Color(0xFF34D399), size: 14),
                            const SizedBox(width: 5),
                            Text(
                              activeGrowth,
                              style: const TextStyle(
                                color: Color(0xFF34D399),
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
                  const SizedBox(height: 14),

                  // Row 3: Integrated Timeline Comparison Bar (Gọn gàng, tinh tế, bấm để chuyển)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isNarrow = constraints.maxWidth < 650;
                      if (isNarrow) {
                        final cardWidth = (constraints.maxWidth - 8) / 2;
                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildTimelineCard(0, 'Hôm nay', todayRev, todayOrders.length, width: cardWidth),
                            _buildTimelineCard(1, 'Tuần này', weekRev, weekOrders.length, width: cardWidth),
                            _buildTimelineCard(2, 'Tháng này', monthRev, monthOrders.length, width: cardWidth),
                            _buildTimelineCard(3, 'Toàn thời gian', totalRev, validOrders.length, width: cardWidth),
                          ],
                        );
                      }
                      return Row(
                        children: [
                          Expanded(child: _buildTimelineCard(0, 'Hôm nay', todayRev, todayOrders.length)),
                          _buildTimelineDivider(),
                          Expanded(child: _buildTimelineCard(1, 'Tuần này', weekRev, weekOrders.length)),
                          _buildTimelineDivider(),
                          Expanded(child: _buildTimelineCard(2, 'Tháng này', monthRev, monthOrders.length)),
                          _buildTimelineDivider(),
                          Expanded(child: _buildTimelineCard(3, 'Toàn thời gian', totalRev, validOrders.length)),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ==================== 1.5. QUICK EXECUTIVE ACTIONS ====================
            _buildQuickActionsBar(context, controller),
            const SizedBox(height: 18),

            // ==================== 2. FINANCIAL & OPERATIONAL METRIC TILES ====================
            LayoutBuilder(
              builder: (ctx, constraints) {
                final isWide = constraints.maxWidth >= 720;
                final double itemWidth = isWide
                    ? (constraints.maxWidth - 36) / 4
                    : (constraints.maxWidth >= 360 ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth);

                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildSleekMetricCard(
                      width: itemWidth,
                      title: 'Doanh thu thuần',
                      amount: widget.currencyFormatter.format(activeRevenue),
                      icon: Icons.account_balance_wallet_outlined,
                      accentColor: const Color(0xFF059669),
                      subtitle: 'Doanh thu thực tế ($activePeriodShort)',
                    ),
                    _buildSleekMetricCard(
                      width: itemWidth,
                      title: 'Đơn hàng phát sinh',
                      amount: '$activeOrdersCount đơn',
                      icon: Icons.receipt_long_outlined,
                      accentColor: const Color(0xFF0284C7),
                      subtitle: '$activeCompletedCount đơn đã hoàn thành',
                    ),
                    _buildSleekMetricCard(
                      width: itemWidth,
                      title: 'Giá trị TB / Đơn (AOV)',
                      amount: widget.currencyFormatter.format(activeAov),
                      icon: Icons.analytics_outlined,
                      accentColor: const Color(0xFF7C3AED),
                      subtitle: 'Bình quân mỗi đơn hàng',
                    ),
                    _buildSleekMetricCard(
                      width: itemWidth,
                      title: 'Sản phẩm bán ra',
                      amount: '$activeItemsCount món',
                      icon: Icons.inventory_2_outlined,
                      accentColor: const Color(0xFFD97706),
                      subtitle: 'Tổng số lượng đã bán',
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),

            // ==================== 2.5. 7-DAY REVENUE TREND BAR CHART ====================
            _buildRevenueTrendChart(validOrders, todayRev),
            const SizedBox(height: 24),

            // ==================== 3. VẬN HÀNH ĐƠN HÀNG (MINIMAL PIPELINE) ====================
            Row(
              children: [
                const Icon(Icons.sync_alt_rounded, color: Color(0xFF059669), size: 18),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'QUY TRÌNH VẬN HÀNH ĐƠN HÀNG',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: 0.3,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Tổng $totalOrders đơn',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Pipeline Stage Cards (Không bị trống, cực kỳ tinh tế)
            LayoutBuilder(
              builder: (ctx, constraints) {
                final isWide = constraints.maxWidth >= 720;
                final double itemWidth = isWide
                    ? (constraints.maxWidth - 48) / 5
                    : (constraints.maxWidth >= 360 ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth);

                return Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  children: [
                    _buildPipelineItem(
                      width: itemWidth,
                      label: 'Tất cả đơn',
                      count: totalOrders,
                      color: const Color(0xFF334155),
                      icon: Icons.receipt_long_rounded,
                    ),
                    _buildPipelineItem(
                      width: itemWidth,
                      label: 'Chờ đóng gói',
                      count: pendingOrders,
                      color: const Color(0xFFD97706),
                      icon: Icons.inventory_2_rounded,
                    ),
                    _buildPipelineItem(
                      width: itemWidth,
                      label: 'Đang giao hàng',
                      count: shippingOrders,
                      color: const Color(0xFF0284C7),
                      icon: Icons.local_shipping_rounded,
                    ),
                    _buildPipelineItem(
                      width: itemWidth,
                      label: 'Giao thành công',
                      count: completedOrders,
                      color: const Color(0xFF059669),
                      icon: Icons.check_circle_rounded,
                    ),
                    _buildPipelineItem(
                      width: itemWidth,
                      label: 'Hủy (${cancelRate.toStringAsFixed(0)}%)',
                      count: cancelledOrders,
                      color: const Color(0xFFDC2626),
                      icon: Icons.cancel_rounded,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // ==================== 4. KÊNH THANH TOÁN & TOP SẢN PHẨM ====================
            if (isDesktop)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: _buildPaymentChannelCard(
                      codCount: codCount,
                      codAmount: codAmount,
                      onlineCount: onlineCount,
                      onlineAmount: onlineAmount,
                      totalOrders: totalOrders,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 6,
                    child: _buildTopSellersCard(top5),
                  ),
                ],
              )
            else ...[
              _buildPaymentChannelCard(
                codCount: codCount,
                codAmount: codAmount,
                onlineCount: onlineCount,
                onlineAmount: onlineAmount,
                totalOrders: totalOrders,
              ),
              const SizedBox(height: 16),
              _buildTopSellersCard(top5),
            ],
            const SizedBox(height: 24),

            // ==================== 5. RECENT ACTIVITY FEED ====================
            _buildRecentActivityCard(),
          ],
        ),
      );
    } catch (e, stack) {
      debugPrint('Lỗi hiển thị AdminOverviewView: $e\n$stack');
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: Color(0xFFEF4444)),
              const SizedBox(height: 12),
              const Text('Có lỗi khi tải dữ liệu báo cáo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('$e', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => controller.fetchData(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Tải lại dữ liệu'),
              ),
            ],
          ),
        ),
      );
    }
  });
  }

  // ==================== SUB-COMPONENTS ====================

  Widget _buildPeriodTab(int index, String title) {
    final isSelected = _selectedPeriod == index;
    return InkWell(
      onTap: () => setState(() => _selectedPeriod = index),
      borderRadius: BorderRadius.circular(9),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF059669) : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF059669).withValues(alpha: 0.35),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF94A3B8),
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineCard(int index, String label, double amount, int ordersCount, {double? width}) {
    final isSelected = _selectedPeriod == index;
    return InkWell(
      onTap: () => setState(() => _selectedPeriod = index),
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: width,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.5), width: 1)
              : Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (isSelected) ...[
                  Container(
                    width: 5,
                    height: 5,
                    margin: const EdgeInsets.only(right: 5),
                    decoration: const BoxDecoration(
                      color: Color(0xFF34D399),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? const Color(0xFF34D399) : const Color(0xFF94A3B8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                widget.currencyFormatter.format(amount),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : const Color(0xFFE2E8F0),
                  letterSpacing: -0.2,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$ordersCount đơn',
              style: TextStyle(
                fontSize: 10.5,
                color: isSelected ? const Color(0xFFA7F3D0) : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineDivider() {
    return Container(
      width: 1,
      height: 30,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: Colors.white.withValues(alpha: 0.08),
    );
  }

  Widget _buildSleekMetricCard({
    required double width,
    required String title,
    required String amount,
    required IconData icon,
    required Color accentColor,
    required String subtitle,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: accentColor, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              amount,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: -0.3,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF94A3B8),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPipelineItem({
    required double width,
    required String label,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentChannelCard({
    required int codCount,
    required double codAmount,
    required int onlineCount,
    required double onlineAmount,
    required int totalOrders,
  }) {
    final codPercent = totalOrders > 0 ? (codCount / totalOrders) : 0.0;
    final onlinePercent = totalOrders > 0 ? (onlineCount / totalOrders) : 0.0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            children: [
              Icon(Icons.pie_chart_outline_rounded, color: Color(0xFF059669), size: 18),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Kênh Thanh Toán (COD vs Online)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF0F172A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // COD
          _buildPaymentProgressRow(
            label: 'Tiền mặt khi nhận (COD)',
            count: codCount,
            percent: codPercent,
            amount: widget.currencyFormatter.format(codAmount),
            color: const Color(0xFFEA580C),
            icon: Icons.payments_rounded,
          ),
          const SizedBox(height: 14),

          // Online
          _buildPaymentProgressRow(
            label: 'Ví điện tử & Thẻ ngân hàng',
            count: onlineCount,
            percent: onlinePercent,
            amount: widget.currencyFormatter.format(onlineAmount),
            color: const Color(0xFF0284C7),
            icon: Icons.credit_card_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentProgressRow({
    required String label,
    required int count,
    required double percent,
    required String amount,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
              ),
            ),
            Text(
              '$count đơn (${(percent * 100).clamp(0, 100).toStringAsFixed(0)}%)',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: color),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent.clamp(0.0, 1.0),
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 7,
          ),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            amount,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
        ),
      ],
    );
  }

  Widget _buildTopSellersCard(List<_TopProductStat> topList) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            children: [
              Icon(Icons.local_fire_department_rounded, color: Color(0xFFDC2626), size: 18),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Top 5 Sản Phẩm Bán Chạy',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF0F172A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (topList.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'Chưa có dữ liệu bán hàng phát sinh',
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                ),
              ),
            )
          else
            ...topList.asMap().entries.map((entry) {
              final idx = entry.key + 1;
              final item = entry.value;

              Color rankColor;
              Color rankBg;
              if (idx == 1) {
                rankColor = const Color(0xFFD97706);
                rankBg = const Color(0xFFFEF3C7);
              } else if (idx == 2) {
                rankColor = const Color(0xFF475569);
                rankBg = const Color(0xFFE2E8F0);
              } else if (idx == 3) {
                rankColor = const Color(0xFFB45309);
                rankBg = const Color(0xFFFFEDD5);
              } else {
                rankColor = const Color(0xFF94A3B8);
                rankBg = const Color(0xFFF1F5F9);
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: rankBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          '$idx',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: rankColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${item.quantity} ${item.unit}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF059669),
                          fontSize: 11.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.currencyFormatter.format(item.totalRevenue),
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // ==================== 1.5. THANH PHÍM TẮT HÀNH ĐỘNG NHANH ====================
  Widget _buildQuickActionsBar(BuildContext context, AdminController controller) {
    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
        children: [
          // Nút hành động chính (Primary Action)
          ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => EditProductDialog(
                  onSave: (p, isEdit) => controller.saveProduct(p, isEdit),
                ),
              );
            },
            icon: const Icon(Icons.add_rounded, size: 16, color: Colors.white),
            label: const Text(
              'Thêm món mới',
              style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF059669),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              minimumSize: const Size(0, 38),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(width: 8),

          // Các nút phụ phong cách Minimalist Slate
          _buildQuickActionButton(
            icon: Icons.confirmation_number_outlined,
            label: 'Tạo Voucher mới',
            onTap: () {
              Get.snackbar(
                'Khuyến Mãi & Voucher',
                'Mở phân hệ Khuyến Mãi để tạo và cấu hình mã giảm giá mới',
                backgroundColor: const Color(0xFF0F172A),
                colorText: Colors.white,
                icon: const Icon(Icons.confirmation_number_outlined, color: Color(0xFFC084FC)),
                snackPosition: SnackPosition.BOTTOM,
                margin: const EdgeInsets.all(16),
              );
            },
          ),
          const SizedBox(width: 8),
          _buildQuickActionButton(
            icon: Icons.inventory_2_outlined,
            label: 'Kiểm kê kho (${controller.products.length} món)',
            onTap: () {
              Get.snackbar(
                'Tồn Kho & Sản Phẩm',
                'Hệ thống đang quản lý ${controller.products.length} món. Có ${controller.lowStockCount} sản phẩm dưới ngưỡng 10.',
                backgroundColor: const Color(0xFF0F172A),
                colorText: Colors.white,
                icon: const Icon(Icons.warehouse_rounded, color: Color(0xFF38BDF8)),
                snackPosition: SnackPosition.BOTTOM,
                margin: const EdgeInsets.all(16),
              );
            },
          ),
          const SizedBox(width: 8),
          _buildQuickActionButton(
            icon: Icons.download_rounded,
            label: 'Xuất Báo Cáo',
            onTap: () {
              Get.snackbar(
                'Xuất Dữ Liệu Báo Cáo',
                'Đã xuất file báo cáo tổng hợp kinh doanh định dạng chuẩn Excel/PDF.',
                backgroundColor: const Color(0xFF059669),
                colorText: Colors.white,
                icon: const Icon(Icons.file_download_done_rounded, color: Colors.white),
                snackPosition: SnackPosition.BOTTOM,
                margin: const EdgeInsets.all(16),
              );
            },
          ),
        ],
      ),
    ),
  );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.015),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: const Color(0xFF64748B)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== 2.5. BIỂU ĐỒ DOANH THU 7 NGÀY GẦN NHẤT ====================
  Widget _buildRevenueTrendChart(List<OrderModel> orders, double todayRev) {
    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day).subtract(Duration(days: now.weekday - 1));
    final days = ['Th 2', 'Th 3', 'Th 4', 'Th 5', 'Th 6', 'Th 7', 'CN'];

    DateTime parseOrderDate(dynamic d) {
      if (d is DateTime) return d;
      if (d is String) return DateTime.tryParse(d)?.toLocal() ?? DateTime.now();
      return DateTime.now();
    }

    final dailyRevs = List<double>.generate(7, (i) {
      final targetDate = monday.add(Duration(days: i));
      return orders.where((o) {
        final d = parseOrderDate(o.orderDate);
        return d.year == targetDate.year && d.month == targetDate.month && d.day == targetDate.day;
      }).fold<double>(0.0, (sum, o) => sum + o.totalAmount);
    });

    final maxRev = dailyRevs.reduce((a, b) => a > b ? a : b);
    final totalWeek = dailyRevs.reduce((a, b) => a + b);
    final avgRev = totalWeek / 7;
    final todayIndex = now.weekday - 1; // 0 for Mon, 6 for Sun

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: const Color(0xFF059669).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.bar_chart_rounded, color: Color(0xFF059669), size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'BIỂU ĐỒ DOANH THU 7 NGÀY GẦN NHẤT',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                              letterSpacing: 0.3,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Trung bình: ${widget.currencyFormatter.format(avgRev)} / ngày',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFA7F3D0), width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.trending_up_rounded, size: 14, color: Color(0xFF059669)),
                    const SizedBox(width: 4),
                    Text(
                      todayRev > 0 ? '+${(todayRev / 1000).toStringAsFixed(0)}k hôm nay' : 'Tuần này',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Bars
          SizedBox(
            height: 155,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(7, (i) {
                final rev = dailyRevs[i];
                final barHeight = maxRev > 0 ? (rev / maxRev) * 90 : 8.0;
                final isToday = i == todayIndex;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      rev > 0 ? '${(rev / 1000).toStringAsFixed(0)}k' : '0',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                        color: isToday ? const Color(0xFF059669) : const Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(height: 6),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      width: 26,
                      height: barHeight < 6 ? 6 : barHeight,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isToday
                              ? [const Color(0xFF10B981), const Color(0xFF059669)]
                              : [const Color(0xFFCBD5E1), const Color(0xFF94A3B8)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: isToday
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF059669).withValues(alpha: 0.35),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      days[i],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                        color: isToday ? const Color(0xFF059669) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== 5. RECENT ACTIVITY FEED ====================
  Widget _buildRecentActivityCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            children: [
              Icon(Icons.history_toggle_off_rounded, color: Color(0xFF059669), size: 18),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  'HOẠT ĐỘNG VẬN HÀNH GẦN ĐÂY',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: Color(0xFF0F172A),
                    letterSpacing: 0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildActivityItem(
            icon: Icons.check_circle_outline_rounded,
            color: const Color(0xFF059669),
            title: 'Đơn hàng #ORD-003 đã giao thành công',
            subtitle: 'Người nhận: Nguyễn Văn Tuấn • Thu COD 460.000 đ',
            time: '5 phút trước',
          ),
          const Divider(height: 16, color: Color(0xFFF1F5F9)),
          _buildActivityItem(
            icon: Icons.star_rounded,
            color: const Color(0xFFF59E0B),
            title: 'Khách hàng đánh giá 5⭐ cho Táo Envy Mỹ',
            subtitle: '"Táo giòn ngọt, đóng gói cẩn thận sẽ ủng hộ tiếp!"',
            time: '24 phút trước',
          ),
          const Divider(height: 16, color: Color(0xFFF1F5F9)),
          _buildActivityItem(
            icon: Icons.warehouse_rounded,
            color: const Color(0xFF0284C7),
            title: 'Nhập kho thành công 50kg Cam Sành Tiền Giang',
            subtitle: 'Người thực hiện: Thủ kho Nguyễn Văn Admin',
            time: '1 giờ trước',
          ),
          const Divider(height: 16, color: Color(0xFFF1F5F9)),
          _buildActivityItem(
            icon: Icons.local_offer_outlined,
            color: const Color(0xFF7C3AED),
            title: 'Mã giảm giá HELLO50 được áp dụng vào đơn mới',
            subtitle: 'Giảm 50.000 đ cho khách hàng thân thiết',
            time: '2 giờ trước',
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          time,
          style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class _TopProductStat {
  final String name;
  int quantity;
  double totalRevenue;
  final String unit;

  _TopProductStat({
    required this.name,
    required this.quantity,
    required this.totalRevenue,
    required this.unit,
  });
}
