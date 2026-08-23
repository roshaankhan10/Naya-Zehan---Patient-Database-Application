import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthStorage {
  AuthStorage._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  static const _keyAccessToken = 'jwt_access_token';
  static const _keyRefreshToken = 'jwt_refresh_token';
  static const _keyIsAdmin = 'is_admin';

  static Future<void> saveTokens({
    required String access,
    required String refresh,
  }) async {
    await _storage.write(key: _keyAccessToken, value: access);
    await _storage.write(key: _keyRefreshToken, value: refresh);
  }

  static Future<String?> getAccessToken() =>
      _storage.read(key: _keyAccessToken);

  static Future<String?> getRefreshToken() =>
      _storage.read(key: _keyRefreshToken);

  static Future<void> saveIsAdmin(bool isAdmin) =>
      _storage.write(key: _keyIsAdmin, value: isAdmin.toString());

  static Future<bool> getIsAdmin() async {
    final value = await _storage.read(key: _keyIsAdmin);
    return value == 'true';
  }

  static Future<void> clearAll() => _storage.deleteAll();
}