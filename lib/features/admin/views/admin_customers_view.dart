import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../admin_controller.dart';
import '../models/admin_models.dart';

class AdminCustomersView extends StatefulWidget {
  final NumberFormat currencyFormatter;
  const AdminCustomersView({super.key, required this.currencyFormatter});

  @override
  State<AdminCustomersView> createState() => _AdminCustomersViewState();
}

class _AdminCustomersViewState extends State<AdminCustomersView> {
  final AdminController controller = Get.find<AdminController>();
  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _reviewSearchCtrl = TextEditingController();

  final List<String> _tiers = ['ALL', 'Kim Cương', 'Vàng', 'Bạc', 'Đồng'];
  int _selectedSubTab = 0;
  String _reviewFilterRating = 'ALL';

  @override
  void dispose() {
    _searchCtrl.dispose();
    _reviewSearchCtrl.dispose();
    super.dispose();
  }

  Widget _buildSubTabPill({
    required int index,
    required String label,
    required IconData icon,
    required String badgeText,
  }) {
    final isSelected = _selectedSubTab == index;
    return InkWell(
      onTap: () => setState(() => _selectedSubTab = index),
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7.5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF059669) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF059669).withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : const Color(0xFF64748B)),
            const SizedBox(width: 6),
            Text(
              '$label ($badgeText)',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // TOP SUB-NAVIGATION HEADER
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
          ),
          child: Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Obx(() => Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildSubTabPill(
                              index: 0,
                              label: 'Khách hàng & Hạng',
                              icon: Icons.people_alt_rounded,
                              badgeText: '${controller.customers.length}',
                            ),
                            const SizedBox(width: 4),
                            _buildSubTabPill(
                              index: 1,
                              label: 'Đánh giá & Phản hồi',
                              icon: Icons.reviews_rounded,
                              badgeText: '${controller.reviews.length}',
                            ),
                          ],
                        )),
                  ),
                ),
              ),
            ],
          ),
        ),

        // SUB-TAB VIEW CONTENT
        Expanded(
          child: _selectedSubTab == 0
              ? _buildCustomersTab()
              : _buildReviewsTab(),
        ),
      ],
    );
  }

  // ==================== TAB 1: CRM & HỒ SƠ KHÁCH HÀNG ====================
  Widget _buildCustomersTab() {
    return Column(
      children: [
        // Filter toolbar
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            children: [
              TextField(
                controller: _searchCtrl,
                onChanged: (val) => controller.customerSearchQuery.value = val,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm theo tên khách hàng, SĐT, email...',
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8)),
                  suffixIcon: Obx(() => controller.customerSearchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchCtrl.clear();
                            controller.customerSearchQuery.value = '';
                          },
                        )
                      : const SizedBox.shrink()),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                ),
              ),
              const SizedBox(height: 12),
              // Loyalty Tier Filter Pills (Minimalist Modern Pills)
              Obx(() {
                final currentTier = controller.customerTierFilter.value;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _tiers.map((t) {
                      final isSelected = currentTier == t;
                      final count = t == 'ALL'
                          ? controller.customers.length
                          : controller.customers.where((c) => c.tier == t).length;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: () => controller.customerTierFilter.value = t,
                          borderRadius: BorderRadius.circular(10),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF059669) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? const Color(0xFF059669) : const Color(0xFFE2E8F0),
                                width: 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF059669).withValues(alpha: 0.25),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      )
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  t == 'ALL'
                                      ? 'Tất cả'
                                      : (t == 'Kim Cương'
                                          ? '💎 Kim Cương'
                                          : (t == 'Vàng'
                                              ? '🥇 Vàng'
                                              : (t == 'Bạc' ? '🥈 Bạc' : '🥉 Đồng'))),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                    color: isSelected ? Colors.white : const Color(0xFF475569),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5.5, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white.withValues(alpha: 0.25)
                                        : const Color(0xFFE2E8F0),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '$count',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? Colors.white : const Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              }),
            ],
          ),
        ),

        // CUSTOMERS LIST
        Expanded(
          child: Obx(() {
            final list = controller.filteredCustomers;
            if (list.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_search_rounded, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    const Text('Không tìm thấy khách hàng nào', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, index) => _buildCustomerCard(list[index]),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCustomerCard(CustomerModel customer) {
    Color tierColor;
    Color tierBg;
    switch (customer.tier) {
      case 'Kim Cương':
        tierColor = const Color(0xFF0284C7);
        tierBg = const Color(0xFFE0F2FE);
        break;
      case 'Vàng':
        tierColor = const Color(0xFFD97706);
        tierBg = const Color(0xFFFEF3C7);
        break;
      case 'Bạc':
        tierColor = const Color(0xFF64748B);
        tierBg = const Color(0xFFF1F5F9);
        break;
      default:
        tierColor = const Color(0xFFB45309);
        tierBg = const Color(0xFFFFEDD5);
    }

    return InkWell(
      onTap: () => _showCustomerDetailModal(customer),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: customer.isBlocked ? const Color(0xFFFCA5A5) : const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar circle with Tier indicator
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: tierBg,
                    shape: BoxShape.circle,
                    border: Border.all(color: tierColor, width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      customer.name.isNotEmpty ? customer.name[0].toUpperCase() : 'U',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: tierColor),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Wrap(
                        spacing: 5,
                        runSpacing: 2,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: tierBg, borderRadius: BorderRadius.circular(5)),
                            child: Text(
                              'Hạng ${customer.tier}',
                              style: TextStyle(color: tierColor, fontSize: 10, fontWeight: FontWeight.w800),
                            ),
                          ),
                          if (customer.isBlocked)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(4)),
                              child: const Text('Đã khóa', style: TextStyle(color: Color(0xFFDC2626), fontSize: 9.5, fontWeight: FontWeight.bold)),
                            ),
                          Text(
                            customer.phone,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                // Points badge & Adjust Button (Modern styled pill)
                InkWell(
                  onTap: () => _showPointsDialog(customer),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.stars_rounded, color: Color(0xFFF59E0B), size: 15),
                            const SizedBox(width: 4),
                            Text(
                              '${customer.points} điểm',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF92400E)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          '± Chỉnh điểm',
                          style: TextStyle(fontSize: 10, color: Color(0xFFD97706), fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20, color: Color(0xFFF1F5F9)),

            // LTV Metrics & Status
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tổng chi tiêu (LTV)', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(widget.currencyFormatter.format(customer.totalSpent), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF059669))),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Số đơn hoàn thành', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text('${customer.ordersCount} đơn', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => controller.toggleCustomerBlock(customer.id),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: customer.isBlocked ? const Color(0xFFFEF2F2) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: customer.isBlocked ? const Color(0xFFFECACA) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          customer.isBlocked ? Icons.lock_rounded : Icons.lock_open_rounded,
                          size: 14,
                          color: customer.isBlocked ? const Color(0xFFDC2626) : const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          customer.isBlocked ? 'Đã khóa' : 'Hoạt động',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: customer.isBlocked ? const Color(0xFFDC2626) : const Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomerDetailModal(CustomerModel customer) {
    final customerOrders = controller.orders
        .where((o) => o.receiverPhone == customer.phone || o.receiverName == customer.name)
        .toList();

    Color tierPrimary;
    Color tierSecondary;
    String tierIcon;
    switch (customer.tier) {
      case 'Kim Cương':
        tierPrimary = const Color(0xFF1E3A8A);
        tierSecondary = const Color(0xFF3B82F6);
        tierIcon = '💎';
        break;
      case 'Vàng':
        tierPrimary = const Color(0xFF78350F);
        tierSecondary = const Color(0xFFF59E0B);
        tierIcon = '🥇';
        break;
      case 'Bạc':
        tierPrimary = const Color(0xFF334155);
        tierSecondary = const Color(0xFF94A3B8);
        tierIcon = '🥈';
        break;
      default:
        tierPrimary = const Color(0xFF7C2D12);
        tierSecondary = const Color(0xFFEA580C);
        tierIcon = '🥉';
    }

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Container(
          width: 520,
          padding: const EdgeInsets.all(22),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.badge_rounded, color: Color(0xFF059669), size: 22),
                    const SizedBox(width: 8),
                    const Text('HỒ SƠ KHÁCH HÀNG CRM', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
                    const Spacer(),
                    IconButton(icon: const Icon(Icons.close_rounded, size: 20), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const SizedBox(height: 12),

                // VIP Member Card UI
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [tierPrimary, tierSecondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: tierPrimary.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(tierIcon, style: const TextStyle(fontSize: 20)),
                              const SizedBox(width: 8),
                              Text(
                                'THÀNH VIÊN ${customer.tier.toUpperCase()}',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.8),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${customer.points} Điểm',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        customer.name.toUpperCase(),
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        customer.phone,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13, fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Financial Overview
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Tổng chi tiêu (LTV)', style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                            const SizedBox(height: 3),
                            Text(
                              widget.currencyFormatter.format(customer.totalSpent),
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF059669)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Tổng đơn hàng', style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                            const SizedBox(height: 3),
                            Text(
                              '${customer.ordersCount} đơn hoàn tất',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Contact & Address
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.email_outlined, size: 16, color: Color(0xFF64748B)),
                          const SizedBox(width: 8),
                          Expanded(child: Text(customer.email, style: const TextStyle(fontSize: 12.5, color: Color(0xFF334155)))),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF64748B)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              customer.address.isNotEmpty ? customer.address : 'Chưa cập nhật địa chỉ giao hàng',
                              style: const TextStyle(fontSize: 12.5, color: Color(0xFF334155)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Recent Orders
                const Text('LỊCH SỬ ĐƠN HÀNG GẦN NHẤT:', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                const SizedBox(height: 8),
                if (customerOrders.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Khách hàng chưa phát sinh đơn hàng trên hệ thống', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                  )
                else
                  ...customerOrders.take(3).map((o) => Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Text('#${o.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                            const SizedBox(width: 10),
                            Expanded(child: Text(o.status, style: const TextStyle(fontSize: 12, color: Color(0xFF059669), fontWeight: FontWeight.w600))),
                            Text(widget.currencyFormatter.format(o.totalAmount), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5)),
                          ],
                        ),
                      )),

                const SizedBox(height: 16),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(ctx);
                          _showPointsDialog(customer);
                        },
                        icon: const Icon(Icons.stars_rounded, color: Color(0xFFF59E0B), size: 16),
                        label: const Text('Chỉnh điểm thưởng', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          controller.toggleCustomerBlock(customer.id);
                          Navigator.pop(ctx);
                        },
                        icon: Icon(customer.isBlocked ? Icons.lock_open_rounded : Icons.lock_outline_rounded, size: 16, color: Colors.white),
                        label: Text(
                          customer.isBlocked ? 'Mở khóa tài khoản' : 'Khóa tài khoản',
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: customer.isBlocked ? const Color(0xFF059669) : const Color(0xFFDC2626),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPointsDialog(CustomerModel customer) {
    final pointsCtrl = TextEditingController(text: '50');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final currentInput = int.tryParse(pointsCtrl.text.trim()) ?? 0;
          final projectedTotal = (customer.points + currentInput).clamp(0, 999999);

          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            clipBehavior: Clip.antiAlias,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Header Banner
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.stars_rounded, color: Color(0xFFF59E0B), size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Điều Chỉnh Điểm Thưởng',
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${customer.name} • Hạng ${customer.tier}',
                                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),

                  // Dialog Body
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Current Points Info Box
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Điểm hiện tại:', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                              Row(
                                children: [
                                  const Icon(Icons.stars_rounded, color: Color(0xFFF59E0B), size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${customer.points} điểm',
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          'Số điểm thay đổi (+ để cộng, - để trừ):',
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                        ),
                        const SizedBox(height: 8),

                        // Input Field with - and + step buttons
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFCBD5E1)),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.remove_rounded, color: Color(0xFFDC2626)),
                                onPressed: () {
                                  final current = int.tryParse(pointsCtrl.text.trim()) ?? 0;
                                  setDialogState(() {
                                    pointsCtrl.text = '${current - 50}';
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: pointsCtrl,
                                keyboardType: const TextInputType.numberWithOptions(signed: true),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: currentInput >= 0 ? const Color(0xFF059669) : const Color(0xFFDC2626),
                                ),
                                onChanged: (val) => setDialogState(() {}),
                                decoration: InputDecoration(
                                  hintText: '0',
                                  suffixText: 'điểm',
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFCBD5E1)),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.add_rounded, color: Color(0xFF059669)),
                                onPressed: () {
                                  final current = int.tryParse(pointsCtrl.text.trim()) ?? 0;
                                  setDialogState(() {
                                    pointsCtrl.text = '${current + 50}';
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Quick adjustment chips
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            {'label': '+20', 'val': 20},
                            {'label': '+50', 'val': 50},
                            {'label': '+100', 'val': 100},
                            {'label': '+200', 'val': 200},
                            {'label': '-50', 'val': -50},
                            {'label': '-100', 'val': -100},
                          ].map((chip) {
                            final int v = chip['val'] as int;
                            final isPositive = v > 0;
                            return InkWell(
                              onTap: () {
                                setDialogState(() {
                                  pointsCtrl.text = '$v';
                                });
                              },
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: isPositive ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: isPositive ? const Color(0xFFA7F3D0) : const Color(0xFFFECACA)),
                                ),
                                child: Text(
                                  chip['label'] as String,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    color: isPositive ? const Color(0xFF059669) : const Color(0xFFDC2626),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 14),

                        // Projected new total point box
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xFF64748B)),
                              const SizedBox(width: 6),
                              Text(
                                'Điểm sau cập nhật: $projectedTotal điểm',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Actions: Clean 50/50 Horizontal split
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              side: const BorderSide(color: Color(0xFFCBD5E1)),
                            ),
                            child: const Text('Hủy bỏ', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              final val = int.tryParse(pointsCtrl.text.trim()) ?? 0;
                              if (val != 0) {
                                controller.adjustCustomerPoints(customer.id, val);
                              }
                              Navigator.pop(ctx);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF059669),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
                            child: const Text('Xác nhận lưu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ==================== TAB 2: ĐÁNH GIÁ & PHẢN HỒI (REVIEWS) ====================
  Widget _buildReviewsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Filter toolbar
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Search input
              TextField(
                controller: _reviewSearchCtrl,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Tìm theo tên khách, sản phẩm, nội dung đánh giá...',
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8)),
                  suffixIcon: _reviewSearchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _reviewSearchCtrl.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                ),
              ),
              const SizedBox(height: 12),
              // Rating & Status filter pills
              Obx(() {
                final all = controller.reviews;
                final total = all.length;
                final count5 = all.where((r) => r.rating >= 4.5).length;
                final count4 = all.where((r) => r.rating >= 3.5 && r.rating < 4.5).length;
                final count3 = all.where((r) => r.rating >= 2.5 && r.rating < 3.5).length;
                final countUnreplied = all.where((r) => r.reply == null || r.reply!.isEmpty).length;
                final countHidden = all.where((r) => r.isHidden).length;

                final filterChips = [
                  {'key': 'ALL', 'label': 'Tất cả', 'count': total},
                  {'key': '5', 'label': '⭐ 5 Sao', 'count': count5},
                  {'key': '4', 'label': '⭐ 4 Sao', 'count': count4},
                  {'key': '3', 'label': '⭐ 3 Sao', 'count': count3},
                  {'key': 'UNREPLIED', 'label': '💬 Chưa trả lời', 'count': countUnreplied},
                  if (countHidden > 0)
                    {'key': 'HIDDEN', 'label': '👁️ Đã ẩn', 'count': countHidden},
                ];

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: filterChips.map((chip) {
                      final key = chip['key'] as String;
                      final label = chip['label'] as String;
                      final count = chip['count'] as int;
                      final isSelected = _reviewFilterRating == key;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: () => setState(() => _reviewFilterRating = key),
                          borderRadius: BorderRadius.circular(10),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF059669) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? const Color(0xFF059669) : const Color(0xFFE2E8F0),
                                width: 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF059669).withValues(alpha: 0.25),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      )
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  label,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                    color: isSelected ? Colors.white : const Color(0xFF475569),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5.5, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white.withValues(alpha: 0.25)
                                        : const Color(0xFFE2E8F0),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '$count',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? Colors.white : const Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              }),
            ],
          ),
        ),

        // Reviews list
        Expanded(
          child: Obx(() {
            final allReviews = controller.reviews;
            final query = _reviewSearchCtrl.text.trim().toLowerCase();

            final filtered = allReviews.where((r) {
              if (_reviewFilterRating == '5' && r.rating < 4.5) return false;
              if (_reviewFilterRating == '4' && (r.rating < 3.5 || r.rating >= 4.5)) return false;
              if (_reviewFilterRating == '3' && (r.rating < 2.5 || r.rating >= 3.5)) return false;
              if (_reviewFilterRating == 'UNREPLIED' && (r.reply != null && r.reply!.trim().isNotEmpty)) return false;
              if (_reviewFilterRating == 'HIDDEN' && !r.isHidden) return false;

              if (query.isNotEmpty) {
                final matchName = r.customerName.toLowerCase().contains(query);
                final matchProd = r.productName.toLowerCase().contains(query);
                final matchComm = r.comment.toLowerCase().contains(query);
                return matchName || matchProd || matchComm;
              }
              return true;
            }).toList();

            if (filtered.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.rate_review_outlined, size: 36, color: Color(0xFF94A3B8)),
                    ),
                    const SizedBox(height: 12),
                    const Text('Không có đánh giá nào phù hợp', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 6),
                    const Text('Hãy thử thay đổi bộ lọc hoặc từ khóa tìm kiếm.', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12.5)),
                  ],
                ),
              );
            }

            final dateFmt = DateFormat('dd/MM/yyyy • HH:mm');

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, index) {
                final review = filtered[index];
                return _buildReviewCard(review, dateFmt);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildReviewCard(ReviewModerationModel review, DateFormat dateFmt) {
    // Generate initials for avatar
    final nameParts = review.customerName.trim().split(' ');
    final initials = nameParts.length >= 2
        ? '${nameParts[0][0]}${nameParts[nameParts.length - 1][0]}'.toUpperCase()
        : (review.customerName.isNotEmpty ? review.customerName[0].toUpperCase() : 'U');

    final hasReply = review.reply != null && review.reply!.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: review.isHidden ? const Color(0xFFCBD5E1) : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HEADER: Avatar + Name + Verified Badge + Status Tag + Date
          Row(
            children: [
              // Avatar
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFDCFCE7)),
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF059669)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Customer Name & Verified badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            review.customerName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF0F172A)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified_rounded, size: 11, color: Color(0xFF059669)),
                              SizedBox(width: 3),
                              Text('Đã mua', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateFmt.format(review.createdAt),
                      style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ),
              // Status Tag
              if (review.isHidden)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: const Text('Đã ẩn', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFFDC2626))),
                )
              else if (hasReply)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: const Text('Đã trả lời', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: const Text('Chờ trả lời', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFFD97706))),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // 2. PRODUCT & STARS STRIP
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Row(
              children: [
                const Icon(Icons.inventory_2_outlined, size: 14, color: Color(0xFF2563EB)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Sản phẩm: ${review.productName}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                // Stars
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (starIdx) {
                    final isFilled = starIdx < review.rating.floor();
                    return Icon(
                      isFilled ? Icons.star_rounded : Icons.star_border_rounded,
                      size: 15,
                      color: const Color(0xFFF59E0B),
                    );
                  }),
                ),
                const SizedBox(width: 4),
                Text(
                  review.rating.toStringAsFixed(1),
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFFD97706)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // 3. REVIEW COMMENT
          Text(
            review.comment,
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              color: review.isHidden ? const Color(0xFF94A3B8) : const Color(0xFF1E293B),
              fontStyle: review.isHidden ? FontStyle.italic : FontStyle.normal,
            ),
          ),

          // 4. SHOP REPLY (if present)
          if (hasReply) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.reply_rounded, size: 16, color: Color(0xFF059669)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Phản hồi từ Cửa hàng:',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          review.reply!,
                          style: const TextStyle(fontSize: 12.5, color: Color(0xFF1E293B), height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),

          // 5. ACTION BUTTONS
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: () => controller.toggleReviewVisibility(review.id),
                icon: Icon(
                  review.isHidden ? Icons.visibility_rounded : Icons.visibility_off_outlined,
                  size: 14,
                  color: review.isHidden ? const Color(0xFF059669) : const Color(0xFF64748B),
                ),
                label: Text(
                  review.isHidden ? 'Hiện công khai' : 'Ẩn đánh giá',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: review.isHidden ? const Color(0xFF059669) : const Color(0xFF64748B),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  minimumSize: const Size(0, 32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  side: BorderSide(
                    color: review.isHidden ? const Color(0xFF86EFAC) : const Color(0xFFCBD5E1),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _showReplyDialog(review),
                icon: const Icon(Icons.reply_rounded, size: 14, color: Colors.white),
                label: Text(
                  hasReply ? 'Sửa phản hồi' : 'Trả lời khách',
                  style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  minimumSize: const Size(0, 32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showReplyDialog(ReviewModerationModel review) {
    final replyCtrl = TextEditingController(text: review.reply ?? '');

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                color: const Color(0xFF0F172A),
                child: Row(
                  children: [
                    const Icon(Icons.reply_rounded, color: Color(0xFF10B981), size: 20),
                    const SizedBox(width: 8),
                    const Text('Phản Hồi Đánh Giá', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70, size: 18),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Đánh giá của: ${review.customerName} • ${review.rating} ⭐', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                    const SizedBox(height: 4),
                    Text('"${review.comment}"', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Color(0xFF64748B))),
                    const SizedBox(height: 14),
                    TextField(
                      controller: replyCtrl,
                      decoration: InputDecoration(
                        hintText: 'Nhập nội dung phản hồi công khai đến khách hàng...',
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                        child: const Text('Hủy bỏ', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (replyCtrl.text.trim().isNotEmpty) {
                            controller.replyToReview(review.id, replyCtrl.text);
                          }
                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF059669),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        child: const Text('Gửi phản hồi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
}
