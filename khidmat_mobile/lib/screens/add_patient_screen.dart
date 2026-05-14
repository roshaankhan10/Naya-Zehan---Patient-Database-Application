import 'package:flutter/material.dart';

import '../services/api_client.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();

  final _hospitalIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _nicController = TextEditingController();
  final _dobController = TextEditingController();
  final _ageController = TextEditingController();
  final _religionController = TextEditingController();
  final _educationController = TextEditingController();
  final _occupationController = TextEditingController();
  final _addressController = TextEditingController();

  String? _sex;
  String? _maritalStatus;

  bool _loading = false;
  String _error = '';

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = '';
    });

    final body = {
      "hospital_id": _hospitalIdController.text,
      "name": _nameController.text,
      "father_name": _fatherNameController.text,
      "surname": _surnameController.text,
      "nic": _nicController.text,
      "dob": _dobController.text,
      "age": int.tryParse(_ageController.text),
      "sex": _sex,
      "marital_status": _maritalStatus,
      "religion": _religionController.text,
      "education": _educationController.text,
      "occupation": _occupationController.text,
      "address": _addressController.text,
    };

    try {
      await ApiClient.post('/patients/', body);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ New patient added successfully')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Patient")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _hospitalIdController,
                      decoration: const InputDecoration(labelText: "Hospital ID"),
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: "Name"),
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                    TextFormField(
                      controller: _fatherNameController,
                      decoration: const InputDecoration(labelText: "Father's Name"),
                    ),
                    TextFormField(
                      controller: _surnameController,
                      decoration: const InputDecoration(labelText: "Surname"),
                    ),
                    TextFormField(
                      controller: _nicController,
                      decoration: const InputDecoration(labelText: "NIC"),
                    ),
                    TextFormField(
                      controller: _dobController,
                      decoration: const InputDecoration(labelText: "DOB (YYYY-MM-DD)"),
                    ),
                    TextFormField(
                      controller: _ageController,
                      decoration: const InputDecoration(labelText: "Age"),
                      keyboardType: TextInputType.number,
                    ),
                    DropdownButtonFormField<String>(
                      initialValue: _sex,
                      items: const [
                        DropdownMenuItem(value: "Male", child: Text("Male")),
                        DropdownMenuItem(value: "Female", child: Text("Female")),
                      ],
                      onChanged: (val) => setState(() => _sex = val),
                      decoration: const InputDecoration(labelText: "Sex"),
                    ),
                    DropdownButtonFormField<String>(
                      initialValue: _maritalStatus,
                      items: const [
                        DropdownMenuItem(value: "Single", child: Text("Single")),
                        DropdownMenuItem(value: "Married", child: Text("Married")),
                      ],
                      onChanged: (val) => setState(() => _maritalStatus = val),
                      decoration: const InputDecoration(labelText: "Marital Status"),
                    ),
                    TextFormField(
                      controller: _religionController,
                      decoration: const InputDecoration(labelText: "Religion"),
                    ),
                    TextFormField(
                      controller: _educationController,
                      decoration: const InputDecoration(labelText: "Education"),
                    ),
                    TextFormField(
                      controller: _occupationController,
                      decoration: const InputDecoration(labelText: "Occupation"),
                    ),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(labelText: "Address"),
                      maxLines: 2,
                    ),

                    if (_error.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(_error, style: const TextStyle(color: Colors.red)),
                      ),

                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _submit,
                      child: const Text("Save Patient"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
