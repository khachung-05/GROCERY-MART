import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_routes.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/order_model.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Nhận model đơn hàng vừa tạo xong
    final OrderModel order = Get.arguments as OrderModel;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          Get.offAllNamed(AppRoutes.main);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  // 1. Icon tròn xanh có dấu tích v
                  Container(
                    width: 110,
                    height: 110,
                    decoration: const BoxDecoration(
                      color: Color(0xFF388E3C),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 65,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 2. Tiêu đề và dòng mô tả
                  const Text(
                    'Đặt hàng thành công!',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Đơn hàng của bạn đã được đặt thành công.\nChúng tôi sẽ xử lý ngay!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // 3. Card chi tiết đơn hàng tóm tắt
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildRow('Mã đơn hàng', order.id, isBold: true),
                        const SizedBox(height: 14),
                        _buildRow(
                          'Tổng tiền',
                          Formatters.formatCurrency(order.totalAmount),
                          valueColor: const Color(0xFF2E7D32),
                          isBold: true,
                        ),
                        const SizedBox(height: 14),
                        _buildRow(
                          'Thanh toán',
                          order.paymentMethod.contains('COD')
                              ? 'COD - Tiền mặt khi nhận hàng'
                              : order.paymentMethod,
                          isBold: true,
                        ),
                        const SizedBox(height: 14),
                        _buildRow(
                          'Trạng thái',
                          order.status,
                          valueColor: const Color(0xFFFFA000),
                          isBold: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // 4. Nút "Xem đơn hàng"
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF388E3C),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        // Chuyển thẳng sang trang Chi tiết đơn hàng vừa đặt
                        Get.offNamed(AppRoutes.orderDetail, arguments: order);
                      },
                      icon: const Icon(Icons.receipt_outlined, color: Colors.white, size: 20),
                      label: const Text(
                        'Xem đơn hàng',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 5. Nút "Tiếp tục mua sắm"
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF388E3C), width: 1.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Get.offAllNamed(AppRoutes.main);
                      },
                      child: const Text(
                        'Tiếp tục mua sắm',
                        style: TextStyle(
                          color: Color(0xFF388E3C),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {Color? valueColor, bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}