import 'package:get/get.dart';
import '../../core/storage/local_storage.dart';
import '../../data/models/category_model.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';

class HomeController extends GetxController {
  final ProductRepository _productRepo = ProductRepository();

  // Dữ liệu hiển thị trang chủ (Reactive)
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxList<ProductModel> flashSaleProducts = <ProductModel>[].obs;
  final RxList<ProductModel> featuredProducts = <ProductModel>[].obs;

  // Tên người dùng chào mừng trên AppBar
  final RxString userName = 'Khách hàng'.obs;

  @override
  void onInit() {
    super.onInit();
    loadHomeData();
  }

  /// Tải dữ liệu hiển thị trang chủ từ ProductRepository và LocalStorage
  Future<void> loadHomeData() async {
    // 1. Lấy tên người dùng đăng nhập (nếu có)
    if (LocalStorage.isLoggedIn) {
      final info = LocalStorage.getUserInfo();
      final name = info['name'];
      if (name != null && name.isNotEmpty) {
        final parts = name.trim().split(' ');
        userName.value = parts.isNotEmpty ? parts.last : name;
      }
    } else {
      userName.value = 'Khách hàng';
    }

    // 2. Nạp danh mục thực phẩm từ API
    final allCategories = await _productRepo.getCategories();
    categories.assignAll(allCategories);

    // 3. Nạp danh sách sản phẩm trực tiếp từ API
    final allProducts = await _productRepo.getProducts();

    // Sản phẩm Flash Sale có giá khuyến mãi (originalPrice != null)
    flashSaleProducts.assignAll(
      allProducts.where((p) => p.originalPrice != null).toList(),
    );

    // Sản phẩm nổi bật
    featuredProducts.assignAll(allProducts);
  }

  /// Làm mới lại dữ liệu khi người dùng kéo tải lại (Pull to Refresh)
  Future<void> refreshHome() async {
    await loadHomeData();
  }
}
