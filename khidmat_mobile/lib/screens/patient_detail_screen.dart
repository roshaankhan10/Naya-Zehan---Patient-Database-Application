import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/patient.dart';
import '../models/admission.dart';
import '../services/api_service.dart';
import '../widgets/info_section.dart';
import 'edit_patient_screen.dart';
import 'add_admission_screen.dart';

class PatientDetailScreen extends StatefulWidget {
  final String hospitalId;

  const PatientDetailScreen({super.key, required this.hospitalId});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  Patient? _patient;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchPatient();
  }

  Future<void> _fetchPatient() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final patient = await ApiService.getPatientDetail(widget.hospitalId);
      setState(() {
        _patient = patient;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _deletePatient() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Patient'),
        content: Text(
            'Are you sure you want to delete ${_patient?.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ApiService.deletePatient(widget.hospitalId);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient deleted successfully')),
        );
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Patient Details')),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (_error != null || _patient == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Patient Details')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text(_error ?? 'Patient not found'),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _fetchPatient, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final p = _patient!;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Header ──
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.headerGradient,
                ),
                child: SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 30),
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _initials(p.name),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          p.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'ID: ${p.hospitalId}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit patient',
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditPatientScreen(patient: p),
                    ),
                  );
                  if (result == true) _fetchPatient();
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete patient',
                onPressed: _deletePatient,
              ),
            ],
          ),

          // ── Content ──
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Personal Info
                InfoSection(
                  title: 'Personal Info',
                  icon: Icons.person_outline,
                  rows: [
                    InfoRow('Hospital ID', p.hospitalId),
                    InfoRow('Name', p.name),
                    InfoRow("Father's Name", p.fatherName ?? ''),
                    InfoRow('Surname', p.surname ?? ''),
                  ],
                ),

                // Identity
                InfoSection(
                  title: 'Identity',
                  icon: Icons.badge_outlined,
                  rows: [
                    InfoRow('NIC', p.nic ?? ''),
                    InfoRow('Date of Birth', p.dob ?? ''),
                    InfoRow('Age', p.age?.toString() ?? ''),
                  ],
                ),

                // Demographics
                InfoSection(
                  title: 'Demographics',
                  icon: Icons.groups_outlined,
                  rows: [
                    InfoRow('Sex', p.sex ?? ''),
                    InfoRow('Marital Status', p.maritalStatus ?? ''),
                    InfoRow('Religion', p.religion ?? ''),
                    InfoRow('Education', p.education ?? ''),
                    InfoRow('Occupation', p.occupation ?? ''),
                  ],
                ),

                // Address
                InfoSection(
                  title: 'Address',
                  icon: Icons.location_on_outlined,
                  rows: [
                    InfoRow('Address', p.address ?? ''),
                  ],
                ),

                // Admissions
                _buildAdmissionsSection(p),

                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdmissionsSection(Patient p) {
    final admissions = p.admissions ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.medical_services_outlined,
                      size: 18, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Admission History',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${admissions.length}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(),

            if (admissions.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    'No admissions recorded',
                    style: TextStyle(color: AppColors.textTertiary),
                  ),
                ),
              )
            else
              ...admissions.map((admJson) {
                final adm = Admission.fromJson(admJson);
                return Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: adm.isCurrent
                        ? Border.all(
                            color: AppColors.success.withOpacity(0.4),
                            width: 1.5)
                        : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: adm.isCurrent
                              ? AppColors.success.withOpacity(0.1)
                              : AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          adm.isCurrent
                              ? Icons.check_circle_outline
                              : Icons.history,
                          size: 18,
                          color: adm.isCurrent
                              ? AppColors.success
                              : AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              adm.formattedDate,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Ward ${adm.wardNo} • Ref: ${adm.refSource ?? "N/A"}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (adm.isCurrent)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Current',
                            style: TextStyle(
                              color: AppColors.success,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }),

            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final added = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AddAdmissionScreen(hospitalId: p.hospitalId),
                    ),
                  );
                  if (added == true) _fetchPatient();
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Admission'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
