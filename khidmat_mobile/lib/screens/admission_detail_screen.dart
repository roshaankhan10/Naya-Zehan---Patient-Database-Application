import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/admission.dart';
import '../services/api_service.dart';
import '../widgets/info_section.dart';
import 'patient_detail_screen.dart';

class AdmissionDetailScreen extends StatelessWidget {
  final Admission admission;

  const AdmissionDetailScreen({super.key, required this.admission});

  Future<void> _delete(BuildContext context) async {
    if (admission.id == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Admission'),
        content: const Text(
            'Are you sure you want to delete this admission record?'),
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
      final success = await ApiService.deleteAdmission(admission.id!);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Admission deleted'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admission Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete admission',
            onPressed: () => _delete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Status badge
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: admission.isCurrent
                    ? AppColors.success.withOpacity(0.08)
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: admission.isCurrent
                      ? AppColors.success.withOpacity(0.3)
                      : AppColors.border,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    admission.isCurrent
                        ? Icons.check_circle
                        : Icons.history,
                    color: admission.isCurrent
                        ? AppColors.success
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    admission.isCurrent
                        ? 'Current Admission'
                        : 'Past Admission',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: admission.isCurrent
                          ? AppColors.success
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            InfoSection(
              title: 'Admission Details',
              icon: Icons.medical_services_outlined,
              rows: [
                InfoRow('Patient', admission.patientName ?? '—'),
                InfoRow('Patient ID', admission.patientHospitalId),
                InfoRow('Date', admission.formattedDate),
                InfoRow('Ward No', admission.wardNo),
                InfoRow('Ref Source', admission.refSource ?? '—'),
                InfoRow('Status',
                    admission.isCurrent ? 'Currently Admitted' : 'Discharged'),
              ],
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PatientDetailScreen(
                        hospitalId: admission.patientHospitalId,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.person_outline),
                label: const Text('View Full Patient Details'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
