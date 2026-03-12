import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:admin_panel/utils/utils.dart';

import 'api_calls/services/services.dart';
import 'navigators/navigators.dart';
import 'theme/app_theme.dart';

//Get.put(BannerController());

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyAOa06woA99QEUgrL1SGmGj43tNobuqpYA",
        appId: "1:447654304394:web:16561aae38fc6b1b7dab73",
        messagingSenderId: "447654304394",
        projectId: "smartfixapp-18342",
      ),
    );
    //    Get.put(BannerRepository(), permanent: true);
    // Get.put(BannerController(), permanent: true);

    await initializeServices();

    runApp(const MyApp());
  } catch (error) {
    Utility.printELog('❌ Firebase initialization failed: $error');
  }
}

Future<void> initializeServices() async {
  Get.put(CommonService(), permanent: true);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarBrightness: Brightness.dark),
    );

    return ScreenUtilInit(
      designSize: const Size(1440, 1024),
      builder: (ctx, _) => GetMaterialApp(
        locale: const Locale('en'),
        title: 'SmartFix App',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.light,
        getPages: AppPages.pages,
        translations: TranslationFile(),
        initialRoute: AppPages.initial,
        theme: themeData(context),
        enableLog: true,
      ),
    );
  }
}
