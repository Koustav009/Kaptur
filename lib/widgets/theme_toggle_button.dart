import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// A simple toggle button to switch between Light and Dark modes.
/// It uses GetX's built-in theme management.
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      // We use Get.isDarkMode to determine which icon to show.
      // Note: Get.isDarkMode might need a rebuild to update correctly if not using Obx.
      // However, Get.changeThemeMode handles the global state.
      icon: Icon(
        Get.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
      ),
      onPressed: () {
        // Toggle the theme mode
        if (Get.isDarkMode) {
          Get.changeThemeMode(ThemeMode.light);
        } else {
          Get.changeThemeMode(ThemeMode.dark);
        }
      },
      tooltip: "Toggle Light/Dark Mode",
    );
  }
}
