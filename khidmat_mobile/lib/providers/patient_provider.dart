import 'package:flutter/foundation.dart';
import '../models/patient.dart';
import '../services/api_service.dart';

/// Search type options for the multi-parameter search.
enum SearchField { hospitalId, name, fatherName, surname }

/// Manages patient list state, search, and pagination.
class PatientProvider extends ChangeNotifier {
  List<Patient> _patients = [];
  bool _isLoading = false;
  String? _error;
  String? _nextPageUrl;
  int _totalCount = 0;
  SearchField _searchField = SearchField.name;
  String _searchQuery = '';

  List<Patient> get patients => _patients;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _nextPageUrl != null;
  int get totalCount => _totalCount;
  SearchField get searchField => _searchField;
  String get searchQuery => _searchQuery;

  /// Change the active search field (Hospital ID, Name, etc.)
  void setSearchField(SearchField field) {
    _searchField = field;
    notifyListeners();
  }

  /// Perform a search with the current field and query. Resets pagination.
  Future<void> search(String query) async {
    _searchQuery = query.trim();

    if (_searchQuery.isEmpty) {
      _patients = [];
      _nextPageUrl = null;
      _totalCount = 0;
      _error = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    _patients = [];
    notifyListeners();

    try {
      final result = await ApiService.searchPatients(
        hospitalId: _searchField == SearchField.hospitalId ? _searchQuery : null,
        name: _searchField == SearchField.name ? _searchQuery : null,
        fatherName: _searchField == SearchField.fatherName ? _searchQuery : null,
        surname: _searchField == SearchField.surname ? _searchQuery : null,
      );

      _patients = result.results;
      _nextPageUrl = result.nextUrl;
      _totalCount = result.count;
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Connection error: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Load the next page of results (infinite scroll).
  Future<void> loadMore() async {
    if (_nextPageUrl == null || _isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      final result = await ApiService.searchPatients(
        pageUrl: _nextPageUrl,
      );

      _patients.addAll(result.results);
      _nextPageUrl = result.nextUrl;
      _totalCount = result.count;
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Connection error: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Fetch all patients (first page). Used when no search is active.
  Future<void> fetchAll() async {
    _isLoading = true;
    _error = null;
    _patients = [];
    _searchQuery = '';
    notifyListeners();

    try {
      final result = await ApiService.getPatients();
      _patients = result.results;
      _nextPageUrl = result.nextUrl;
      _totalCount = result.count;
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Connection error: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Clear all state.
  void clear() {
    _patients = [];
    _nextPageUrl = null;
    _totalCount = 0;
    _searchQuery = '';
    _error = null;
    notifyListeners();
  }
}
