import 'package:flutter/material.dart';
import 'package:fotoowlclone/controllers/auth_controller.dart';
import 'package:get/get.dart';

/// The Screen where users can log in with email/password or Google.
class LoginScreen extends StatelessWidget {
  // We use Get.find to get our AuthController instance.
  final AuthController _authController = Get.find<AuthController>();

  // Controllers for the text input fields.
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Welcome to Fotoowl",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true, // Hides the password
            ),
            const SizedBox(height: 32),
            
            // Obx makes the button reactive. It listens to isLoading variable.
            Obx(() => _authController.isLoading.value
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _authController.login(
                          emailController.text.trim(),
                          passwordController.text.trim(),
                        );
                      },
                      child: const Text("Login"),
                    ),
                  )),
            
            const SizedBox(height: 16),
            const Text("OR"),
            const SizedBox(height: 16),
            
            // Google Login Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.login),
                label: const Text("Sign in with Google"),
                onPressed: () => _authController.signInWithGoogle(),
              ),
            ),
            
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Get.toNamed('/signup'),
              child: const Text("Don't have an account? Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}
