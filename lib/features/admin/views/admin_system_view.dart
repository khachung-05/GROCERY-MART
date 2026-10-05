import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../admin_controller.dart';
import '../models/admin_models.dart';

class AdminSystemView extends StatefulWidget {
  const AdminSystemView({super.key});

  @override
  State<AdminSystemView> createState() => _AdminSystemViewState();
}

class _AdminSystemViewState extends State<AdminSystemView> {
  final AdminController controller = Get.find<AdminController>();
  int _selectedSubTab = 0;

  // Search & Filter state for Staff
  final TextEditingController _staffSearchCtrl = TextEditingController();
  String _staffFilter = 'ALL'; // 'ALL', 'ACTIVE', 'LOCKED'

  @override
  void dispose() {
    _staffSearchCtrl.dispose();
    super.dispose();
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
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
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
              color: isSelected ? const Color(0xFF059669) : const Color(0xFF64748B),
            ),
            const SizedBox(width: 7),
            Text(
              badgeText != null ? '$label ($badgeText)' : label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
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
        // TOP SUB-NAVIGATION HEADER
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
                              label: 'Phân quyền nhân sự',
                              icon: Icons.admin_panel_settings_rounded,
                              badgeText: '${controller.staffMembers.length}',
                            ),
                            const SizedBox(width: 4),
                            _buildSubTabPill(
                              index: 1,
                              label: 'Cài đặt chung & Cổng thanh toán',
                              icon: Icons.tune_rounded,
                            ),
                          ],
                        )),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (_selectedSubTab == 0)
                ElevatedButton.icon(
                  onPressed: () => _showAddStaffDialog(),
                  icon: const Icon(Icons.person_add_rounded, color: Colors.white, size: 18),
                  label: Text(
                    MediaQuery.of(context).size.width >= 650 ? 'Thêm nhân sự mới' : 'Thêm mới',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    minimumSize: const Size(0, 36),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                ),
            ],
          ),
        ),

        // SUB-TAB VIEW CONTENT
        Expanded(
          child: _selectedSubTab == 0
              ? _buildStaffRbacTab()
              : _buildGeneralSettingsTab(),
        ),
      ],
    );
  }

  // ==================== TAB 1: PHÂN QUYỀN NHÂN SỰ (RBAC) ====================
  Widget _buildStaffRbacTab() {
    return Obx(() {
      final allStaff = controller.staffMembers;
      final totalCount = allStaff.length;
      final activeCount = allStaff.where((s) => s.isActive).length;
      final lockedCount = totalCount - activeCount;

      final query = _staffSearchCtrl.text.trim().toLowerCase();
      final filteredList = allStaff.where((s) {
        if (_staffFilter == 'ACTIVE' && !s.isActive) return false;
        if (_staffFilter == 'LOCKED' && s.isActive) return false;
        if (query.isNotEmpty) {
          final nameMatch = s.name.toLowerCase().contains(query);
          final emailMatch = s.email.toLowerCase().contains(query);
          final phoneMatch = s.phone.toLowerCase().contains(query);
          final roleMatch = s.role.toLowerCase().contains(query);
          return nameMatch || emailMatch || phoneMatch || roleMatch;
        }
        return true;
      }).toList();

      return Column(
        children: [
          // SEARCH & FILTER HEADER
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            color: Colors.white,
            child: LayoutBuilder(
              builder: (ctx, constraints) {
                final isNarrow = constraints.maxWidth < 650;
                final searchField = SizedBox(
                  height: 38,
                  child: TextField(
                    controller: _staffSearchCtrl,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Tìm theo tên, email, SĐT hoặc vai trò...',
                      hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                      prefixIcon: const Icon(Icons.search_rounded, size: 18, color: Color(0xFF64748B)),
                      suffixIcon: _staffSearchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 16, color: Color(0xFF94A3B8)),
                              onPressed: () {
                                _staffSearchCtrl.clear();
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
                      _buildStaffFilterChip('ALL', 'Tất cả ($totalCount)'),
                      const SizedBox(width: 6),
                      _buildStaffFilterChip('ACTIVE', 'Đang hoạt động ($activeCount)'),
                      const SizedBox(width: 6),
                      _buildStaffFilterChip('LOCKED', 'Tạm khóa ($lockedCount)'),
                    ],
                  ),
                );

                if (isNarrow) {
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
                        _buildStaffFilterChip('ALL', 'Tất cả ($totalCount)'),
                        const SizedBox(width: 6),
                        _buildStaffFilterChip('ACTIVE', 'Đang hoạt động ($activeCount)'),
                        const SizedBox(width: 6),
                        _buildStaffFilterChip('LOCKED', 'Tạm khóa ($lockedCount)'),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),

          // STAFF LIST
          Expanded(
            child: filteredList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: const BoxDecoration(color: Color(0xFFF1F5F9), shape: BoxShape.circle),
                          child: const Icon(Icons.people_outline_rounded, size: 40, color: Color(0xFF94A3B8)),
                        ),
                        const SizedBox(height: 12),
                        const Text('Không tìm thấy nhân sự phù hợp', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF475569))),
                        const SizedBox(height: 14),
                        ElevatedButton.icon(
                          onPressed: () => _showAddStaffDialog(),
                          icon: const Icon(Icons.person_add_rounded, size: 16, color: Colors.white),
                          label: const Text('Thêm nhân sự mới', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
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
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, index) {
                      final staff = filteredList[index];
                      return _buildStaffCard(staff);
                    },
                  ),
          ),
        ],
      );
    });
  }

  Widget _buildStaffFilterChip(String key, String label) {
    final isSelected = _staffFilter == key;
    return InkWell(
      onTap: () => setState(() => _staffFilter = key),
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildStaffCard(StaffMemberModel staff) {
    Color roleColor;
    Color roleBg;
    IconData roleIcon;

    switch (staff.role) {
      case 'Super Admin':
        roleColor = const Color(0xFFBE123C); // Rose-700
        roleBg = const Color(0xFFFFF1F2);    // Rose-50
        roleIcon = Icons.shield_rounded;
        break;
      case 'Quản lý kho':
        roleColor = const Color(0xFFB45309); // Amber-700
        roleBg = const Color(0xFFFFFBEB);    // Amber-50
        roleIcon = Icons.inventory_2_rounded;
        break;
      case 'CSKH & Đơn hàng':
        roleColor = const Color(0xFF1D4ED8); // Blue-700
        roleBg = const Color(0xFFEFF6FF);    // Blue-50
        roleIcon = Icons.headset_mic_rounded;
        break;
      default:
        roleColor = const Color(0xFF047857); // Emerald-700
        roleBg = const Color(0xFFECFDF5);    // Emerald-50
        roleIcon = Icons.query_stats_rounded;
    }

    final isSuperAdmin = staff.role == 'Super Admin';
    final hasAllPerms = staff.permissions.length >= 6;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: staff.isActive ? const Color(0xFFE2E8F0) : const Color(0xFFCBD5E1),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Sleek Minimalist Avatar (Soft Neutral with subtle initial)
          Stack(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                ),
                child: Center(
                  child: Text(
                    staff.name.isNotEmpty ? staff.name[0].toUpperCase() : 'S',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF334155),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: -1,
                bottom: -1,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: staff.isActive ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),

          // 2. Main Info Block
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Name + Role Badge
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        staff.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                          color: staff.isActive ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                          decoration: staff.isActive ? null : TextDecoration.lineThrough,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: roleBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(roleIcon, size: 11, color: roleColor),
                          const SizedBox(width: 3.5),
                          Text(
                            staff.role,
                            style: TextStyle(color: roleColor, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),

                // Contact Details (Clean single-line with subtle separator)
                Row(
                  children: [
                    Text(
                      staff.email,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Text('·', style: TextStyle(color: Color(0xFFCBD5E1), fontWeight: FontWeight.bold)),
                    ),
                    Text(
                      staff.phone,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Minimalist Permissions representation
                if (isSuperAdmin || hasAllPerms)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.all_inclusive_rounded, size: 11, color: Color(0xFF64748B)),
                        SizedBox(width: 4),
                        Text(
                          'Toàn quyền 6 phân hệ',
                          style: TextStyle(fontSize: 11, color: Color(0xFF475569), fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  )
                else
                  Wrap(
                    spacing: 5,
                    runSpacing: 4,
                    children: staff.permissions.map((p) => _buildMinimalistPermissionPill(p)).toList(),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // 3. Right Minimalist Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Clean Switch (Scale 0.75 for minimalism)
              Tooltip(
                message: staff.isActive ? 'Bấm để tạm khóa tài khoản' : 'Bấm để kích hoạt lại',
                child: Transform.scale(
                  scale: 0.75,
                  child: Switch(
                    value: staff.isActive,
                    activeThumbColor: const Color(0xFF059669),
                    activeTrackColor: const Color(0xFFD1FAE5),
                    inactiveThumbColor: const Color(0xFF94A3B8),
                    inactiveTrackColor: const Color(0xFFE2E8F0),
                    trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
                    onChanged: (val) => controller.toggleStaffStatus(staff.id),
                  ),
                ),
              ),
              const SizedBox(width: 4),

              // Edit Icon Button
              InkWell(
                onTap: () => _showAddStaffDialog(staffToEdit: staff),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Icon(Icons.edit_outlined, size: 15, color: Color(0xFF475569)),
                ),
              ),
              const SizedBox(width: 6),

              // Delete Icon Button (disabled for Super Admin)
              if (!isSuperAdmin)
                InkWell(
                  onTap: () => _confirmDeleteStaff(staff),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFEE2E2)),
                    ),
                    child: const Icon(Icons.delete_outline_rounded, size: 15, color: Color(0xFFDC2626)),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.lock_outline_rounded, size: 15, color: Color(0xFFCBD5E1)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalistPermissionPill(String p) {
    String label;
    IconData icon;

    switch (p) {
      case 'products':
        label = 'Kho & Sản phẩm';
        icon = Icons.inventory_2_outlined;
        break;
      case 'orders':
        label = 'Đơn hàng';
        icon = Icons.local_shipping_outlined;
        break;
      case 'crm':
        label = 'Khách hàng';
        icon = Icons.people_outline_rounded;
        break;
      case 'promotions':
        label = 'Khuyến mãi';
        icon = Icons.confirmation_number_outlined;
        break;
      case 'analytics':
        label = 'Báo cáo';
        icon = Icons.insights_rounded;
        break;
      case 'settings':
        label = 'Cài đặt';
        icon = Icons.tune_rounded;
        break;
      default:
        label = p;
        icon = Icons.circle_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10.5, color: const Color(0xFF64748B)),
          const SizedBox(width: 3),
          Text(
            label,
            style: const TextStyle(fontSize: 10.5, color: Color(0xFF475569), fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteStaff(StaffMemberModel staff) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        elevation: 20,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEE2E2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delete_forever_rounded, color: Color(0xFFDC2626), size: 28),
                ),
                const SizedBox(height: 14),
                const Text('Xóa tài khoản nhân sự?', style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                const SizedBox(height: 8),
                Text(
                  'Bạn có chắc chắn muốn gỡ tài khoản "${staff.name}" (${staff.role}) khỏi hệ thống? Thao tác này sẽ thu hồi toàn bộ quyền truy cập và không thể hoàn tác.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.45),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          minimumSize: const Size(0, 40),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                        child: const Text('Hủy bỏ', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          controller.deleteStaff(staff.id);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          minimumSize: const Size(0, 40),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        child: const Text('Xác nhận xóa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
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

  // ==================== TAB 2: CÀI ĐẶT CHUNG & CỔNG THANH TOÁN ====================
  Widget _buildGeneralSettingsTab() {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. CỔNG THANH TOÁN
              _buildSectionCard(
                title: 'CỔNG THANH TOÁN ĐANG KÍCH HOẠT',
                icon: Icons.account_balance_rounded,
                children: [
                  Obx(() => SwitchListTile(
                        title: const Text('Thanh toán khi nhận hàng (COD)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                        subtitle: const Text('Cho phép khách trả tiền mặt trực tiếp cho shipper khi nhận hàng'),
                        value: controller.enableCOD.value,
                        activeThumbColor: const Color(0xFF059669),
                        onChanged: (val) => controller.enableCOD.value = val,
                      )),
                  const Divider(height: 1),
                  Obx(() => SwitchListTile(
                        title: const Text('Cổng thanh toán VNPay (QR Pay / Thẻ ATM)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                        subtitle: const Text('Tích hợp quét mã VNPAY-QR từ ứng dụng ngân hàng'),
                        value: controller.enableVNPay.value,
                        activeThumbColor: const Color(0xFF059669),
                        onChanged: (val) => controller.enableVNPay.value = val,
                      )),
                  const Divider(height: 1),
                  Obx(() => SwitchListTile(
                        title: const Text('Ví điện tử MoMo', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                        subtitle: const Text('Liên kết thanh toán ví điện tử MoMo tức thì'),
                        value: controller.enableMoMo.value,
                        activeThumbColor: const Color(0xFF059669),
                        onChanged: (val) => controller.enableMoMo.value = val,
                      )),
                  const Divider(height: 1),
                  Obx(() => SwitchListTile(
                        title: const Text('Ví điện tử ZaloPay', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                        subtitle: const Text('Cổng ví điện tử ZaloPay trực tuyến'),
                        value: controller.enableZaloPay.value,
                        activeThumbColor: const Color(0xFF059669),
                        onChanged: (val) => controller.enableZaloPay.value = val,
                      )),
                ],
              ),
              const SizedBox(height: 20),

              // 2. THÔNG TIN CỬA HÀNG & PHÍ SHIP
              _buildSectionCard(
                title: 'THÔNG TIN CỬA HÀNG & VẬN HÀNH',
                icon: Icons.storefront_rounded,
                children: [
                  Obx(() => ListTile(
                        leading: const Icon(Icons.badge_outlined, color: Color(0xFF059669)),
                        title: const Text('Tên cửa hàng hiển thị', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        subtitle: Text(controller.storeName.value.isEmpty ? 'Chưa thiết lập' : controller.storeName.value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        trailing: OutlinedButton(
                          onPressed: () => _showEditStoreNameDialog(),
                          child: const Text('Đổi tên'),
                        ),
                      )),
                  const Divider(height: 1),
                  Obx(() => ListTile(
                        leading: const Icon(Icons.phone_in_talk_outlined, color: Color(0xFF059669)),
                        title: const Text('Hotline hỗ trợ', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        subtitle: Text(controller.storeHotline.value.isEmpty ? 'Chưa thiết lập' : controller.storeHotline.value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        trailing: OutlinedButton(
                          onPressed: () => _showEditHotlineDialog(),
                          child: const Text('Cập nhật'),
                        ),
                      )),
                  const Divider(height: 1),
                  Obx(() => ListTile(
                        leading: const Icon(Icons.location_on_outlined, color: Color(0xFF059669)),
                        title: const Text('Địa chỉ kho tổng & trụ sở', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        subtitle: Text(controller.storeAddress.value.isEmpty ? 'Chưa thiết lập' : controller.storeAddress.value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        trailing: OutlinedButton(
                          onPressed: () => _showEditAddressDialog(),
                          child: const Text('Cập nhật'),
                        ),
                      )),
                  const Divider(height: 1),
                  Obx(() => ListTile(
                        leading: const Icon(Icons.local_shipping_outlined, color: Color(0xFF059669)),
                        title: const Text('Phí giao hàng mặc định', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                        subtitle: Text(currencyFormatter.format(controller.storeShippingFee.value), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF059669))),
                        trailing: OutlinedButton(
                          onPressed: () => _showEditShippingFeeDialog(),
                          child: const Text('Thay đổi'),
                        ),
                      )),
                ],
              ),
              const SizedBox(height: 20),

              // 3. TỰ ĐỘNG HÓA & THÔNG BÁO ÂM THANH
              _buildSectionCard(
                title: 'TỰ ĐỘNG HÓA HỆ THỐNG',
                icon: Icons.bolt_rounded,
                children: [
                  Obx(() => SwitchListTile(
                        title: const Text('Tự động duyệt đơn hàng mới (Auto Accept)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                        subtitle: const Text('Tự động chuyển đơn sang "Chờ xử lý đóng gói" không cần click thủ công'),
                        value: controller.autoAcceptOrders.value,
                        activeThumbColor: const Color(0xFF059669),
                        onChanged: (val) => controller.toggleAutoAcceptOrders(val),
                      )),
                  const Divider(height: 1),
                  Obx(() => SwitchListTile(
                        title: const Text('Phát âm thanh chuông báo khi có đơn mới', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                        subtitle: const Text('Phát âm báo ding-dong ngay trên màn hình bảng điều khiển quản trị'),
                        value: controller.soundNotification.value,
                        activeThumbColor: const Color(0xFF059669),
                        onChanged: (val) => controller.toggleSoundNotification(val),
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF059669), size: 20),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A), letterSpacing: 0.3)),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  // ==================== DIALOGS ====================
  void _showAddStaffDialog({StaffMemberModel? staffToEdit}) {
    final isEditing = staffToEdit != null;
    final nameCtrl = TextEditingController(text: staffToEdit?.name ?? '');
    final emailCtrl = TextEditingController(text: staffToEdit?.email ?? '');
    final phoneCtrl = TextEditingController(text: staffToEdit?.phone ?? '');
    String selectedRole = staffToEdit?.role ?? 'Quản lý kho';

    List<String> selectedPerms = staffToEdit != null
        ? List<String>.from(staffToEdit.permissions)
        : ['products'];

    final allPermOptions = [
      {
        'key': 'products',
        'label': 'Kho hàng & Sản phẩm',
        'desc': 'Quản lý danh mục, tồn kho, giá bán và nhập xuất',
        'icon': Icons.inventory_2_rounded,
        'color': const Color(0xFFD97706),
        'bg': const Color(0xFFFEF3C7),
      },
      {
        'key': 'orders',
        'label': 'Đơn hàng & Vận chuyển',
        'desc': 'Tiếp nhận xử lý đơn, theo dõi vận chuyển & in phiếu',
        'icon': Icons.local_shipping_rounded,
        'color': const Color(0xFF2563EB),
        'bg': const Color(0xFFDBEAFE),
      },
      {
        'key': 'crm',
        'label': 'Khách hàng & CRM',
        'desc': 'Hồ sơ người dùng, phân hạng thành viên & chăm sóc',
        'icon': Icons.people_alt_rounded,
        'color': const Color(0xFF7C3AED),
        'bg': const Color(0xFFEDE9FE),
      },
      {
        'key': 'promotions',
        'label': 'Khuyến mãi & Voucher',
        'desc': 'Tạo mã giảm giá, chiến dịch Flash Sale & Banner',
        'icon': Icons.confirmation_number_rounded,
        'color': const Color(0xFFDB2777),
        'bg': const Color(0xFFFCE7F3),
      },
      {
        'key': 'analytics',
        'label': 'Báo cáo & Tài chính',
        'desc': 'Thống kê doanh thu, tỷ suất lợi nhuận & xuất file Excel',
        'icon': Icons.insights_rounded,
        'color': const Color(0xFF059669),
        'bg': const Color(0xFFD1FAE5),
      },
      {
        'key': 'settings',
        'label': 'Cài đặt & Phân quyền',
        'desc': 'Cấu hình cửa hàng, thanh toán, bảo mật & tài khoản',
        'icon': Icons.tune_rounded,
        'color': const Color(0xFF475569),
        'bg': const Color(0xFFF1F5F9),
      },
    ];

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          backgroundColor: Colors.white,
          elevation: 24,
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. HEADER
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
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
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF059669).withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.5), width: 1),
                        ),
                        child: const Icon(Icons.manage_accounts_rounded, color: Color(0xFF34D399), size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Text(
                                  isEditing ? 'Chỉnh Sửa Quyền Nhân Sự' : 'Thêm Nhân Sự Mới',
                                  style: const TextStyle(color: Colors.white, fontSize: 16.5, fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF059669).withValues(alpha: 0.3),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFF34D399).withValues(alpha: 0.4), width: 0.8),
                                  ),
                                  child: const Text('RBAC', style: TextStyle(color: Color(0xFF34D399), fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              isEditing ? 'Cập nhật thông tin & gán quyền truy cập phân hệ' : 'Tạo hồ sơ tài khoản và phân quyền quản trị',
                              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () => Navigator.pop(ctx),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.close_rounded, color: Colors.white70, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. DIALOG BODY FORM
                Flexible(
                  child: Container(
                    color: Colors.white,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // SECTION: THÔNG TIN TÀI KHOẢN
                          Row(
                            children: [
                              Container(
                                width: 3,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF059669),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'THÔNG TIN TÀI KHOẢN',
                                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF64748B), letterSpacing: 0.5),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Name field
                          const Text('Họ và tên nhân sự *', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
                          const SizedBox(height: 5),
                          TextField(
                            controller: nameCtrl,
                            style: const TextStyle(fontSize: 13.5, color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
                            decoration: InputDecoration(
                              hintText: 'Nhập họ và tên đầy đủ...',
                              hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                              prefixIcon: const Icon(Icons.badge_outlined, size: 18, color: Color(0xFF64748B)),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF059669), width: 1.5)),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Email & Phone in 2 columns
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Email đăng nhập *', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
                                    const SizedBox(height: 5),
                                    TextField(
                                      controller: emailCtrl,
                                      keyboardType: TextInputType.emailAddress,
                                      style: const TextStyle(fontSize: 13.5, color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
                                      decoration: InputDecoration(
                                        hintText: 'admin@grocery.com',
                                        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                                        prefixIcon: const Icon(Icons.alternate_email_rounded, size: 17, color: Color(0xFF64748B)),
                                        filled: true,
                                        fillColor: const Color(0xFFF8FAFC),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF059669), width: 1.5)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Số điện thoại *', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
                                    const SizedBox(height: 5),
                                    TextField(
                                      controller: phoneCtrl,
                                      keyboardType: TextInputType.phone,
                                      style: const TextStyle(fontSize: 13.5, color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
                                      decoration: InputDecoration(
                                        hintText: '0901234567',
                                        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                                        prefixIcon: const Icon(Icons.phone_iphone_rounded, size: 17, color: Color(0xFF64748B)),
                                        filled: true,
                                        fillColor: const Color(0xFFF8FAFC),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF059669), width: 1.5)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),

                          // SECTION: VAI TRÒ & PHÂN QUYỀN
                          Row(
                            children: [
                              Container(
                                width: 3,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF059669),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'VAI TRÒ & PHÂN HỆ TRUY CẬP',
                                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: Color(0xFF64748B), letterSpacing: 0.5),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Role selection dropdown
                          const Text('Vai trò phân quyền chuẩn', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
                          const SizedBox(height: 5),
                          DropdownButtonFormField<String>(
                            initialValue: selectedRole,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.shield_rounded, size: 18, color: Color(0xFF059669)),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF059669), width: 1.5)),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'Super Admin', child: Text('Super Admin (Toàn quyền hệ thống)', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold))),
                              DropdownMenuItem(value: 'Quản lý kho', child: Text('Quản lý kho (Sản phẩm & Tồn kho)', style: TextStyle(fontSize: 13.5))),
                              DropdownMenuItem(value: 'CSKH & Đơn hàng', child: Text('CSKH & Vận chuyển (Đơn & Khách)', style: TextStyle(fontSize: 13.5))),
                              DropdownMenuItem(value: 'Kế toán', child: Text('Kế toán (Báo cáo doanh thu & Dữ liệu)', style: TextStyle(fontSize: 13.5))),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setDialogState(() {
                                  selectedRole = val;
                                  if (val == 'Super Admin') {
                                    selectedPerms = ['products', 'orders', 'crm', 'promotions', 'analytics', 'settings'];
                                  } else if (val == 'Quản lý kho') {
                                    selectedPerms = ['products'];
                                  } else if (val == 'CSKH & Đơn hàng') {
                                    selectedPerms = ['orders', 'crm'];
                                  } else if (val == 'Kế toán') {
                                    selectedPerms = ['analytics'];
                                  }
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 8),

                          // Quick Role Pills
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              _buildQuickRoleChip('Super Admin', '👑 Toàn quyền', selectedRole == 'Super Admin', () {
                                setDialogState(() {
                                  selectedRole = 'Super Admin';
                                  selectedPerms = ['products', 'orders', 'crm', 'promotions', 'analytics', 'settings'];
                                });
                              }),
                              _buildQuickRoleChip('Quản lý kho', '📦 Kho hàng', selectedRole == 'Quản lý kho', () {
                                setDialogState(() {
                                  selectedRole = 'Quản lý kho';
                                  selectedPerms = ['products'];
                                });
                              }),
                              _buildQuickRoleChip('CSKH & Đơn hàng', '🎧 CSKH & Đơn', selectedRole == 'CSKH & Đơn hàng', () {
                                setDialogState(() {
                                  selectedRole = 'CSKH & Đơn hàng';
                                  selectedPerms = ['orders', 'crm'];
                                });
                              }),
                              _buildQuickRoleChip('Kế toán', '📊 Kế toán', selectedRole == 'Kế toán', () {
                                setDialogState(() {
                                  selectedRole = 'Kế toán';
                                  selectedPerms = ['analytics'];
                                });
                              }),
                            ],
                          ),
                          const SizedBox(height: 18),

                          // Permissions Title Row with Select All / Deselect All
                          Row(
                            children: [
                              const Text('Chi tiết quyền truy cập các phân hệ:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECFDF5),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  '${selectedPerms.length}/6 đã cấp',
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                                ),
                              ),
                              const Spacer(),
                              InkWell(
                                onTap: () {
                                  setDialogState(() {
                                    if (selectedPerms.length == allPermOptions.length) {
                                      selectedPerms.clear();
                                    } else {
                                      selectedPerms = allPermOptions.map((e) => e['key'] as String).toList();
                                    }
                                  });
                                },
                                borderRadius: BorderRadius.circular(6),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                  child: Text(
                                    selectedPerms.length == allPermOptions.length ? 'Bỏ chọn hết' : 'Chọn tất cả',
                                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Permission Cards List
                          Column(
                            children: allPermOptions.map((opt) {
                              final key = opt['key'] as String;
                              final label = opt['label'] as String;
                              final desc = opt['desc'] as String;
                              final icon = opt['icon'] as IconData;
                              final color = opt['color'] as Color;
                              final bg = opt['bg'] as Color;
                              final isChecked = selectedPerms.contains(key);

                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: InkWell(
                                  onTap: () {
                                    setDialogState(() {
                                      if (isChecked) {
                                        selectedPerms.remove(key);
                                      } else {
                                        selectedPerms.add(key);
                                      }
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 180),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: isChecked ? const Color(0xFFF0FDF4) : const Color(0xFFFAFAFA),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isChecked ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
                                        width: isChecked ? 1.5 : 1,
                                      ),
                                      boxShadow: isChecked
                                          ? [
                                              BoxShadow(
                                                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                                                blurRadius: 6,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Row(
                                      children: [
                                        // Module Icon Container
                                        Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: isChecked ? bg : const Color(0xFFF1F5F9),
                                            borderRadius: BorderRadius.circular(9),
                                          ),
                                          child: Icon(
                                            icon,
                                            size: 18,
                                            color: isChecked ? color : const Color(0xFF94A3B8),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                label,
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: isChecked ? FontWeight.bold : FontWeight.w600,
                                                  color: isChecked ? const Color(0xFF0F172A) : const Color(0xFF334155),
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                desc,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: isChecked ? const Color(0xFF059669) : const Color(0xFF94A3B8),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        // Custom Check Badge
                                        AnimatedContainer(
                                          duration: const Duration(milliseconds: 180),
                                          width: 22,
                                          height: 22,
                                          decoration: BoxDecoration(
                                            color: isChecked ? const Color(0xFF059669) : Colors.transparent,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isChecked ? const Color(0xFF059669) : const Color(0xFFCBD5E1),
                                              width: 1.6,
                                            ),
                                          ),
                                          child: isChecked
                                              ? const Icon(Icons.check, size: 14, color: Colors.white)
                                              : null,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 3. DIALOG FOOTER
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(ctx),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            minimumSize: const Size(0, 42),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                          ),
                          child: const Text('Hủy bỏ', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            if (nameCtrl.text.trim().isNotEmpty && emailCtrl.text.trim().isNotEmpty) {
                              controller.saveStaff(
                                StaffMemberModel(
                                  id: isEditing ? staffToEdit.id : 'ST-${DateTime.now().millisecondsSinceEpoch}',
                                  name: nameCtrl.text.trim(),
                                  email: emailCtrl.text.trim(),
                                  phone: phoneCtrl.text.trim(),
                                  role: selectedRole,
                                  permissions: selectedPerms,
                                  joinedDate: isEditing ? staffToEdit.joinedDate : DateTime.now(),
                                  isActive: isEditing ? staffToEdit.isActive : true,
                                ),
                                isEditing,
                              );
                              Navigator.pop(ctx);
                            }
                          },
                          icon: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                          label: Text(
                            isEditing ? 'Lưu thay đổi' : 'Tạo nhân sự',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF059669),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            minimumSize: const Size(0, 42),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 2,
                            shadowColor: const Color(0xFF059669).withValues(alpha: 0.35),
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

  Widget _buildQuickRoleChip(String role, String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF059669) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF059669) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  void _showModernEditDialog({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required String initialValue,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    required Function(String) onSave,
  }) {
    final ctrl = TextEditingController(text: initialValue);
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        elevation: 20,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
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
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: iconColor.withValues(alpha: 0.5), width: 0.8),
                      ),
                      child: Icon(icon, color: iconColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text(subtitle, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11.5)),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(ctx),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.close_rounded, color: Colors.white70, size: 16),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
                    const SizedBox(height: 6),
                    TextField(
                      controller: ctrl,
                      keyboardType: keyboardType,
                      autofocus: true,
                      style: const TextStyle(fontSize: 13.5, color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
                      decoration: InputDecoration(
                        hintText: hint,
                        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF059669), width: 1.5)),
                      ),
                    ),
                  ],
                ),
              ),

              // Footer
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
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          minimumSize: const Size(0, 40),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                        child: const Text('Hủy bỏ', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          onSave(ctrl.text.trim());
                          Navigator.pop(ctx);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF059669),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          minimumSize: const Size(0, 40),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          elevation: 0,
                        ),
                        child: const Text('Lưu thay đổi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
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

  void _showEditStoreNameDialog() {
    _showModernEditDialog(
      title: 'Đổi tên cửa hàng',
      subtitle: 'Tên hiển thị thương hiệu với người dùng',
      icon: Icons.storefront_rounded,
      iconColor: const Color(0xFF34D399),
      initialValue: controller.storeName.value,
      label: 'Tên cửa hàng *',
      hint: 'VD: Siêu thị Xanh - FreshMart',
      onSave: (val) {
        if (val.isNotEmpty) controller.updateStoreName(val);
      },
    );
  }

  void _showEditHotlineDialog() {
    _showModernEditDialog(
      title: 'Cập nhật Hotline',
      subtitle: 'Đường dây nóng hỗ trợ khách hàng',
      icon: Icons.phone_in_talk_rounded,
      iconColor: const Color(0xFF60A5FA),
      initialValue: controller.storeHotline.value,
      label: 'Số điện thoại hotline *',
      hint: 'VD: 1900 6868',
      keyboardType: TextInputType.phone,
      onSave: (val) {
        if (val.isNotEmpty) controller.updateStoreHotline(val);
      },
    );
  }

  void _showEditAddressDialog() {
    _showModernEditDialog(
      title: 'Cập nhật trụ sở',
      subtitle: 'Địa chỉ kho vận và trung tâm xử lý đơn',
      icon: Icons.location_on_rounded,
      iconColor: const Color(0xFFF87171),
      initialValue: controller.storeAddress.value,
      label: 'Địa chỉ kho / Trụ sở chính *',
      hint: 'VD: 123 Nguyễn Huệ, Phường Bến Nghé, Quận 1, TP.HCM',
      onSave: (val) {
        if (val.isNotEmpty) controller.updateStoreAddress(val);
      },
    );
  }

  void _showEditShippingFeeDialog() {
    _showModernEditDialog(
      title: 'Phí giao hàng mặc định',
      subtitle: 'Áp dụng cho mọi đơn hàng tiêu chuẩn',
      icon: Icons.local_shipping_rounded,
      iconColor: const Color(0xFFFBBF24),
      initialValue: controller.storeShippingFee.value.toInt().toString(),
      label: 'Phí giao hàng tiêu chuẩn (VNĐ) *',
      hint: 'VD: 15000',
      keyboardType: TextInputType.number,
      onSave: (val) {
        final fee = double.tryParse(val) ?? 0;
        controller.updateStoreShippingFee(fee);
      },
    );
  }
}
