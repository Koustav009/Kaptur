import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

/// Bindings are used to initialize controllers when a route is called.
/// This helps in memory management as controllers are only in memory when needed.
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // We use fenix: true so the controller is recreated if it was deleted.
    Get.lazyPut<AuthController>(() => AuthController(), fenix: true);
  }
}
