import 'package:admin_panel/pages/home/home.dart';
import 'package:admin_panel/pages/pages.dart';
import 'package:get/get.dart';

part 'app_routes.dart';

class AppPages {
  static final transitionDuration = const Duration(milliseconds: 350);

  static const initial = Routes.login;

  static final pages = [
    GetPage(
      name: _Paths.login,
      transitionDuration: transitionDuration,
      page: () => LoginView(),
      binding: LoginBinding(),
      transition: Transition.rightToLeft,
    ),
   
    GetPage(
      name: _Paths.home,
      transitionDuration: transitionDuration,
      page: () =>  AdminHomeScreen(),
      binding: HomeBinding(),
      transition: Transition.rightToLeft,
    ),
  ];
}
