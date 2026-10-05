import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/utils/formatters.dart';
import '../../data/datasource/mock_data.dart';
import '../../data/models/order_model.dart';
import '../../data/models/product_model.dart';

class OrderDetailScreen extends StatelessWidget {
  const OrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final OrderModel? order = Get.arguments is OrderModel ? Get.arguments as OrderModel : null;
    if (order == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Chi tiết đơn hàng'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
        ),
        body: const Center(child: Text('Không tìm thấy thông tin đơn hàng')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Chi tiết đơn hàng',
          style: TextStyle(
            color: AppColors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Trạng thái và Mã đơn hàng
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        order.id,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.black,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          order.status,
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Ngày đặt: ${Formatters.formatDateTime(order.orderDate)}',
                    style: const TextStyle(fontSize: 13, color: AppColors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Thông tin người nhận & Địa chỉ giao hàng
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 20, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text(
                        'Địa chỉ nhận hàng',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Text(
                    '${order.receiverName.isNotEmpty ? order.receiverName : 'Người nhận'} | ${order.receiverPhone.isNotEmpty ? order.receiverPhone : '---'}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order.shippingAddress.isNotEmpty ? order.shippingAddress : 'Chưa có địa chỉ cụ thể',
                    style: const TextStyle(fontSize: 13, color: AppColors.grey, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. Danh sách các mặt hàng đã mua
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sản phẩm đã đặt',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: order.items.length,
                    separatorBuilder: (_, __) => const Divider(height: 20),
                    itemBuilder: (context, index) {
                      final item = order.items[index];
                      return Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: _buildProductThumbnail(item.productImage),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.productName.isNotEmpty ? item.productName : 'Sản phẩm',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'x${item.quantity} ${item.unit}',
                                  style: const TextStyle(color: AppColors.grey, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                Formatters.formatCurrency(item.price * item.quantity),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppColors.black,
                                ),
                              ),
                              if (order.status == 'Đã giao' || order.status.contains('Đã giao')) ...[
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: () {
                                    final p = MockData.products.firstWhere(
                                      (prod) => prod.id == item.productId,
                                      orElse: () => ProductModel(
                                        id: item.productId,
                                        name: item.productName,
                                        description: 'Thực phẩm tươi ngon sạch chuẩn VietGAP.',
                                        price: item.price,
                                        image: item.productImage.isNotEmpty
                                            ? item.productImage
                                            : 'https://images.unsplash.com/photo-1619566636858-adf3ef46400b?w=500&q=80',
                                        categoryId: 'fruit',
                                        unit: item.unit,
                                      ),
                                    );
                                    Get.toNamed(AppRoutes.productDetail, arguments: p);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFFF8E1),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: Colors.amber.shade300),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                                        SizedBox(width: 2),
                                        Text('Đánh giá', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.amber)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 4. Chi tiết thanh toán
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Phương thức thanh toán', style: TextStyle(color: AppColors.grey)),
                      Text(order.paymentMethod, style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tạm tính', style: TextStyle(color: AppColors.grey)),
                      Text(Formatters.formatCurrency(order.subtotal)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Phí vận chuyển', style: TextStyle(color: AppColors.grey)),
                      Text(Formatters.formatCurrency(order.shippingFee)),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tổng cộng',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                      Text(
                        Formatters.formatCurrency(order.totalAmount),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
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
    );
  }

  // Widget hiển thị ảnh thumbnail an toàn
  Widget _buildProductThumbnail(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Container(
        width: 55,
        height: 55,
        color: Colors.grey.shade100,
        child: const Icon(Icons.shopping_bag_outlined, color: Colors.grey, size: 28),
      );
    }

    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        width: 55,
        height: 55,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(color: Colors.grey.shade200),
        errorWidget: (_, __, ___) => Container(
          width: 55,
          height: 55,
          color: Colors.grey.shade100,
          child: const Icon(Icons.shopping_bag_outlined, color: Colors.grey, size: 28),
        ),
      );
    }

    return Image.asset(
      imageUrl,
      width: 55,
      height: 55,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        width: 55,
        height: 55,
        color: Colors.grey.shade100,
        child: const Icon(Icons.shopping_bag_outlined, color: Colors.grey, size: 28),
      ),
    );
  }
}