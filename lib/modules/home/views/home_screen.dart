import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kaptur/modules/auth/controllers/auth_controller.dart';
import 'package:kaptur/widgets/theme_toggle_button.dart';

/// The Screen users see AFTER a successful login.
class HomeScreen extends StatelessWidget {
  final AuthController _authController = Get.find<AuthController>();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fotoowl Home"),
        actions: [
          const ThemeToggleButton(),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _authController.logout(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 100, color: Colors.green),
            const SizedBox(height: 24),
            const Text(
              "Successfully Logged In!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text("Welcome to your photo management dashboard."),
            const SizedBox(height: 32),
            // Show the token (or first few characters) as proof.
            Obx(
              () => Text(
                "JWT Token: ${_authController.userToken.value.substring(0, 10)}...",
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () {
                Clipboard.setData(
                  ClipboardData(text: _authController.userToken.value),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

