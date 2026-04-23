import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

/// Handles JWT authentication: login, logout, token storage & refresh.
class AuthService {
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  // ── Token storage ──

  static Future<void> _saveTokens(String access, String refresh) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessKey, access);
    await prefs.setString(_refreshKey, refresh);
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessKey);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshKey);
  }

  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessKey);
    await prefs.remove(_refreshKey);
  }

  static Future<bool> hasValidToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  // ── Login ──

  /// Attempts login with [username] and [password].
  /// Returns `true` on success, throws on failure.
  static Future<bool> login(String username, String password) async {
    final response = await http.post(
      Uri.parse(ApiConfig.tokenUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username.trim(),
        'password': password.trim(),
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _saveTokens(data['access'], data['refresh']);
      return true;
    } else if (response.statusCode == 401) {
      throw AuthException('Invalid username or password.');
    } else {
      throw AuthException('Login failed (${response.statusCode}).');
    }
  }

  // ── Token refresh ──

  /// Refreshes the access token using the stored refresh token.
  /// Returns the new access token, or null if refresh fails.
  static Future<String?> refreshAccessToken() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) return null;

    try {
      final response = await http.post(
        Uri.parse(ApiConfig.tokenRefreshUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAccess = data['access'] as String;
        final newRefresh = data['refresh'] as String? ?? refreshToken;
        await _saveTokens(newAccess, newRefresh);
        return newAccess;
      }
    } catch (e) {
      debugPrint('Token refresh failed: $e');
    }

    // Refresh failed — clear tokens
    await clearTokens();
    return null;
  }

  // ── Logout ──

  static Future<void> logout() async {
    await clearTokens();
  }
}

/// Custom exception for auth-related errors.
class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}
