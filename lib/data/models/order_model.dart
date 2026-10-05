import 'dart:convert';

class OrderItemModel {
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final int quantity;
  final String unit;

  OrderItemModel({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    this.unit = 'kg',
  });

  double get total => price * quantity;

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productId: json['productId']?.toString() ?? json['product_id']?.toString() ?? '',
      productName: json['productName']?.toString() ?? json['product_name']?.toString() ?? '',
      productImage: json['productImage']?.toString() ?? json['product_image']?.toString() ?? json['image']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      unit: json['unit']?.toString() ?? 'kg',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'quantity': quantity,
      'unit': unit,
    };
  }

  OrderItemModel copyWith({
    String? productId,
    String? productName,
    String? productImage,
    double? price,
    int? quantity,
    String? unit,
  }) {
    return OrderItemModel(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
    );
  }
}

class OrderModel {
  final String id;
  final String userId;
  final List<OrderItemModel> items;
  final double subtotal;
  final double shippingFee;
  final double totalAmount;
  final String shippingAddress;
  final String receiverName;
  final String receiverPhone;
  final String paymentMethod;
  final String status;
  final String orderDate;
  final String? carrier;
  final String? trackingCode;
  final String? orderNote;
  final String? refundStatus;
  final String? refundReason;
  final double discountAmount;
  final String? voucherCode;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.shippingFee,
    required this.totalAmount,
    required this.shippingAddress,
    required this.receiverName,
    required this.receiverPhone,
    required this.paymentMethod,
    required this.status,
    required this.orderDate,
    this.carrier,
    this.trackingCode,
    this.orderNote,
    this.refundStatus,
    this.refundReason,
    this.discountAmount = 0.0,
    this.voucherCode,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    var rawItems = json['items'];
    List<OrderItemModel> parsedItems = [];
    if (rawItems is String) {
      try {
        final decoded = jsonDecode(rawItems);
        if (decoded is List) {
          parsedItems = decoded
              .map((e) => OrderItemModel.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList();
        }
      } catch (_) {}
    } else if (rawItems is List) {
      parsedItems = rawItems
          .map((e) => e is OrderItemModel
              ? e
              : OrderItemModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }

    return OrderModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? json['user_id']?.toString() ?? '',
      items: parsedItems,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      shippingFee: (json['shippingFee'] as num?)?.toDouble() ??
          (json['shipping_fee'] as num?)?.toDouble() ??
          0.0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ??
          (json['total_amount'] as num?)?.toDouble() ??
          0.0,
      shippingAddress: json['shippingAddress']?.toString() ??
          json['shipping_address']?.toString() ??
          json['delivery_address']?.toString() ??
          '',
      receiverName: json['receiverName']?.toString() ??
          json['receiver_name']?.toString() ??
          '',
      receiverPhone: json['receiverPhone']?.toString() ??
          json['receiver_phone']?.toString() ??
          '',
      paymentMethod: json['paymentMethod']?.toString() ??
          json['payment_method']?.toString() ??
          '',
      status: json['status']?.toString() ?? 'Chờ xác nhận',
      orderDate: json['orderDate']?.toString() ??
          json['order_date']?.toString() ??
          '',
      carrier: json['carrier']?.toString(),
      trackingCode: json['trackingCode']?.toString() ?? json['tracking_code']?.toString(),
      orderNote: json['orderNote']?.toString() ?? json['note']?.toString(),
      refundStatus: json['refundStatus']?.toString() ?? json['refund_status']?.toString(),
      refundReason: json['refundReason']?.toString() ?? json['refund_reason']?.toString(),
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ??
          (json['discount'] as num?)?.toDouble() ??
          0.0,
      voucherCode: json['voucherCode']?.toString() ?? json['voucher_code']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'items': items.map((e) => e.toJson()).toList(),
      'subtotal': subtotal,
      'shippingFee': shippingFee,
      'totalAmount': totalAmount,
      'shippingAddress': shippingAddress,
      'receiverName': receiverName,
      'receiverPhone': receiverPhone,
      'paymentMethod': paymentMethod,
      'status': status,
      'orderDate': orderDate,
      'carrier': carrier,
      'trackingCode': trackingCode,
      'orderNote': orderNote,
      'refundStatus': refundStatus,
      'refundReason': refundReason,
      'discountAmount': discountAmount,
      'voucherCode': voucherCode,
    };
  }

  OrderModel copyWith({
    String? id,
    String? userId,
    List<OrderItemModel>? items,
    double? subtotal,
    double? shippingFee,
    double? totalAmount,
    String? shippingAddress,
    String? receiverName,
    String? receiverPhone,
    String? paymentMethod,
    String? status,
    String? orderDate,
    String? carrier,
    String? trackingCode,
    String? orderNote,
    String? refundStatus,
    String? refundReason,
    double? discountAmount,
    String? voucherCode,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      shippingFee: shippingFee ?? this.shippingFee,
      totalAmount: totalAmount ?? this.totalAmount,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      receiverName: receiverName ?? this.receiverName,
      receiverPhone: receiverPhone ?? this.receiverPhone,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      orderDate: orderDate ?? this.orderDate,
      carrier: carrier ?? this.carrier,
      trackingCode: trackingCode ?? this.trackingCode,
      orderNote: orderNote ?? this.orderNote,
      refundStatus: refundStatus ?? this.refundStatus,
      refundReason: refundReason ?? this.refundReason,
      discountAmount: discountAmount ?? this.discountAmount,
      voucherCode: voucherCode ?? this.voucherCode,
    );
  }
}
