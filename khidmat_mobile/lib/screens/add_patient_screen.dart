import 'dart:convert';
import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/patient.dart';
import '../services/api_service.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  // Controllers
  final _hospitalIdCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _fatherNameCtrl = TextEditingController();
  final _surnameCtrl = TextEditingController();
  final _nicCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final _religionCtrl = TextEditingController();
  final _educationCtrl = TextEditingController();
  final _occupationCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  String? _sex;
  String? _maritalStatus;
  bool _loading = false;

  @override
  void dispose() {
    _hospitalIdCtrl.dispose();
    _nameCtrl.dispose();
    _fatherNameCtrl.dispose();
    _surnameCtrl.dispose();
    _nicCtrl.dispose();
    _dobCtrl.dispose();
    _ageCtrl.dispose();
    _religionCtrl.dispose();
    _educationCtrl.dispose();
    _occupationCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final patient = Patient(
        hospitalId: _hospitalIdCtrl.text.trim(),
        name: _nameCtrl.text.trim(),
        fatherName: _fatherNameCtrl.text.trim(),
        surname: _surnameCtrl.text.trim(),
        nic: _nicCtrl.text.trim(),
        dob: _dobCtrl.text.trim().isNotEmpty ? _dobCtrl.text.trim() : null,
        age: int.tryParse(_ageCtrl.text.trim()),
        sex: _sex,
        maritalStatus: _maritalStatus,
        religion: _religionCtrl.text.trim(),
        education: _educationCtrl.text.trim(),
        occupation: _occupationCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
      );

      await ApiService.createPatient(patient);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Patient added successfully'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }

    setState(() => _loading = false);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _dobCtrl.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Patient')),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : Form(
              key: _formKey,
              child: Stepper(
                currentStep: _currentStep,
                onStepContinue: () {
                  if (_currentStep < 2) {
                    setState(() => _currentStep++);
                  } else {
                    _submit();
                  }
                },
                onStepCancel: () {
                  if (_currentStep > 0) {
                    setState(() => _currentStep--);
                  }
                },
                controlsBuilder: (context, details) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(
                      children: [
                        ElevatedButton(
                          onPressed: details.onStepContinue,
                          child: Text(
                              _currentStep == 2 ? 'Save Patient' : 'Next'),
                        ),
                        if (_currentStep > 0) ...[
                          const SizedBox(width: 12),
                          TextButton(
                            onPressed: details.onStepCancel,
                            child: const Text('Back'),
                          ),
                        ],
                      ],
                    ),
                  );
                },
                steps: [
                  // Step 1: Identity
                  Step(
                    title: const Text('Identification'),
                    subtitle: const Text('Hospital ID, name, NIC'),
                    isActive: _currentStep >= 0,
                    state:
                        _currentStep > 0 ? StepState.complete : StepState.indexed,
                    content: Column(
                      children: [
                        TextFormField(
                          controller: _hospitalIdCtrl,
                          decoration:
                              const InputDecoration(labelText: 'Hospital ID *'),
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _nameCtrl,
                          decoration:
                              const InputDecoration(labelText: 'Full Name *'),
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Required' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _fatherNameCtrl,
                          decoration: const InputDecoration(
                              labelText: "Father's / Husband's Name"),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _surnameCtrl,
                          decoration:
                              const InputDecoration(labelText: 'Surname'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _nicCtrl,
                          decoration:
                              const InputDecoration(labelText: 'NIC Number'),
                        ),
                      ],
                    ),
                  ),

                  // Step 2: Demographics
                  Step(
                    title: const Text('Demographics'),
                    subtitle: const Text('Age, sex, status, religion'),
                    isActive: _currentStep >= 1,
                    state:
                        _currentStep > 1 ? StepState.complete : StepState.indexed,
                    content: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _dobCtrl,
                                readOnly: true,
                                decoration: InputDecoration(
                                  labelText: 'Date of Birth',
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.calendar_today,
                                        size: 18),
                                    onPressed: _pickDate,
                                  ),
                                ),
                                onTap: _pickDate,
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 80,
                              child: TextFormField(
                                controller: _ageCtrl,
                                decoration:
                                    const InputDecoration(labelText: 'Age'),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _sex,
                          items: const [
                            DropdownMenuItem(value: 'M', child: Text('Male')),
                            DropdownMenuItem(
                                value: 'F', child: Text('Female')),
                          ],
                          onChanged: (val) => setState(() => _sex = val),
                          decoration:
                              const InputDecoration(labelText: 'Sex'),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _maritalStatus,
                          items: const [
                            DropdownMenuItem(
                                value: 'S', child: Text('Single')),
                            DropdownMenuItem(
                                value: 'M', child: Text('Married')),
                            DropdownMenuItem(
                                value: 'W', child: Text('Widowed')),
                            DropdownMenuItem(
                                value: 'D', child: Text('Divorced')),
                          ],
                          onChanged: (val) =>
                              setState(() => _maritalStatus = val),
                          decoration: const InputDecoration(
                              labelText: 'Marital Status'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _religionCtrl,
                          decoration:
                              const InputDecoration(labelText: 'Religion'),
                        ),
                      ],
                    ),
                  ),

                  // Step 3: Additional
                  Step(
                    title: const Text('Additional Details'),
                    subtitle: const Text('Education, occupation, address'),
                    isActive: _currentStep >= 2,
                    state: StepState.indexed,
                    content: Column(
                      children: [
                        TextFormField(
                          controller: _educationCtrl,
                          decoration:
                              const InputDecoration(labelText: 'Education'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _occupationCtrl,
                          decoration:
                              const InputDecoration(labelText: 'Occupation'),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _addressCtrl,
                          decoration:
                              const InputDecoration(labelText: 'Address'),
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
