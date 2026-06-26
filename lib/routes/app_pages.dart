import 'package:get/get.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/login_screen.dart';
import '../modules/auth/views/signup_screen.dart';
import '../modules/before_login/bindings/before_login_bindings.dart';
import '../modules/before_login/views/splash_screen.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_screen.dart';

part 'app_routes.dart';

class AppPages {
  static const initial = Routes.splash;

  static final routes = [
    GetPage(
      name: _Paths.splash,
      page: () => const SplashScreen(),
      binding: BeforeLoginBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.login,
      page: () => LoginScreen(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.signup,
      page: () => SignupScreen(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: _Paths.home,
      page: () => HomeScreen(),
      binding: HomeBinding(),
      transition: Transition.zoom,
    ),
  ];
}
