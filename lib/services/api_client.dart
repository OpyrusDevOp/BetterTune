import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  // Singleton
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  String? baseUrl;
  String? accessToken;
  String? userId;
  String clientName = "BetterTune";
  String deviceName = "Flutter App";
  String deviceId = "bettertune_flutter_id";
  String version = "1.0.0";

  void setCredentials(String url, String token, String uid) {
    baseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
    accessToken = token;
    userId = uid;
  }

  void clearCredentials() {
    baseUrl = null;
    accessToken = null;
    userId = null;
  }

  Map<String, String> get _headers {
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    // Authorization Header for Jellyfin
    // Format: MediaBrowser Client="Client", Device="Device", DeviceId="DeviceId", Version="Version", Token="Token"
    String auth =
        'MediaBrowser Client="$clientName", Device="$deviceName", DeviceId="$deviceId", Version="$version"';
    if (accessToken != null) {
      auth += ', Token="$accessToken"';
    }

    headers['X-Emby-Authorization'] = auth;
    return headers;
  }

  Future<dynamic> get(String endpoint) async {
    if (baseUrl == null) throw Exception("Base URL not set");

    final uri = Uri.parse('$baseUrl$endpoint');
    final response = await http.get(uri, headers: _headers);

    return _handleResponse(response);
  }

  Future<dynamic> post(String endpoint, {Object? body}) async {
    if (baseUrl == null) throw Exception("Base URL not set");

    final uri = Uri.parse('$baseUrl$endpoint');
    final response = await http.post(
      uri,
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );

    return _handleResponse(response);
  }

  Future<dynamic> delete(String endpoint) async {
    if (baseUrl == null) throw Exception("Base URL not set");

    final uri = Uri.parse('$baseUrl$endpoint');
    final response = await http.delete(uri, headers: _headers);

    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      // If content is empty, return null
      if (response.body.isEmpty) return null;
      try {
        return jsonDecode(response.body);
      } catch (e) {
        // Return body as string if not JSON
        return response.body;
      }
    } else {
      throw Exception('API Error: ${response.statusCode} ${response.body}');
    }
  }

  // Builder for Image URLs
  String getImageUrl(String itemId, {int? width, int? height}) {
    if (baseUrl == null) return "";
    String url = '$baseUrl/Items/$itemId/Images/Primary?quality=90';
    if (width != null) url += '&width=$width';
    if (height != null) url += '&height=$height';
    return url;
  }
}
