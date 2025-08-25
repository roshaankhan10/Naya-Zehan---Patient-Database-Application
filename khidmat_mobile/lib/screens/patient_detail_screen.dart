// lib/screens/patient_detail_screen.dart
import 'package:flutter/material.dart';

class PatientDetailScreen extends StatelessWidget {
  final Map<String, dynamic> patient;

  const PatientDetailScreen({super.key, required this.patient});

  String _formatField(String? value) {
    if (value == null || value.isEmpty) {
      return "N/A";
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(patient['name'] ?? 'Patient Detail')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow("Hospital ID", patient['hospital_id']),
            _buildDetailRow("Name", patient['name']),
            _buildDetailRow("Father's Name", patient['father_name']),
            _buildDetailRow("Surname", patient['surname']),
            _buildDetailRow("NIC", patient['nic']),
            _buildDetailRow("Date of Birth", patient['dob']),
            _buildDetailRow("Age", patient['age']?.toString()),
            _buildDetailRow("Sex", patient['sex']),
            _buildDetailRow("Marital Status", patient['marital_status']),
            _buildDetailRow("Religion", patient['religion']),
            _buildDetailRow("Education", patient['education']),
            _buildDetailRow("Occupation", patient['occupation']),
            _buildDetailRow("Address", patient['address']),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 140,
              child: Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16))),
          Expanded(
            child: Text(
              _formatField(value),
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
