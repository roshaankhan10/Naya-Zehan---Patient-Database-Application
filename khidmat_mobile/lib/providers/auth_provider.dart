import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

/// Manages authentication state across the app via ChangeNotifier.
class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _error;

  bool get isLoggedIn => _isLoggedIn;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AuthProvider() {
    _checkLoginStatus();
  }

  /// Check if user has a stored token on app start.
  Future<void> _checkLoginStatus() async {
    _isLoggedIn = await AuthService.hasValidToken();
    _isInitialized = true;
    notifyListeners();
  }

  /// Attempt login with credentials.
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await AuthService.login(username, password);
      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Connection error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logout and clear tokens.
  Future<void> logout() async {
    await AuthService.logout();
    _isLoggedIn = false;
    _error = null;
    notifyListeners();
  }

  /// Clear any error state.
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
