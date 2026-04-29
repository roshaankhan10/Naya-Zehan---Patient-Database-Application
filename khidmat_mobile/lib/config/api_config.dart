import 'package:flutter/foundation.dart';

/// Centralized API configuration for the Khidmat Mobile app.
///
/// Override with:
/// `--dart-define=API_BASE_URL=http://YOUR_IP:8000`
/// when testing on a physical device.
class ApiConfig {
  static const String _overrideBaseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: '');

  static String get baseUrl {
    if (_overrideBaseUrl.isNotEmpty) {
      return _overrideBaseUrl;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'http://10.0.2.2:8000';
      default:
        return 'http://127.0.0.1:8000';
    }
  }

  // ── Auth endpoints ──
  static String get tokenUrl => '$baseUrl/api/token/';
  static String get tokenRefreshUrl => '$baseUrl/api/token/refresh/';

  // ── Patient endpoints ──
  static String get patientsUrl => '$baseUrl/api/patients/';
  static String patientDetailUrl(String hospitalId) =>
      '$baseUrl/api/patients/$hospitalId/';
  static String get patientSearchUrl => '$baseUrl/api/patients/search/';

  // ── Admission endpoints ──
  static String get admissionsUrl => '$baseUrl/api/admissions/';
  static String admissionDetailUrl(int id) =>
      '$baseUrl/api/admissions/$id/';
}
