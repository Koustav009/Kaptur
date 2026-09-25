import 'package:kaptur/core/config/app_config.dart';

/// This file contains all the network-related constants.
/// Endpoints live here; the base URL comes from [AppConfig] so it follows
/// the active flavor (dev/prod) and the platform (Android emulator vs web).
class ApiConstants {
  // Resolved by flavor + platform, see AppConfig.baseUrl.
  static String get baseUrl => AppConfig.baseUrl;

  // Auth Endpoints
  static const String loginPath = "/auth/login";
  static const String registerPath = "/auth/register";
  static const String googleLoginPath = "/auth/google";
  static const String refreshTokenPath = "/auth/refresh";

  // Event Endpoints (for creating, reading, updating, and deleting events)
  // We attach this path to baseUrl, e.g., http://10.0.2.2:8080/events
  static const String eventsPath = "/events";
}
