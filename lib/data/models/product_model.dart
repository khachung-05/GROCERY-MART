import 'dart:convert';

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? originalPrice;
  final String image;
  final String categoryId;
  final String unit;
  final bool isFavorite;
  final double rating;
  final int stock;
  final bool isHidden;
  final List<String> variants;
  final List<String> tags;
  final String? brand;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.image,
    required this.categoryId,
    this.unit = 'kg',
    this.isFavorite = false,
    this.rating = 5.0,
    this.stock = 50,
    this.isHidden = false,
    this.variants = const [],
    this.tags = const [],
    this.brand,
  });

  /// Hàm parse dữ liệu an toàn từ cả Backend MySQL (chuỗi/số, snake_case) và Local JSON
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final double parsedPrice =
        double.tryParse(json['price']?.toString() ?? '0') ?? 0.0;

    final rawOriginalPrice = json['original_price'] ?? json['originalPrice'];
    final double? parsedOriginalPrice = rawOriginalPrice != null
        ? double.tryParse(rawOriginalPrice.toString())
        : null;

    final String parsedCategoryId =
        (json['category_id'] ?? json['categoryId'] ?? '').toString();

    List<String> parseList(dynamic val) {
      if (val == null) return [];
      if (val is List) return val.map((e) => e.toString()).toList();
      if (val is String && val.isNotEmpty) {
        try {
          final decoded = jsonDecode(val);
          if (decoded is List) return decoded.map((e) => e.toString()).toList();
        } catch (_) {}
      }
      return [];
    }

    return ProductModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      price: parsedPrice,
      originalPrice: parsedOriginalPrice,
      image: (json['image'] ?? '').toString(),
      categoryId: parsedCategoryId,
      unit: (json['unit'] ?? 'kg').toString(),
      isFavorite: json['isFavorite'] == true || json['isFavorite'] == 1,
      rating: double.tryParse(json['rating']?.toString() ?? '5.0') ?? 5.0,
      stock: int.tryParse(json['stock']?.toString() ?? '50') ?? 50,
      isHidden: json['isHidden'] == true || json['isHidden'] == 1,
      variants: parseList(json['variants']),
      tags: parseList(json['tags']),
      brand: json['brand']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'original_price': originalPrice,
        'originalPrice': originalPrice,
        'image': image,
        'category_id': categoryId,
        'categoryId': categoryId,
        'unit': unit,
        'isFavorite': isFavorite,
        'rating': rating,
        'stock': stock,
        'isHidden': isHidden,
        'variants': variants,
        'tags': tags,
        'brand': brand,
      };

  // --- DÙNG CHO CƠ SỞ DỮ LIỆU SQLITE ---
  factory ProductModel.fromMap(Map<String, dynamic> map) =>
      ProductModel.fromJson(map);

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'originalPrice': originalPrice,
        'image': image,
        'categoryId': categoryId,
        'unit': unit,
        'isFavorite': isFavorite ? 1 : 0,
        'rating': rating,
        'stock': stock,
        'isHidden': isHidden ? 1 : 0,
        'variants': jsonEncode(variants),
        'tags': jsonEncode(tags),
        'brand': brand,
      };

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? originalPrice,
    String? image,
    String? categoryId,
    String? unit,
    bool? isFavorite,
    double? rating,
    int? stock,
    bool? isHidden,
    List<String>? variants,
    List<String>? tags,
    String? brand,
  }) =>
      ProductModel(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        price: price ?? this.price,
        originalPrice: originalPrice ?? this.originalPrice,
        image: image ?? this.image,
        categoryId: categoryId ?? this.categoryId,
        unit: unit ?? this.unit,
        isFavorite: isFavorite ?? this.isFavorite,
        rating: rating ?? this.rating,
        stock: stock ?? this.stock,
        isHidden: isHidden ?? this.isHidden,
        variants: variants ?? this.variants,
        tags: tags ?? this.tags,
        brand: brand ?? this.brand,
      );
}
