import 'package:flutter/material.dart';
import 'package:fotoowlclone/controllers/auth_controller.dart';
import 'package:get/get.dart';

/// The Screen where users can create a new account.
class SignupScreen extends StatelessWidget {
  final AuthController _authController = Get.find<AuthController>();

  // Text fields for user input.
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Create your Account",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Full Name"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 32),
            
            // Re-use our reactive AuthController state.
            Obx(() => _authController.isLoading.value
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _authController.register(
                          nameController.text.trim(),
                          emailController.text.trim(),
                          passwordController.text.trim(),
                        );
                      },
                      child: const Text("Register"),
                    ),
                  )),
            
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Get.back(), // Go back to Login screen.
              child: const Text("Already have an account? Login"),
            ),
          ],
        ),
      ),
    );
  }
}
