import 'dart:convert';
import 'package:http/http.dart' as http;

/// This service handles all the network requests to our Spring Boot Backend.
/// We use the 'http' package to send POST requests.
class AuthService {
  // Use 10.0.2.2 for Android Emulator to reach your local machine's localhost.
  static const String baseUrl = "http://10.0.2.2:8080/auth";

  /// Sends login credentials to the backend.
  Future<http.Response> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    return response;
  }

  /// Sends registration data to the backend.
  Future<http.Response> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );
    return response;
  }

  /// Sends Google User data to our backend to get a JWT.
  Future<http.Response> googleLogin({
    required String name,
    required String email,
    required String id,
    String? photoUrl,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/google'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'id': id,
        'photoUrl': photoUrl,
      }),
    );
    return response;
  }
}
