import 'package:get/get.dart';
import '../cart/cart_controller.dart';
import '../favorite/favorite_controller.dart';

class ProductBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CartController>(() => CartController());
    Get.lazyPut<FavoriteController>(() => FavoriteController());
  }
}