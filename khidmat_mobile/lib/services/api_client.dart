import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

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

  static Future<dynamic> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
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

    if (kDebugMode) debugPrint('Response ${response.statusCode}: ${response.body}');

    if (response.statusCode == 401) {
      await AuthStorage.clearAll();
      throw ApiException(401, 'Session expired. Please log in again.');
    }

    if (response.statusCode >= 400) {
      throw ApiException(response.statusCode, response.body);
    }

    if (response.body.isEmpty) return {};
    return jsonDecode(response.body);
  }
}
