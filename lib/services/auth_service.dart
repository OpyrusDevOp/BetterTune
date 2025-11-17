import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../datas/auth.dart';

class AuthService {
  static const _deviceIdKey = 'device_id';
  static String? _serverUrl;

  static Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    var deviceId = prefs.getString(_deviceIdKey);

    if (deviceId == null) {
      deviceId = const Uuid().v4();
      await prefs.setString(_deviceIdKey, deviceId);
    }

    return deviceId;
  }

  static String getDeviceName() {
    // You can use device_info_plus package for real device info
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'Android Device';
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'iOS Device';
    } else {
      return 'Flutter Device';
    }
  }

  static Future<AuthenticationResult> authenticateByName({
    required String serverUrl,
    required String username,
    required String password,
  }) async {
    final deviceId = await getDeviceId();
    final deviceName = getDeviceName();

    const appName = 'MyJellyfinApp';
    const appVersion = '1.0.0';

    // Build authorization header
    final authHeader =
        'MediaBrowser '
        'Client="$appName", '
        'Device="$deviceName", '
        'DeviceId="$deviceId", '
        'Version="$appVersion"';

    final url = Uri.parse('$serverUrl/Users/AuthenticateByName');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': authHeader,
      },
      body: jsonEncode({'Username': username, 'Pw': password}),
    );

    if (response.statusCode == 200) {
      _serverUrl = serverUrl;
      final data = jsonDecode(response.body);

      return AuthenticationResult.fromJson(data);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['Message'] ?? 'Authentication failed');
    }
  }

  static Future<http.Response> authenticatedRequest(
    String endpoint,
    String accessToken, {
    String method = 'GET',
    Map<String, dynamic>? body,
  }) async {
    if (_serverUrl == null) throw Exception("No server URL found !!");
    final url = Uri.parse('$_serverUrl$endpoint');

    final headers = {
      'X-Emby-Token': accessToken,
      'Content-Type': 'application/json',
    };

    switch (method.toUpperCase()) {
      case 'GET':
        return http.get(url, headers: headers);
      case 'POST':
        return http.post(
          url,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
      case 'PUT':
        return http.put(
          url,
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
      case 'DELETE':
        return http.delete(url, headers: headers);
      default:
        throw Exception('Unsupported HTTP method: $method');
    }
  }
}
