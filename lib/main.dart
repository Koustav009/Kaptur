import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaptur/controllers/auth_controller.dart';
import 'routes/pages.dart';
import 'theme/app_theme.dart';

void main() {
  // 1. We put the AuthController into Get's memory so it's ready to use.
  Get.put(AuthController());

  runApp(const KapturApp());
}

class KapturApp extends StatelessWidget {
  const KapturApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. We use GetMaterialApp to enable GetX routing and features.
    return GetMaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      title: 'Fotoowl Clone',
      debugShowCheckedModeBanner: false,

      // 3. Centralized routes (from lib/routes/pages.dart)
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    );
  }
}
