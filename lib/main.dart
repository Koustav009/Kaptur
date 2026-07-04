import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kaptur/core/utils/app_logger.dart';
import 'package:kaptur/data/storage/storage_keys.dart';
import 'package:kaptur/data/storage/storage_service.dart';

import 'core/theme/app_theme.dart';
import 'routes/app_pages.dart';

void main() async {
  // Ensure Flutter is initialized before using plugins.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize GetStorage
  await GetStorage.init(StorageKey.kaptur.name);

  // Register global storage service
  Get.put<StorageService>(StorageService());

  runApp(const KapturApp());
}

class KapturApp extends StatelessWidget {
  const KapturApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = Get.find<StorageService>();
    final String? savedTheme = storage.getThemeMode();

    ThemeMode themeMode;
    LoggerUtility.info("Saved theme: $savedTheme");
    switch (savedTheme) {
      case 'light':
        themeMode = ThemeMode.light;
        break;
      case 'dark':
        themeMode = ThemeMode.dark;
        break;
      default:
        themeMode = ThemeMode.system;
    }

    return GetMaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      title: 'Kaptur',
      debugShowCheckedModeBanner: false,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    );
  }
}
