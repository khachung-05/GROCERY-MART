import 'package:get/get.dart';
import '../cart/cart_controller.dart';
import 'checkout_controller.dart';

class CheckoutBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CartController>(() => CartController());
    Get.lazyPut<CheckoutController>(() => CheckoutController());
  }
}