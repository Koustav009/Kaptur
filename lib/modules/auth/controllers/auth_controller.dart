import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kaptur/routes/app_pages.dart';
import 'package:kaptur/data/services/auth_service.dart';
import 'package:kaptur/core/utils/snackbar_utils.dart';

/// AuthController manages the state of the user's login.
/// It uses 'GetxController' so we can access it from anywhere in the app.
class AuthController extends GetxController {
  // Tools we need
  final AuthService _authService = AuthService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  // Reactive variables (obs) - when these change, the UI updates automatically!
  var isLoading = false.obs;
  var isLoggedIn = false.obs;
  var userToken = "".obs;

  @override
  void onInit() {
    super.onInit();
    // Check if the user is already logged in when the app starts.
    checkLoginStatus();
  }

  /// Checks if a token exists in the secure storage.
  void checkLoginStatus() async {
    String? token = await _storage.read(key: "jwt_token");
    if (token != null) {
      userToken.value = token;
      isLoggedIn.value = true;
    }
  }

  /// Handles standard Email/Password Login.
  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      var response = await _authService.login(email, password);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        String token = data['accessToken'];

        // Save token securely and update state.
        await _storage.write(key: "jwt_token", value: token);
        userToken.value = token;
        isLoggedIn.value = true;

        AppSnackbar.success(title: "Success", message: "Login Successful!");
        Get.offAllNamed(
          Routes.home,
        ); // Go to Home and remove all previous screens.
      } else {
        AppSnackbar.error(
          title: "Error",
          message: "Invalid credentials. Please try again.",
        );
      }
    } catch (e) {
      AppSnackbar.error(
        title: "Error",
        message: "Something went wrong. Please check your connection.",
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Handles Email/Password Registration.
  Future<void> register(String name, String email, String password) async {
    try {
      isLoading.value = true;
      var response = await _authService.register(name, email, password);

      if (response.statusCode == 200) {
        AppSnackbar.success(
          title: "Success",
          message: "Account created! Please login.",
        );
        Get.toNamed(Routes.login);
      } else {
        AppSnackbar.error(title: "Error", message: response.body);
      }
    } catch (e) {
      AppSnackbar.error(title: "Error", message: "Could not create account.");
    } finally {
      isLoading.value = false;
    }
  }

  /// Handles Native Google Sign In.
  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      // 1. Trigger Google Sign In flow on the phone.
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser != null) {
        // 2. Send the user's Google info to our backend.
        var response = await _authService.googleLogin(
          name: googleUser.displayName ?? "",
          email: googleUser.email,
          id: googleUser.id,
          photoUrl: googleUser.photoUrl,
        );

        if (response.statusCode == 200) {
          var data = jsonDecode(response.body);
          String token = data['accessToken'];

          await _storage.write(key: "jwt_token", value: token);
          userToken.value = token;
          isLoggedIn.value = true;

          AppSnackbar.success(
            title: "Success",
            message: "Google Login Successful!",
          );
          Get.offAllNamed(Routes.home);
        }
      }
    } catch (e) {
      AppSnackbar.error(title: "Error", message: "Google Sign In failed.");
    } finally {
      isLoading.value = false;
    }
  }

  /// Logs the user out.
  void logout() async {
    await _storage.delete(key: "jwt_token");
    await _googleSignIn.signOut();
    userToken.value = "";
    isLoggedIn.value = false;
    Get.offAllNamed(Routes.login);
  }
}

