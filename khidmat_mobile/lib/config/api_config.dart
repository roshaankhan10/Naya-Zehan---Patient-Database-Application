/// Centralized API configuration for the Khidmat Mobile app.
///
/// Change [baseUrl] to point to your Django server's address.
/// For Android emulator use '10.0.2.2' to reach host machine's localhost.
/// For physical device use the server's LAN IP address.
class ApiConfig {
  // ── Change this to your Django server address ──
  static const String baseUrl = 'http://10.0.2.2:8000';

  // ── Auth endpoints ──
  static const String tokenUrl = '$baseUrl/api/token/';
  static const String tokenRefreshUrl = '$baseUrl/api/token/refresh/';

  // ── Patient endpoints ──
  static const String patientsUrl = '$baseUrl/api/patients/';
  static String patientDetailUrl(String hospitalId) =>
      '$baseUrl/api/patients/$hospitalId/';
  static const String patientSearchUrl = '$baseUrl/api/patients/search/';

  // ── Admission endpoints ──
  static const String admissionsUrl = '$baseUrl/api/admissions/';
  static String admissionDetailUrl(int id) =>
      '$baseUrl/api/admissions/$id/';
}
