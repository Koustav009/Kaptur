import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:kaptur/core/utils/app_logger.dart';
import 'package:kaptur/data/storage/storage_service.dart';
import 'api_constants.dart';

/// A centralized API client that handles base URL, headers, and HTTP methods.
/// Use this class for all network communications to ensure consistency.
///
/// Automatically refreshes the JWT token on 401 responses using the stored
/// refresh token, then retries the original request.
class ApiClient {
  final StorageService _storage = Get.find<StorageService>();

  /// Tracks whether a token refresh is currently in progress to avoid
  /// multiple concurrent refresh calls.
  Future<bool>? _refreshInProgress;

  /// Paths that should NOT trigger an automatic token refresh on 401.
  static const _authPaths = {
    ApiConstants.loginPath,
    ApiConstants.registerPath,
    ApiConstants.googleLoginPath,
    ApiConstants.refreshTokenPath,
  };

  /// Private generic request method.
  /// Handles the common logic: URI construction, JSON encoding, and JWT headers.
  Future<http.Response> _request(
    String path,
    String method, {
    dynamic body,
    Map<String, dynamic>? queryParams,
  }) async {
    final response = await _executeRequest(path, method,
        body: body, queryParams: queryParams);

    // If 401 and this isn't an auth endpoint, attempt token refresh + retry.
    if (response.statusCode == 401 && !_authPaths.contains(path)) {
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        LoggerUtility.debug('Token refreshed, retrying $method $path');
        return _executeRequest(path, method,
            body: body, queryParams: queryParams);
      }
    }

    return response;
  }

  /// Executes the actual HTTP request with current token from storage.
  Future<http.Response> _executeRequest(
    String path,
    String method, {
    dynamic body,
    Map<String, dynamic>? queryParams,
  }) async {
    // a. Create the full URI with optional query parameters.
    final uri = Uri.parse('${ApiConstants.baseUrl}$path').replace(
      queryParameters: queryParams?.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );

    // b. Retrieve the stored JWT token (if any).
    String? token = await _storage.getToken();

    // c. Setup standard headers.
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    // d. Execute the appropriate HTTP method.
    LoggerUtility.debug('$method ${uri.path}');
    try {
      http.Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: headers,
            body: jsonEncode(body),
          );
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: headers,
            body: jsonEncode(body),
          );
          break;
        case 'DELETE':
          response = await http.delete(
            uri,
            headers: headers,
            body: jsonEncode(body),
          );
          break;
        default:
          throw Exception("HTTP Method $method not supported");
      }
      LoggerUtility.debug('$method ${uri.path} → ${response.statusCode}');
      return response;
    } catch (e, st) {
      LoggerUtility.error('$method ${uri.path} failed', e, st);
      rethrow;
    }
  }

  /// Attempts to refresh the access token using the stored refresh token.
  /// Returns true if the refresh succeeded and the new tokens were saved.
  /// Deduplicates concurrent calls via [_refreshInProgress].
  Future<bool> _tryRefreshToken() {
    _refreshInProgress ??= _performRefresh();
    return _refreshInProgress!.whenComplete(() => _refreshInProgress = null);
  }

  /// Performs the actual refresh token call.
  Future<bool> _performRefresh() async {
    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null) {
        LoggerUtility.warning('No refresh token available');
        return false;
      }

      final uri = Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.refreshTokenPath}');

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Backend returns both camelCase and snake_case keys.
        final newAccessToken =
            data['accessToken'] ?? data['access_token'] as String?;
        final newRefreshToken =
            data['refreshToken'] ?? data['refresh_token'] as String?;

        if (newAccessToken != null) {
          await _storage.saveToken(newAccessToken);
          LoggerUtility.debug('Access token refreshed');
        }
        if (newRefreshToken != null) {
          await _storage.saveRefreshToken(newRefreshToken);
          LoggerUtility.debug('Refresh token rotated');
        }
        return true;
      } else {
        LoggerUtility.warning(
            'Refresh token failed: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e, st) {
      LoggerUtility.error('Refresh token error', e, st);
      return false;
    }
  }

  // --- Public Methods ---

  /// GET: Use for fetching data.
  Future<http.Response> get(String path, {Map<String, dynamic>? queryParams}) {
    return _request(path, 'GET', queryParams: queryParams);
  }

  /// POST: Use for creating data or sending sensitive information.
  Future<http.Response> post(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParams,
  }) {
    return _request(path, 'POST', body: body, queryParams: queryParams);
  }

  /// PUT: Use for updating existing data.
  Future<http.Response> put(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParams,
  }) {
    return _request(path, 'PUT', body: body, queryParams: queryParams);
  }

  /// DELETE: Use for removing data.
  Future<http.Response> delete(
    String path, {
    dynamic body,
    Map<String, dynamic>? queryParams,
  }) {
    return _request(path, 'DELETE', body: body, queryParams: queryParams);
  }
}
