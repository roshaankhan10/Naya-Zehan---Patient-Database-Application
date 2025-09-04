// admission_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'patient_detail_screen.dart';

class AdmissionDetailScreen extends StatelessWidget {
  final Map<String, dynamic> admission;

  const AdmissionDetailScreen({super.key, required this.admission});

  Future<void> _deleteAdmission(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final response = await http.delete(
      Uri.parse("http://127.0.0.1:8000/api/admissions/${admission['id']}/"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 204) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Admission deleted successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to delete admission")),
      );
    }
  }

  String _formatDate(String rawDate) {
    try {
      final dt = DateTime.parse(rawDate);
      return "${dt.day}-${dt.month}-${dt.year}";
    } catch (_) {
      return rawDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admission Detail"),
        actions: [
          Tooltip(
            message: 'Delete admission',
            child: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteAdmission(context),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Patient: ${admission['patient_name']}"),
            Text("Ward No: ${admission['ward_no']}"),
            Text("Date: ${_formatDate(admission['date_of_admission'])}"),
            Text("Ref Source: ${admission['ref_source'] ?? '-'}"),
            Text("Current: ${admission['is_current'] ? "Yes" : "No"}"),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.person),
              label: const Text("View Full Patient Details"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PatientDetailScreen(
                      patient: {
                        "hospital_id": admission['patient'],
                        "name": admission['patient_name'],
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
