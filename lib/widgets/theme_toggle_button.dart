import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaptur/core/utils/app_logger.dart';
import 'package:kaptur/data/storage/storage_service.dart';

/// A simple toggle button to switch between Light and Dark modes.
/// It uses GetX's built-in theme management and persists the choice.
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = Get.find<StorageService>();

    return IconButton(
      icon: Icon(
        context.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
      ),
      onPressed: () {
        if (context.isDarkMode) {
          Get.changeThemeMode(ThemeMode.light);
          LoggerUtility.info("Theme changed to light");
          storage.saveThemeMode('light');
        } else {
          Get.changeThemeMode(ThemeMode.dark);
          LoggerUtility.info("Theme changed to dark");
          storage.saveThemeMode('dark');
        }
      },
      tooltip: "Toggle Light/Dark Mode",
    );
  }
}
