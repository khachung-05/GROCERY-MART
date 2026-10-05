import 'package:get/get.dart';
import '../../core/constants/app_routes.dart';
import '../../core/storage/local_storage.dart';
import '../../core/utils/app_notification.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/cart_repository.dart';

class CartController extends GetxController {
  final CartRepository _cartRepo = CartRepository();

  // Danh sách giỏ hàng phản ứng (Reactive)
  final RxList<CartItemModel> cartItems = <CartItemModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadCart();
  }

  /// Nạp danh sách giỏ hàng từ LocalStorage/Repository
  void loadCart() {
    final list = _cartRepo.loadCart();
    cartItems.assignAll(list);
  }

  // --- GETTERS TÍNH TOÁN GIỎ HÀNG ---

  /// Tổng số lượng từng món trong giỏ hàng
  int get totalItems => cartItems.fold(0, (sum, i) => sum + i.quantity);

  /// Tiền hàng chưa tính phí vận chuyển
  double get subtotal => cartItems.fold(0.0, (sum, i) => sum + i.total);

  /// Phí vận chuyển mặc định (nếu giỏ trống thì 0đ)
  double get shippingFee => cartItems.isEmpty ? 0.0 : LocalStorage.storeShippingFee;

  /// Giảm giá khuyến mãi
  double get discount => 0.0;

  /// Tổng tiền thanh toán cuối cùng
  double get total => subtotal + shippingFee - discount;

  // --- GETTERS ALIAS ĐỒNG BỘ CÁC MÀN HÌNH KHÁC ---

  /// Trả về danh sách giỏ hàng cho MainScreen và CheckoutController
  List<CartItemModel> get items => cartItems;

  /// Tương thích cả totalPrice và totalAmount
  double get totalPrice => subtotal;
  double get totalAmount => subtotal;

  // --- CÁC HÀM NGHIỆP VỤ GIỎ HÀNG ---

  /// Thêm sản phẩm vào giỏ hàng
  Future<void> addToCart(ProductModel product, {int quantity = 1, bool showSnackbar = true}) async {
    // 1. Bắt buộc đăng nhập trước khi thao tác
    if (!LocalStorage.isLoggedIn) {
      Get.toNamed(AppRoutes.login);
      return;
    }

    // 2. Lưu vào giỏ qua Repository
    final updatedList = await _cartRepo.addToCart(product, quantity);
    cartItems.assignAll(updatedList);

    if (showSnackbar) {
      AppNotification.showAddToCartSuccess(product, quantity);
    }
  }

  /// Tăng số lượng sản phẩm (Kiểm tra giới hạn tồn kho stock)
  Future<void> increaseQuantity(CartItemModel item) async {
    if (item.quantity >= item.stock) {
      AppNotification.showWarning(
        title: 'Giới hạn tồn kho',
        message: 'Đã đạt giới hạn số lượng sản phẩm có sẵn trong kho!',
      );
      return;
    }
    final updatedList = await _cartRepo.updateQuantity(item.id, item.quantity + 1);
    cartItems.assignAll(updatedList);
  }

  /// Giảm số lượng sản phẩm
  Future<void> decreaseQuantity(CartItemModel item) async {
    if (item.quantity > 1) {
      final updatedList = await _cartRepo.updateQuantity(item.id, item.quantity - 1);
      cartItems.assignAll(updatedList);
    } else {
      // Nếu số lượng về 1 mà giảm tiếp thì xóa khỏi giỏ
      await removeItem(item.id);
    }
  }

  /// Xóa hẳn một món hàng ra khỏi giỏ
  Future<void> removeItem(String cartItemId) async {
    final updatedList = await _cartRepo.removeFromCart(cartItemId);
    cartItems.assignAll(updatedList);
  }

  /// Làm sạch toàn bộ giỏ hàng
  Future<void> clearCart() async {
    await _cartRepo.clearCart();
    cartItems.clear();
  }
}