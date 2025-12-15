import 'dart:convert';
import 'package:flutter/material.dart'; // For debugPrint
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
    debugPrint("[ApiClient] Credentials set: $baseUrl, User: $userId");
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
    if (baseUrl == null) {
      debugPrint("[ApiClient] Error: Base URL not set");
      throw Exception("Base URL not set");
    }

    final uri = Uri.parse('$baseUrl$endpoint');
    debugPrint("[ApiClient] GET $uri");

    try {
      final response = await http.get(uri, headers: _headers);
      return _handleResponse(response);
    } catch (e) {
      debugPrint("[ApiClient] GET failed: $e");
      rethrow;
    }
  }

  Future<dynamic> post(String endpoint, {Object? body}) async {
    if (baseUrl == null) throw Exception("Base URL not set");

    final uri = Uri.parse('$baseUrl$endpoint');
    debugPrint("[ApiClient] POST $uri");
    if (body != null) debugPrint("[ApiClient] Body: $body");

    try {
      final response = await http.post(
        uri,
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      debugPrint("[ApiClient] POST failed: $e");
      rethrow;
    }
  }

  Future<dynamic> delete(String endpoint) async {
    if (baseUrl == null) throw Exception("Base URL not set");

    final uri = Uri.parse('$baseUrl$endpoint');
    debugPrint("[ApiClient] DELETE $uri");

    try {
      final response = await http.delete(uri, headers: _headers);
      return _handleResponse(response);
    } catch (e) {
      debugPrint("[ApiClient] DELETE failed: $e");
      rethrow;
    }
  }

  dynamic _handleResponse(http.Response response) {
    debugPrint("[ApiClient] Response: ${response.statusCode}");

    if (response.statusCode >= 200 && response.statusCode < 300) {
      // 204 No Content
      if (response.statusCode == 204 || response.body.isEmpty) return null;

      try {
        return jsonDecode(response.body);
      } catch (e) {
        // Return body as string if not JSON
        return response.body;
      }
    } else {
      debugPrint("[ApiClient] Error Response: ${response.body}");
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
