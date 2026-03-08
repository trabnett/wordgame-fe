class AuthService {
  static final AuthService _instance = AuthService._();
  factory AuthService() => _instance;
  AuthService._();

  String? _accessToken;
  String? _refreshToken;
  String? _firstName;

  bool get isLoggedIn => _accessToken != null;
  String? get accessToken => _accessToken;
  String? get firstName => _firstName;

  void login({
    required String accessToken,
    required String refreshToken,
    String? firstName,
  }) {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    _firstName = firstName;
  }

  void logout() {
    _accessToken = null;
    _refreshToken = null;
    _firstName = null;
  }
}
