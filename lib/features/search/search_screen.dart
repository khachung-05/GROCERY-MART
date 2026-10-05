import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_routes.dart';
import '../../core/storage/local_storage.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';
import '../../shared/widgets/product_card.dart';
import '../cart/cart_controller.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ProductRepository _productRepo = ProductRepository();
  final CartController _cartController = Get.find<CartController>();

  List<ProductModel> _searchResults = [];
  List<String> _recentSearches = [];
  bool _isSearching = false;

  // Danh sách từ khóa phổ biến (Hình 3.11)
  final List<String> _popularKeywords = [
    'Táo',
    'Chuối',
    'Cam',
    'Cà rốt',
    'Bông cải',
    'Cá hồi',
    'Sữa',
    'Trứng',
    'Bánh mì',
    'Tôm'
  ];

  @override
  void initState() {
    super.initState();
    _loadRecentSearches();
  }

  void _loadRecentSearches() {
    setState(() {
      _recentSearches = LocalStorage.recentSearches;
    });
  }

  void _onSearchChanged(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults.clear();
      });
      return;
    }

    _productRepo.searchProducts(query).then((results) {
      if (mounted) {
        setState(() {
          _isSearching = true;
          _searchResults = results;
        });
      }
    });
  }

  void _submitSearch(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return;

    // Lưu từ khóa vào lịch sử tìm kiếm gần đây[cite: 1]
    final searches = List<String>.from(_recentSearches);
    searches.remove(cleanQuery);
    searches.insert(0, cleanQuery);
    if (searches.length > 10) searches.removeLast();

    await LocalStorage.saveRecentSearches(searches);
    _loadRecentSearches();
  }

  void _selectKeyword(String keyword) {
    _searchController.text = keyword;
    _onSearchChanged(keyword);
    _submitSearch(keyword);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.black),
                onPressed: () => Get.back(),
              ),
              Expanded(
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F3F5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    onChanged: _onSearchChanged,
                    onSubmitted: _submitSearch,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm sản phẩm...',
                      hintStyle:
                          const TextStyle(fontSize: 14, color: AppColors.grey),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close,
                                  size: 18, color: AppColors.grey),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                            )
                          : null,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    const Icon(Icons.tune, size: 18, color: AppColors.primary),
              ),
              TextButton(
                onPressed: () => Get.back(),
                child: const Text(
                  'Hủy',
                  style: TextStyle(color: AppColors.black, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
      body: _isSearching
          ? _searchResults.isEmpty
              ? const Center(
                  child: Text(
                    'Không tìm thấy sản phẩm phù hợp',
                    style: TextStyle(color: AppColors.grey, fontSize: 15),
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final product = _searchResults[index];
                    return ProductCard(
                      product: product,
                      onTap: () => Get.toNamed(
                        AppRoutes.productDetail,
                        arguments: product,
                      ),
                      onAddToCart: () => _cartController.addToCart(product),
                    );
                  },
                )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Tìm kiếm phổ biến (Hình 3.11)[cite: 1]
                  const Row(
                    children: [
                      Text(
                        '🔥 Tìm kiếm phổ biến',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 10,
                    children: _popularKeywords.map((keyword) {
                      return GestureDetector(
                        onTap: () => _selectKeyword(keyword),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Text(
                            keyword,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.black,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 28),

                  // 2. Lịch sử tìm kiếm gần đây (nếu có)[cite: 1]
                  if (_recentSearches.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tìm kiếm gần đây',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            await LocalStorage.clearRecentSearches();
                            _loadRecentSearches();
                          },
                          child: const Text(
                            'Xóa tất cả',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 10,
                      children: _recentSearches.map((keyword) {
                        return GestureDetector(
                          onTap: () => _selectKeyword(keyword),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.history,
                                    size: 16, color: AppColors.grey),
                                const SizedBox(width: 6),
                                Text(
                                  keyword,
                                  style: const TextStyle(
                                      fontSize: 13, color: AppColors.black),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
