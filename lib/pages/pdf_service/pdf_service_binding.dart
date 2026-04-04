import 'package:get/get.dart';

import 'package:admin_panel/pages/pdf_service/pdf_service_controller.dart';

class OrderBinding extends Bindings {
  @override
  void dependencies() {
    // Get.lazyPut(() => AuthController());
    Get.lazyPut(() => Pdf_Service_Controller());
  }
}
