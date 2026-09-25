import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kaptur/core/config/app_config.dart';
import 'package:kaptur/core/utils/app_logger.dart';
import 'package:kaptur/data/storage/storage_keys.dart';
import 'package:kaptur/data/storage/storage_service.dart';

import 'core/theme/app_theme.dart';
import 'routes/app_pages.dart';

/// Shared app bootstrap used by the flavor entrypoints
/// (`main_dev.dart` / `main_prod.dart`). Never call this directly —
/// run the app with `flutter run --flavor dev -t lib/main_dev.dart`.
Future<void> bootstrap(AppFlavor flavor) async {
  // Ensure Flutter is initialized before using plugins.
  WidgetsFlutterBinding.ensureInitialized();

  AppConfig.setFlavor(flavor);
  LoggerUtility.info(
      "Starting Kaptur flavor: ${flavor.name}, baseUrl: ${AppConfig.baseUrl}");

  // Initialize GetStorage
  await GetStorage.init(StorageKey.kaptur.name);

  // Register global storage service
  Get.put<StorageService>(StorageService());

  runApp(const KapturApp());
}

/// Default entrypoint (dev flavor) so `flutter run` without -t still works.
/// Prefer the explicit flavor entrypoints for real runs.
void main() => bootstrap(AppFlavor.dev);

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
      title: AppConfig.appTitle,
      debugShowCheckedModeBanner: false,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    );
  }
}
