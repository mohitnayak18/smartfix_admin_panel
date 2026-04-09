import 'package:get/get.dart';
import 'package:admin_panel/pages/settings_screen/setting.dart';

class SettingBinding extends Bindings {
  @override
  void dependencies() {
   Get.lazyPut(() => SettingController(), fenix: true);
  }
}
