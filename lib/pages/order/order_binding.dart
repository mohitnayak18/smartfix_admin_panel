import 'package:get/get.dart';

import 'package:admin_panel/pages/order/order_controller.dart';

class OrderBinding extends Bindings {
  @override
  void dependencies() {
    // Get.lazyPut(() => AuthController());
    Get.lazyPut(() => OrderController());
  }
}
