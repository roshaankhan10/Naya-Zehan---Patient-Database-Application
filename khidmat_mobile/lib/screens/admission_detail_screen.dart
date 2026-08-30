// admission_detail_screen.dart
import 'package:flutter/material.dart';

import '../services/api_client.dart';
import 'patient_detail_screen.dart';

class AdmissionDetailScreen extends StatelessWidget {
  final Map<String, dynamic> admission;

  const AdmissionDetailScreen({super.key, required this.admission});

  Future<void> _deleteAdmission(BuildContext context) async {
    try {
      await ApiClient.delete('/admissions/${admission['id']}/');
      if (context.mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Admission deleted successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete admission: $e')),
        );
      }
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
                        "id": admission['patient'],
                        "hospital_id": admission['patient_hospital_id'],
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
