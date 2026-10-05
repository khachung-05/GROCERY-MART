import 'package:get/get.dart';
import '../../core/storage/local_storage.dart';
import '../../core/utils/app_notification.dart';
import '../../data/datasource/mock_data.dart';
import '../../data/models/product_model.dart';

class FavoriteController extends GetxController {
  // Danh sách các ID sản phẩm yêu thích (Reactive)
  final RxList<String> favoriteIds = <String>[].obs;

  // Danh sách ProductModel tương ứng để hiển thị lên màn hình FavoriteScreen
  final RxList<ProductModel> favoriteProducts = <ProductModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadFavorites();
  }

  /// Tải danh sách ID yêu thích từ LocalStorage và lọc danh sách sản phẩm
  void loadFavorites() {
    final ids = LocalStorage.getFavoriteIds();
    favoriteIds.assignAll(ids);
    _syncFavoriteProducts();
  }

  /// Đồng bộ danh sách sản phẩm yêu thích từ MockData dựa trên favoriteIds
  void _syncFavoriteProducts() {
    final products = MockData.products
        .where((product) => favoriteIds.contains(product.id))
        .map((p) => p.copyWith(isFavorite: true))
        .toList();
    favoriteProducts.assignAll(products);
  }

  /// Kiểm tra xem sản phẩm có trong danh sách yêu thích hay không
  bool isFavorite(String productId) {
    return favoriteIds.contains(productId);
  }

  /// Thêm hoặc xóa sản phẩm khỏi danh sách yêu thích (toggle)
  Future<void> toggleFavorite(String productId) async {
    ProductModel? product;
    try {
      product = MockData.products.firstWhereOrNull((p) => p.id == productId);
    } catch (_) {}

    if (favoriteIds.contains(productId)) {
      favoriteIds.remove(productId);
      AppNotification.showFavoriteToggle(isAdded: false, product: product);
    } else {
      favoriteIds.add(productId);
      AppNotification.showFavoriteToggle(isAdded: true, product: product);
    }

    // Lưu bền vững vào SharedPreferences theo userId
    await LocalStorage.saveFavoriteIds(favoriteIds.toList());

    // Cập nhật lại danh sách sản phẩm hiển thị trên FavoriteScreen
    _syncFavoriteProducts();
  }

  /// Xóa trực tiếp sản phẩm khỏi danh sách yêu thích
  Future<void> removeFavorite(String productId) async {
    if (favoriteIds.contains(productId)) {
      favoriteIds.remove(productId);
      await LocalStorage.saveFavoriteIds(favoriteIds.toList());
      _syncFavoriteProducts();
    }
  }
}