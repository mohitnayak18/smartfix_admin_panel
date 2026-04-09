// import 'package:get/get.dart';

import 'package:get/get.dart';
import 'PartnerController.dart';

class PartnersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PartnerController());
  }
}
