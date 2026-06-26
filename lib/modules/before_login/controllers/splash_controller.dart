import 'package:get/get.dart';
import 'package:kaptur/core/utils/app_logger.dart';
import 'package:kaptur/data/storage/storage_service.dart';
import 'package:kaptur/routes/app_pages.dart';

class SplashController extends GetxController {
  final StorageService _storage = Get.find<StorageService>();

  @override
  void onReady() {
    super.onReady();
    LoggerUtility.info('Splash controller ready');
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 1));

    if (await _storage.hasSession) {
      LoggerUtility.info('Session restored — navigating to home');
      Get.offAllNamed(Routes.home);
    } else {
      LoggerUtility.info('No session found — navigating to login');
      Get.offAllNamed(Routes.login);
    }
  }
}
