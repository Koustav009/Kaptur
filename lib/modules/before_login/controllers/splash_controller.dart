import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kaptur/core/utils/app_logger.dart';
import 'package:kaptur/routes/app_pages.dart';

class SplashController extends GetxController {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final GetStorage _userStorage = GetStorage();

  @override
  void onReady() {
    LoggerUtility.info("Spalsh controller Ready");
    _checkAuth();
    super.onReady();
  }
  // @override
  // void onReady() {
  //   LoggerUtility.info("Spalsh controller Ready");
  //   super.onReady();
  // _checkAuth();
  // }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 1));

    String? token = await _secureStorage.read(key: "jwt_token");
    var userData = _userStorage.read("user_details");

    if (token != null && userData != null) {
      LoggerUtility.info('Session restored — navigating to home');
      Get.offAllNamed(Routes.home);
    } else {
      LoggerUtility.info('No session found — navigating to login');
      Get.offAllNamed(Routes.login);
    }
  }
}
