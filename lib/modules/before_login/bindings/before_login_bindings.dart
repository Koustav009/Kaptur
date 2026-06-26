import 'package:get/get.dart';
import '../controllers/splash_controller.dart';

class BeforeLoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<SplashController>(SplashController());
  }
}
