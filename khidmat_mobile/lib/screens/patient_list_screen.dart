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
  List<dynamic> _filteredPatients = [];

  @override
  void initState() {
    super.initState();
    _fetchPatients();
  }

  // Future<void> _fetchPatients() async {
  //   try {
  //     final patients = await ApiClient.get('/patients/');
  //     setState(() {
  //       _patients = patients as List<dynamic>;
  //       _filteredPatients = _patients;
  //       _loading = false;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       _error = 'Error: $e';
  //       _loading = false;
  //     });
  //   }
  // }
    Future<void> _fetchPatients() async {
    try {
      final response = await ApiClient.get('/patients/');
      final results = (response as Map<String, dynamic>)['results'] as List<dynamic>;
      setState(() {
        _patients = results;
        _filteredPatients = results;
        _loading = false;
      });
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
      _filteredPatients = results;
    });
  }

  Future<void> _logout() async {
    await AuthStorage.clearAll();
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
  }

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
              if (added == true) _fetchPatients();
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
