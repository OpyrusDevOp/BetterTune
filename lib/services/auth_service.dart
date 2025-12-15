import 'package:bettertune/services/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  bool get isLoggedIn => ApiClient().accessToken != null;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final url = prefs.getString('server_url');
    final token = prefs.getString('access_token');
    final userId = prefs.getString('user_id');

    if (url != null && token != null && userId != null) {
      ApiClient().setCredentials(url, token, userId);
    }
  }

  Future<bool> login(String serverUrl, String username, String password) async {
    try {
      // Normalize URL
      if (!serverUrl.startsWith('http')) {
        serverUrl = 'http://$serverUrl';
      }

      // Temporarily set base URL for the request
      ApiClient().baseUrl = serverUrl.endsWith('/')
          ? serverUrl.substring(0, serverUrl.length - 1)
          : serverUrl;

      final response = await ApiClient().post(
        '/Users/AuthenticateByName',
        body: {"Username": username, "Pw": password},
      );

      if (response != null && response['AccessToken'] != null) {
        final token = response['AccessToken'];
        final userId = response['User']['Id'];

        // Update Client
        ApiClient().setCredentials(serverUrl, token, userId);

        // Persist
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('server_url', serverUrl);
        await prefs.setString('access_token', token);
        await prefs.setString('user_id', userId);

        return true;
      }
      return false;
    } catch (e) {
      print("Login Error: $e");
      ApiClient().clearCredentials();
      return false;
    }
  }

  Future<void> logout() async {
    // Call logout API if needed (usually /Sessions/Logout)
    try {
      await ApiClient().post('/Sessions/Logout');
    } catch (_) {}

    ApiClient().clearCredentials();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('server_url');
    await prefs.remove('access_token');
    await prefs.remove('user_id');
  }
}
