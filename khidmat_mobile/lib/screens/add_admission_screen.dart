import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/admission.dart';
import '../services/api_service.dart';

class AddAdmissionScreen extends StatefulWidget {
  final String hospitalId;

  const AddAdmissionScreen({super.key, required this.hospitalId});

  @override
  State<AddAdmissionScreen> createState() => _AddAdmissionScreenState();
}

class _AddAdmissionScreenState extends State<AddAdmissionScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _hospitalIdCtrl;
  final _wardCtrl = TextEditingController();
  final _refCtrl = TextEditingController();
  DateTime? _date;
  bool _isCurrent = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _hospitalIdCtrl = TextEditingController(text: widget.hospitalId);
  }

  @override
  void dispose() {
    _hospitalIdCtrl.dispose();
    _wardCtrl.dispose();
    _refCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _date == null) {
      if (_date == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select an admission date'),
            backgroundColor: AppColors.warning,
          ),
        );
      }
      return;
    }

    setState(() => _loading = true);

    try {
      final admission = Admission(
        patientHospitalId: _hospitalIdCtrl.text.trim(),
        dateOfAdmission:
            '${_date!.year}-${_date!.month.toString().padLeft(2, '0')}-${_date!.day.toString().padLeft(2, '0')}',
        wardNo: _wardCtrl.text.trim(),
        refSource: _refCtrl.text.trim().isNotEmpty ? _refCtrl.text.trim() : null,
        isCurrent: _isCurrent,
      );

      await ApiService.createAdmission(admission);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Admission added successfully'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Admission')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Patient ID
              TextFormField(
                controller: _hospitalIdCtrl,
                readOnly: widget.hospitalId.isNotEmpty,
                decoration: InputDecoration(
                  labelText: 'Patient Hospital ID *',
                  prefixIcon: const Icon(Icons.badge_outlined),
                  filled: widget.hospitalId.isNotEmpty,
                  fillColor: widget.hospitalId.isNotEmpty
                      ? AppColors.surfaceVariant
                      : null,
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Ward
              TextFormField(
                controller: _wardCtrl,
                decoration: const InputDecoration(
                  labelText: 'Ward Number *',
                  prefixIcon: Icon(Icons.meeting_room_outlined),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Reference Source
              TextFormField(
                controller: _refCtrl,
                decoration: const InputDecoration(
                  labelText: 'Reference Source',
                  prefixIcon: Icon(Icons.person_search_outlined),
                ),
              ),
              const SizedBox(height: 16),

              // Date picker
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _date = picked);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.surfaceVariant,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          size: 20, color: AppColors.textSecondary),
                      const SizedBox(width: 12),
                      Text(
                        _date == null
                            ? 'Select Admission Date *'
                            : '${_date!.day.toString().padLeft(2, '0')}-${_date!.month.toString().padLeft(2, '0')}-${_date!.year}',
                        style: TextStyle(
                          color: _date == null
                              ? AppColors.textTertiary
                              : AppColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Current admission toggle
              Card(
                child: SwitchListTile(
                  title: const Text('Current Admission'),
                  subtitle: const Text('Mark as currently admitted'),
                  value: _isCurrent,
                  activeColor: AppColors.primary,
                  onChanged: (val) => setState(() => _isCurrent = val),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 28),

              // Submit
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white),
                        )
                      : const Text('Save Admission'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
