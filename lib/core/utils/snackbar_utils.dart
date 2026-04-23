import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// A utility class to show consistent and themed Snackbars across the app.
/// It uses GetX's snackbar but adds a layer of custom styling.
class AppSnackbar {
  /// Shows a success snackbar with a green-ish theme.
  static void success({required String title, required String message}) {
    _showSnackbar(
      title: title,
      message: message,
      backgroundColor: Colors.green.withOpacity(0.9),
      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
      textColor: Colors.white,
    );
  }

  /// Shows an error snackbar with the theme's error color.
  static void error({required String title, required String message}) {
    _showSnackbar(
      title: title,
      message: message,
      backgroundColor: Get.theme.colorScheme.error.withOpacity(0.9),
      icon: const Icon(Icons.error_outline, color: Colors.white),
      textColor: Colors.white,
    );
  }

  /// Shows an info snackbar with the theme's primary color.
  static void info({required String title, required String message}) {
    _showSnackbar(
      title: title,
      message: message,
      backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.9),
      icon: Icon(Icons.info_outline, color: Get.theme.colorScheme.onPrimary),
      textColor: Get.theme.colorScheme.onPrimary,
    );
  }

  /// Internal helper to configure the snackbar.
  /// This ensures all snackbars have the same rounded corners, margins, and behavior.
  static void _showSnackbar({
    required String title,
    required String message,
    required Color backgroundColor,
    required Icon icon,
    required Color textColor,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: backgroundColor,
      colorText: textColor,
      icon: icon,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
      // Theming: Ensuring it looks good on both light and dark mode
      // by using the provided background and text colors.
      overlayBlur: 0.5,
    );
  }
}
