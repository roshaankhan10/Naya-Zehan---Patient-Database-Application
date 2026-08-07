// import 'package:flutter/foundation.dart';

// class ApiConfig {
//   static const String _overrideBaseUrl =
//       String.fromEnvironment('API_BASE_URL', defaultValue: '');

//   static String get baseUrl {
//     if (_overrideBaseUrl.isNotEmpty) {
//       return _overrideBaseUrl;
//     }

//     switch (defaultTargetPlatform) {
//       case TargetPlatform.android:
//         return 'http://10.0.2.2:8000';
//       default:
//         return 'http://127.0.0.1:8000';
//     }
//   }

//   static Uri uri(String path) => Uri.parse('$baseUrl$path');
// }
