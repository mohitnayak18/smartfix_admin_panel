import 'package:admin_panel/pages/price_details/price_details_controller.dart';
import 'package:get/get.dart';

class PriceDetailsBinding extends Bindings {
  @override
  void dependencies() {
   Get.lazyPut(() => PriceDetailsController(), fenix: true);
  }
}
