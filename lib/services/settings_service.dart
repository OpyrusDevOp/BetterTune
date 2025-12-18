import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  late SharedPreferences _prefs;
  bool _isInitialized = false;

  // Keys
  static const String _keyDolbyEnabled = 'dolby_enabled';
  static const String _keyBackgroundColor = 'background_color';
  static const String _keyBackgroundImage = 'background_image';

  // State
  bool _dolbyEnabled = false;
  int _backgroundColor = 0xFF121212; // Default dark
  String? _backgroundImagePath;

  bool get dolbyEnabled => _dolbyEnabled;
  Color get backgroundColor => Color(_backgroundColor);
  String? get backgroundImagePath => _backgroundImagePath;

  Future<void> init() async {
    if (_isInitialized) return;
    _prefs = await SharedPreferences.getInstance();

    _dolbyEnabled = _prefs.getBool(_keyDolbyEnabled) ?? false;
    _backgroundColor = _prefs.getInt(_keyBackgroundColor) ?? 0xFF121212;
    _backgroundImagePath = _prefs.getString(_keyBackgroundImage);

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setDolbyEnabled(bool value) async {
    _dolbyEnabled = value;
    await _prefs.setBool(_keyDolbyEnabled, value);
    notifyListeners();
  }

  Future<void> setBackgroundColor(Color color) async {
    _backgroundColor = color.value;
    await _prefs.setInt(_keyBackgroundColor, color.value);
    // If setting color, clear image? Or let image override?
    // Let's keep them independent but maybe image takes precedence in UI.
    notifyListeners();
  }

  Future<void> setBackgroundImage(String? path) async {
    _backgroundImagePath = path;
    if (path == null) {
      await _prefs.remove(_keyBackgroundImage);
    } else {
      await _prefs.setString(_keyBackgroundImage, path);
    }
    notifyListeners();
  }
}
