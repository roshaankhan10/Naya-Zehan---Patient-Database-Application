import 'package:flutter/material.dart';

import '../services/api_client.dart';

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

    try {
      await ApiClient.put('/patients/${patient['hospital_id']}/', patient);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update patient: $e')),
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
