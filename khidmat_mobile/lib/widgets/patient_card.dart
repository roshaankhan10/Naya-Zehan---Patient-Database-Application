import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/patient.dart';

/// A premium patient card for list views with avatar, key info, and tap action.
class PatientCard extends StatelessWidget {
  final Patient patient;
  final VoidCallback onTap;

  const PatientCard({
    super.key,
    required this.patient,
    required this.onTap,
  });

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  Color _avatarColor(String id) {
    final colors = [
      AppColors.primary,
      AppColors.primaryLight,
      const Color(0xFF6366F1),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFF14B8A6),
      const Color(0xFFF97316),
    ];
    final hash = id.hashCode.abs();
    return colors[hash % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // ── Avatar ──
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: _avatarColor(patient.hospitalId).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    _initials(patient.name),
                    style: TextStyle(
                      color: _avatarColor(patient.hospitalId),
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // ── Info ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      patient.name,
                      style: theme.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    if (patient.fatherName != null &&
                        patient.fatherName!.isNotEmpty)
                      Text(
                        'F: ${patient.fatherName}',
                        style: theme.textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _infoPill(
                          Icons.badge_outlined,
                          patient.hospitalId,
                        ),
                        if (patient.age != null) ...[
                          const SizedBox(width: 8),
                          _infoPill(
                            Icons.calendar_today_outlined,
                            '${patient.age}y',
                          ),
                        ],
                        if (patient.sex != null) ...[
                          const SizedBox(width: 8),
                          _infoPill(
                            patient.sex == 'M' || patient.sex == 'Male'
                                ? Icons.male
                                : Icons.female,
                            patient.sex!,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // ── Arrow ──
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoPill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textTertiary),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
