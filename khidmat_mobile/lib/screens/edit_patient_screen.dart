import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class EditPatientScreen extends StatefulWidget {
  final Map<String, dynamic> patient;

  const EditPatientScreen({super.key, required this.patient});

  @override
  State<EditPatientScreen> createState() => _EditPatientScreenState();
}

class _EditPatientScreenState extends State<EditPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> patient;

  @override
  void initState() {
    super.initState();
    patient = Map<String, dynamic>.from(widget.patient);
  }

  Future<void> _updatePatient() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final response = await http.put(
      Uri.parse("http://127.0.0.1:8000/api/patients/${patient['hospital_id']}/"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: jsonEncode(patient),
    );

    if (!mounted) return;

    if (response.statusCode == 200) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update patient")),
      );
    }
  }

  Widget _buildTextField(String label, String key, {bool readOnly = false}) {
    return TextFormField(
      initialValue: patient[key]?.toString() ?? '',
      readOnly: readOnly,
      decoration: InputDecoration(labelText: label),
      onSaved: (value) => patient[key] = value,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Patient")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField("Hospital ID", "hospital_id", readOnly: true),
              _buildTextField("Name", "name"),
              _buildTextField("Father's Name", "father_name"),
              _buildTextField("Surname", "surname"),
              _buildTextField("NIC", "nic"),
              _buildTextField("DOB", "dob"),
              _buildTextField("Age", "age"),
              _buildTextField("Sex", "sex"),
              _buildTextField("Marital Status", "marital_status"),
              _buildTextField("Religion", "religion"),
              _buildTextField("Education", "education"),
              _buildTextField("Occupation", "occupation"),
              _buildTextField("Address", "address"),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updatePatient,
                child: const Text("Save Changes"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
