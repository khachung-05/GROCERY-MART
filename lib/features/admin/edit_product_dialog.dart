import 'package:flutter/material.dart';
import '../../data/datasource/mock_data.dart';
import '../../data/models/product_model.dart';

class EditProductDialog extends StatefulWidget {
  final ProductModel? product;
  final Function(ProductModel product, bool isEdit) onSave;

  const EditProductDialog({
    super.key,
    this.product,
    required this.onSave,
  });

  @override
  State<EditProductDialog> createState() => _EditProductDialogState();
}

class _EditProductDialogState extends State<EditProductDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _originalPriceController;
  late TextEditingController _unitController;
  late TextEditingController _stockController;
  late TextEditingController _imageController;
  late TextEditingController _descriptionController;

  String _selectedCategory = 'fruit';

  final List<Map<String, String>> _presetImages = [
    {
      'label': '🍎 Táo Fuji',
      'url': 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=600&q=80',
    },
    {
      'label': '🍇 Nho Đen',
      'url': 'https://images.unsplash.com/photo-1537640538966-79f369143f8f?w=600&q=80',
    },
    {
      'label': '🥦 Súp lơ',
      'url': 'https://images.unsplash.com/photo-1584270354949-c26b0d5b4a0c?w=600&q=80',
    },
    {
      'label': '🥩 Thịt bò',
      'url': 'https://images.unsplash.com/photo-1588168333986-5078d3ae3976?w=600&q=80',
    },
    {
      'label': '🦐 Tôm sú',
      'url': 'https://images.unsplash.com/photo-1565680018434-b513d5e5fd47?w=600&q=80',
    },
  ];

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p?.name ?? '');
    _priceController = TextEditingController(text: p?.price.toInt().toString() ?? '');
    _originalPriceController = TextEditingController(text: p?.originalPrice?.toInt().toString() ?? '');
    _unitController = TextEditingController(text: p?.unit ?? '1kg');
    _stockController = TextEditingController(text: p?.stock.toString() ?? '50');
    _imageController = TextEditingController(
      text: p?.image ?? 'https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=500&q=80',
    );
    _descriptionController = TextEditingController(text: p?.description ?? '');
    if (p != null && MockData.categories.any((c) => c.id == p.categoryId)) {
      _selectedCategory = p.categoryId;
    }

    _imageController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _originalPriceController.dispose();
    _unitController.dispose();
    _stockController.dispose();
    _imageController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final isEdit = widget.product != null;
      final newProduct = ProductModel(
        id: widget.product?.id ?? 'prod_${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.tryParse(_priceController.text.trim()) ?? 0,
        originalPrice: double.tryParse(_originalPriceController.text.trim()),
        image: _imageController.text.trim(),
        categoryId: _selectedCategory,
        unit: _unitController.text.trim(),
        rating: widget.product?.rating ?? 5.0,
        stock: int.tryParse(_stockController.text.trim()) ?? 10,
        isFavorite: widget.product?.isFavorite ?? false,
      );

      widget.onSave(newProduct, isEdit);
      Navigator.of(context).pop();
    }
  }

  InputDecoration _buildInputDecoration(String label, {String? hint, IconData? icon}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, size: 18, color: const Color(0xFF64748B)) : null,
      labelStyle: const TextStyle(color: Color(0xFF475569), fontSize: 13, fontWeight: FontWeight.w500),
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF059669), width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFDC2626)),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF059669)),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;

    return Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Dialog
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF059669), Color(0xFF10B981)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF059669).withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(
                            isEdit ? Icons.edit_note_rounded : Icons.add_box_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isEdit ? 'Chỉnh Sửa Sản Phẩm' : 'Thêm Sản Phẩm Mới',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              isEdit ? 'Cập nhật thông tin hàng hóa hệ thống' : 'Tạo mới mặt hàng vào kho quản lý',
                              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Color(0xFF94A3B8), size: 22),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),

                // SECTION 1: THÔNG TIN CƠ BẢN
                _buildSectionHeader('THÔNG TIN THỰC PHẨM', Icons.info_outline_rounded),

                TextFormField(
                  controller: _nameController,
                  decoration: _buildInputDecoration('Tên sản phẩm *', hint: 'Ví dụ: Táo Fuji Nhật', icon: Icons.shopping_bag_outlined),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập tên sản phẩm' : null,
                ),
                const SizedBox(height: 10),

                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: _buildInputDecoration('Danh mục thực phẩm *', icon: Icons.category_outlined),
                  items: MockData.categories.map((c) {
                    return DropdownMenuItem(
                      value: c.id,
                      child: Text('${c.icon} ${c.name}'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCategory = val);
                  },
                ),

                // SECTION 2: GIÁ BÁN & TỒN KHO
                _buildSectionHeader('GIÁ BÁN & KHO HÀNG', Icons.payments_outlined),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: _buildInputDecoration('Giá bán (VNĐ) *', hint: '45000', icon: Icons.sell_outlined),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _originalPriceController,
                        keyboardType: TextInputType.number,
                        decoration: _buildInputDecoration('Giá gốc (VNĐ)', hint: '60000', icon: Icons.price_change_outlined),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _unitController,
                        decoration: _buildInputDecoration('Đơn vị tính *', hint: '1kg, 500g, khay', icon: Icons.straighten_outlined),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _stockController,
                        keyboardType: TextInputType.number,
                        decoration: _buildInputDecoration('Tồn kho *', hint: '50', icon: Icons.inventory_2_outlined),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Bắt buộc' : null,
                      ),
                    ),
                  ],
                ),

                // SECTION 3: HÌNH ẢNH & MÔ TẢ
                _buildSectionHeader('HÌNH ẢNH & MÔ TẢ', Icons.image_outlined),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: _imageController.text.trim().isNotEmpty
                            ? Image.network(
                                _imageController.text.trim(),
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.grey, size: 28),
                              )
                            : const Icon(Icons.image_search, color: Colors.grey, size: 28),
                      ),
                    ),
                    const SizedBox(width: 10),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _imageController,
                            decoration: _buildInputDecoration('Link ảnh (URL) *', hint: 'https://...', icon: Icons.link_rounded),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập đường dẫn ảnh' : null,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: _presetImages.map((preset) {
                    final isSelected = _imageController.text.trim() == preset['url'];
                    return InkWell(
                      onTap: () => _imageController.text = preset['url']!,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFECFDF5) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF059669) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Text(
                          preset['label']!,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? const Color(0xFF047857) : const Color(0xFF475569),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: _buildInputDecoration('Mô tả chi tiết', hint: 'Nguồn gốc xuất xứ, độ ngọt, bảo quản...', icon: Icons.notes_rounded),
                ),
                const SizedBox(height: 22),

                // SECTION 4: NÚT BẤM HÀNH ĐỘNG
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Hủy bỏ',
                          style: TextStyle(color: Color(0xFF475569), fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: const Color(0xFF059669),
                          foregroundColor: Colors.white,
                          elevation: 3,
                          shadowColor: const Color(0xFF059669).withValues(alpha: 0.4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _submit,
                        icon: Icon(isEdit ? Icons.check_circle_outline : Icons.add_circle_outline, size: 18),
                        label: Text(
                          isEdit ? 'Lưu cập nhật' : 'Thêm sản phẩm',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
}
