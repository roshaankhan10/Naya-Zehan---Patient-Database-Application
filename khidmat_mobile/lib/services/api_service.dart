import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/patient.dart';
import '../models/admission.dart';
import 'auth_service.dart';

/// Central API client that handles all HTTP requests with auth header injection
/// and automatic token refresh on 401 responses.
class ApiService {
  /// Makes an authenticated GET request with auto-refresh on 401.
  static Future<http.Response> _authGet(String url) async {
    var token = await AuthService.getAccessToken();
    var response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );

    // If 401, try refreshing the token once
    if (response.statusCode == 401) {
      final newToken = await AuthService.refreshAccessToken();
      if (newToken != null) {
        response = await http.get(
          Uri.parse(url),
          headers: {'Authorization': 'Bearer $newToken'},
        );
      }
    }

    return response;
  }

  /// Makes an authenticated POST request with auto-refresh on 401.
  static Future<http.Response> _authPost(String url, Map<String, dynamic> body) async {
    var token = await AuthService.getAccessToken();
    var response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 401) {
      final newToken = await AuthService.refreshAccessToken();
      if (newToken != null) {
        response = await http.post(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $newToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(body),
        );
      }
    }

    return response;
  }

  /// Makes an authenticated PUT request with auto-refresh on 401.
  static Future<http.Response> _authPut(String url, Map<String, dynamic> body) async {
    var token = await AuthService.getAccessToken();
    var response = await http.put(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 401) {
      final newToken = await AuthService.refreshAccessToken();
      if (newToken != null) {
        response = await http.put(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $newToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(body),
        );
      }
    }

    return response;
  }

  /// Makes an authenticated DELETE request with auto-refresh on 401.
  static Future<http.Response> _authDelete(String url) async {
    var token = await AuthService.getAccessToken();
    var response = await http.delete(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 401) {
      final newToken = await AuthService.refreshAccessToken();
      if (newToken != null) {
        response = await http.delete(
          Uri.parse(url),
          headers: {'Authorization': 'Bearer $newToken'},
        );
      }
    }

    return response;
  }

  // ═══════════════════════════════════════════════════════════════
  //  PATIENTS
  // ═══════════════════════════════════════════════════════════════

  /// Fetches a paginated list of patients.
  /// Returns a [PaginatedResult] containing the patient list and pagination info.
  static Future<PaginatedResult<Patient>> getPatients({String? pageUrl}) async {
    final url = pageUrl ?? ApiConfig.patientsUrl;
    final response = await _authGet(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return PaginatedResult<Patient>.fromJson(
        data,
        (json) => Patient.fromJson(json as Map<String, dynamic>),
      );
    }

    throw ApiException('Failed to fetch patients (${response.statusCode})');
  }

  /// Multi-parameter patient search.
  /// At least one parameter must be non-empty.
  static Future<PaginatedResult<Patient>> searchPatients({
    String? hospitalId,
    String? name,
    String? fatherName,
    String? surname,
    String? pageUrl,
  }) async {
    String url;

    if (pageUrl != null) {
      url = pageUrl;
    } else {
      final params = <String, String>{};
      if (hospitalId != null && hospitalId.isNotEmpty) {
        params['hospital_id'] = hospitalId;
      }
      if (name != null && name.isNotEmpty) params['name'] = name;
      if (fatherName != null && fatherName.isNotEmpty) {
        params['father_name'] = fatherName;
      }
      if (surname != null && surname.isNotEmpty) params['surname'] = surname;

      final query = Uri(queryParameters: params).query;
      url = '${ApiConfig.patientSearchUrl}?$query';
    }

    final response = await _authGet(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return PaginatedResult<Patient>.fromJson(
        data,
        (json) => Patient.fromJson(json as Map<String, dynamic>),
      );
    }

    throw ApiException('Search failed (${response.statusCode})');
  }

  /// Fetches a single patient's full detail (including admissions).
  static Future<Patient> getPatientDetail(String hospitalId) async {
    final response = await _authGet(ApiConfig.patientDetailUrl(hospitalId));

    if (response.statusCode == 200) {
      return Patient.fromJson(jsonDecode(response.body));
    }

    throw ApiException('Failed to fetch patient (${response.statusCode})');
  }

  /// Creates a new patient. Returns the created [Patient].
  static Future<Patient> createPatient(Patient patient) async {
    final response = await _authPost(ApiConfig.patientsUrl, patient.toJson());

    if (response.statusCode == 201) {
      return Patient.fromJson(jsonDecode(response.body));
    }

    throw ApiException('Failed to create patient: ${response.body}');
  }

  /// Updates an existing patient. Returns the updated [Patient].
  static Future<Patient> updatePatient(Patient patient) async {
    final response = await _authPut(
      ApiConfig.patientDetailUrl(patient.hospitalId),
      patient.toJson(),
    );

    if (response.statusCode == 200) {
      return Patient.fromJson(jsonDecode(response.body));
    }

    throw ApiException('Failed to update patient: ${response.body}');
  }

  /// Deletes a patient by hospital ID.
  static Future<bool> deletePatient(String hospitalId) async {
    final response =
        await _authDelete(ApiConfig.patientDetailUrl(hospitalId));
    return response.statusCode == 204;
  }

  // ═══════════════════════════════════════════════════════════════
  //  ADMISSIONS
  // ═══════════════════════════════════════════════════════════════

  /// Fetches admissions, optionally filtered by patient hospital ID.
  static Future<PaginatedResult<Admission>> getAdmissions({
    String? patientId,
    String? pageUrl,
  }) async {
    String url;
    if (pageUrl != null) {
      url = pageUrl;
    } else if (patientId != null) {
      url = '${ApiConfig.admissionsUrl}?patient=$patientId';
    } else {
      url = ApiConfig.admissionsUrl;
    }

    final response = await _authGet(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return PaginatedResult<Admission>.fromJson(
        data,
        (json) => Admission.fromJson(json as Map<String, dynamic>),
      );
    }

    throw ApiException('Failed to fetch admissions (${response.statusCode})');
  }

  /// Creates a new admission record.
  static Future<Admission> createAdmission(Admission admission) async {
    final response =
        await _authPost(ApiConfig.admissionsUrl, admission.toJson());

    if (response.statusCode == 201) {
      return Admission.fromJson(jsonDecode(response.body));
    }

    throw ApiException('Failed to create admission: ${response.body}');
  }

  /// Deletes an admission by ID.
  static Future<bool> deleteAdmission(int id) async {
    final response = await _authDelete(ApiConfig.admissionDetailUrl(id));
    return response.statusCode == 204;
  }
}

// ═══════════════════════════════════════════════════════════════
//  HELPERS
// ═══════════════════════════════════════════════════════════════

/// Wraps a paginated API response (DRF PageNumberPagination format).
class PaginatedResult<T> {
  final int count;
  final String? nextUrl;
  final String? previousUrl;
  final List<T> results;

  PaginatedResult({
    required this.count,
    this.nextUrl,
    this.previousUrl,
    required this.results,
  });

  bool get hasNext => nextUrl != null;
  bool get hasPrevious => previousUrl != null;

  factory PaginatedResult.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    return PaginatedResult<T>(
      count: json['count'] ?? 0,
      nextUrl: json['next'],
      previousUrl: json['previous'],
      results: (json['results'] as List<dynamic>)
          .map((item) => fromJsonT(item))
          .toList(),
    );
  }
}

/// Custom exception for API errors.
class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}
