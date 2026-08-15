import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../services/auth_storage.dart';
import 'add_patient_screen.dart';
import 'patient_detail_screen.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  bool _loading = true;
  String _error = '';
  List<dynamic> _patients = [];
  String? _nextPageUrl;
  String? _previousPageUrl;
  int _currentPage = 1;
  int _totalCount = 0;
  Timer? _debounce;
  String _currentQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchPatients();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  String _stripApiPrefix(String fullUrl) {
    final uri = Uri.parse(fullUrl);
    final pathAndQuery = '${uri.path}${uri.hasQuery ? '?${uri.query}' : ''}';
    return pathAndQuery.replaceFirst('/api', '');
  }

  Future<void> _fetchPatients({String query = '', int page = 1}) async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final params = <String>[];
      if (query.isNotEmpty) params.add('search=${Uri.encodeQueryComponent(query)}');
      if (page > 1) params.add('page=$page');
      final path = '/patients/${params.isNotEmpty ? '?${params.join('&')}' : ''}';

      final response = await ApiClient.get(path);
      final map = response as Map<String, dynamic>;
      setState(() {
        _patients = map['results'] as List<dynamic>;
        _nextPageUrl = map['next'] as String?;
        _previousPageUrl = map['previous'] as String?;
        _totalCount = map['count'] as int? ?? 0;
        _currentQuery = query;
        _currentPage = page;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _loading = false;
      });
    }
  }

  Future<void> _goToNextPage() async {
    if (_nextPageUrl == null) return;
    setState(() => _loading = true);
    try {
      final response = await ApiClient.get(_stripApiPrefix(_nextPageUrl!));
      final map = response as Map<String, dynamic>;
      setState(() {
        _patients = map['results'] as List<dynamic>;
        _nextPageUrl = map['next'] as String?;
        _previousPageUrl = map['previous'] as String?;
        _currentPage += 1;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _loading = false;
      });
    }
  }

  Future<void> _goToPreviousPage() async {
    if (_previousPageUrl == null) return;
    setState(() => _loading = true);
    try {
      final response = await ApiClient.get(_stripApiPrefix(_previousPageUrl!));
      final map = response as Map<String, dynamic>;
      setState(() {
        _patients = map['results'] as List<dynamic>;
        _nextPageUrl = map['next'] as String?;
        _previousPageUrl = map['previous'] as String?;
        _currentPage -= 1;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _loading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _fetchPatients(query: query, page: 1);
    });
  }

  Future<void> _logout() async {
    await AuthStorage.clearAll();
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
  }

  int get _totalPages => _totalCount == 0 ? 1 : (( _totalCount + 24) ~/ 25);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patients'),
        actions: [
          Tooltip(
            message: 'Add patient',
            child: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                final added = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddPatientScreen()),
                );
                if (added == true) _fetchPatients(query: _currentQuery, page: _currentPage);
              },
            ),
          ),
          Tooltip(
            message: 'View admissions',
            child: IconButton(
              icon: const Icon(Icons.people),
              onPressed: () {
                Navigator.pushNamed(context, '/admissions');
              },
            ),
          ),
          Tooltip(
            message: 'Logout',
            child: IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search by Name, Father Name, Surname, or ID',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error.isNotEmpty
                    ? Center(child: Text(_error, style: const TextStyle(color: Colors.red)))
                    : ListView.builder(
                        itemCount: _patients.length,
                        itemBuilder: (context, index) {
                          final patient = _patients[index];
                          return ListTile(
                            title: Text(patient['name'] ?? 'Unknown'),
                            subtitle: Text('ID: ${patient['hospital_id'] ?? 'N/A'}'),
                            onTap: () async {
                              final deleted = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PatientDetailScreen(patient: patient),
                                ),
                              );
                              if (deleted == true) {
                                _fetchPatients(query: _currentQuery, page: _currentPage);
                              }
                            },
                          );
                        },
                      ),
          ),
          if (!_loading && _error.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _previousPageUrl != null ? _goToPreviousPage : null,
                  ),
                  Text('Page $_currentPage of $_totalPages  •  $_totalCount total'),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _nextPageUrl != null ? _goToNextPage : null,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}