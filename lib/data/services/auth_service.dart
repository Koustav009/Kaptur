import 'package:http/http.dart' as http;
import 'api_client.dart';
import 'api_constants.dart';

/// This service handles all the network requests to our Spring Boot Backend.
/// It uses the centralized [ApiClient] and [ApiConstants] for clean communication.
class AuthService {
  final ApiClient _apiClient = ApiClient();

  /// Sends login credentials to the backend.
  Future<http.Response> login(String email, String password) async {
    return _apiClient.post(
      ApiConstants.loginPath,
      body: {'email': email, 'password': password},
    );
  }

  /// Sends registration data to the backend.
  Future<http.Response> register(
    String name,
    String email,
    String password,
  ) async {
    return _apiClient.post(
      ApiConstants.registerPath,
      body: {'name': name, 'email': email, 'password': password},
    );
  }

  /// Sends Google User data to our backend to get a JWT.
  Future<http.Response> googleLogin({
    required String name,
    required String email,
    required String id,
    String? photoUrl,
  }) async {
    return _apiClient.post(
      ApiConstants.googleLoginPath,
      body: {
        'name': name,
        'email': email,
        'id': id,
        'photoUrl': photoUrl,
      },
    );
  }
}
