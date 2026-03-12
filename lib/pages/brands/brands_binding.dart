import 'package:get/get.dart';
import 'package:admin_panel/pages/brands/brands_controller.dart';

class BrandsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BrandController());
  }
}
