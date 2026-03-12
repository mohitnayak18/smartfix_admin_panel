import 'package:admin_panel/pages/banners/banners_controller.dart';
import 'package:get/get.dart';


class BrandsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => BannersController());
  }
}
