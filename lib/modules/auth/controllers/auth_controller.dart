import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kaptur/core/utils/app_logger.dart';
import 'package:kaptur/core/utils/snackbar_utils.dart';
import 'package:kaptur/data/models/user.dart';
import 'package:kaptur/data/services/auth_service.dart';
import 'package:kaptur/data/storage/storage_service.dart';
import 'package:kaptur/routes/app_pages.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final StorageService _storage = Get.find<StorageService>();

  // Google Sign-In v7+ Singleton
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool _isGoogleInitialized = false;

  // Reactive State
  var isLoading = false.obs;
  var isLoggedIn = false.obs;
  var userToken = "".obs;
  var currentUser = Rxn<User>();

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  /// Initialize Google Sign-In (call once)
  Future<void> initializeGoogleSignIn() async {
    if (_isGoogleInitialized) return;

    try {
      await _googleSignIn.initialize(
        serverClientId:
            '571822273181-29n1ssccnpenv47ee4lvrjt0op70tf32.apps.googleusercontent.com',
      );
      _isGoogleInitialized = true;
      LoggerUtility.info("GoogleSignIn v7 initialized successfully");
    } catch (e) {
      LoggerUtility.error("GoogleSignIn initialize failed", e);
      rethrow;
    }
  }

  /// Restore session from storage
  void checkLoginStatus() async {
    final token = await _storage.getToken();
    final user = _storage.getUser();

    if (token != null && user != null) {
      userToken.value = token;
      currentUser.value = user;
      isLoggedIn.value = true;
      LoggerUtility.debug('Session restored for: ${user.email}');
    }
  }

  // ==================== EMAIL/PASSWORD AUTH ====================

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;

      final response = await _authService.login(email, password);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String token = data['accessToken'];

        await _storage.saveToken(token);
        userToken.value = token;

        if (data['user'] != null) {
          final User user = User.fromJson(data['user']);
          await _storage.saveUser(user);
          currentUser.value = user;
        }

        isLoggedIn.value = true;
        AppSnackbar.success(title: "Success", message: "Login Successful!");
        Get.offAllNamed(Routes.home);
      } else {
        AppSnackbar.error(title: "Error", message: "Invalid credentials.");
      }
    } catch (e, st) {
      LoggerUtility.error('Login error', e, st);
      AppSnackbar.error(title: "Error", message: "Login failed.");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register(String name, String email, String password) async {
    try {
      isLoading.value = true;

      final response = await _authService.register(name, email, password);

      if (response.statusCode == HttpStatus.created) {
        AppSnackbar.success(title: "Success", message: "Account created!");
        Get.toNamed(Routes.login);
      } else {
        AppSnackbar.error(title: "Error", message: response.body);
      }
    } catch (e, st) {
      LoggerUtility.error('Registration error', e, st);
      AppSnackbar.error(title: "Error", message: "Could not create account.");
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== GOOGLE SIGN-IN (v7.2.0) ====================

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      LoggerUtility.info('Attempting Google Sign-In');

      // Initialize if not done
      if (!_isGoogleInitialized) {
        await initializeGoogleSignIn();
      }

      // v7+ method
      final GoogleSignInAccount account = await _googleSignIn.authenticate();

      LoggerUtility.info("Google Sign-In Success: ${account.email}");

      // Get ID Token (this is what we send to backend)
      final GoogleSignInAuthentication auth = account.authentication;
      final String? idToken = auth.idToken;

      if (idToken == null || idToken.isEmpty) {
        LoggerUtility.error(
          'Google ID Token is null. Check serverClientId in Google Cloud Console.',
        );
        AppSnackbar.error(
          title: "Error",
          message: "Failed to get Google ID token.",
        );
        return;
      }

      LoggerUtility.info("ID Token received successfully");

      // Send to your backend
      final response = await _authService.googleLogin(id: idToken);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        LoggerUtility.debug('Login response for google login : $data');

        final String accessToken = data['accessToken'];

        await _storage.saveToken(accessToken);
        userToken.value = accessToken;

        if (data['user'] != null) {
          final User user = User.fromJson(data['user']);
          await _storage.saveUser(user);
          currentUser.value = user;
        }

        isLoggedIn.value = true;
        AppSnackbar.success(title: "Success", message: "Welcome back!");
        Get.offAllNamed(Routes.home);
      } else {
        LoggerUtility.warning(
          'Backend rejected Google login. Status: ${response.statusCode}',
        );
        AppSnackbar.error(
          title: "Login Failed",
          message: "Could not sign in with Google. Please try again.",
        );
      }
    } on GoogleSignInException catch (e) {
      LoggerUtility.error("GoogleSignInException [${e.code}]", e.description);
      AppSnackbar.error(title: "Error", message: "Google Sign-In failed.");
    } catch (e, stackTrace) {
      LoggerUtility.error('Google Sign-In Error', e, stackTrace);
      AppSnackbar.error(
        title: "Error",
        message: "Google Sign-In failed. Please try again.",
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== LOGOUT ====================

  Future<void> logout() async {
    LoggerUtility.info(
      'Logging out user: ${currentUser.value?.email ?? "unknown"}',
    );

    await _storage.clearAll();
    await _googleSignIn.signOut();

    userToken.value = "";
    currentUser.value = null;
    isLoggedIn.value = false;

    Get.offAllNamed(Routes.login);
  }
}
