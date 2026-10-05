import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../data/datasource/mock_data.dart';
import '../../../data/models/product_model.dart';
import '../../../shared/widgets/app_network_image.dart';
import '../admin_controller.dart';
import '../edit_product_dialog.dart';

class AdminCatalogView extends StatefulWidget {
  final NumberFormat currencyFormatter;
  const AdminCatalogView({super.key, required this.currencyFormatter});

  @override
  State<AdminCatalogView> createState() => _AdminCatalogViewState();
}

class _AdminCatalogViewState extends State<AdminCatalogView> {
  final AdminController controller = Get.find<AdminController>();
  final TextEditingController _searchCtrl = TextEditingController();

  final List<Map<String, String>> _categoryTabs = [
    {'id': 'ALL', 'label': 'Tất cả', 'icon': '🛒'},
    {'id': 'LOW_STOCK', 'label': 'Sắp hết hàng', 'icon': '⚠️'},
    {'id': 'fruit', 'label': 'Trái cây', 'icon': '🍎'},
    {'id': 'veg', 'label': 'Rau củ', 'icon': '🥦'},
    {'id': 'meat', 'label': 'Thịt tươi', 'icon': '🥩'},
    {'id': 'seafood', 'label': 'Hải sản', 'icon': '🦐'},
    {'id': 'drink', 'label': 'Đồ uống', 'icon': '🥤'},
    {'id': 'dairy', 'label': 'Bơ sữa', 'icon': '🥛'},
    {'id': 'snack', 'label': 'Đồ ăn vặt', 'icon': '🍿'},
  ];

  String _getCategoryDisplay(String catId) {
    final cat = MockData.categories.firstWhereOrNull((c) => c.id.toLowerCase() == catId.toLowerCase());
    if (cat != null) {
      return '${cat.icon} ${cat.name}';
    }
    if (catId.toLowerCase() == 'fruit') return '🍎 Trái cây';
    if (catId.toLowerCase() == 'veg') return '🥦 Rau củ';
    if (catId.toLowerCase() == 'meat') return '🥩 Thịt tươi';
    if (catId.toLowerCase() == 'seafood') return '🦐 Hải sản';
    if (catId.toLowerCase() == 'drink') return '🥤 Đồ uống';
    if (catId.toLowerCase() == 'snack') return '🍿 Đồ ăn vặt';
    if (catId.toLowerCase() == 'bakery') return '🥖 Bánh mì';
    if (catId.toLowerCase() == 'spices') return '🧂 Gia vị';
    return catId.toUpperCase();
  }

  int _selectedSubTab = 0;
  String _selectedSort = 'DEFAULT';

