import 'dart:convert';
import '../../core/storage/local_storage.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';

class CartRepository {
  /// Đọc danh sách giỏ hàng từ LocalStorage
  List<CartItemModel> loadCart() {
    final cartJson = LocalStorage.getCartItems();
    if (cartJson == null || cartJson.isEmpty) return [];

    try {
      final List<dynamic> decoded = jsonDecode(cartJson);
      return decoded.map((item) => CartItemModel.fromJson(item)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Lưu danh sách giỏ hàng xuống LocalStorage
  Future<void> saveCart(List<CartItemModel> items) async {
    final encoded = jsonEncode(items.map((e) => e.toJson()).toList());
    await LocalStorage.saveCartItems(encoded);
  }

  /// Thêm sản phẩm vào giỏ hàng hoặc cộng dồn số lượng
  Future<List<CartItemModel>> addToCart(ProductModel product, int quantity) async {
    final cartList = loadCart();
    final index = cartList.indexWhere((item) => item.productId == product.id);

    if (index != -1) {
      final existingItem = cartList[index];
      final newQty = existingItem.quantity + quantity;
      final finalQty = newQty > product.stock ? product.stock : newQty;
      cartList[index] = existingItem.copyWith(quantity: finalQty);
    } else {
      final newItem = CartItemModel(
        id: 'cart_${DateTime.now().millisecondsSinceEpoch}',
        productId: product.id,
        productName: product.name,
        productImage: product.image,
        price: product.price,
        quantity: quantity > product.stock ? product.stock : quantity,
        unit: product.unit,
        categoryId: product.categoryId,
        stock: product.stock,
      );
      cartList.add(newItem);
    }

    await saveCart(cartList);
    return cartList;
  }

  /// Cập nhật số lượng mặt hàng
  Future<List<CartItemModel>> updateQuantity(String cartItemId, int newQuantity) async {
    final cartList = loadCart();
    final index = cartList.indexWhere((item) => item.id == cartItemId);

    if (index != -1) {
      if (newQuantity <= 0) {
        cartList.removeAt(index);
      } else {
        final current = cartList[index];
        final cappedQty = newQuantity > current.stock ? current.stock : newQuantity;
        cartList[index] = current.copyWith(quantity: cappedQty);
      }
      await saveCart(cartList);
    }

    return cartList;
  }

  /// Xóa sản phẩm khỏi giỏ
  Future<List<CartItemModel>> removeFromCart(String cartItemId) async {
    final cartList = loadCart();
    cartList.removeWhere((item) => item.id == cartItemId);
    await saveCart(cartList);
    return cartList;
  }

  /// Làm rỗng toàn bộ giỏ hàng
  Future<void> clearCart() async {
    await LocalStorage.clearCartItems();
  }
}