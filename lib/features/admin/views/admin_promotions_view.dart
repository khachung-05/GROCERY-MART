import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../admin_controller.dart';
import '../models/admin_models.dart';

class AdminPromotionsView extends StatefulWidget {
  final NumberFormat currencyFormatter;
  const AdminPromotionsView({super.key, required this.currencyFormatter});

  @override
  State<AdminPromotionsView> createState() => _AdminPromotionsViewState();
}

class _AdminPromotionsViewState extends State<AdminPromotionsView> {
  final AdminController controller = Get.find<AdminController>();
  int _selectedSubTab = 0;

  // Search & Filter state for Vouchers
  final TextEditingController _voucherSearchCtrl = TextEditingController();
  String _voucherFilter = 'ALL'; // 'ALL', 'ACTIVE', 'INACTIVE'

  // Push Notification state
  final TextEditingController _pushTitleCtrl = TextEditingController(
    text: 'Rau Củ Tươi Mới Sáng Nay 🥬',
  );
  final TextEditingController _pushMsgCtrl = TextEditingController(
    text: 'Nhập mã FRESH20 để được giảm ngay 20.000đ cho đơn hàng từ 100.000đ!',
  );
  final TextEditingController _pushCodeCtrl = TextEditingController(text: 'FRESH20');
  String _pushCategory = 'promo';

  @override
  void dispose() {
    _voucherSearchCtrl.dispose();
    _pushTitleCtrl.dispose();
    _pushMsgCtrl.dispose();
    _pushCodeCtrl.dispose();
    super.dispose();
  }

  void _copyVoucherCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    Get.rawSnackbar(
      titleText: const Text('Đã sao chép mã ưu đãi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
      messageText: Text('Mã "$code" đã sẵn sàng để dán', style: const TextStyle(color: Color(0xFFD1FAE5), fontSize: 12)),
      backgroundColor: const Color(0xFF059669),
      icon: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
      duration: const Duration(seconds: 2),
    );
  }

