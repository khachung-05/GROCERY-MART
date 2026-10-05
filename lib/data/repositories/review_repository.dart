import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/review_model.dart';

class ReviewRepository {
  static const String _storageKey = 'global_product_reviews_list';

  // Seed sample reviews for demo products
  static final List<ReviewModel> _sampleReviews = [
    ReviewModel(
      id: 'rev_101',
      productId: 'prod_001',
      userId: 'user_002',
      userName: 'Trần Thanh Mai',
      userAvatar: 'https://ui-avatars.com/api/?name=Tran+Thanh+Mai&background=059669&color=fff',
      rating: 5.0,
      comment: 'Táo rất tươi giòn, mọng nước và ngọt lịm. Đóng gói cẩn thận!',
      date: '2026-09-10 14:30',
    ),
    ReviewModel(
      id: 'rev_102',
      productId: 'prod_001',
      userId: 'user_003',
      userName: 'Nguyễn Văn Minh',
      userAvatar: 'https://ui-avatars.com/api/?name=Nguyen+Van+Minh&background=2563EB&color=fff',
      rating: 4.5,
      comment: 'Trái cây ngon sạch chuẩn Fuji Nhật. Giao hàng siêu nhanh trong 30 phút.',
      date: '2026-09-11 09:15',
    ),
    ReviewModel(
      id: 'rev_103',
      productId: 'prod_002',
      userId: 'user_004',
      userName: 'Lê Hoàng Hải',
      userAvatar: 'https://ui-avatars.com/api/?name=Le+Hoang+Hai&background=D97706&color=fff',
      rating: 5.0,
      comment: 'Nho không hạt Úc ngọt đậm đà, cuống còn tươi xanh lắm. 10/10 điểm!',
      date: '2026-09-12 18:45',
    ),
    ReviewModel(
      id: 'rev_104',
      productId: 'prod_007',
      userId: 'user_005',
      userName: 'Phạm Thu Trang',
      userAvatar: 'https://ui-avatars.com/api/?name=Pham+Thu+Trang&background=DC2626&color=fff',
      rating: 4.8,
      comment: 'Bông cải xanh Đà Lạt giòn ngọt hữu cơ, xào với bò cực kỳ bắt cơm.',
      date: '2026-09-12 20:10',
    ),
  ];

  /// Đọc danh sách tất cả đánh giá đã lưu
  Future<List<ReviewModel>> getAllReviews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> rawList = prefs.getStringList(_storageKey) ?? [];

      if (rawList.isEmpty) {
        // Tự động khởi tạo seed data mẫu
        await _seedInitialReviews(prefs);
        return _sampleReviews;
      }

      final List<ReviewModel> result = [];
      for (final itemStr in rawList) {
        try {
          final decoded = jsonDecode(itemStr) as Map<String, dynamic>;
          result.add(ReviewModel.fromJson(decoded));
        } catch (_) {}
      }
      return result;
    } catch (e) {
      debugPrint('Lỗi đọc ReviewRepository: $e');
      return _sampleReviews;
    }
  }

  Future<void> _seedInitialReviews(SharedPreferences prefs) async {
    final List<String> encoded = _sampleReviews.map((r) => jsonEncode(r.toJson())).toList();
    await prefs.setStringList(_storageKey, encoded);
  }

  /// Đọc danh sách đánh giá theo sản phẩm
  Future<List<ReviewModel>> getReviewsForProduct(String productId) async {
    final all = await getAllReviews();
    return all.where((r) => r.productId == productId).toList();
  }

  /// Thêm đánh giá mới
  Future<void> addReview(ReviewModel review) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> rawList = prefs.getStringList(_storageKey) ?? [];

      rawList.insert(0, jsonEncode(review.toJson()));
      await prefs.setStringList(_storageKey, rawList);
      debugPrint('Đã thêm đánh giá mới thành công cho SP: ${review.productId}');
    } catch (e) {
      debugPrint('Lỗi thêm ReviewRepository: $e');
    }
  }

  /// Tính điểm sao trung bình của sản phẩm
  Future<double> getAverageRating(String productId) async {
    final reviews = await getReviewsForProduct(productId);
    if (reviews.isEmpty) return 5.0;
    final total = reviews.fold<double>(0.0, (sum, r) => sum + r.rating);
    return double.parse((total / reviews.length).toStringAsFixed(1));
  }
}
