// admissions_list_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'admission_detail_screen.dart';
import 'add_admission_screen.dart';

class AdmissionsListScreen extends StatefulWidget {
  const AdmissionsListScreen({super.key});

  @override
  State<AdmissionsListScreen> createState() => _AdmissionsListScreenState();
}

class _AdmissionsListScreenState extends State<AdmissionsListScreen> {
  List<dynamic> admissions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchAdmissions();
  }

  Future<void> _fetchAdmissions() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final response = await http.get(
      Uri.parse("http://127.0.0.1:8000/api/admissions/?is_current=true"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      setState(() {
        admissions = jsonDecode(response.body);
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Current Admissions"),
        actions: [
          Tooltip(
            message: 'add new admission',
            child:IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                final added = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddAdmissionScreen(hospitalId: "")), // We’ll adjust this
                );
                if (added == true) _fetchAdmissions();
              },
            ),
          ),
          ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: admissions.length,
              itemBuilder: (context, index) {
                final adm = admissions[index];
                return ListTile(
                  title: Text("${adm['patient_name']}"),
                  subtitle: Text("Ward ${adm['ward_no']} | ${adm['date_of_admission']}"),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdmissionDetailScreen(admission: adm),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
