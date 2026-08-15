import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../utils/navigation_service.dart';
import 'auth_storage.dart';
import '../config/app_config.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  ApiClient._();

  static final _client = http.Client();
  static const _timeout = Duration(seconds: 30);

  // Guards against multiple simultaneous refresh attempts racing each other.
  static Future<bool>? _refreshInFlight;

  static Future<Map<String, String>> _authHeaders() async {
    final token = await AuthStorage.getAccessToken();
    if (token == null) {
      throw ApiException(401, 'No access token available');
    }

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Uri _buildUri(String path) {
    AppConfig.verifyUrl();
    final base = AppConfig.baseUrl;
    return Uri.parse('$base$path');
  }

  static Future<dynamic> get(String path) => _request('GET', path);

  static Future<dynamic> post(String path, Map<String, dynamic> body) =>
      _request('POST', path, body: body);

  static Future<dynamic> put(String path, Map<String, dynamic> body) =>
      _request('PUT', path, body: body);

  static Future<dynamic> delete(String path) => _request('DELETE', path);

  /// Attempts to refresh the access token using the stored refresh token.
  /// Returns true if refresh succeeded, false otherwise.
  /// Safe to call concurrently — only one actual refresh request is made.
  static Future<bool> _refreshAccessToken() {
    // If a refresh is already in progress, wait for that one instead of
    // starting a second one (avoids racing against token rotation).
    _refreshInFlight ??= _doRefresh();
    return _refreshInFlight!.whenComplete(() {
      _refreshInFlight = null;
    });
  }

  static Future<bool> _doRefresh() async {
    final refreshToken = await AuthStorage.getRefreshToken();
    if (refreshToken == null) return false;

    try {
      final uri = _buildUri('/token/refresh/');
      final response = await _client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'refresh': refreshToken}),
          )
          .timeout(_timeout);

      if (response.statusCode != 200) return false;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final newAccess = data['access'] as String?;
      if (newAccess == null) return false;

      // SIMPLE_JWT has ROTATE_REFRESH_TOKENS=True, so a new refresh token
      // may also come back — save it if present, otherwise keep the old one.
      final newRefresh = data['refresh'] as String? ?? refreshToken;

      await AuthStorage.saveTokens(access: newAccess, refresh: newRefresh);
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<dynamic> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool isRetry = false,
  }) async {
    final uri = _buildUri(path);
    final headers = await _authHeaders();

    if (kDebugMode) debugPrint('[$method] $uri');

    late http.Response response;
    try {
      final request = http.Request(method, uri)..headers.addAll(headers);
      if (body != null) request.body = jsonEncode(body);
      final streamed = await _client.send(request).timeout(_timeout);
      response = await http.Response.fromStream(streamed);
    } on SocketException {
      throw ApiException(0, 'No internet connection');
    } on HttpException {
      throw ApiException(0, 'Network error');
    }

    if (kDebugMode) debugPrint('Response ${response.statusCode}');

    if (response.statusCode == 401) {
      // Only attempt a refresh once per request, to avoid infinite retry loops.
      if (!isRetry) {
        final refreshed = await _refreshAccessToken();
        if (refreshed) {
          return _request(method, path, body: body, isRetry: true);
        }
      }

      // Refresh failed (or already retried once) — session is truly over.
      await AuthStorage.clearAll();
      navigatorKey.currentState?.pushNamedAndRemoveUntil(
        '/login',
        (route) => false,
      );
      throw ApiException(401, 'Session expired. Please log in again.');
    }

    if (response.statusCode >= 400) {
      throw ApiException(response.statusCode, response.body);
    }

    if (response.body.isEmpty) return {};
    return jsonDecode(response.body);
  }
}