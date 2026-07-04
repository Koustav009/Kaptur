import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:kaptur/core/utils/app_logger.dart';
import 'package:kaptur/data/models/user.dart';
import 'package:kaptur/data/storage/storage_keys.dart';

/// Centralized storage service for all persistent data.
/// - Secure storage (JWT token) via FlutterSecureStorage
/// - Non-secure storage (user profile) via GetStorage
class StorageService extends GetxService {
  final FlutterSecureStorage _secure = const FlutterSecureStorage();
  final GetStorage _box = GetStorage(StorageKey.kaptur.name);

  // ── Secure: JWT Token ──────────────────────────────────

  Future<String?> getToken() => _secure.read(key: StorageKey.jwtToken.name);

  Future<void> saveToken(String token) async {
    await _secure.write(key: StorageKey.jwtToken.name, value: token);
    LoggerUtility.debug('JWT token saved');
  }

  Future<void> clearToken() async {
    await _secure.delete(key: StorageKey.jwtToken.name);
    LoggerUtility.debug('JWT token cleared');
  }

  // ── Non-secure: User Details ───────────────────────────

  User? getUser() {
    final data = _box.read<Map<String, dynamic>>(StorageKey.userDetails.name);
    return data != null ? User.fromJson(data) : null;
  }

  Future<void> saveUser(User user) async {
    await _box.write(StorageKey.userDetails.name, user.toJson());
    LoggerUtility.debug('User details saved: ${user.email}');
  }

  Future<void> clearUser() async {
    await _box.remove(StorageKey.userDetails.name);
    LoggerUtility.debug('User details cleared');
  }

  // ── Non-secure: Theme Mode ─────────────────────────────

  String? getThemeMode() {
    return _box.read<String>(StorageKey.themeMode.name);
  }

  Future<void> saveThemeMode(String mode) async {
    await _box.write(StorageKey.themeMode.name, mode);
    LoggerUtility.debug('Theme mode saved: $mode');
  }

  // ── Convenience: Session checks ────────────────────────

  Future<bool> get hasSession async {
    final token = await getToken();
    final user = getUser();
    LoggerUtility.debug('Session check: token=$token, user=$user');
    return token != null && user != null;
  }

  Future<void> clearAll() async {
    await clearToken();
    await clearUser();
    LoggerUtility.info('All storage cleared');
  }
}
