import 'package:flutter/foundation.dart';

class AppConfig {
  AppConfig._();

  static const baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'https://naya-zehan-backend.onrender.com/api',
  );

  static void verifyUrl() {
    assert(
      kDebugMode || baseUrl.startsWith('https://'),
      'BASE_URL must use HTTPS in release builds.',
    );
  }
}
