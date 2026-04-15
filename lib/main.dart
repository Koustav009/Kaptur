import 'package:flutter/material.dart';
import 'package:fotoowlclone/controllers/auth_controller.dart';
import 'package:fotoowlclone/views/home_screen.dart';
import 'package:fotoowlclone/views/login_screen.dart';
import 'package:fotoowlclone/views/signup_screen.dart';
import 'package:get/get.dart';

void main() {
  // 1. We put the AuthController into Get's memory so it's ready to use.
  Get.put(AuthController());
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. We use GetMaterialApp to enable GetX routing and features.
    return GetMaterialApp(
      title: 'Fotoowl Clone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true, // Use modern Material 3 design.
      ),
      // 3. Define the routes (URLs) for our screens.
      initialRoute: '/login',
      getPages: [
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/signup', page: () => SignupScreen()),
        GetPage(name: '/home', page: () => HomeScreen()),
      ],
    );
  }
}
