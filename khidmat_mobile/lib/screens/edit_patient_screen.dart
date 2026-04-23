import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/patient.dart';
import '../services/api_service.dart';

class EditPatientScreen extends StatefulWidget {
  final Patient patient;

  const EditPatientScreen({super.key, required this.patient});

  @override
  State<EditPatientScreen> createState() => _EditPatientScreenState();
}

class _EditPatientScreenState extends State<EditPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _fatherNameCtrl;
  late final TextEditingController _surnameCtrl;
  late final TextEditingController _nicCtrl;
  late final TextEditingController _dobCtrl;
  late final TextEditingController _ageCtrl;
  late final TextEditingController _sexCtrl;
  late final TextEditingController _maritalCtrl;
  late final TextEditingController _religionCtrl;
  late final TextEditingController _educationCtrl;
  late final TextEditingController _occupationCtrl;
  late final TextEditingController _addressCtrl;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final p = widget.patient;
    _nameCtrl = TextEditingController(text: p.name);
    _fatherNameCtrl = TextEditingController(text: p.fatherName ?? '');
    _surnameCtrl = TextEditingController(text: p.surname ?? '');
    _nicCtrl = TextEditingController(text: p.nic ?? '');
    _dobCtrl = TextEditingController(text: p.dob ?? '');
    _ageCtrl = TextEditingController(text: p.age?.toString() ?? '');
    _sexCtrl = TextEditingController(text: p.sex ?? '');
    _maritalCtrl = TextEditingController(text: p.maritalStatus ?? '');
    _religionCtrl = TextEditingController(text: p.religion ?? '');
    _educationCtrl = TextEditingController(text: p.education ?? '');
    _occupationCtrl = TextEditingController(text: p.occupation ?? '');
    _addressCtrl = TextEditingController(text: p.address ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _fatherNameCtrl.dispose();
    _surnameCtrl.dispose();
    _nicCtrl.dispose();
    _dobCtrl.dispose();
    _ageCtrl.dispose();
    _sexCtrl.dispose();
    _maritalCtrl.dispose();
    _religionCtrl.dispose();
    _educationCtrl.dispose();
    _occupationCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final updated = widget.patient.copyWith(
        name: _nameCtrl.text.trim(),
        fatherName: _fatherNameCtrl.text.trim(),
        surname: _surnameCtrl.text.trim(),
        nic: _nicCtrl.text.trim(),
        dob: _dobCtrl.text.trim().isNotEmpty ? _dobCtrl.text.trim() : null,
        age: int.tryParse(_ageCtrl.text.trim()),
        sex: _sexCtrl.text.trim(),
        maritalStatus: _maritalCtrl.text.trim(),
        religion: _religionCtrl.text.trim(),
        education: _educationCtrl.text.trim(),
        occupation: _occupationCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
      );

      await ApiService.updatePatient(updated);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Patient updated successfully'),
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

  Widget _field(String label, TextEditingController ctrl,
      {bool readOnly = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: ctrl,
        readOnly: readOnly,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          filled: readOnly,
          fillColor: readOnly ? AppColors.surfaceVariant : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Patient'),
        actions: [
          TextButton.icon(
            onPressed: _loading ? null : _save,
            icon: _loading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.check, color: Colors.white),
            label: Text(
              'Save',
              style: TextStyle(
                  color: _loading ? Colors.white54 : Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _field('Hospital ID', TextEditingController(text: widget.patient.hospitalId),
                  readOnly: true),
              _field('Name', _nameCtrl),
              _field("Father's Name", _fatherNameCtrl),
              _field('Surname', _surnameCtrl),
              _field('NIC', _nicCtrl),
              _field('Date of Birth', _dobCtrl),
              _field('Age', _ageCtrl),
              _field('Sex', _sexCtrl),
              _field('Marital Status', _maritalCtrl),
              _field('Religion', _religionCtrl),
              _field('Education', _educationCtrl),
              _field('Occupation', _occupationCtrl),
              _field('Address', _addressCtrl, maxLines: 3),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : _save,
                  child: _loading
                      ? const CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white)
                      : const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
