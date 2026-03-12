import 'package:get/get.dart';
import 'package:admin_panel/pages/auth/auth.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthController());
  }
}
