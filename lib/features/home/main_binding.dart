import 'package:get/get.dart';
import '../auth/auth_controller.dart';
import '../cart/cart_controller.dart';
import '../favorite/favorite_controller.dart';
import '../notification/notification_controller.dart';
import '../order/order_controller.dart';
import 'home_controller.dart';
import 'main_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainController>(() => MainController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<CartController>(() => CartController());
    Get.lazyPut<FavoriteController>(() => FavoriteController());
    Get.lazyPut<OrderController>(() => OrderController());
    Get.lazyPut<AuthController>(() => AuthController());
    Get.lazyPut<NotificationController>(() => NotificationController());
  }
}