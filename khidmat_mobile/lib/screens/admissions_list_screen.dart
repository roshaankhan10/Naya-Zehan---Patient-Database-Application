// lib/screens/admissions_list_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'add_admission_screen.dart';
import 'admission_detail_screen.dart';

class AdmissionsListScreen extends StatefulWidget {
  const AdmissionsListScreen({super.key});

  @override
  State<AdmissionsListScreen> createState() => _AdmissionsListScreenState();
}

class _AdmissionsListScreenState extends State<AdmissionsListScreen> {
  bool _loading = true;
  String _error = '';
  List<dynamic> _admissions = [];
  List<dynamic> _filteredAdmissions = [];
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAdmissions();
    _searchController.addListener(_applySearch);
  }

  Future<void> _fetchAdmissions() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access_token");

    final response = await http.get(
      Uri.parse("http://127.0.0.1:8000/api/admissions/"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      setState(() {
        _admissions = jsonDecode(response.body);
        _filteredAdmissions = _admissions;
        _loading = false;
      });
    } else {
      setState(() {
        _error = "Failed: ${response.statusCode}";
        _loading = false;
      });
    }
  }

  void _applySearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredAdmissions = _admissions.where((adm) {
        final ward = (adm['ward_no'] ?? '').toString().toLowerCase();
        final ref = (adm['ref_source'] ?? '').toString().toLowerCase();
        return ward.contains(query) || ref.contains(query);
      }).toList();
    });
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("Admissions"),
      actions: [
        Tooltip(
          message: 'Add admission',
          child: IconButton( 
            icon: const Icon(Icons.add),
            onPressed: () async {
              final added = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddAdmissionScreen(hospitalId: "")),
              );
              if (added == true) _fetchAdmissions();
            },
          ),
        ),
      ],
    ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text(_error, style: const TextStyle(color: Colors.red)))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          labelText: "Search by ward or reference source",
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _filteredAdmissions.length,
                        itemBuilder: (context, index) {
                          final adm = _filteredAdmissions[index];
                          return ListTile(
                            title: Text("Ward ${adm['ward_no']}"),
                            subtitle: Text("Ref: ${adm['ref_source'] ?? '-'}"),
                            trailing: adm['is_current'] == true
                                ? const Icon(Icons.check_circle, color: Colors.green)
                                : null,
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AdmissionDetailScreen(admission: adm),
                                ),
                              );
                              _fetchAdmissions();
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
