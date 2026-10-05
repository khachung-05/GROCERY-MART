class VoucherModel {
  final String id;
  final String code;
  final String title;
  final String discountType; // 'FIXED', 'PERCENT', 'SHIPPING'
  final double discountValue;
  final double minOrderValue;
  final double? maxDiscount;
  final DateTime expiryDate;
  final String? description;
  final bool isActive;

  VoucherModel({
    required this.id,
    required this.code,
    required this.title,
    required this.discountType,
    required this.discountValue,
    required this.minOrderValue,
    this.maxDiscount,
    required this.expiryDate,
    this.description,
    this.isActive = true,
  });

  /// Tính số tiền giảm giá thực tế dựa trên tạm tính và phí ship
  double calculateDiscount(double subtotal, double shippingFee) {
    if (subtotal < minOrderValue) return 0.0;
    if (discountType == 'FIXED') {
      return discountValue > subtotal ? subtotal : discountValue;
    } else if (discountType == 'PERCENT') {
      double d = subtotal * (discountValue / 100.0);
      if (maxDiscount != null && d > maxDiscount!) {
        d = maxDiscount!;
      }
      return d;
    } else if (discountType == 'SHIPPING') {
      return discountValue > shippingFee ? shippingFee : discountValue;
    }
    return 0.0;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'title': title,
    'discountType': discountType,
    'discountValue': discountValue,
    'minOrderValue': minOrderValue,
    'maxDiscount': maxDiscount,
    'expiryDate': expiryDate.toIso8601String(),
    'description': description,
    'isActive': isActive,
  };

  factory VoucherModel.fromJson(Map<String, dynamic> json) => VoucherModel(
    id: json['id'] ?? '',
    code: json['code'] ?? '',
    title: json['title'] ?? '',
    discountType: json['discountType'] ?? 'FIXED',
    discountValue: (json['discountValue'] as num?)?.toDouble() ?? 0.0,
    minOrderValue: (json['minOrderValue'] as num?)?.toDouble() ?? 0.0,
    maxDiscount: (json['maxDiscount'] as num?)?.toDouble(),
    expiryDate: json['expiryDate'] != null
        ? (DateTime.tryParse(json['expiryDate'].toString()) ?? DateTime.now().add(const Duration(days: 30)))
        : DateTime.now().add(const Duration(days: 30)),
    description: json['description']?.toString(),
    isActive: json['isActive'] ?? true,
  );
}
