import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final AuthService _instance = AuthService._();
  factory AuthService() => _instance;
  AuthService._();

  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';
  static const _keyFirstName = 'first_name';

  String? _accessToken;
  String? _refreshToken;
  String? _firstName;

  bool get isLoggedIn => _accessToken != null;
  String? get accessToken => _accessToken;
  String? get firstName => _firstName;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString(_keyAccessToken);
    _refreshToken = prefs.getString(_keyRefreshToken);
    _firstName = prefs.getString(_keyFirstName);
  }

  Future<void> login({
    required String accessToken,
    required String refreshToken,
    String? firstName,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _firstName = firstName;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAccessToken, accessToken);
    await prefs.setString(_keyRefreshToken, refreshToken);
    if (firstName != null) {
      await prefs.setString(_keyFirstName, firstName);
    }
  }

  Future<void> logout() async {
    _accessToken = null;
    _refreshToken = null;
    _firstName = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyRefreshToken);
    await prefs.remove(_keyFirstName);
  }
}