  @override
  void dispose() {
    _searchCtrl.dispose();
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
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7.5),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF059669) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF059669).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : const Color(0xFF64748B)),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF475569),
              ),
            ),
            const SizedBox(width: 7),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withValues(alpha: 0.25) : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                badgeText,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : const Color(0xFF475569),
                ),
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
                              label: 'Sản phẩm',
                              icon: Icons.inventory_2_rounded,
                              badgeText: '${controller.products.length}',
                            ),
                            const SizedBox(width: 4),
                            _buildSubTabPill(
                              index: 1,
                              label: 'Lịch sử kho',
                              icon: Icons.history_rounded,
                              badgeText: '${controller.inventoryLogs.length}',
                            ),
                          ],
                        )),
                  ),
                ),
              ),
              if (MediaQuery.of(context).size.width >= 600) ...[
                const SizedBox(width: 8),
                ElevatedButton.icon(
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
                  icon: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                  label: Text(
                    MediaQuery.of(context).size.width >= 750 ? 'Thêm sản phẩm mới' : 'Thêm mới',
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
            ],
          ),
        ),

        // SUB-TAB VIEW CONTENT
        Expanded(
          child: _selectedSubTab == 0
              ? _buildProductListTab()
              : _buildInventoryHistoryTab(),
        ),
      ],
    );
  }

  // ==================== TAB 1: DANH SÁCH SẢN PHẨM ====================
  Widget _buildProductListTab() {
    return Column(
      children: [
        // TOOLBAR: SEARCH & CATEGORY CHIPS
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          color: Colors.white,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 42,
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: (val) => controller.productSearchQuery.value = val,
                        decoration: InputDecoration(
                          hintText: 'Tìm theo tên, mã SKU, thương hiệu...',
                          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                          prefixIcon: const Icon(Icons.search_rounded, size: 20, color: Color(0xFF94A3B8)),
                          suffixIcon: Obx(() => controller.productSearchQuery.value.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    controller.productSearchQuery.value = '';
                                  },
                                )
                              : const SizedBox.shrink()),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xFF059669)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  PopupMenuButton<String>(
                    tooltip: 'Sắp xếp danh sách',
                    initialValue: _selectedSort,
                    onSelected: (val) => setState(() => _selectedSort = val),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Container(
                      height: 42,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.sort_rounded, size: 18, color: Color(0xFF475569)),
                          const SizedBox(width: 6),
                          Text(
                            _selectedSort == 'LOW_STOCK'
                                ? 'Tồn ít nhất'
                                : (_selectedSort == 'PRICE_DESC'
                                    ? 'Giá cao ➔ thấp'
                                    : (_selectedSort == 'PRICE_ASC' ? 'Giá thấp ➔ cao' : 'Mặc định')),
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                          ),
                          const Icon(Icons.arrow_drop_down, size: 18, color: Color(0xFF64748B)),
                        ],
                      ),
                    ),
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(value: 'DEFAULT', child: Text('Mặc định (A-Z)')),
                      const PopupMenuItem(value: 'LOW_STOCK', child: Text('⚠️ Tồn kho ít nhất')),
                      const PopupMenuItem(value: 'PRICE_DESC', child: Text('Giá từ cao đến thấp')),
                      const PopupMenuItem(value: 'PRICE_ASC', child: Text('Giá từ thấp đến cao')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Category Filter Pills (Minimalist Modern Pills)
              Obx(() {
                final currentCat = controller.selectedCategoryFilter.value;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categoryTabs.map((cat) {
                      final isSelected = currentCat == cat['id'];
                      final countLow = controller.lowStockCount;
                      final isLowStockTab = cat['id'] == 'LOW_STOCK';
                      final isAlert = isLowStockTab && countLow > 0;

                      int count = 0;
                      if (cat['id'] == 'ALL') {
                        count = controller.products.length;
                      } else if (cat['id'] == 'LOW_STOCK') {
                        count = countLow;
                      } else {
                        count = controller.products.where((p) => p.categoryId == cat['id']).length;
                      }

                      final activeBg = isAlert ? const Color(0xFFDC2626) : const Color(0xFF059669);

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: () => controller.setProductCategoryFilter(cat['id']!),
                          borderRadius: BorderRadius.circular(10),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            height: 34,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? activeBg
                                  : (isAlert ? const Color(0xFFFEF2F2) : const Color(0xFFF8FAFC)),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? activeBg
                                    : (isAlert ? const Color(0xFFFECACA) : const Color(0xFFE2E8F0)),
                                width: 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: activeBg.withValues(alpha: 0.25),
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
                                  '${cat['icon'] != null ? '${cat['icon']} ' : ''}${cat['label']!}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : (isAlert ? const Color(0xFFDC2626) : const Color(0xFF475569)),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5.5, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white.withValues(alpha: 0.25)
                                        : (isAlert ? const Color(0xFFDC2626).withValues(alpha: 0.12) : const Color(0xFFE2E8F0)),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '$count',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Colors.white
                                          : (isAlert ? const Color(0xFFDC2626) : const Color(0xFF64748B)),
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

        // PRODUCT LIST TABLE / GRID
        Expanded(
          child: Obx(() {
            final rawList = controller.filteredProducts;
            if (rawList.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inventory_rounded, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    const Text('Không tìm thấy sản phẩm nào', style: TextStyle(fontSize: 16, color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            }

            var list = List<ProductModel>.from(rawList);
            if (_selectedSort == 'LOW_STOCK') {
              list.sort((a, b) => a.stock.compareTo(b.stock));
            } else if (_selectedSort == 'PRICE_DESC') {
              list.sort((a, b) => b.price.compareTo(a.price));
            } else if (_selectedSort == 'PRICE_ASC') {
              list.sort((a, b) => a.price.compareTo(b.price));
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, index) {
                final product = list[index];
                return _buildProductRowCard(product);
              },
            );
          }),
        ),
      ],
    );
  }

  String _formatStockUnit(int stock, String unit) {
    final u = unit.trim();
    if (u.isEmpty) return '$stock';
    if (RegExp(r'^[0-9]').hasMatch(u)) {
      return '$stock • ĐVT: $u';
    }
    return '$stock $u';
  }

  Widget _buildProductRowCard(ProductModel product) {
    final isLowStock = product.stock <= 10 && product.stock > 0;
    final isOutOfStock = product.stock == 0;
    final hasDiscount = product.originalPrice != null && product.originalPrice! > product.price;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOutOfStock
              ? const Color(0xFFFECACA)
              : (isLowStock ? const Color(0xFFFED7AA) : const Color(0xFFE2E8F0)),
          width: (isLowStock || isOutOfStock) ? 1.2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. TOP ROW: Image + Info + Status Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image with subtle shadow and zoom overlay
              InkWell(
                onTap: () => _showProductImagePreview(context, product),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        AppNetworkImage(
                          imageUrl: product.image,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          right: 3,
                          bottom: 3,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.55),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.zoom_in_rounded, size: 10, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Product Info: Name, Category, Price & Unit
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: product.isHidden ? const Color(0xFF94A3B8) : const Color(0xFF0F172A),
                        decoration: product.isHidden ? TextDecoration.lineThrough : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Category Pill & Unit Tag
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Text(
                            _getCategoryDisplay(product.categoryId),
                            style: const TextStyle(fontSize: 10, color: Color(0xFF334155), fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Text(
                            product.unit,
                            style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                          ),
                        ),
                        if (product.tags.isNotEmpty) ...[
                          const SizedBox(width: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '#${product.tags.first}',
                              style: const TextStyle(fontSize: 9.5, color: Color(0xFFB45309), fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 5),

                    // Price Line: formatted price + original price (if any)
                    Row(
                      children: [
                        Text(
                          widget.currencyFormatter.format(product.price),
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF059669),
                          ),
                        ),
                        if (hasDiscount) ...[
                          const SizedBox(width: 6),
                          Text(
                            widget.currencyFormatter.format(product.originalPrice),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF94A3B8),
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Stock Status Chip & Hidden Tag
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (product.isHidden)
                    Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.visibility_off_rounded, size: 10, color: Color(0xFF64748B)),
                          SizedBox(width: 3),
                          Text('Đã ẩn', style: TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isOutOfStock
                          ? const Color(0xFFFEF2F2)
                          : (isLowStock ? const Color(0xFFFFFBEB) : const Color(0xFFECFDF5)),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isOutOfStock
                            ? const Color(0xFFFECACA)
                            : (isLowStock ? const Color(0xFFFDE68A) : const Color(0xFFA7F3D0)),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isOutOfStock
                              ? Icons.cancel_outlined
                              : (isLowStock ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded),
                          size: 11.5,
                          color: isOutOfStock
                              ? const Color(0xFFDC2626)
                              : (isLowStock ? const Color(0xFFD97706) : const Color(0xFF059669)),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isOutOfStock
                              ? 'Hết hàng'
                              : (isLowStock ? 'Sắp hết (${product.stock})' : 'Còn ${product.stock}'),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isOutOfStock
                                ? const Color(0xFFDC2626)
                                : (isLowStock ? const Color(0xFFB45309) : const Color(0xFF059669)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 9),

          // 2. BOTTOM ROW: Quick Stepper + Modern Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Stepper Capsule + Quick Stock Edit
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: () => controller.quickUpdateStock(product.id, -1),
                          borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                          child: Container(
                            width: 30,
                            height: 32,
                            alignment: Alignment.center,
                            child: const Icon(Icons.remove_rounded, size: 15, color: Color(0xFF64748B)),
                          ),
                        ),
                        InkWell(
                          onTap: () => _showSetStockDialog(context, product),
                          child: Tooltip(
                            message: 'Chạm để sửa trực tiếp tồn kho',
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                border: Border.symmetric(vertical: BorderSide(color: Color(0xFFE2E8F0), width: 0.8)),
                              ),
                              child: Text(
                                '${product.stock}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: isOutOfStock
                                      ? const Color(0xFFDC2626)
                                      : (isLowStock ? const Color(0xFFD97706) : const Color(0xFF0F172A)),
                                ),
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () => controller.quickUpdateStock(product.id, 5),
                          borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                          child: Container(
                            width: 30,
                            height: 32,
                            alignment: Alignment.center,
                            child: const Icon(Icons.add_rounded, size: 15, color: Color(0xFF059669)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: isOutOfStock
                          ? const Color(0xFFFEF2F2)
                          : (isLowStock ? const Color(0xFFFFFBEB) : const Color(0xFFF8FAFC)),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isOutOfStock
                            ? const Color(0xFFFECACA)
                            : (isLowStock ? const Color(0xFFFDE68A) : const Color(0xFFE2E8F0)),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 12,
                          color: isOutOfStock
                              ? const Color(0xFFDC2626)
                              : (isLowStock ? const Color(0xFFD97706) : const Color(0xFF64748B)),
                        ),
                        const SizedBox(width: 4.5),
                        Text(
                          'Tồn: ${_formatStockUnit(product.stock, product.unit)}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isOutOfStock
                                ? const Color(0xFFDC2626)
                                : (isLowStock ? const Color(0xFFB45309) : const Color(0xFF334155)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Action Buttons Row (Unified Pill Buttons)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Hide/Show Toggle
                  Tooltip(
                    message: product.isHidden ? 'Hiện lại trên ứng dụng' : 'Tạm ẩn khỏi ứng dụng',
                    child: InkWell(
                      onTap: () => controller.toggleProductVisibility(product.id),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: product.isHidden ? const Color(0xFFF1F5F9) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Icon(
                          product.isHidden ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                          color: product.isHidden ? const Color(0xFF94A3B8) : const Color(0xFF059669),
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),

                  // Edit Button
                  InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => EditProductDialog(
                          product: product,
                          onSave: (editedProduct, isEdit) {
                            controller.saveProduct(editedProduct, isEdit);
                          },
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 32,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFDBEAFE)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit_note_rounded, color: Color(0xFF2563EB), size: 16),
                          SizedBox(width: 4),
                          Text('Sửa', style: TextStyle(color: Color(0xFF2563EB), fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),

                  // Delete Button
                  Tooltip(
                    message: 'Xóa món khỏi danh mục',
                    child: InkWell(
                      onTap: () => _confirmDeleteProduct(context, product),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFEE2E2)),
                        ),
                        child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFDC2626), size: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== TAB 2: LỊCH SỬ KHO (INVENTORY LOGS) ====================
  Widget _buildInventoryHistoryTab() {
    return Obx(() {
      final logs = controller.inventoryLogs;
      if (logs.isEmpty) {
        return const Center(
          child: Text('Chưa có lịch sử nhập/xuất kho nào', style: TextStyle(color: Color(0xFF64748B))),
        );
      }

      final dateFormatter = DateFormat('HH:mm - dd/MM/yyyy');

      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: logs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (ctx, index) {
          final item = logs[index];
          final isImport = item.type == 'IN';
          final isAdjust = item.type == 'ADJUST';

          final color = isImport
              ? const Color(0xFF059669)
              : (isAdjust ? const Color(0xFFD97706) : const Color(0xFFDC2626));

          final icon = isImport
              ? Icons.south_west_rounded
              : (isAdjust ? Icons.tune_rounded : Icons.north_east_rounded);

          final typeLabel = isImport
              ? 'NHẬP KHO'
              : (isAdjust ? 'KIỂM KÊ' : 'XUẤT BÁN');

          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              typeLabel,
                              style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w800),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            item.productName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.note,
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Người thực hiện: ${item.actor} • ${dateFormatter.format(item.timestamp)}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${item.quantity > 0 ? '+' : ''}${item.quantity}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: color,
                      ),
                    ),
                    Text(
                      'Tồn sau: ${item.stockAfter}',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
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

  void _confirmDeleteProduct(BuildContext context, ProductModel product) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        elevation: 20,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
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
                  child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFDC2626), size: 28),
                ),
                const SizedBox(height: 14),
                const Text('Xóa sản phẩm này?', style: TextStyle(fontSize: 16.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                const SizedBox(height: 8),
                Text(
                  'Bạn có chắc chắn muốn xóa "${product.name}" khỏi danh mục kinh doanh không?',
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
                          controller.deleteProduct(product.id);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFDC2626),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          minimumSize: const Size(0, 40),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        child: const Text('Xóa ngay', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
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

  void _showProductImagePreview(BuildContext context, ProductModel product) {
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
              Stack(
                children: [
                  SizedBox(
                    height: 260,
                    width: double.infinity,
                    child: AppNetworkImage(
                      imageUrl: product.image,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withValues(alpha: 0.5),
                      radius: 16,
                      child: IconButton(
                        icon: const Icon(Icons.close, size: 16, color: Colors.white),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF059669),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.currencyFormatter.format(product.price),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product.description.isEmpty ? 'Không có mô tả chi tiết' : product.description,
                      style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.4),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFE2E8F0), width: 0.8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.inventory_2_outlined, size: 14, color: Color(0xFF64748B)),
                              const SizedBox(width: 5),
                              Text(
                                'Tồn kho: ${_formatStockUnit(product.stock, product.unit)}',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            showDialog(
                              context: context,
                              builder: (dCtx) => EditProductDialog(
                                product: product,
                                onSave: (editedProduct, isEdit) {
                                  controller.saveProduct(editedProduct, isEdit);
                                },
                              ),
                            );
                          },
                          icon: const Icon(Icons.edit_rounded, size: 16, color: Colors.white),
                          label: const Text('Chỉnh sửa', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF059669)),
                        ),
                      ],
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

  void _showSetStockDialog(BuildContext context, ProductModel product) {
    final stockCtrl = TextEditingController(text: '${product.stock}');
    String selectedReason = 'Kiểm kê định kỳ';
    final reasons = ['Kiểm kê định kỳ', 'Nhập thêm hàng', 'Hàng hỏng / Hết hạn', 'Điều chỉnh hệ thống'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStockState) => Dialog(
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
                      const Icon(Icons.tune_rounded, color: Color(0xFF10B981), size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Cập nhật tồn kho: ${product.name}',
                          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
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
                      const Text('Số lượng tồn hiện tại', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                      const SizedBox(height: 6),
                      TextField(
                        controller: stockCtrl,
                        keyboardType: TextInputType.number,
                        autofocus: true,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                        decoration: InputDecoration(
                          suffixText: product.unit,
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        children: [5, 10, 50, 100].map((step) {
                          return ActionChip(
                            label: Text('+$step'),
                            onPressed: () {
                              final current = int.tryParse(stockCtrl.text.trim()) ?? product.stock;
                              stockCtrl.text = '${current + step}';
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      const Text('Lý do điều chỉnh:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: reasons.map((r) {
                          final isSelected = selectedReason == r;
                          return ChoiceChip(
                            label: Text(r, style: TextStyle(fontSize: 11.5, color: isSelected ? Colors.white : const Color(0xFF334155))),
                            selected: isSelected,
                            selectedColor: const Color(0xFF059669),
                            onSelected: (val) {
                              if (val) setStockState(() => selectedReason = r);
                            },
                          );
                        }).toList(),
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
                            final newStock = int.tryParse(stockCtrl.text.trim());
                            if (newStock != null) {
                              Navigator.pop(ctx);
                              controller.setExactStock(product.id, newStock, selectedReason);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF059669),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          child: const Text('Lưu thay đổi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
}
