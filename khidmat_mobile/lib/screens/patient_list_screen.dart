import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
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
  List<dynamic> _filteredPatients = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchPatients();
  }

  Future<void> _fetchPatients() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        setState(() {
          _error = 'No access token found. Please login again.';
          _loading = false;
        });
        return;
      }

      final url = Uri.parse('http://127.0.0.1:8000/api/patients/');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final patients = jsonDecode(response.body);
        setState(() {
          _patients = patients;
          _filteredPatients = patients;
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to fetch patients: ${response.statusCode}';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _loading = false;
      });
    }
  }

  void _filterPatients(String query) {
    final results = _patients.where((p) {
      final name = (p['name'] ?? '').toString().toLowerCase();
      final id = (p['hospital_id'] ?? '').toString().toLowerCase();
      return name.contains(query.toLowerCase()) ||
          id.contains(query.toLowerCase());
    }).toList();

    setState(() {
      _searchQuery = query;
      _filteredPatients = results;
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patients'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final added = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddPatientScreen()),
              );
              if (added == true) _fetchPatients();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search by Name or ID',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: _filterPatients,
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error.isNotEmpty
                    ? Center(child: Text(_error, style: const TextStyle(color: Colors.red)))
                    : ListView.builder(
                        itemCount: _filteredPatients.length,
                        itemBuilder: (context, index) {
                          final patient = _filteredPatients[index];
                          return ListTile(
                            title: Text(patient['name'] ?? 'Unknown'),
                            subtitle: Text('ID: ${patient['hospital_id']}'),
                            onTap: () async {
                              final deleted = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PatientDetailScreen(patient: patient),
                                ),
                              );
                              if (deleted == true) _fetchPatients();
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
