import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kaptur/core/utils/app_logger.dart';
import 'package:kaptur/routes/app_pages.dart';
import 'package:kaptur/data/services/auth_service.dart';
import 'package:kaptur/core/utils/snackbar_utils.dart';
import 'package:kaptur/data/models/users.dart';

/// AuthController manages the state of the user's login.
class AuthController extends GetxController {
  // Storage Tools
  final AuthService _authService = AuthService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final GetStorage _userStorage = GetStorage();
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  // Reactive variables
  var isLoading = false.obs;
  var isLoggedIn = false.obs;
  var userToken = "".obs;
  var currentUser = Rxn<User>();

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  /// Restores user session from storage (called by AuthBinding on login screen).
  void checkLoginStatus() async {
    String? token = await _secureStorage.read(key: "jwt_token");
    var userData = _userStorage.read("user_details");

    if (token != null && userData != null) {
      userToken.value = token;
      currentUser.value = User.fromJson(userData);
      isLoggedIn.value = true;
      LoggerUtility.debug(
        'Session restored for: ${currentUser.value?.email ?? "unknown"}',
      );
    }
  }

  /// Handles standard Email/Password Login.
  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      LoggerUtility.info('Attempting login for: $email');
      var response = await _authService.login(email, password);

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        String token = data['accessToken'];

        // Save token securely
        await _secureStorage.write(key: "jwt_token", value: token);
        userToken.value = token;

        // Save user details non-securely (for persistence)
        if (data['user'] != null) {
          User user = User.fromJson(data['user']);
          _userStorage.write("user_details", user.toJson());
          currentUser.value = user;
        }

        isLoggedIn.value = true;
        LoggerUtility.info('Login successful for: $email');
        AppSnackbar.success(title: "Success", message: "Login Successful!");
        Get.offAllNamed(Routes.home);
      } else {
        LoggerUtility.warning(
          'Login failed for: $email — status: ${response.statusCode}',
        );
        AppSnackbar.error(title: "Error", message: "Invalid credentials.");
      }
    } catch (e, st) {
      LoggerUtility.error('Login error for: $email', e, st);
      AppSnackbar.error(title: "Error", message: "Login failed.");
    } finally {
      isLoading.value = false;
    }
  }

  /// Handles Email/Password Registration.
  Future<void> register(String name, String email, String password) async {
    try {
      isLoading.value = true;
      LoggerUtility.info('Attempting registration for: $email');
      var response = await _authService.register(name, email, password);

      if (response.statusCode == HttpStatus.created) {
        LoggerUtility.info('Registration successful for: $email');
        AppSnackbar.success(title: "Success", message: "Account created!");
        Get.toNamed(Routes.login);
      } else {
        LoggerUtility.warning(
          'Registration failed for: $email — status: ${response.statusCode}',
        );
        AppSnackbar.error(title: "Error", message: response.body);
      }
    } catch (e, st) {
      LoggerUtility.error('Registration error for: $email', e, st);
      AppSnackbar.error(title: "Error", message: "Could not create account.");
    } finally {
      isLoading.value = false;
    }
  }

  /// Handles Native Google Sign In.
  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      LoggerUtility.info('Attempting Google sign-in');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser != null) {
        var response = await _authService.googleLogin(
          name: googleUser.displayName ?? "",
          email: googleUser.email,
          id: googleUser.id,
          photoUrl: googleUser.photoUrl,
        );

        if (response.statusCode == 200) {
          var data = jsonDecode(response.body);
          String token = data['accessToken'];

          await _secureStorage.write(key: "jwt_token", value: token);
          userToken.value = token;

          if (data['user'] != null) {
            User user = User.fromJson(data['user']);
            _userStorage.write("user_details", user.toJson());
            currentUser.value = user;
          }

          isLoggedIn.value = true;
          LoggerUtility.info(
            'Google login successful for: ${googleUser.email}',
          );
          AppSnackbar.success(
            title: "Success",
            message: "Google Login Successful!",
          );
          Get.offAllNamed(Routes.home);
        } else {
          LoggerUtility.warning(
            'Google backend auth failed — status: ${response.statusCode}',
          );
        }
      } else {
        LoggerUtility.debug('Google sign-in cancelled by user');
      }
    } catch (e, st) {
      LoggerUtility.error('Google sign-in error', e, st);
      AppSnackbar.error(title: "Error", message: "Google Sign In failed.");
    } finally {
      isLoading.value = false;
    }
  }

  /// Logs the user out.
  void logout() async {
    LoggerUtility.info(
      'Logging out user: ${currentUser.value?.email ?? "unknown"}',
    );
    await _secureStorage.delete(key: "jwt_token");
    await _userStorage.remove("user_details");
    await _googleSignIn.signOut();
    userToken.value = "";
    currentUser.value = null;
    isLoggedIn.value = false;
    Get.offAllNamed(Routes.login);
  }
}
