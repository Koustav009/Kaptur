/// This file contains all the network-related constants.
/// Centralizing them here makes it easy to switch between local, staging, and production URLs.
class ApiConstants {
  // Use 10.0.2.2 for Android Emulator to reach your local machine's localhost (127.0.0.1).
  static const String baseUrl = "http://10.0.2.2:8080";

  // Auth Endpoints
  static const String loginPath = "/auth/login";
  static const String registerPath = "/auth/register";
  static const String googleLoginPath = "/auth/google";
}
