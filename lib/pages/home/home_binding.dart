import 'package:get/get.dart';
import 'package:admin_panel/pages/home/home.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
   Get.lazyPut(() => HomeController(), fenix: true);
  }
}