  Widget _buildSubTabPill({
    required int index,
    required String label,
    required IconData icon,
    String? badgeText,
  }) {
    final isSelected = _selectedSubTab == index;
    return InkWell(
      onTap: () => setState(() => _selectedSubTab = index),
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
              badgeText != null ? '$label ($badgeText)' : label,
              style: TextStyle(
                fontSize: 13,
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
      children: [
        // ==================== TOP NAVIGATION BAR ====================
        Container(
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
                              label: 'Mã giảm giá',
                              icon: Icons.confirmation_number_rounded,
                              badgeText: '${controller.vouchers.length}',
                            ),
                            const SizedBox(width: 4),
                            _buildSubTabPill(
                              index: 1,
                              label: 'Flash Sale',
                              icon: Icons.flash_on_rounded,
                              badgeText: '${controller.flashSales.length}',
                            ),
                            const SizedBox(width: 4),
                            _buildSubTabPill(
                              index: 2,
                              label: 'Phát thông báo đẩy',
                              icon: Icons.send_rounded,
                            ),
                          ],
                        )),
                  ),
                ),
              ),
              if (_selectedSubTab == 0 || _selectedSubTab == 1) ...[
                const SizedBox(width: 10),
                if (_selectedSubTab == 0)
                  ElevatedButton.icon(
                    onPressed: () => _showVoucherFormDialog(),
                    icon: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                    label: Text(
                      MediaQuery.of(context).size.width >= 600 ? 'Tạo Voucher mới' : 'Tạo mới',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      minimumSize: const Size(0, 36),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                  ),
                if (_selectedSubTab == 1)
                  ElevatedButton.icon(
                    onPressed: () => _showAddFlashSaleDialog(),
                    icon: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                    label: Text(
                      MediaQuery.of(context).size.width >= 600 ? 'Tạo Flash Sale' : 'Tạo mới',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEA580C),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      minimumSize: const Size(0, 36),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                  ),
              ],
            ],
          ),
        ),

        // ==================== SUB-TAB CONTENT ====================
        Expanded(
          child: _selectedSubTab == 0
              ? _buildVouchersTab()
              : (_selectedSubTab == 1 ? _buildFlashSalesTab() : _buildPushNotificationTab()),
        ),
      ],
    );
  }

  // ==================== TAB 1: DANH SÁCH VOUCHERS ====================
  Widget _buildVouchersTab() {
    return Obx(() {
      final allVouchers = controller.vouchers;
      final totalCount = allVouchers.length;
      final activeCount = allVouchers.where((v) => v.isActive).length;
      final inactiveCount = totalCount - activeCount;

      final query = _voucherSearchCtrl.text.trim().toLowerCase();
      final filteredList = allVouchers.where((v) {
        if (_voucherFilter == 'ACTIVE' && !v.isActive) return false;
        if (_voucherFilter == 'INACTIVE' && v.isActive) return false;
        if (query.isNotEmpty) {
          final codeMatch = v.code.toLowerCase().contains(query);
          final titleMatch = v.title.toLowerCase().contains(query);
          return codeMatch || titleMatch;
        }
        return true;
      }).toList();

      return Column(
        children: [
          // QUICK STATS & SEARCH / FILTER BAR
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            color: Colors.white,
            child: Column(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 600;
                    final searchField = SizedBox(
                      height: 38,
                      child: TextField(
                        controller: _voucherSearchCtrl,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Tìm theo mã coupon hoặc mô tả...',
                          hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                          prefixIcon: const Icon(Icons.search_rounded, size: 18, color: Color(0xFF64748B)),
                          suffixIcon: _voucherSearchCtrl.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 16, color: Color(0xFF94A3B8)),
                                  onPressed: () {
                                    _voucherSearchCtrl.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Color(0xFF059669)),
                          ),
                        ),
                      ),
                    );

                    final filterChips = SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('ALL', 'Tất cả ($totalCount)'),
                          const SizedBox(width: 6),
                          _buildFilterChip('ACTIVE', 'Đang mở ($activeCount)'),
                          const SizedBox(width: 6),
                          _buildFilterChip('INACTIVE', 'Đã tắt ($inactiveCount)'),
                        ],
                      ),
                    );

                    if (isMobile) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          searchField,
                          const SizedBox(height: 8),
                          filterChips,
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(child: searchField),
                        const SizedBox(width: 10),
                        Row(
                          children: [
                            _buildFilterChip('ALL', 'Tất cả ($totalCount)'),
                            const SizedBox(width: 6),
                            _buildFilterChip('ACTIVE', 'Đang mở ($activeCount)'),
                            const SizedBox(width: 6),
                            _buildFilterChip('INACTIVE', 'Đã tắt ($inactiveCount)'),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          // VOUCHER LIST
          Expanded(
            child: filteredList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.confirmation_number_outlined, size: 40, color: Color(0xFF94A3B8)),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Không tìm thấy mã giảm giá phù hợp',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF475569)),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Thử tìm với từ khóa khác hoặc tạo mã mới',
                          style: TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _showVoucherFormDialog(),
                          icon: const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                          label: const Text('Tạo Voucher mới ngay', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF059669),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (ctx, index) {
                      return _buildVoucherTicketCard(filteredList[index]);
                    },
                  ),
          ),
        ],
      );
    });
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _voucherFilter == key;
    return InkWell(
      onTap: () => setState(() => _voucherFilter = key),
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF059669).withValues(alpha: 0.1) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF059669) : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? const Color(0xFF059669) : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  // ==================== MODERN PERFORATED TICKET CARD ====================
  Widget _buildVoucherTicketCard(AdminVoucherModel v) {
    final isPercent = v.discountType == 'PERCENT';
    final dateFmt = DateFormat('dd/MM/yyyy');
    final isExpiringSoon = v.expiryDate.difference(DateTime.now()).inDays <= 7;
    final usagePercent = v.usageLimit > 0 ? (v.usedCount / v.usageLimit).clamp(0.0, 1.0) : 0.0;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: v.isActive ? const Color(0xFFE2E8F0) : const Color(0xFFF1F5F9),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. TICKET STUB (LEFT BADGE)
            Container(
              width: isMobile ? 88 : 118,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: v.isActive
                      ? [const Color(0xFF059669), const Color(0xFF047857)]
                      : [const Color(0xFF64748B), const Color(0xFF475569)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Type tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isPercent
                          ? 'VOUCHER %'
                          : (v.code.toUpperCase().contains('SHIP') ? 'FREESHIP' : 'GIẢM TIỀN'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 9,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Discount amount with FittedBox so it never wraps!
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      isPercent
                          ? '-${v.discountValue.toInt()}%'
                          : '-${(v.discountValue / 1000).toInt()}k',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Copyable Code Pill
                  InkWell(
                    onTap: () => _copyVoucherCode(v.code),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                v.code,
                                maxLines: 1,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 11,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.copy_rounded, size: 10, color: Colors.white70),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. PERFORATION DIVIDER WITH TOP & BOTTOM PUNCH HOLES (DECORATIVE)
            IgnorePointer(
              child: SizedBox(
                width: 16,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    // Center dashed perforation line
                    const Positioned.fill(
                      child: CustomPaint(
                        painter: _DashedVerticalLinePainter(),
                      ),
                    ),
                    // Top Punch Notch
                    Positioned(
                      top: -8,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF8FAFC),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    // Bottom Punch Notch
                    Positioned(
                      bottom: -8,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF8FAFC),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. VOUCHER DETAILS & CONTROLS (RIGHT BODY)
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(isMobile ? 8 : 10, 10, isMobile ? 8 : 14, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top: Title and Actions
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            v.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: isMobile ? 13 : 14.5,
                              height: 1.25,
                              color: v.isActive ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),

                        // Action Controls (Status Toggle, Edit, Delete)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Status Pill
                            InkWell(
                              onTap: () {
                                controller.saveVoucher(v.copyWith(isActive: !v.isActive), true);
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: v.isActive ? const Color(0xFFECFDF5) : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: v.isActive ? const Color(0xFFA7F3D0) : const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: v.isActive ? const Color(0xFF059669) : const Color(0xFF94A3B8),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      v.isActive ? 'Bật' : 'Tắt',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.bold,
                                        color: v.isActive ? const Color(0xFF059669) : const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 2),

                            // Edit Button
                            InkWell(
                              onTap: () => _showVoucherFormDialog(voucherToEdit: v),
                              borderRadius: BorderRadius.circular(6),
                              child: const Padding(
                                padding: EdgeInsets.all(4),
                                child: Icon(Icons.edit_outlined, size: 16, color: Color(0xFF475569)),
                              ),
                            ),
                            const SizedBox(width: 2),

                            // Delete Button
                            InkWell(
                              onTap: () => _confirmDeleteVoucher(v),
                              borderRadius: BorderRadius.circular(6),
                              child: const Padding(
                                padding: EdgeInsets.all(4),
                                child: Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFDC2626)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Conditions Wrap (full width of right body)
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        // Minimum order chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.shopping_bag_outlined, size: 11, color: Color(0xFF475569)),
                              const SizedBox(width: 3),
                              Text(
                                'Đơn: ${widget.currencyFormatter.format(v.minOrderValue)}',
                                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                              ),
                            ],
                          ),
                        ),
                        // Max discount chip if percent
                        if (v.maxDiscount != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFBEB),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.bolt_rounded, size: 11, color: Color(0xFFD97706)),
                                const SizedBox(width: 3),
                                Text(
                                  'Tối đa: ${widget.currencyFormatter.format(v.maxDiscount!)}',
                                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFFB45309)),
                                ),
                              ],
                            ),
                          ),
                        // Expiry Chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isExpiringSoon ? const Color(0xFFFEF2F2) : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.event_outlined,
                                size: 11,
                                color: isExpiringSoon ? const Color(0xFFEF4444) : const Color(0xFF64748B),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                'HSD: ${dateFmt.format(v.expiryDate)}',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: isExpiringSoon ? const Color(0xFFEF4444) : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Bottom: Usage Progress Bar
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                'Đã dùng: ${v.usedCount} / ${v.usageLimit}',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: v.isActive ? const Color(0xFF059669) : const Color(0xFF64748B),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'Còn ${(v.usageLimit - v.usedCount).clamp(0, 999999)} (${(usagePercent * 100).toStringAsFixed(0)}%)',
                                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: usagePercent,
                            backgroundColor: const Color(0xFFF1F5F9),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              v.isActive ? const Color(0xFF059669) : const Color(0xFF94A3B8),
                            ),
                            minHeight: 5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Confirm delete voucher dialog
  void _confirmDeleteVoucher(AdminVoucherModel v) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 22),
            SizedBox(width: 8),
            Text('Xóa mã giảm giá?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text('Bạn có chắc chắn muốn xóa mã "${v.code}" (${v.title})? Hành động này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy bỏ', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              controller.deleteVoucher(v.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
            child: const Text('Xác nhận xóa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // ==================== TAB 2: FLASH SALE SCHEDULE ====================
  Widget _buildFlashSalesTab() {
    return Obx(() {
      final list = controller.flashSales;
      final timeFmt = DateFormat('HH:mm dd/MM');

      if (list.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.flash_off_rounded, size: 48, color: Color(0xFF94A3B8)),
              const SizedBox(height: 12),
              const Text('Chưa có chương trình Flash Sale nào', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF475569))),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _showAddFlashSaleDialog(),
                icon: const Icon(Icons.add, color: Colors.white, size: 18),
                label: const Text('Tạo chiến dịch Flash Sale', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEA580C)),
              ),
            ],
          ),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (ctx, index) {
          final fs = list[index];
          final now = DateTime.now();
          final isRunning = fs.isActive && now.isAfter(fs.startTime) && now.isBefore(fs.endTime);

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isRunning ? const Color(0xFFFDBA74) : const Color(0xFFE2E8F0),
                width: isRunning ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isRunning ? const Color(0xFFEA580C).withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Flame icon badge
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isRunning ? const Color(0xFFFFF7ED) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isRunning ? const Color(0xFFFED7AA) : Colors.transparent,
                    ),
                  ),
                  child: Icon(
                    Icons.bolt_rounded,
                    size: 30,
                    color: isRunning ? const Color(0xFFEA580C) : const Color(0xFF94A3B8),
                  ),
                ),
                const SizedBox(width: 16),

                // Campaign Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDC2626),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              'GIẢM ${fs.discountPercent}%',
                              style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w900),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (isRunning)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(5),
                                border: Border.all(color: const Color(0xFFA7F3D0)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.fiber_manual_record, size: 8, color: Color(0xFF059669)),
                                  SizedBox(width: 4),
                                  Text('Đang diễn ra', style: TextStyle(color: Color(0xFF059669), fontSize: 10.5, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              fs.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: Color(0xFF0F172A)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.access_time_rounded, size: 13, color: Color(0xFF64748B)),
                          const SizedBox(width: 4),
                          Text(
                            'Khung giờ: ${timeFmt.format(fs.startTime)} - ${timeFmt.format(fs.endTime)}',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.inventory_2_outlined, size: 13, color: Color(0xFF059669)),
                          const SizedBox(width: 4),
                          Text(
                            'Áp dụng cho ${fs.productIds.length} sản phẩm chỉ định',
                            style: const TextStyle(fontSize: 12, color: Color(0xFF059669), fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Switch status
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: fs.isActive,
                      activeThumbColor: const Color(0xFFEA580C),
                      onChanged: (val) => controller.toggleFlashSale(fs.id),
                    ),
                    Text(
                      fs.isActive ? 'Bật' : 'Tắt',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: fs.isActive ? const Color(0xFFEA580C) : const Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    });
  }

  // ==================== TAB 3: SOẠN & PHÁT THÔNG BÁO ĐẨY ====================
  Widget _buildPushNotificationTab() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: isDesktop
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left: Composer Form
                        Expanded(
                          flex: 3,
                          child: _buildPushComposerCard(),
                        ),
                        const SizedBox(width: 24),
                        // Right: Live Mobile Smartphone Preview
                        Expanded(
                          flex: 2,
                          child: _buildSmartphonePreview(),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        _buildPushComposerCard(),
                        const SizedBox(height: 20),
                        _buildSmartphonePreview(),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPushComposerCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF059669).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.campaign_rounded, color: Color(0xFF059669), size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Soạn & Phát Sóng Thông Báo Đẩy', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    Text('Gửi tin nhắn ưu đãi tức thì đến thiết bị của khách hàng', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 30),

          // Quick Templates
          const Text('Mẫu tin nhắn nhanh:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155))),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTemplateChip(
                label: '🥬 Rau củ tươi sáng',
                title: 'Rau Củ Hữu Cơ Tươi Mới Sáng Nay 🥬',
                msg: 'Ưu đãi đặc biệt giảm 20.000đ khi nhập mã FRESH20. Rau tươi vườn nhà giao ngay trong 2h!',
                code: 'FRESH20',
              ),
              _buildTemplateChip(
                label: '🔥 Flash Sale sốc',
                title: '⚡ FLASH SALE ĐANG DIỄN RA: Giảm Đến 30%!',
                msg: 'Hàng trăm sản phẩm trái cây và thực phẩm nhập khẩu giảm giá cực sâu chỉ trong 2 giờ.',
                code: 'FLASH30',
              ),
              _buildTemplateChip(
                label: '🚚 Freeship cuối tuần',
                title: 'Miễn Phí Vận Chuyển Cuối Tuần 🚚',
                msg: 'Nhập FREESHIP50 để nhận ngay ưu đãi freeship cho mọi đơn hàng từ 200.000đ.',
                code: 'FREESHIP50',
              ),
            ],
          ),
          const SizedBox(height: 18),

          const Text('Phân loại thông báo:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155))),
          const SizedBox(height: 8),
          Row(
            children: [
              ChoiceChip(
                label: const Text('Ưu đãi / Khuyến mãi'),
                selected: _pushCategory == 'promo',
                selectedColor: const Color(0xFF059669).withValues(alpha: 0.15),
                labelStyle: TextStyle(
                  color: _pushCategory == 'promo' ? const Color(0xFF059669) : const Color(0xFF64748B),
                  fontWeight: _pushCategory == 'promo' ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: (val) => setState(() => _pushCategory = 'promo'),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Tin tức / Cập nhật kho'),
                selected: _pushCategory == 'news',
                selectedColor: const Color(0xFF059669).withValues(alpha: 0.15),
                labelStyle: TextStyle(
                  color: _pushCategory == 'news' ? const Color(0xFF059669) : const Color(0xFF64748B),
                  fontWeight: _pushCategory == 'news' ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: (val) => setState(() => _pushCategory = 'news'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          const Text('Tiêu đề thông báo:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155))),
          const SizedBox(height: 8),
          TextField(
            controller: _pushTitleCtrl,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Nhập tiêu đề hấp dẫn kèm biểu tượng emoji...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
            ),
          ),
          const SizedBox(height: 16),

          const Text('Nội dung chi tiết thông báo:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155))),
          const SizedBox(height: 8),
          TextField(
            controller: _pushMsgCtrl,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Mô tả ưu đãi, thông tin sản phẩm hoặc hướng dẫn mua hàng...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),

          const Text('Mã Coupon đính kèm (Tùy chọn):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155))),
          const SizedBox(height: 8),
          TextField(
            controller: _pushCodeCtrl,
            onChanged: (_) => setState(() {}),
            textCapitalization: TextCapitalization.characters,
            decoration: InputDecoration(
              hintText: 'Ví dụ: FRESH20, FREESHIP50...',
              prefixIcon: const Icon(Icons.confirmation_number_outlined, size: 18, color: Color(0xFF059669)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
            ),
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                final title = _pushTitleCtrl.text.trim();
                final msg = _pushMsgCtrl.text.trim();
                final code = _pushCodeCtrl.text.trim().toUpperCase();
                if (title.isNotEmpty && msg.isNotEmpty) {
                  controller.broadcastPushNotification(
                    title: title,
                    message: msg,
                    category: _pushCategory,
                    promoCode: code.isNotEmpty ? code : null,
                  );
                }
              },
              icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              label: const Text('Bắn Thông Báo Đẩy Ngay 🚀', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF059669),
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateChip({
    required String label,
    required String title,
    required String msg,
    required String code,
  }) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
      backgroundColor: const Color(0xFFF1F5F9),
      side: const BorderSide(color: Color(0xFFE2E8F0)),
      onPressed: () {
        setState(() {
          _pushTitleCtrl.text = title;
          _pushMsgCtrl.text = msg;
          _pushCodeCtrl.text = code;
        });
      },
    );
  }

  // Smartphone live notification preview
  Widget _buildSmartphonePreview() {
    final title = _pushTitleCtrl.text.trim().isEmpty ? 'Tiêu đề thông báo đẩy...' : _pushTitleCtrl.text.trim();
    final msg = _pushMsgCtrl.text.trim().isEmpty ? 'Nội dung thông báo hiển thị trên màn hình khóa...' : _pushMsgCtrl.text.trim();
    final code = _pushCodeCtrl.text.trim().toUpperCase();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF334155), width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Mock Phone Top Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('09:41', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
              Container(
                width: 60,
                height: 14,
                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8)),
              ),
              const Row(
                children: [
                  Icon(Icons.wifi, size: 12, color: Colors.white70),
                  SizedBox(width: 4),
                  Icon(Icons.battery_full, size: 14, color: Colors.white70),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          const Center(
            child: Text(
              'XEM TRƯỚC THÔNG BÁO THỰC TẾ',
              style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1),
            ),
          ),
          const SizedBox(height: 16),

          // PUSH NOTIFICATION POPUP CARD
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 5)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row (App icon + App name + Time)
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF059669), Color(0xFF10B981)]),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.shopping_basket_rounded, color: Colors.white, size: 14),
                    ),
                    const SizedBox(width: 8),
                    const Text('SIÊU THỊ XANH', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: 0.5)),
                    const Spacer(),
                    const Text('Vừa xong', style: TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8))),
                  ],
                ),
                const SizedBox(height: 8),

                // Title
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 4),

                // Body text
                Text(
                  msg,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF475569), height: 1.3),
                ),

                // Attached Promo Code Pill if available
                if (code.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.confirmation_number_rounded, size: 14, color: Color(0xFF059669)),
                            const SizedBox(width: 6),
                            Text('Mã: $code', style: const TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.w900, fontSize: 12)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF059669),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('Dùng ngay', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Center(
            child: Text(
              'Tất cả khách hàng đã cài ứng dụng sẽ nhận được thông báo này ngay trên màn hình khóa.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== FORM DIALOG: CREATE & EDIT VOUCHER ====================
  void _showVoucherFormDialog({AdminVoucherModel? voucherToEdit}) {
    final isEditing = voucherToEdit != null;
    final codeCtrl = TextEditingController(text: voucherToEdit?.code ?? '');
    final titleCtrl = TextEditingController(text: voucherToEdit?.title ?? '');
    final valueCtrl = TextEditingController(
      text: voucherToEdit != null
          ? (voucherToEdit.discountType == 'PERCENT' ? voucherToEdit.discountValue.toInt().toString() : voucherToEdit.discountValue.toInt().toString())
          : '20000',
    );
    final minOrderCtrl = TextEditingController(
      text: voucherToEdit != null ? voucherToEdit.minOrderValue.toInt().toString() : '100000',
    );
    final maxDiscountCtrl = TextEditingController(
      text: voucherToEdit?.maxDiscount != null ? voucherToEdit!.maxDiscount!.toInt().toString() : '50000',
    );
    final limitCtrl = TextEditingController(
      text: voucherToEdit != null ? voucherToEdit.usageLimit.toString() : '200',
    );
    String discountType = voucherToEdit?.discountType ?? 'FIXED';
    DateTime expiryDate = voucherToEdit?.expiryDate ?? DateTime.now().add(const Duration(days: 30));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Dialog Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  color: const Color(0xFF0F172A),
                  child: Row(
                    children: [
                      const Icon(Icons.confirmation_number_rounded, color: Color(0xFF10B981), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        isEditing ? 'Chỉnh Sửa Mã Khuyến Mãi' : 'Tạo Mã Khuyến Mãi Mới',
                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
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

                // Dialog Form Body
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // LIVE INTERACTIVE TICKET PREVIEW
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF059669),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  discountType == 'PERCENT'
                                      ? '-${valueCtrl.text}%'
                                      : '-${((double.tryParse(valueCtrl.text) ?? 0) / 1000).toInt()}k',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF10B981).withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            codeCtrl.text.trim().isEmpty ? 'MÃ_ƯU_ĐÃI' : codeCtrl.text.trim().toUpperCase(),
                                            style: const TextStyle(color: Color(0xFF34D399), fontWeight: FontWeight.w900, fontSize: 12),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'HSD: ${DateFormat('dd/MM/yyyy').format(expiryDate)}',
                                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      titleCtrl.text.trim().isEmpty ? 'Tiêu đề khuyến mãi hiển thị...' : titleCtrl.text.trim(),
                                      style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Form Inputs
                        TextField(
                          controller: codeCtrl,
                          onChanged: (_) => setDialogState(() {}),
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            labelText: 'Mã Voucher (Ví dụ: TET2026, FREESHIP50)',
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        const SizedBox(height: 12),

                        TextField(
                          controller: titleCtrl,
                          onChanged: (_) => setDialogState(() {}),
                          decoration: InputDecoration(
                            labelText: 'Mô tả tiêu đề ưu đãi',
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        const SizedBox(height: 12),

                        DropdownButtonFormField<String>(
                          initialValue: discountType,
                          decoration: InputDecoration(
                            labelText: 'Hình thức chiết khấu',
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'FIXED', child: Text('Giảm số tiền cố định (VNĐ)')),
                            DropdownMenuItem(value: 'PERCENT', child: Text('Giảm theo phần trăm (%)')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setDialogState(() {
                                discountType = val;
                                if (discountType == 'PERCENT' && valueCtrl.text == '20000') {
                                  valueCtrl.text = '10';
                                } else if (discountType == 'FIXED' && valueCtrl.text == '10') {
                                  valueCtrl.text = '20000';
                                }
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: valueCtrl,
                                onChanged: (_) => setDialogState(() {}),
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: discountType == 'PERCENT' ? 'Mức giảm (%)' : 'Mức giảm (VNĐ)',
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                            if (discountType == 'PERCENT') ...[
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: maxDiscountCtrl,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Giảm tối đa (VNĐ)',
                                    filled: true,
                                    fillColor: const Color(0xFFF8FAFC),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: minOrderCtrl,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Đơn tối thiểu (VNĐ)',
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: limitCtrl,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Lượt dùng tối đa',
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Expiry Date Picker
                        InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: expiryDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) {
                              setDialogState(() => expiryDate = picked);
                            }
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFCBD5E1)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today_rounded, size: 16, color: Color(0xFF059669)),
                                const SizedBox(width: 10),
                                const Text('Ngày hết hạn áp dụng: ', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                                Text(
                                  DateFormat('dd/MM/yyyy').format(expiryDate),
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                ),
                                const Spacer(),
                                const Text('Đổi', style: TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.bold, fontSize: 12)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Dialog Action Buttons (50 / 50)
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
                            final code = codeCtrl.text.trim().toUpperCase();
                            final title = titleCtrl.text.trim();
                            final val = double.tryParse(valueCtrl.text.trim()) ?? 0;
                            final minOrder = double.tryParse(minOrderCtrl.text.trim()) ?? 0;
                            final maxDisc = double.tryParse(maxDiscountCtrl.text.trim());
                            final limit = int.tryParse(limitCtrl.text.trim()) ?? 100;

                            if (code.isNotEmpty && title.isNotEmpty && val > 0) {
                              final newOrUpdatedVoucher = AdminVoucherModel(
                                id: isEditing ? voucherToEdit.id : 'VOUCHER-${DateTime.now().millisecondsSinceEpoch}',
                                code: code,
                                title: title,
                                discountType: discountType,
                                discountValue: val,
                                minOrderValue: minOrder,
                                maxDiscount: discountType == 'PERCENT' ? maxDisc : null,
                                usageLimit: limit,
                                usedCount: isEditing ? voucherToEdit.usedCount : 0,
                                expiryDate: expiryDate,
                                isActive: isEditing ? voucherToEdit.isActive : true,
                              );

                              controller.saveVoucher(newOrUpdatedVoucher, isEditing);
                              Navigator.pop(ctx);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF059669),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          child: Text(
                            isEditing ? 'Lưu thay đổi' : 'Kích hoạt Voucher',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== FORM DIALOG: ADD FLASH SALE ====================
  void _showAddFlashSaleDialog() {
    final titleCtrl = TextEditingController(text: 'Flash Sale Cuối Tuần ⚡');
    final discountCtrl = TextEditingController(text: '25');

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                color: const Color(0xFF0F172A),
                child: Row(
                  children: [
                    const Icon(Icons.bolt_rounded, color: Color(0xFFF59E0B), size: 22),
                    const SizedBox(width: 8),
                    const Text('Tạo Chiến Dịch Flash Sale Mới', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
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
                  children: [
                    TextField(
                      controller: titleCtrl,
                      decoration: InputDecoration(
                        labelText: 'Tên chiến dịch Flash Sale',
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: discountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Phần trăm giảm giá (%)',
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                color: const Color(0xFFF8FAFC),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Hủy', style: TextStyle(color: Color(0xFF64748B))),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final title = titleCtrl.text.trim();
                          final disc = int.tryParse(discountCtrl.text.trim()) ?? 20;
                          if (title.isNotEmpty) {
                            controller.flashSales.insert(
                              0,
                              FlashSaleCampaignModel(
                                id: 'FS-${DateTime.now().millisecondsSinceEpoch}',
                                title: title,
                                discountPercent: disc,
                                startTime: DateTime.now(),
                                endTime: DateTime.now().add(const Duration(hours: 48)),
                                productIds: ['prod_1', 'prod_2', 'prod_3'],
                                isActive: true,
                              ),
                            );
                            Navigator.pop(ctx);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEA580C),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Kích hoạt ngay', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

/// Custom painter for dashed perforation vertical line in voucher cards
class _DashedVerticalLinePainter extends CustomPainter {
  const _DashedVerticalLinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 1.5;
    const dashHeight = 4.0;
    const dashSpace = 4.0;
    double startY = 10.0;
    while (startY < size.height - 10.0) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
