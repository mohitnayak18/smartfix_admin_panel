import 'package:admin_panel/pages/term_condiontions/term_controller.dart';
import 'package:get/get.dart';

class TermBinding extends Bindings {
  @override
  void dependencies() {
   Get.lazyPut(() => TermController(), fenix: true);
  }
}
