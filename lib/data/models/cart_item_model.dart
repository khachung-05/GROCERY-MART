class CartItemModel {
  final String id;
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final int quantity;
  final String unit;
  final String categoryId;
  final int stock;

  CartItemModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    this.unit = 'kg',
    this.categoryId = '',
    this.stock = 50,
  });

  /// Thuộc tính tính tổng tiền của sản phẩm trong giỏ: totalPrice = price * quantity
  double get total => price * quantity;

  factory CartItemModel.fromJson(Map<String, dynamic> json) => CartItemModel(
    id: json['id'] ?? '',
    productId: json['productId'] ?? '',
    productName: json['productName'] ?? '',
    productImage: json['productImage'] ?? '',
    price: (json['price'] as num?)?.toDouble() ?? 0.0,
    quantity: json['quantity'] ?? 1,
    unit: json['unit'] ?? 'kg',
    categoryId: json['categoryId'] ?? '',
    stock: json['stock'] ?? 50,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'productId': productId,
    'productName': productName,
    'productImage': productImage,
    'price': price,
    'quantity': quantity,
    'unit': unit,
    'categoryId': categoryId,
    'stock': stock,
  };

  CartItemModel copyWith({
    String? id,
    String? productId,
    String? productName,
    String? productImage,
    double? price,
    int? quantity,
    String? unit,
    String? categoryId,
    int? stock,
  }) =>
      CartItemModel(
        id: id ?? this.id,
        productId: productId ?? this.productId,
        productName: productName ?? this.productName,
        productImage: productImage ?? this.productImage,
        price: price ?? this.price,
        quantity: quantity ?? this.quantity,
        unit: unit ?? this.unit,
        categoryId: categoryId ?? this.categoryId,
        stock: stock ?? this.stock,
      );
}