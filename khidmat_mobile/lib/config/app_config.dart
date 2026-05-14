import 'package:flutter/foundation.dart';

class AppConfig {
  AppConfig._();

  static const baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://172.23.55.143:8000/api',
  );

  static void verifyUrl() {
    assert(
      kDebugMode || baseUrl.startsWith('https://'),
      'BASE_URL must use HTTPS in release builds.',
    );
  }
}
