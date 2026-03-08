import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';

class ApiService {
  Future<Map<String, dynamic>> getWelcome() async {
    final response = await http.get(Uri.parse('$apiBaseUrl/welcome'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to connect to API');
    }
  }
}
