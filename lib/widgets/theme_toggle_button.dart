import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// A simple toggle button to switch between Light and Dark modes.
/// It uses GetX's built-in theme management.
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        context.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
      ),
      onPressed: () {
        // Toggle the theme mode
        if (context.isDarkMode) {
          Get.changeThemeMode(ThemeMode.light);
        } else {
          Get.changeThemeMode(ThemeMode.dark);
        }
      },
      tooltip: "Toggle Light/Dark Mode",
    );
  }
}
