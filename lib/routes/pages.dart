import 'package:get/get.dart';
import '../views/home_screen.dart';
import '../views/login_screen.dart';
import '../views/signup_screen.dart';

/// This file contains all the routes for the application.
/// We use a centralized route system to make navigation cleaner and easier to manage.

class Routes {
  // 1. Route names as constants to avoid typos.
  static const LOGIN = '/login';
  static const SIGNUP = '/signup';
  static const HOME = '/home';
}

class AppPages {
  // 2. The initial route when the app starts.
  static const INITIAL = Routes.LOGIN;

  // 3. The list of all pages and their corresponding screens.
  static final routes = [
    GetPage(
      name: Routes.LOGIN,
      page: () => LoginScreen(),
      transition: Transition.fadeIn, // Optional: smooth transition between screens.
    ),
    GetPage(
      name: Routes.SIGNUP,
      page: () => SignupScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.HOME,
      page: () => HomeScreen(),
      transition: Transition.zoom,
    ),
  ];
}
