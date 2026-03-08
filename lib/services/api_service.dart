import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';

class ApiService {
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

  Future<Map<String, dynamic>> getUserProfile(String accessToken) async {
    final response = await http.get(
      Uri.parse('$apiBaseUrl/user/'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );
    return jsonDecode(response.body);
  }
}
