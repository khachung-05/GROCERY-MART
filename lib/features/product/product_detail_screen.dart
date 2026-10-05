import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/storage/local_storage.dart';
import '../../core/utils/formatters.dart';
import '../../data/datasource/mock_data.dart';
import '../../data/models/category_model.dart';
import '../../data/models/product_model.dart';
import '../../data/models/review_model.dart';
import '../../data/repositories/review_repository.dart';
import '../cart/cart_controller.dart';
import '../favorite/favorite_controller.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late ProductModel product;
  int quantity = 1;

  final ReviewRepository _reviewRepo = ReviewRepository();
  List<ReviewModel> _reviews = [];
  double _averageRating = 5.0;
  bool _isLoadingReviews = true;

  // Review Form state
  double _userRating = 5.0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmittingReview = false;

  // Map tracking helpful votes
  final Map<String, int> _helpfulVotes = {};
  final Set<String> _likedReviews = {};

  @override
  void initState() {
    super.initState();
    product = Get.arguments as ProductModel;
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() => _isLoadingReviews = true);
    final list = await _reviewRepo.getReviewsForProduct(product.id);
    final avg = await _reviewRepo.getAverageRating(product.id);
    if (mounted) {
      setState(() {
        _reviews = list;
        _averageRating = avg;
        _isLoadingReviews = false;
      });
    }
  }

  Future<void> _submitReview() async {
    final comment = _commentController.text.trim();
    if (comment.isEmpty) {
      Get.snackbar(
        'Thông báo',
        'Vui lòng viết nội dung nhận xét của bạn',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.amber.shade800,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    setState(() => _isSubmittingReview = true);

    final userInfo = LocalStorage.getUserInfo();
    final userId = userInfo['id'] ?? 'user_guest';
    final userName = userInfo['name'] ?? 'Khách hàng';
    final userAvatar = userInfo['avatar'] ?? 'https://ui-avatars.com/api/?name=${Uri.encodeComponent(userName)}';

    final newReview = ReviewModel(
      id: 'rev_${DateTime.now().millisecondsSinceEpoch}',
      productId: product.id,
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      rating: _userRating,
      comment: comment,
      date: DateTime.now().toString().substring(0, 16),
    );

    await _reviewRepo.addReview(newReview);
    _commentController.clear();
    _userRating = 5.0;

    Get.snackbar(
      'Cảm ơn bạn!',
      'Đánh giá của bạn đã được đăng thành công',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.check_circle, color: Colors.white),
    );

    await _loadReviews();
    if (mounted) setState(() => _isSubmittingReview = false);
  }

  String _getRatingText(double rating) {
    if (rating >= 4.8) return 'Rất tuyệt vời! 😍';
    if (rating >= 4.0) return 'Rất tốt 😊';
    if (rating >= 3.0) return 'Bình thường 😐';
    if (rating >= 2.0) return 'Chưa hài lòng 🙁';
    return 'Rất tệ 😡';
  }

  Map<int, int> get _ratingDistribution {
    final map = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (var r in _reviews) {
      final star = r.rating.round().clamp(1, 5);
      map[star] = (map[star] ?? 0) + 1;
    }
    return map;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();
    final favoriteController = Get.put(FavoriteController());

    final discountPercent = product.originalPrice != null
        ? (((product.originalPrice! - product.price) / product.originalPrice!) * 100).round()
        : null;

    final category = MockData.categories.firstWhere(
      (c) => c.id == product.categoryId,
      orElse: () => CategoryModel(
        id: '',
        name: 'Thực phẩm',
        icon: '🛒',
        image: '',
        description: '',
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // 1. SLIVER APP BAR VỚI ẢNH BÌA COLLAPSE MƯỢT MÀ
              SliverAppBar(
                expandedHeight: 320,
                pinned: true,
                elevation: 0,
                backgroundColor: Colors.white,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withValues(alpha: 0.9),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A), size: 20),
                      onPressed: () => Get.back(),
                    ),
                  ),
                ),
                actions: [
                  Obx(() {
                    final isFav = favoriteController.isFavorite(product.id);
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        backgroundColor: Colors.white.withValues(alpha: 0.9),
                        child: IconButton(
                          icon: Icon(
                            isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: isFav ? const Color(0xFFEF4444) : const Color(0xFF0F172A),
                            size: 20,
                          ),
                          onPressed: () => favoriteController.toggleFavorite(product.id),
                        ),
                      ),
                    );
                  }),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 60, bottom: 16, right: 60),
                  centerTitle: true,
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: product.image,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(color: const Color(0xFFE2E8F0)),
                        errorWidget: (_, __, ___) => Container(
                          color: const Color(0xFFE2E8F0),
                          child: const Icon(Icons.broken_image_rounded, size: 60, color: Colors.grey),
                        ),
                      ),
                      // Gradient overlay ở viền dưới ảnh
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 60,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.0),
                                Colors.black.withValues(alpha: 0.3),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. NỘI DUNG CHI TIẾT SẢN PHẨM & ĐÁNH GIÁ
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(left: 18, right: 18, top: 18, bottom: 130),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tag danh mục & Trạng thái tồn kho
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primarySurface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.primaryBorder),
                            ),
                            child: Text(
                              '${category.icon} ${category.name}',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: product.stock > 0 ? AppColors.primarySurface : const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              product.stock > 0 ? '✓ Còn kho: ${product.stock} sản phẩm' : '✕ Hết hàng',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: product.stock > 0 ? AppColors.primary : const Color(0xFFDC2626),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Tên sản phẩm
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Đánh giá sao nhanh & lượt mua
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star_rounded, color: Color(0xFFD97706), size: 16),
                                const SizedBox(width: 3),
                                Text(
                                  _averageRating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Color(0xFFB45309),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${_reviews.length} đánh giá)',
                            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                          ),
                          const Spacer(),
                          Text(
                            'Khối lượng: ${product.unit}',
                            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Giá bán & Giảm giá
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Giá ưu đãi', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                const SizedBox(height: 2),
                                Text(
                                  Formatters.formatCurrency(product.price),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            if (product.originalPrice != null) ...[
                              const SizedBox(width: 14),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    Formatters.formatCurrency(product.originalPrice!),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF94A3B8),
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEF4444),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '-$discountPercent%',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Badges cam kết chất lượng
                      Row(
                        children: [
                          Expanded(
                            child: _buildBadgeItem(
                              icon: Icons.verified_rounded,
                              title: '100% Tươi ngon',
                              color: const Color(0xFF16A34A),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildBadgeItem(
                              icon: Icons.bolt_rounded,
                              title: 'Giao 30 phút',
                              color: const Color(0xFFEA580C),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildBadgeItem(
                              icon: Icons.autorenew_rounded,
                              title: 'Đổi trả 24h',
                              color: const Color(0xFF2563EB),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Mô tả sản phẩm
                      const Text(
                        'Thông tin chi tiết',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Text(
                          product.description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF334155),
                            height: 1.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // SECTION: ĐÁNH GIÁ & NHẬN XÉT SẢN PHẨM
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Đánh giá & Nhận xét',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFFDE68A)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star_rounded, color: Color(0xFFD97706), size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '$_averageRating / 5.0',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFB45309)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // BẢNG TỔNG QUAN PHÂN BỔ SAO (RATING BREAKDOWN)
                      _buildRatingSummaryCard(),

                      const SizedBox(height: 18),

                      // FORM VIẾT ĐÁNH GIÁ MỚI
                      _buildWriteReviewCard(),

                      const SizedBox(height: 20),

                      // DANH SÁCH BÌNH LUẬN KHÁCH HÀNG
                      if (_isLoadingReviews)
                        const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: AppColors.primary)))
                      else if (_reviews.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: const Column(
                            children: [
                              Icon(Icons.rate_review_outlined, size: 36, color: Color(0xFF94A3B8)),
                              SizedBox(height: 8),
                              Text(
                                'Chưa có nhận xét nào cho sản phẩm này.',
                                style: TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Hãy là người đầu tiên chia sẻ cảm nhận của bạn!',
                                style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                              ),
                            ],
                          ),
                        )
                      else
                        Column(
                          children: _reviews.map((rev) => _buildReviewItemCard(rev)).toList(),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // BOTTOM BAR MUA HÀNG VỚI NÚT TĂNG GIẢM VÀ THÊM GIỎ HÀNG
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 15,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    // Bộ chọn số lượng
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_rounded, size: 18, color: Color(0xFF475569)),
                            onPressed: () {
                              if (quantity > 1) {
                                setState(() => quantity--);
                              }
                            },
                          ),
                          Text(
                            '$quantity',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_rounded, size: 18, color: Color(0xFF475569)),
                            onPressed: () {
                              if (quantity < product.stock) {
                                setState(() => quantity++);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    if (product.stock > 0) ...[
                      // Nút Thêm vào giỏ hàng
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary, width: 1.5),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () => cartController.addToCart(
                              product,
                              quantity: quantity,
                            ),
                            icon: const Icon(Icons.add_shopping_cart_rounded, color: AppColors.primary, size: 18),
                            label: const Text(
                              'Thêm vào giỏ',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Nút Đặt hàng ngay
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () async {
                              if (!LocalStorage.isLoggedIn) {
                                Get.toNamed(AppRoutes.login);
                                return;
                              }
                              await cartController.addToCart(
                                product,
                                quantity: quantity,
                                showSnackbar: false,
                              );
                              Get.toNamed(AppRoutes.checkout);
                            },
                            icon: const Icon(Icons.bolt_rounded, color: Colors.white, size: 20),
                            label: const Text(
                              'Đặt hàng ngay',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ] else
                      // Nút Hết hàng
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF94A3B8),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: null,
                            child: const Text(
                              'Hết hàng',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET CARD HIỂN THỊ TỔNG QUAN VÀ THANH PHÂN BỔ SAO
  Widget _buildRatingSummaryCard() {
    final dist = _ratingDistribution;
    final total = _reviews.isEmpty ? 1 : _reviews.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          // Cột điểm trung bình
          Column(
            children: [
              Text(
                _averageRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
              RatingBarIndicator(
                rating: _averageRating,
                itemBuilder: (context, index) => const Icon(
                  Icons.star_rounded,
                  color: Color(0xFFF59E0B),
                ),
                itemCount: 5,
                itemSize: 16.0,
              ),
              const SizedBox(height: 4),
              Text(
                '${_reviews.length} đánh giá',
                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Container(width: 1, height: 70, color: const Color(0xFFE2E8F0)),
          const SizedBox(width: 16),

          // Các thanh progress phân bổ từ 5 sao đến 1 sao
          Expanded(
            child: Column(
              children: List.generate(5, (idx) {
                final starLevel = 5 - idx;
                final count = dist[starLevel] ?? 0;
                final ratio = count / total;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Row(
                    children: [
                      Text('$starLevel★', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: ratio,
                            minHeight: 6,
                            backgroundColor: const Color(0xFFF1F5F9),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF59E0B)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 22,
                        child: Text(
                          '$count',
                          textAlign: TextAlign.end,
                          style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET BADGE CAM KẾT SẢN PHẨM CAO CẤP HIỆN ĐẠI
  Widget _buildBadgeItem({
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
                letterSpacing: -0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET CARD GỬI ĐÁNH GIÁ TƯƠNG TÁC
  Widget _buildWriteReviewCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Viết nhận xét của bạn',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 10),

          // Rating Bar chọn sao & Label phản hồi cảm xúc
          Row(
            children: [
              RatingBar.builder(
                initialRating: _userRating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 24,
                itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star_rounded,
                  color: Color(0xFFF59E0B),
                ),
                onRatingUpdate: (rating) {
                  setState(() => _userRating = rating);
                },
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Text(
                  _getRatingText(_userRating),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB45309),
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Ô nhập phản hồi
          TextField(
            controller: _commentController,
            maxLines: 3,
            maxLength: 200,
            style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
            decoration: InputDecoration(
              hintText: 'Cảm nhận của bạn về độ tươi ngon, quy cách đóng gói, gian hàng...',
              hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.all(12),
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
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 8),

          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              ),
              onPressed: _isSubmittingReview ? null : _submitReview,
              icon: _isSubmittingReview
                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.send_rounded, size: 15),
              label: const Text('Gửi đánh giá', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET HIỂN THỊ 1 ITEM NHẬN XÉT VỚI VERIFIED BUYER & HELPFUL BUTTON
  Widget _buildReviewItemCard(ReviewModel rev) {
    final isLiked = _likedReviews.contains(rev.id);
    final likeCount = (_helpfulVotes[rev.id] ?? 0) + (isLiked ? 1 : 0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CachedNetworkImage(
                  imageUrl: rev.userAvatar,
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      rev.userName.isNotEmpty ? rev.userName[0].toUpperCase() : 'U',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          rev.userName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 10),
                              SizedBox(width: 2),
                              Text(
                                'Đã mua hàng',
                                style: TextStyle(fontSize: 9, color: AppColors.primary, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(rev.date, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                  ],
                ),
              ),
              RatingBarIndicator(
                rating: rev.rating,
                itemBuilder: (context, index) => const Icon(
                  Icons.star_rounded,
                  color: Color(0xFFF59E0B),
                ),
                itemCount: 5,
                itemSize: 14.0,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            rev.comment,
            style: const TextStyle(fontSize: 13, color: Color(0xFF334155), height: 1.5),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    if (isLiked) {
                      _likedReviews.remove(rev.id);
                    } else {
                      _likedReviews.add(rev.id);
                    }
                  });
                },
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        isLiked ? Icons.thumb_up_rounded : Icons.thumb_up_outlined,
                        size: 13,
                        color: isLiked ? AppColors.primary : const Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        likeCount > 0 ? 'Hữu ích ($likeCount)' : 'Hữu ích',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isLiked ? FontWeight.bold : FontWeight.w500,
                          color: isLiked ? AppColors.primary : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}