import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/order_model.dart';
import '../admin_controller.dart';

class AdminOrdersView extends StatefulWidget {
  final NumberFormat currencyFormatter;
  const AdminOrdersView({super.key, required this.currencyFormatter});

  @override
  State<AdminOrdersView> createState() => _AdminOrdersViewState();
}

class _AdminOrdersViewState extends State<AdminOrdersView> {
  final AdminController controller = Get.find<AdminController>();
  final TextEditingController _searchCtrl = TextEditingController();

  final List<Map<String, String>> _statusTabs = [
    {'id': 'ALL', 'label': 'Tất cả đơn'},
    {'id': 'Chờ xác nhận', 'label': 'Chờ xác nhận'},
    {'id': 'Chờ xử lý', 'label': 'Đang đóng gói'},
    {'id': 'Đang giao', 'label': 'Đang giao'},
    {'id': 'Đã giao', 'label': 'Hoàn thành'},
    {'id': 'Đã hủy', 'label': 'Đã hủy'},
    {'id': 'REFUND', 'label': '🔄 Đổi trả / Hoàn tiền'},
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // TOOLBAR & STATUS TABS
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search input
              TextField(
                controller: _searchCtrl,
                onChanged: (val) => controller.orderSearchQuery.value = val,
                decoration: InputDecoration(
                  hintText: 'Tìm theo mã đơn (#ORD-...), tên người nhận, SĐT, mã tracking...',
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8)),
                  suffixIcon: Obx(() => controller.orderSearchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchCtrl.clear();
                            controller.orderSearchQuery.value = '';
                          },
                        )
                      : const SizedBox.shrink()),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Status Filter Tabs (Minimalist Modern Pills with Live Counts)
              Obx(() {
                final currentStatus = controller.selectedOrderStatusFilter.value;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _statusTabs.map((tab) {
                      final id = tab['id']!;
                      final isSelected = currentStatus == id;
                      final isRefundTab = id == 'REFUND';

                      int count = 0;
                      if (id == 'ALL') {
                        count = controller.orders.length;
                      } else if (id == 'REFUND') {
                        count = controller.orders.where((o) => o.refundStatus != null).length;
                      } else {
                        count = controller.orders.where((o) => o.status == id).length;
                      }

                      final activeBg = isRefundTab ? const Color(0xFF7C3AED) : const Color(0xFF059669);

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: () => controller.selectedOrderStatusFilter.value = id,
                          borderRadius: BorderRadius.circular(10),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? activeBg
                                  : (isRefundTab ? const Color(0xFFFAF5FF) : const Color(0xFFF1F5F9)),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? activeBg
                                    : (isRefundTab ? const Color(0xFFE9D5FF) : const Color(0xFFE2E8F0)),
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
                                  tab['label']!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                    color: isSelected
                                        ? Colors.white
                                        : (isRefundTab ? const Color(0xFF7C3AED) : const Color(0xFF475569)),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5.5, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white.withValues(alpha: 0.25)
                                        : (isRefundTab ? const Color(0xFF7C3AED).withValues(alpha: 0.12) : const Color(0xFFE2E8F0)),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '$count',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Colors.white
                                          : (isRefundTab ? const Color(0xFF7C3AED) : const Color(0xFF64748B)),
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

        // ORDERS LIST
        Expanded(
          child: Obx(() {
            final ordersList = controller.filteredOrders;
            if (ordersList.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long_rounded, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    const Text('Không có đơn hàng nào trong mục này', style: TextStyle(fontSize: 16, color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: ordersList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, index) {
                final order = ordersList[index];
                return _buildOrderCard(order);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    Color statusColor;
    Color statusBg;
    switch (order.status) {
      case 'Chờ xác nhận':
        statusColor = const Color(0xFFD97706);
        statusBg = const Color(0xFFFEF3C7);
        break;
      case 'Chờ xử lý':
        statusColor = const Color(0xFF2563EB);
        statusBg = const Color(0xFFDBEAFE);
        break;
      case 'Đang giao':
        statusColor = const Color(0xFF0284C7);
        statusBg = const Color(0xFFE0F2FE);
        break;
      case 'Đã giao':
        statusColor = const Color(0xFF059669);
        statusBg = const Color(0xFFD1FAE5);
        break;
      case 'Đã hủy':
        statusColor = const Color(0xFFDC2626);
        statusBg = const Color(0xFFFEE2E2);
        break;
      default:
        statusColor = const Color(0xFF64748B);
        statusBg = const Color(0xFFF1F5F9);
    }

    final hasRefund = order.refundStatus != null && order.refundStatus != 'none';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasRefund ? const Color(0xFFC084FC) : const Color(0xFFE2E8F0),
          width: hasRefund ? 1.5 : 1.0,
        ),
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
          // Order Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '#${order.id}',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F172A)),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '• ${Formatters.formatDateTime(order.orderDate)}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order.status,
                  style: TextStyle(color: statusColor, fontSize: 11.5, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const Divider(height: 20, color: Color(0xFFF1F5F9)),

          // Buyer Info
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.person_outline_rounded, size: 16, color: Color(0xFF64748B)),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        order.receiverName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF0F172A)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.phone_outlined, size: 15, color: Color(0xFF64748B)),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        order.receiverPhone,
                        style: const TextStyle(fontSize: 12.5, color: Color(0xFF475569)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.currencyFormatter.format(order.totalAmount),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF059669)),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Shipping Address
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF64748B)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  order.shippingAddress,
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          // Carrier & Tracking Code (nếu có)
          if (order.carrier != null || order.trackingCode != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.local_shipping_rounded, size: 16, color: Color(0xFF059669)),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'ĐVVC: ${order.carrier ?? "Tự giao"}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (order.trackingCode != null) ...[
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Mã: ${order.trackingCode}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F172A)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],

          // Refund Request Banner (nếu có yêu cầu đổi trả)
          if (hasRefund) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF5FF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE9D5FF)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.restart_alt_rounded, size: 16, color: Color(0xFF7C3AED)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Yêu cầu hoàn trả: ${order.refundReason ?? "Hàng dập nát / lỗi đóng gói"} (${order.refundStatus == "approved" ? "Đã duyệt hoàn tiền" : "Chờ quản trị viên xử lý"})',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF7C3AED)),
                    ),
                  ),
                  if (order.refundStatus == 'pending') ...[
                    TextButton(
                      onPressed: () => controller.handleRefund(orderId: order.id, isApprove: true),
                      child: const Text('Duyệt hoàn', style: TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                    TextButton(
                      onPressed: () => controller.handleRefund(orderId: order.id, isApprove: false),
                      child: const Text('Từ chối', style: TextStyle(color: Color(0xFFDC2626), fontSize: 12)),
                    ),
                  ],
                ],
              ),
            ),
          ],

          const Divider(height: 20, color: Color(0xFFF1F5F9)),

          // Actions toolbar
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Nút 1-chạm hành động nhanh theo giai đoạn đơn hàng
              if (order.status == 'Chờ xác nhận')
                ElevatedButton.icon(
                  onPressed: () => controller.changeOrderStatus(order.id, 'Chờ xử lý'),
                  icon: const Icon(Icons.check_circle_rounded, size: 15, color: Colors.white),
                  label: const Text('Xác nhận & Đóng gói', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                )
              else if (order.status == 'Chờ xử lý')
                ElevatedButton.icon(
                  onPressed: () => controller.changeOrderStatus(order.id, 'Đang giao'),
                  icon: const Icon(Icons.local_shipping_rounded, size: 15, color: Colors.white),
                  label: const Text('Giao Shipper', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0284C7),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                )
              else if (order.status == 'Đang giao')
                ElevatedButton.icon(
                  onPressed: () => controller.changeOrderStatus(order.id, 'Đã giao'),
                  icon: const Icon(Icons.task_alt_rounded, size: 15, color: Colors.white),
                  label: const Text('Đã giao thành công', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),

              // Xem chi tiết & Ghi chú
              OutlinedButton.icon(
                onPressed: () => _showOrderDetailDialog(order),
                icon: const Icon(Icons.visibility_outlined, size: 15),
                label: const Text('Chi tiết đơn', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF334155),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),

              // Gán vận chuyển / tracking
              OutlinedButton.icon(
                onPressed: () => _showTrackingDialog(order),
                icon: const Icon(Icons.local_shipping_outlined, size: 15),
                label: const Text('Gán Vận Đơn', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0284C7),
                  side: const BorderSide(color: Color(0xFFBAE6FD)),
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),

              // In phiếu gửi / xem trước vận đơn
              OutlinedButton.icon(
                onPressed: () => _showWaybillPreviewDialog(order),
                icon: const Icon(Icons.print_outlined, size: 15),
                label: const Text('In Phiếu Gửi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF059669),
                  side: const BorderSide(color: Color(0xFFA7F3D0)),
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),

              // Cập nhật trạng thái dropdown
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: ['Chờ xác nhận', 'Chờ xử lý', 'Đang giao', 'Đã giao', 'Đã hủy'].contains(order.status)
                        ? order.status
                        : 'Chờ xác nhận',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    items: const [
                      DropdownMenuItem(value: 'Chờ xác nhận', child: Text('Chờ xác nhận')),
                      DropdownMenuItem(value: 'Chờ xử lý', child: Text('Đóng gói (Chờ xử lý)')),
                      DropdownMenuItem(value: 'Đang giao', child: Text('Đang giao hàng')),
                      DropdownMenuItem(value: 'Đã giao', child: Text('Hoàn thành (Đã giao)')),
                      DropdownMenuItem(value: 'Đã hủy', child: Text('Đã hủy đơn')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        controller.changeOrderStatus(order.id, val);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== DIALOG 1: CHI TIẾT ĐƠN HÀNG ====================
  void _showOrderDetailDialog(OrderModel order) {
    final noteCtrl = TextEditingController(text: order.orderNote ?? '');

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 580,
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.receipt_long_rounded, color: Color(0xFF059669), size: 24),
                    const SizedBox(width: 10),
                    Text('Chi Tiết Đơn Hàng #${order.id}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const Divider(height: 24),

                // Customer info
                const Text('THÔNG TIN GIAO NHẬN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
                const SizedBox(height: 8),
                Text('Người nhận: ${order.receiverName} • ${order.receiverPhone}', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Địa chỉ: ${order.shippingAddress}', style: const TextStyle(color: Color(0xFF475569), fontSize: 13)),
                const SizedBox(height: 4),
                Text('Phương thức thanh toán: ${order.paymentMethod}', style: const TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.w600, fontSize: 13)),

                const SizedBox(height: 16),
                const Text('DANH SÁCH MÓN ĐẶT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: order.items.map((item) {
                      return ListTile(
                        dense: true,
                        title: Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        subtitle: Text('${widget.currencyFormatter.format(item.price)} x ${item.quantity} ${item.unit}'),
                        trailing: Text(
                          widget.currencyFormatter.format(item.total),
                          style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),

                // Subtotal & Shipping
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tạm tính:', style: TextStyle(color: Color(0xFF64748B))),
                    Text(widget.currencyFormatter.format(order.subtotal)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Phí giao hàng:', style: TextStyle(color: Color(0xFF64748B))),
                    Text(widget.currencyFormatter.format(order.shippingFee)),
                  ],
                ),
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tổng thanh toán:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(
                      widget.currencyFormatter.format(order.totalAmount),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF059669)),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Text('GHI CHÚ NỘI BỘ ADMIN', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
                const SizedBox(height: 8),
                TextField(
                  controller: noteCtrl,
                  decoration: InputDecoration(
                    hintText: 'Nhập ghi chú cho nhân viên soạn hàng hoặc tài xế...',
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      controller.updateOrderNote(order.id, noteCtrl.text);
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF059669)),
                    child: const Text('Lưu ghi chú', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== DIALOG 2: GÁN VẬN ĐƠN ====================
  void _showTrackingDialog(OrderModel order) {
    String selectedCarrier = order.carrier ?? 'Giao Hàng Nhanh (GHN)';
    final trackingCtrl = TextEditingController(
      text: order.trackingCode ?? 'GHN${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
    );

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Dialog(
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
                      const Icon(Icons.local_shipping_rounded, color: Color(0xFF38BDF8), size: 20),
                      const SizedBox(width: 8),
                      Text('Gán Vận Đơn (#${order.id})', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
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
                      const Text('Chọn đối tác giao vận:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155))),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: selectedCarrier,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Giao Hàng Nhanh (GHN)', child: Text('Giao Hàng Nhanh (GHN)')),
                          DropdownMenuItem(value: 'Giao Hàng Tiết Kiệm (GHTK)', child: Text('Giao Hàng Tiết Kiệm (GHTK)')),
                          DropdownMenuItem(value: 'Viettel Post', child: Text('Viettel Post')),
                          DropdownMenuItem(value: 'Tự giao (Đội shipper cửa hàng)', child: Text('Tự giao (Shipper cửa hàng)')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => selectedCarrier = val);
                        },
                      ),
                      const SizedBox(height: 14),
                      const Text('Mã vận đơn tracking:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155))),
                      const SizedBox(height: 8),
                      TextField(
                        controller: trackingCtrl,
                        decoration: InputDecoration(
                          hintText: 'Nhập hoặc dùng mã tự sinh...',
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
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
                            Navigator.pop(ctx);
                            controller.assignOrderTracking(
                              orderId: order.id,
                              carrier: selectedCarrier,
                              trackingCode: trackingCtrl.text.trim(),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0284C7),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          child: const Text('Xác nhận giao', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

  // ==================== DIALOG 3: XEM TRƯỚC PHIẾU GỬI (WAYBILL PREVIEW) ====================
  void _showWaybillPreviewDialog(OrderModel order) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Waybill
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('PHIẾU GỬI HÀNG / VẬN ĐƠN', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A))),
                      Text('Đơn vị: ${order.carrier ?? "GROCERY MART EXPRESS"}', style: const TextStyle(fontSize: 12, color: Color(0xFF059669), fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.qr_code_2_rounded, size: 36, color: Color(0xFF0F172A)),
                        Text('#${order.id}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24, thickness: 1.5),

              // From / To sections
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('NGƯỜI GỬI:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
                        Text(controller.storeName.value.isEmpty ? 'Grocery Mart' : controller.storeName.value, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('Hotline: ${controller.storeHotline.value.isEmpty ? "1900 8888" : controller.storeHotline.value}', style: const TextStyle(fontSize: 11.5)),
                        Text(controller.storeAddress.value.isEmpty ? "TP. Hồ Chí Minh" : controller.storeAddress.value, style: const TextStyle(fontSize: 11.5)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('NGƯỜI NHẬN:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
                        Text(order.receiverName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('SĐT: ${order.receiverPhone}', style: const TextStyle(fontSize: 11.5)),
                        Text(order.shippingAddress, style: const TextStyle(fontSize: 11.5)),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Items table
              const Text('NỘI DUNG HÀNG HÓA:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF64748B))),
              const SizedBox(height: 6),
              ...order.items.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('• ${item.productName} (x${item.quantity} ${item.unit})', style: const TextStyle(fontSize: 12)),
                        Text(widget.currencyFormatter.format(item.total), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  )),

              const Divider(height: 20),

              // Visual Barcode Code128 Strip
              Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(42, (i) {
                        final isThick = (i % 3 == 0) || (i % 7 == 0);
                        final isSpace = (i % 5 == 0);
                        return Container(
                          width: isSpace ? 2.5 : (isThick ? 3.0 : 1.5),
                          height: 36,
                          color: isSpace ? Colors.transparent : const Color(0xFF0F172A),
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                        );
                      }),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '*${order.trackingCode ?? order.id}*',
                      style: const TextStyle(fontFamily: 'monospace', letterSpacing: 2, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // COD Total
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('TIỀN THU NGƯỜI NHẬN (COD):', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFFDC2626))),
                        Text('HTTT: ${order.paymentMethod}', style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                      ],
                    ),
                    Text(
                      order.paymentMethod.toLowerCase().contains('cod')
                          ? widget.currencyFormatter.format(order.totalAmount)
                          : '0 đ (Đã thanh toán Online)',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFFDC2626)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Đóng')),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      Get.snackbar(
                        'Đã gửi lệnh in 🖨️',
                        'Phiếu gửi đơn #${order.id} đã gửi tới máy in vận đơn',
                        backgroundColor: const Color(0xFF059669),
                        colorText: Colors.white,
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    icon: const Icon(Icons.print_rounded, color: Colors.white, size: 18),
                    label: const Text('In Phiếu Gửi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF059669)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
