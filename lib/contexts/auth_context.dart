import 'package:bettertune/datas/auth.dart';
import 'package:bettertune/services/auth_service.dart';
import 'package:bettertune/services/storage_service.dart';
import 'package:flutter/foundation.dart';

class AuthContext extends ChangeNotifier {
  AuthState state = AuthState();

  Future<void> initialize() async {
    // Set loading state
    state = state.copyWith(isLoading: true);
    notifyListeners();

    try {
      // Try to restore authentication from storage
      final token = await StorageService.getToken();
      final userId = await StorageService.getUserId();
      final serverUrl = await StorageService.getServerUrl();

      if (token != null && serverUrl != null) {
        // Set the server URL for authenticated requests
        AuthService.setServerUrl = serverUrl;

        // For now, we'll just set the token and user ID
        // In a real app, you might want to validate the token with the server
        state = state.copyWith(
          accessToken: token,
          user: User(
            id: userId ?? '',
            name: 'User', // You might want to fetch user details from server
            hasPassword: true,
            hasConfiguredPassword: true,
          ),
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to initialize authentication: $error',
      );
    }

    notifyListeners();
  }

  Future<void> login({
    required String serverUrl,
    required String username,
    required String password,
  }) async {
    // Set loading state
    state = state.copyWith(isLoading: true, error: null);
    notifyListeners();

    try {
      final result = await AuthService.authenticateByName(
        serverUrl: serverUrl,
        username: username,
        password: password,
      );

      // Save credentials to storage
      await StorageService.saveToken(result.accessToken);
      await StorageService.saveUserId(result.user.id);
      await StorageService.saveServerUrl(serverUrl);

      // Update state
      state = state.copyWith(
        accessToken: result.accessToken,
        user: result.user,
        isLoading: false,
        error: null,
      );

      notifyListeners();
    } catch (error) {
      state = state.copyWith(isLoading: false, error: error.toString());
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    // Clear storage
    await StorageService.clearAll();

    // Reset state
    state = AuthState();

    notifyListeners();
  }

  Future<void> clearError() async {
    state = state.copyWith(error: null);
    notifyListeners();
  }

  // Helper method to check if user is authenticated
  bool get isAuthenticated => state.isAuthenticated;

  // Helper method to get current user
  User? get currentUser => state.user;

  // Helper method to get access token
  String? get accessToken => state.accessToken;
}
