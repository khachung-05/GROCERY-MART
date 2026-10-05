import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/storage/local_storage.dart';
import '../auth/auth_controller.dart';
import 'admin_controller.dart';
import 'edit_product_dialog.dart';
import 'views/admin_catalog_view.dart';
import 'views/admin_customers_view.dart';
import 'views/admin_orders_view.dart';
import 'views/admin_overview_view.dart';
import 'views/admin_promotions_view.dart';
import 'views/admin_system_view.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminController controller = Get.find<AdminController>();
  int _selectedNavIndex = 0;
  final ScrollController _mobileStripScrollCtrl = ScrollController();

  @override
  void dispose() {
    _mobileStripScrollCtrl.dispose();
    super.dispose();
  }

  final List<Map<String, dynamic>> _navMenuItems = [
    {
      'title': 'Sản Phẩm & Kho Hàng',
      'icon': Icons.inventory_2_rounded,
      'id': 'catalog',
      'desc': 'Sản phẩm, biến thể, tags, tồn kho',
    },
    {
      'title': 'Đơn Hàng & Vận Chuyển',
      'icon': Icons.local_shipping_rounded,
      'id': 'orders',
      'desc': '5 bước đơn, in vận đơn, hoàn tiền',
    },
    {
      'title': 'Khách Hàng & CRM',
      'icon': Icons.people_alt_rounded,
      'id': 'crm',
      'desc': 'Hồ sơ, tích điểm, đánh giá review',
    },
    {
      'title': 'Khuyến Mãi & Marketing',
      'icon': Icons.campaign_rounded,
      'id': 'promotions',
      'desc': 'Voucher, Flash Sale, Push Notif',
    },
    {
      'title': 'Báo Cáo & Thống Kê',
      'icon': Icons.insights_rounded,
      'id': 'overview',
      'desc': 'Doanh thu, kênh thanh toán, top sellers',
    },
    {
      'title': 'Phân Quyền & Cài Đặt',
      'icon': Icons.settings_suggest_rounded,
      'id': 'system',
      'desc': 'RBAC nhân sự, cổng thanh toán, cửa hàng',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final isDesktop = MediaQuery.of(context).size.width >= 850;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Enterprise Slate Light
      appBar: isDesktop ? null : _buildMobileAppBar(context),
      drawer: isDesktop ? null : Drawer(child: _buildSidebarContent(context)),
      body: Row(
        children: [
          // SIDEBAR CỐ ĐỊNH TRÊN DESKTOP / TABLET
          if (isDesktop)
            SizedBox(
              width: 270,
              child: _buildSidebarContent(context),
            ),

          // MAIN WORKSPACE CONTENT
          Expanded(
            child: Column(
              children: [
                // TOP CONSOLE HEADER (Desktop)
                _buildTopConsoleHeader(context),

                // MOBILE HORIZONTAL QUICK MODULE SELECTOR (Mobile)
                if (!isDesktop)
                  _buildMobileModuleStrip(),

                // WORKSPACE BODY
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildWorkspaceModuleView(currencyFormatter),
                      Obx(() {
                        if (!controller.isLoading.value) return const SizedBox.shrink();
                        return Container(
                          color: const Color(0xFFF1F5F9).withValues(alpha: 0.75),
                          child: const Center(
                            child: CircularProgressIndicator(color: Color(0xFF059669)),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // FAB CHỈ XUẤT HIỆN Ở TAB SẢN PHẨM
      floatingActionButton: _selectedNavIndex == 0
          ? Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF059669).withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => EditProductDialog(
                      onSave: (product, isEdit) {
                        controller.saveProduct(product, isEdit);
                      },
                    ),
                  );
                },
                backgroundColor: const Color(0xFF059669),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                icon: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
                label: const Text(
                  'Thêm món mới',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5, letterSpacing: 0.2),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildWorkspaceModuleView(NumberFormat currencyFormatter) {
    switch (_selectedNavIndex) {
      case 0:
        return AdminCatalogView(currencyFormatter: currencyFormatter);
      case 1:
        return AdminOrdersView(currencyFormatter: currencyFormatter);
      case 2:
        return AdminCustomersView(currencyFormatter: currencyFormatter);
      case 3:
        return AdminPromotionsView(currencyFormatter: currencyFormatter);
      case 4:
        return AdminOverviewView(currencyFormatter: currencyFormatter);
      case 5:
        return const AdminSystemView();
      default:
        return AdminCatalogView(currencyFormatter: currencyFormatter);
    }
  }

  // ==================== APP BAR DÀNH CHO MOBILE ====================
  PreferredSizeWidget _buildMobileAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF0F172A),
      elevation: 0,
      toolbarHeight: 52,
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 22),
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF059669).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3), width: 0.8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.admin_panel_settings_rounded, color: Color(0xFF34D399), size: 14),
                SizedBox(width: 4),
                Text('ADMIN', style: TextStyle(color: Color(0xFF34D399), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _navMenuItems[_selectedNavIndex]['title'] as String,
              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search_rounded, color: Colors.white, size: 21),
          tooltip: 'Tìm kiếm toàn hệ thống (Ctrl + K)',
          onPressed: () => _showGlobalSearchDialog(context),
        ),
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Color(0xFF34D399), size: 20),
          tooltip: 'Làm mới dữ liệu',
          onPressed: () => controller.fetchData(),
        ),
        IconButton(
          icon: const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 20),
          tooltip: 'Xem Cửa hàng Khách',
          onPressed: () => Get.offAllNamed(AppRoutes.main),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ==================== THANH ĐIỀU HƯỚNG NHANH CÁC PHÂN HỆ TRÊN MOBILE ====================
  Widget _buildMobileModuleStrip() {
    return Container(
      width: double.infinity,
      color: const Color(0xFF0F172A),
      padding: const EdgeInsets.fromLTRB(12, 2, 12, 10),
      child: SingleChildScrollView(
        controller: _mobileStripScrollCtrl,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: List.generate(_navMenuItems.length, (index) {
            final item = _navMenuItems[index];
            final isSelected = _selectedNavIndex == index;
            final itemId = item['id'] as String?;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() => _selectedNavIndex = index);
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF059669) : const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF10B981)
                            : const Color(0xFF334155).withValues(alpha: 0.6),
                        width: 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFF059669).withValues(alpha: 0.35),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              )
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item['icon'] as IconData,
                          size: 15,
                          color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          item['title'].toString().split('&').first.trim(),
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                          ),
                        ),
                        if (itemId == 'orders')
                          Obx(() {
                            final pending = controller.pendingOrdersCount;
                            if (pending > 0) {
                              return Container(
                                margin: const EdgeInsets.only(left: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEF4444),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '$pending',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          }),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ==================== CONTENT SIDEBAR CHUYÊN NGHIỆP ====================
  Widget _buildSidebarContent(BuildContext context) {
    return Container(
      color: const Color(0xFF0F172A), // Dark Slate Navy
      child: Column(
        children: [
          // BRAND LOGO HEADER
          Container(
            padding: const EdgeInsets.only(left: 18, right: 18, top: 22, bottom: 18),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
            ),
            child: Row(
              children: [
                // Brand Icon với hiệu ứng 3D Gradient
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF059669), Color(0xFF10B981)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF059669).withValues(alpha: 0.45),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.storefront_rounded, color: Colors.white, size: 24),
                  ),
                ),
                const SizedBox(width: 12),

                // Text Thương hiệu & Trạng thái Hệ thống
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'GROCERY',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const Text(
                            ' MART',
                            style: TextStyle(
                              color: Color(0xFF34D399),
                              fontSize: 14.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF059669).withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: const Color(0xFF10B981).withValues(alpha: 0.4),
                                width: 0.8,
                              ),
                            ),
                            child: const Text(
                              'PRO',
                              style: TextStyle(
                                color: Color(0xFF34D399),
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF10B981),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Trực tuyến • v3.0 Enterprise',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ADMIN PROFILE CARD CHUYÊN NGHIỆP
          Builder(builder: (context) {
            final userInfo = LocalStorage.getUserInfo();
            final adminName = userInfo['name'] ?? 'Quản Trị Viên';
            final adminEmail = userInfo['email'] ?? 'admin@gmail.com';

            return Container(
              margin: const EdgeInsets.fromLTRB(12, 14, 12, 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF334155)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF059669), Color(0xFF10B981)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF059669).withValues(alpha: 0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.admin_panel_settings_rounded,
                            color: Colors.white,
                            size: 21,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: const Color(0xFF22C55E),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF1E293B),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                adminName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.2,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.verified_rounded,
                              color: Color(0xFF38BDF8),
                              size: 14,
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          adminEmail,
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF059669).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: const Color(0xFF10B981).withValues(alpha: 0.4),
                        width: 0.8,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shield_rounded, size: 10, color: Color(0xFF34D399)),
                        SizedBox(width: 3),
                        Text(
                          'Quản Trị',
                          style: TextStyle(
                            color: Color(0xFF34D399),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 6),

          // 6 CORE MODULES NAVIGATION MENU LIST
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: _navMenuItems.length,
              itemBuilder: (ctx, index) {
                final item = _navMenuItems[index];
                final isSelected = _selectedNavIndex == index;
                final itemId = item['id'] as String?;

                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [Color(0xFF059669), Color(0xFF10B981)],
                          )
                        : null,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    clipBehavior: Clip.antiAlias,
                    child: ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                      leading: Icon(
                        item['icon'] as IconData,
                        color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                        size: 20,
                      ),
                      title: Text(
                        item['title'] as String,
                        style: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Catalog badge
                          if (itemId == 'catalog')
                            Obx(() {
                              final lowStock = controller.lowStockCount;
                              if (lowStock > 0) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDC2626),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '! $lowStock',
                                    style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
                                  ),
                                );
                              }
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.white.withValues(alpha: 0.25) : const Color(0xFF1E293B),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${controller.products.length}',
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }),

                          // Orders badge
                          if (itemId == 'orders')
                            Obx(() {
                              final pending = controller.pendingOrdersCount;
                              if (pending > 0) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xFFEF4444) : const Color(0xFFDC2626).withValues(alpha: 0.25),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isSelected ? Colors.transparent : const Color(0xFFEF4444).withValues(alpha: 0.4),
                                      width: 0.8,
                                    ),
                                  ),
                                  child: Text(
                                    '$pending',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            }),

                          // CRM badge
                          if (itemId == 'crm')
                            Obx(() => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.white.withValues(alpha: 0.25) : const Color(0xFF1E293B),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${controller.customers.length}',
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )),

                          // Promotions badge
                          if (itemId == 'promotions')
                            Obx(() => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.white.withValues(alpha: 0.25) : const Color(0xFF1E293B),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    '${controller.vouchers.length}',
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )),

                          if (isSelected) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 12),
                          ],
                        ],
                      ),
                      onTap: () {
                        setState(() => _selectedNavIndex = index);
                        final scaffold = Scaffold.maybeOf(ctx);
                        if (scaffold != null && scaffold.isDrawerOpen) {
                          Navigator.of(ctx).pop();
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ),

          // FOOTER ACTIONS (Xem Cửa hàng & Đăng xuất)
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFF1E293B))),
            ),
            child: Column(
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFF334155)),
                    minimumSize: const Size.fromHeight(42),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Get.offAllNamed(AppRoutes.main),
                  icon: const Icon(Icons.storefront_outlined, size: 16, color: Color(0xFF34D399)),
                  label: const Text('Xem Cửa hàng Khách', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 6),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFFCA5A5),
                    minimumSize: const Size.fromHeight(38),
                  ),
                  onPressed: () => _confirmLogout(context),
                  icon: const Icon(Icons.logout_rounded, size: 15),
                  label: const Text('Đăng xuất Quản trị', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Hộp thoại xác nhận thoát hoặc đăng xuất tài khoản Quản trị
  void _confirmLogout(BuildContext context) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF2F2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout_rounded, color: Color(0xFFDC2626), size: 28),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tùy Chọn Thoát Quản Trị',
                style: TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Bạn muốn chuyển sang ứng dụng mua sắm (khách hàng) hay đăng xuất hoàn toàn khỏi hệ thống?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
              ),
              const SizedBox(height: 20),

              // Lựa chọn 1: Xem cửa hàng mua sắm
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primarySurface,
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    side: BorderSide(color: AppColors.primaryBorder),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Get.back();
                    Get.offAllNamed(AppRoutes.main);
                  },
                  icon: const Icon(Icons.storefront_rounded, size: 18),
                  label: const Text(
                    'Về Cửa Hàng Mua Sắm',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Lựa chọn 2: Đăng xuất hoàn toàn
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    Get.back();
                    final authCtrl = Get.isRegistered<AuthController>()
                        ? Get.find<AuthController>()
                        : Get.put(AuthController());
                    await authCtrl.logout();
                  },
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: const Text(
                    'Đăng Xuất Tài Khoản',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              TextButton(
                onPressed: () => Get.back(),
                child: const Text(
                  'Ở lại trang Quản trị',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== TOP CONSOLE HEADER BAR ====================
  Widget _buildTopConsoleHeader(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 850;
    if (!isDesktop) return const SizedBox.shrink();

    final item = _navMenuItems[_selectedNavIndex];
    final isWideDesktop = screenWidth >= 1200;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          // Title and Description
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item['title'] as String,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  item['desc'] as String,
                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Command Palette Search Trigger
          InkWell(
            onTap: () => _showGlobalSearchDialog(context),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: isWideDesktop ? 220 : 160,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded, size: 16, color: Color(0xFF64748B)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      isWideDesktop ? 'Tìm nhanh hệ thống...' : 'Tìm kiếm...',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFFCBD5E1), width: 0.8),
                    ),
                    child: const Text(
                      '⌘K',
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF64748B)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Indicating Live Status (Only show on wide screen)
          if (isWideDesktop) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primaryBorder),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.circle, color: AppColors.primary, size: 7),
                  SizedBox(width: 6),
                  Text('Admin Console Live', style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(width: 8),
          ],

          // Nút Refresh
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary, size: 20),
            tooltip: 'Làm mới dữ liệu',
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
            onPressed: () => controller.fetchData(),
          ),
          const SizedBox(width: 8),

          // Nút về Cửa hàng
          if (screenWidth >= 1050)
            TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                backgroundColor: AppColors.primarySurface,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => Get.offAllNamed(AppRoutes.main),
              icon: const Icon(Icons.storefront_rounded, size: 15),
              label: const Text('Xem Cửa Hàng', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
            )
          else
            IconButton(
              icon: const Icon(Icons.storefront_rounded, color: AppColors.primary, size: 20),
              tooltip: 'Xem Cửa Hàng Khách',
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(),
              onPressed: () => Get.offAllNamed(AppRoutes.main),
            ),
        ],
      ),
    );
  }

  // ==================== GLOBAL SEARCH COMMAND PALETTE (CTRL + K) ====================
  void _showGlobalSearchDialog(BuildContext context) {
    final searchCtrl = TextEditingController();
    final RxString query = ''.obs;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        child: Container(
          width: 580,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: searchCtrl,
                autofocus: true,
                onChanged: (val) => query.value = val.trim().toLowerCase(),
                decoration: InputDecoration(
                  hintText: 'Tìm món ăn, mã đơn #ORD, khách hàng, số điện thoại...',
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF059669)),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 380),
                child: Obx(() {
                  final q = query.value;

                  if (q.isEmpty) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'CHUYỂN NHANH ĐẾN PHÂN HỆ',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF64748B), letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(_navMenuItems.length, (idx) {
                            final m = _navMenuItems[idx];
                            return ActionChip(
                              avatar: Icon(m['icon'] as IconData, size: 15, color: const Color(0xFF059669)),
                              label: Text(m['title'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              onPressed: () {
                                Navigator.pop(ctx);
                                setState(() => _selectedNavIndex = idx);
                              },
                              backgroundColor: const Color(0xFFF1F5F9),
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            );
                          }),
                        ),
                      ],
                    );
                  }

                  final matchedProducts = controller.products
                      .where((p) => p.name.toLowerCase().contains(q) || p.categoryId.toLowerCase().contains(q))
                      .take(4)
                      .toList();

                  final matchedOrders = controller.orders
                      .where((o) =>
                          o.id.toLowerCase().contains(q) ||
                          o.receiverName.toLowerCase().contains(q) ||
                          o.receiverPhone.contains(q))
                      .take(4)
                      .toList();

                  final matchedCustomers = controller.customers
                      .where((c) =>
                          c.name.toLowerCase().contains(q) ||
                          c.phone.contains(q) ||
                          c.email.toLowerCase().contains(q))
                      .take(4)
                      .toList();

                  final totalFound = matchedProducts.length + matchedOrders.length + matchedCustomers.length;

                  if (totalFound == 0) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 28),
                      child: Center(
                        child: Text(
                          'Không tìm thấy dữ liệu khớp với từ khóa',
                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                        ),
                      ),
                    );
                  }

                  return ListView(
                    shrinkWrap: true,
                    children: [
                      if (matchedProducts.isNotEmpty) ...[
                        const Text('SẢN PHẨM & KHO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF059669))),
                        const SizedBox(height: 6),
                        ...matchedProducts.map((p) => ListTile(
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                              leading: const Icon(Icons.inventory_2_outlined, color: Color(0xFF059669), size: 18),
                              title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              subtitle: Text('Tồn kho: ${p.stock} • ${p.categoryId}', style: const TextStyle(fontSize: 11.5)),
                              onTap: () {
                                Navigator.pop(ctx);
                                setState(() => _selectedNavIndex = 0);
                                controller.productSearchQuery.value = p.name;
                              },
                            )),
                        const Divider(height: 12),
                      ],

                      if (matchedOrders.isNotEmpty) ...[
                        const Text('ĐƠN HÀNG', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF0284C7))),
                        const SizedBox(height: 6),
                        ...matchedOrders.map((o) => ListTile(
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                              leading: const Icon(Icons.receipt_long_outlined, color: Color(0xFF0284C7), size: 18),
                              title: Text('Đơn #${o.id} - ${o.receiverName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              subtitle: Text('${o.status} • SĐT: ${o.receiverPhone}', style: const TextStyle(fontSize: 11.5)),
                              onTap: () {
                                Navigator.pop(ctx);
                                setState(() => _selectedNavIndex = 1);
                                controller.orderSearchQuery.value = o.id;
                              },
                            )),
                        const Divider(height: 12),
                      ],

                      if (matchedCustomers.isNotEmpty) ...[
                        const Text('KHÁCH HÀNG CRM', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF7C3AED))),
                        const SizedBox(height: 6),
                        ...matchedCustomers.map((c) => ListTile(
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                              leading: const Icon(Icons.person_outline_rounded, color: Color(0xFF7C3AED), size: 18),
                              title: Text('${c.name} (${c.tier})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              subtitle: Text('${c.phone} • ${c.points} điểm', style: const TextStyle(fontSize: 11.5)),
                              onTap: () {
                                Navigator.pop(ctx);
                                setState(() => _selectedNavIndex = 2);
                                controller.customerSearchQuery.value = c.name;
                              },
                            )),
                      ],
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
