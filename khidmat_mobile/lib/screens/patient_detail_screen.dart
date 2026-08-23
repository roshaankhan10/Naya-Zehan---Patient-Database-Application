import 'package:flutter/material.dart';

import '../services/api_client.dart';
import 'edit_patient_screen.dart';
import '../services/auth_storage.dart';

class PatientDetailScreen extends StatefulWidget {
  final Map<String, dynamic> patient;

  const PatientDetailScreen({super.key, required this.patient});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  Map<String, dynamic>? patient;
  bool _isAdmin = false; // NEW

  @override
  void initState() {
    super.initState();
    patient = widget.patient;
    _loadIsAdmin(); // NEW
  }

  Future<void> _loadIsAdmin() async { // NEW
    final isAdmin = await AuthStorage.getIsAdmin();
    if (mounted) setState(() => _isAdmin = isAdmin);
  }
  
  Future<void> _refreshPatient() async {
    try {
      final updatedPatient = await ApiClient.get('/patients/${patient!['id']}/');
      setState(() {
        patient = updatedPatient as Map<String, dynamic>;
      });
    } catch (_) {
      // ignore errors here; keep the current state visible
    }
  }

  Future<void> _deletePatient() async {
    try {
      await ApiClient.delete('/patients/${patient!['id']}/');
      if (!mounted) return;
      Navigator.pop(context, true); // return success
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete patient: $e')),
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
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Flexible(child: Text(value ?? "-", textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (patient == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Patient: ${patient!['name']}"),
        actions: [
          if (_isAdmin) 
              Tooltip(
                message: "edit patient details",
                child: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                      builder: (_) => EditPatientScreen(patient: patient!),
                    ),
                  );
                  if (result == true) {
                    await _refreshPatient();
                  }
                },
              )
              ),
          if (_isAdmin)
            Tooltip(
            message: "delete patient",
            child: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("Delete Patient"),
                    content: const Text("Are you sure you want to delete this patient?"),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text("Cancel")),
                      TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text("Delete")),
                    ],
                  ),
                );
                if (confirm == true) {
                  await _deletePatient();
                }
              },
            ),
            )
          ],
        ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _buildCard("Personal Info", [
              _buildDetailRow("Hospital ID", patient!['hospital_id']),
              _buildDetailRow("Name", patient!['name']),
              _buildDetailRow("Father's Name", patient!['father_name']),
              _buildDetailRow("Surname", patient!['surname']),
            ]),
            _buildCard("Identity", [
              _buildDetailRow("NIC", patient!['nic']),
              _buildDetailRow("DOB", patient!['dob']),
              _buildDetailRow("Age", patient!['age']?.toString()),
            ]),
            _buildCard("Demographics", [
              _buildDetailRow("Sex", patient!['sex']),
              _buildDetailRow("Marital Status", patient!['marital_status']),
              _buildDetailRow("Religion", patient!['religion']),
              _buildDetailRow("Education", patient!['education']),
              _buildDetailRow("Occupation", patient!['occupation']),
            ]),
            _buildCard("Address", [
              _buildDetailRow("Address", patient!['address']),
            ]),
            _buildAdmissionsSection(),
          ],
        ),
      ),
    );
  }
  Widget _buildAdmissionsSection() {
    final admissions = patient!['admissions'] ?? []; // <-- add ! here

    if (admissions.isEmpty) {
      return _buildCard("Admissions", [
        const Text("No admissions found."),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pushNamed(
              context,
              '/add_admission',
              arguments: patient!['hospital_id'], // <-- add ! here
            );
          },
          icon: const Icon(Icons.add),
          label: const Text("Add Admission"),
        )
      ]);
    }

    return _buildCard("Admissions", [
      ...admissions.map<Widget>((adm) {
        return ListTile(
          title: Text("Date: ${adm['date_of_admission']}"),
          subtitle: Text("Ward: ${adm['ward_no']} | Ref: ${adm['ref_source'] ?? 'N/A'}"),
          trailing: adm['is_current'] == true
              ? const Icon(Icons.check_circle, color: Colors.green)
              : null,
        );
      }).toList(),
      ElevatedButton.icon(
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/add_admission',
            arguments: patient!['hospital_id'], // <-- add ! here
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("Add Admission"),
      )
    ]);
  }

}
