class AuthRepository {
  static final AuthRepository _instance = AuthRepository._internal();

  factory AuthRepository() {
    return _instance;
  }

  AuthRepository._internal();

  String? _host;
  String? _username;
  String? _password;

  bool get isLoggedIn => _host != null && _username != null;

  String? get host => _host;
  String? get username => _username;

  Future<bool> login(String host, String username, String password) async {
    // Simulate network delay
    await Future.delayed(Duration(seconds: 1));

    // Mock validation
    if (host.isEmpty || username.isEmpty) return false;

    _host = host;
    _username = username;
    _password = password;
    return true;
  }

  Future<void> logout() async {
    _host = null;
    _username = null;
    _password = null;
  }
}
