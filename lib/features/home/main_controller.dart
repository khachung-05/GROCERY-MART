import 'package:get/get.dart';
import '../order/order_controller.dart';

class MainController extends GetxController {
  static MainController get to => Get.find<MainController>();

  final RxInt currentIndex = 0.obs;

  void changeTab(int index) {
    currentIndex.value = index;
    if (index == 3 && Get.isRegistered<OrderController>()) {
      Get.find<OrderController>().loadOrders();
    }
  }
}
