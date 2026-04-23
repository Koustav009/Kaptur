import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_constants.dart';

/// A centralized API client that handles base URL, headers, and HTTP methods.
/// Use this class for all network communications to ensure consistency.
class ApiClient {
  final _storage = const FlutterSecureStorage();

  /// Private generic request method.
  /// Handles the common logic: URI construction, JSON encoding, and JWT headers.
  Future<http.Response> _request(
    String path,
    String method, {
    dynamic body,
    Map<String, dynamic>? queryParams,
  }) async {
    // a. Create the full URI with optional query parameters.
    // NOTE: queryParameters expects Map<String, dynamic>? but values are usually Strings.
    final uri = Uri.parse('${ApiConstants.baseUrl}$path').replace(queryParameters: queryParams?.map((key, value) => MapEntry(key, value.toString())));
    
    // b. Retrieve the stored JWT token (if any).
    String? token = await _storage.read(key: "jwt_token");

    // c. Setup standard headers.
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    // d. Execute the appropriate HTTP method.
    http.Response response;
    try {
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          response = await http.post(uri, headers: headers, body: jsonEncode(body));
          break;
        case 'PUT':
          response = await http.put(uri, headers: headers, body: jsonEncode(body));
          break;
        case 'DELETE':
          // Using a different approach for DELETE with body if needed, 
          // but standard http package delete doesn't take body. 
          // For now, standard delete is fine.
          response = await http.delete(uri, headers: headers, body: jsonEncode(body));
          break;
        default:
          throw Exception("HTTP Method $method not supported");
      }
      return response;
    } catch (e) {
      // Re-throw or handle network errors as needed.
      rethrow;
    }
  }

  // --- Public Methods ---

  /// GET: Use for fetching data.
  Future<http.Response> get(String path, {Map<String, dynamic>? queryParams}) {
    return _request(path, 'GET', queryParams: queryParams);
  }

  /// POST: Use for creating data or sending sensitive information.
  Future<http.Response> post(String path, {dynamic body, Map<String, dynamic>? queryParams}) {
    return _request(path, 'POST', body: body, queryParams: queryParams);
  }

  /// PUT: Use for updating existing data.
  Future<http.Response> put(String path, {dynamic body, Map<String, dynamic>? queryParams}) {
    return _request(path, 'PUT', body: body, queryParams: queryParams);
  }

  /// DELETE: Use for removing data.
  Future<http.Response> delete(String path, {dynamic body, Map<String, dynamic>? queryParams}) {
    return _request(path, 'DELETE', body: body, queryParams: queryParams);
  }
}
