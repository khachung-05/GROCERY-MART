/// 1. Model Lịch sử Nhập / Xuất kho (Inventory History)
class InventoryLogModel {
  final String id;
  final String productId;
  final String productName;
  final String type; // 'IN' (Nhập kho), 'OUT' (Xuất kho / Bán hàng), 'ADJUST' (Điều chỉnh kiểm kê)
  final int quantity;
  final int stockAfter;
  final String note;
  final String actor; // Người thực hiện
  final DateTime timestamp;

  InventoryLogModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.type,
    required this.quantity,
    required this.stockAfter,
    required this.note,
    required this.actor,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'productId': productId,
    'productName': productName,
    'type': type,
    'quantity': quantity,
    'stockAfter': stockAfter,
    'note': note,
    'actor': actor,
    'timestamp': timestamp.toIso8601String(),
  };

  factory InventoryLogModel.fromJson(Map<String, dynamic> json) => InventoryLogModel(
    id: json['id'] ?? '',
    productId: json['productId'] ?? '',
    productName: json['productName'] ?? '',
    type: json['type'] ?? 'IN',
    quantity: json['quantity'] ?? 0,
    stockAfter: json['stockAfter'] ?? 0,
    note: json['note'] ?? '',
    actor: json['actor'] ?? 'Admin',
    timestamp: json['timestamp'] != null 
        ? DateTime.tryParse(json['timestamp']) ?? DateTime.now() 
        : DateTime.now(),
  );
}

/// 2. Model Khách hàng CRM & Hạng thành viên (Customer & CRM)
class CustomerModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String tier; // 'Đồng', 'Bạc', 'Vàng', 'Kim Cương'
  final int points;
  final double totalSpent; // LTV
  final int ordersCount;
  final DateTime joinedDate;
  final bool isBlocked;

  CustomerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    this.tier = 'Đồng',
    this.points = 0,
    this.totalSpent = 0.0,
    this.ordersCount = 0,
    required this.joinedDate,
    this.isBlocked = false,
  });

  CustomerModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? tier,
    int? points,
    double? totalSpent,
    int? ordersCount,
    DateTime? joinedDate,
    bool? isBlocked,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      tier: tier ?? this.tier,
      points: points ?? this.points,
      totalSpent: totalSpent ?? this.totalSpent,
      ordersCount: ordersCount ?? this.ordersCount,
      joinedDate: joinedDate ?? this.joinedDate,
      isBlocked: isBlocked ?? this.isBlocked,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'address': address,
    'tier': tier,
    'points': points,
    'totalSpent': totalSpent,
    'ordersCount': ordersCount,
    'joinedDate': joinedDate.toIso8601String(),
    'isBlocked': isBlocked,
  };

  factory CustomerModel.fromJson(Map<String, dynamic> json) => CustomerModel(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    email: json['email'] ?? '',
    phone: json['phone'] ?? '',
    address: json['address'] ?? '',
    tier: json['tier'] ?? 'Đồng',
    points: json['points'] ?? 0,
    totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0.0,
    ordersCount: json['ordersCount'] ?? 0,
    joinedDate: json['joinedDate'] != null
        ? DateTime.tryParse(json['joinedDate']) ?? DateTime.now()
        : DateTime.now(),
    isBlocked: json['isBlocked'] ?? false,
  );
}

/// 3. Model Đánh giá & Bình luận (Review Moderation)
class ReviewModerationModel {
  final String id;
  final String productId;
  final String productName;
  final String productImage;
  final String customerName;
  final double rating;
  final String comment;
  final String? reply;
  final bool isHidden;
  final DateTime createdAt;

  ReviewModerationModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.customerName,
    required this.rating,
    required this.comment,
    this.reply,
    this.isHidden = false,
    required this.createdAt,
  });

  ReviewModerationModel copyWith({
    String? id,
    String? productId,
    String? productName,
    String? productImage,
    String? customerName,
    double? rating,
    String? comment,
    String? reply,
    bool? isHidden,
    DateTime? createdAt,
  }) {
    return ReviewModerationModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      customerName: customerName ?? this.customerName,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      reply: reply ?? this.reply,
      isHidden: isHidden ?? this.isHidden,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// 4. Model Khuyến mãi Voucher / Coupon
class AdminVoucherModel {
  final String id;
  final String code;
  final String title;
  final String discountType; // 'PERCENT' hoặc 'FIXED'
  final double discountValue; // % hoặc số tiền VND
  final double minOrderValue;
  final double? maxDiscount; // Giới hạn giảm tối đa nếu là %
  final int usageLimit;
  final int usedCount;
  final String categoryScope; // 'ALL' hoặc categoryId cụ thể
  final DateTime expiryDate;
  final bool isActive;

  AdminVoucherModel({
    required this.id,
    required this.code,
    required this.title,
    required this.discountType,
    required this.discountValue,
    required this.minOrderValue,
    this.maxDiscount,
    required this.usageLimit,
    this.usedCount = 0,
    this.categoryScope = 'ALL',
    required this.expiryDate,
    this.isActive = true,
  });

  AdminVoucherModel copyWith({
    String? id,
    String? code,
    String? title,
    String? discountType,
    double? discountValue,
    double? minOrderValue,
    double? maxDiscount,
    int? usageLimit,
    int? usedCount,
    String? categoryScope,
    DateTime? expiryDate,
    bool? isActive,
  }) {
    return AdminVoucherModel(
      id: id ?? this.id,
      code: code ?? this.code,
      title: title ?? this.title,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      minOrderValue: minOrderValue ?? this.minOrderValue,
      maxDiscount: maxDiscount ?? this.maxDiscount,
      usageLimit: usageLimit ?? this.usageLimit,
      usedCount: usedCount ?? this.usedCount,
      categoryScope: categoryScope ?? this.categoryScope,
      expiryDate: expiryDate ?? this.expiryDate,
      isActive: isActive ?? this.isActive,
    );
  }
}

/// 5. Model Chương trình Flash Sale
class FlashSaleCampaignModel {
  final String id;
  final String title;
  final int discountPercent;
  final DateTime startTime;
  final DateTime endTime;
  final List<String> productIds;
  final bool isActive;

  FlashSaleCampaignModel({
    required this.id,
    required this.title,
    required this.discountPercent,
    required this.startTime,
    required this.endTime,
    required this.productIds,
    this.isActive = true,
  });
}

/// 6. Model Phân quyền nhân sự (Staff & RBAC)
class StaffMemberModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role; // 'Super Admin', 'Quản lý kho', 'CSKH & Đơn hàng', 'Kế toán'
  final List<String> permissions; // 'products', 'orders', 'crm', 'promotions', 'analytics', 'settings'
  final bool isActive;
  final DateTime joinedDate;

  StaffMemberModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.permissions,
    this.isActive = true,
    required this.joinedDate,
  });

  StaffMemberModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    List<String>? permissions,
    bool? isActive,
    DateTime? joinedDate,
  }) {
    return StaffMemberModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      permissions: permissions ?? this.permissions,
      isActive: isActive ?? this.isActive,
      joinedDate: joinedDate ?? this.joinedDate,
    );
  }
}
