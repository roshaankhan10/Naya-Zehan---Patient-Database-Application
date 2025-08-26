import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PatientDetailScreen extends StatelessWidget {
  final Map<String, dynamic> patient;
  const PatientDetailScreen({super.key, required this.patient});

  Future<void> _deletePatient(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null) throw Exception("No access token found");

      final url = Uri.parse(
          'http://127.0.0.1:8000/api/patients/${patient['hospital_id']}/');
      final response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 204) {
        Navigator.pop(context, true); // go back & refresh list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Widget _buildCard(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Flexible(
            child: Text(value ?? "N/A",
                textAlign: TextAlign.left,
                style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(patient['name'] ?? 'Patient'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deletePatient(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _buildCard("Personal Info", [
              _buildDetailRow("Hospital ID ", patient['hospital_id']),
              _buildDetailRow("Name ", patient['name']),
              _buildDetailRow("Father's Name ", patient['father_name']),
              _buildDetailRow("Surname ", patient['surname']),
            ]),
            _buildCard("Identity", [
              _buildDetailRow("NIC ", patient['nic']),
              _buildDetailRow("DOB ", patient['dob']),
              _buildDetailRow("Age ", patient['age']?.toString()),
            ]),
            _buildCard("Demographics", [
              _buildDetailRow("Sex ", patient['sex']),
              _buildDetailRow("Marital Status ", patient['marital_status']),
              _buildDetailRow("Religion ", patient['religion']),
              _buildDetailRow("Education ", patient['education']),
              _buildDetailRow("Occupation ", patient['occupation']),
            ]),
            _buildCard("Address", [
              _buildDetailRow("Address ", patient['address']),
            ]),
          ],
        ),
      ),
    );
  }
}
