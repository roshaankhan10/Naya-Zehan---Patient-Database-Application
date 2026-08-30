import 'package:flutter/material.dart';

import '../services/api_client.dart';

class AddAdmissionScreen extends StatefulWidget {
  final String hospitalId;

  const AddAdmissionScreen({super.key, required this.hospitalId});

  @override
  State<AddAdmissionScreen> createState() => _AddAdmissionScreenState();
}

class _AddAdmissionScreenState extends State<AddAdmissionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _wardController = TextEditingController();
  final _refController = TextEditingController();
  DateTime? _date;
  bool _isCurrent = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _date == null) return;

    // final body = {
    //   "patient": widget.hospitalId,
    //   "date_of_admission": _date!.toIso8601String().split('T')[0],
    //   "ward_no": _wardController.text,
    //   "ref_source": _refController.text,
    //   "is_current": _isCurrent,
    // };
    final body = {
      "patient": int.tryParse(widget.hospitalId),
      "date_of_admission": _date!.toIso8601String().split('T')[0],
      "ward_no": _wardController.text,
      "ref_source": _refController.text,
      "is_current": _isCurrent,
    };

    try {
      await ApiClient.post('/admissions/', body);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Patient admitted successfully')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add admission: $e')),
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Admission")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // TextFormField(
              //   controller: _refController,
              //   decoration: const InputDecoration(labelText: "Patient Name"),
              // ),
              TextFormField(
                controller: _wardController,
                decoration: const InputDecoration(labelText: "Ward No"),
                validator: (v) => v == null || v.isEmpty ? "Required" : null,
              ),
              TextFormField(
                controller: _refController,
                decoration: const InputDecoration(labelText: "Reference Source"),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(_date == null
                      ? "Pick Admission Date"
                      : "Date: ${_date!.toLocal()}".split(' ')[0]),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) setState(() => _date = picked);
                    },
                  )
                ],
              ),
              SwitchListTile(
                title: const Text("Current Admission"),
                value: _isCurrent,
                onChanged: (val) => setState(() => _isCurrent = val),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text("Save"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
