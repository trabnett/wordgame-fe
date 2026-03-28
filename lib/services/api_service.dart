import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import 'auth_service.dart';

class ApiService {
  /// Attempts to refresh the access token using the stored refresh token.
  /// Returns the new access token, or null if refresh failed.
  Future<String?> _refreshAccessToken() async {
    final refreshToken = AuthService().refreshToken;
    if (refreshToken == null) return null;

    final response = await http.post(
      Uri.parse('$apiBaseUrl/token/refresh/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refresh': refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final newToken = data['access'] as String;
      await AuthService().updateAccessToken(newToken);
      return newToken;
    }
    return null;
  }

  /// Makes an authenticated GET request, retrying once with a refreshed token on 401.
  Future<http.Response> _authGet(String path, String accessToken) async {
    var response = await http.get(
      Uri.parse('$apiBaseUrl$path'),
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode == 401) {
      final newToken = await _refreshAccessToken();
      if (newToken != null) {
        response = await http.get(
          Uri.parse('$apiBaseUrl$path'),
          headers: {'Authorization': 'Bearer $newToken'},
        );
      }
    }
    return response;
  }

  /// Makes an authenticated POST request, retrying once with a refreshed token on 401.
  Future<http.Response> _authPost(String path, String accessToken, {Map<String, dynamic>? body}) async {
    var response = await http.post(
      Uri.parse('$apiBaseUrl$path'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(body ?? {}),
    );

    if (response.statusCode == 401) {
      final newToken = await _refreshAccessToken();
      if (newToken != null) {
        response = await http.post(
          Uri.parse('$apiBaseUrl$path'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $newToken',
          },
          body: jsonEncode(body ?? {}),
        );
      }
    }
    return response;
  }

  Future<Map<String, dynamic>> getWelcome() async {
    final response = await http.get(Uri.parse('$apiBaseUrl/welcome/'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to connect to API');
    }
  }

  Future<Map<String, dynamic>> phoneLogin(String phoneNumber) async {
    final response = await http.post(
      Uri.parse('$apiBaseUrl/login/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone_number': phoneNumber}),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> emailLogin(String email) async {
    final response = await http.post(
      Uri.parse('$apiBaseUrl/login/email/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> register({
    required String phoneNumber,
    required String firstName,
    required String lastName,
    required String email,
    required String username,
  }) async {
    final response = await http.post(
      Uri.parse('$apiBaseUrl/register/'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone_number': phoneNumber,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'username': username,
      }),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> createGame(String accessToken, {String? phoneNumber}) async {
    final body = <String, dynamic>{};
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      body['phone_number'] = phoneNumber;
    }
    final response = await _authPost('/game/', accessToken, body: body);
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> joinGame(String accessToken, int gameId) async {
    final response = await _authPost('/game/$gameId/join/', accessToken);
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getUserProfile(String accessToken) async {
    final response = await _authGet('/user/', accessToken);
    return jsonDecode(response.body);
  }
}
