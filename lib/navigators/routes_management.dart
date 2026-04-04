
import 'package:get/get.dart';
import 'package:admin_panel/navigators/navigators.dart';

class RouteManagement {
  /// Go to the splash screen.
  static void goToHome() {
    Get.offNamed<void>(Routes.home);
  }

  /// Go to the onboarding screen.
  static void goOffAllboarding() {
    Get.offAllNamed<void>(Routes.onboarding);
  }

  /// Go off all Home Screen
  static void goOffAllHomScreen() {
    Get.offAllNamed<void>(Routes.home);
  }

  /// Go to the login screen.
  static void goToLogin() {
    Get.offAllNamed<void>(Routes.login);
  }
  
  /// Go to the otp screen.
   static void goToCartScreen() {
    Get.toNamed<void>(Routes.cart);
   }
}
