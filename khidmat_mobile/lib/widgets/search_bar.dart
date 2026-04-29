import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../providers/patient_provider.dart';

/// A premium search bar with selectable search field (Hospital ID, Name, etc.)
class PatientSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final SearchField searchField;
  final ValueChanged<SearchField> onFieldChanged;
  final ValueChanged<String> onSearch;

  const PatientSearchBar({
    super.key,
    required this.controller,
    required this.searchField,
    required this.onFieldChanged,
    required this.onSearch,
  });

  String _fieldLabel(SearchField f) {
    switch (f) {
      case SearchField.hospitalId:
        return 'Hospital ID';
      case SearchField.name:
        return 'Name';
      case SearchField.fatherName:
        return "Father's Name";
      case SearchField.surname:
        return 'Surname';
    }
  }

  IconData _fieldIcon(SearchField f) {
    switch (f) {
      case SearchField.hospitalId:
        return Icons.badge_outlined;
      case SearchField.name:
        return Icons.person_outline;
      case SearchField.fatherName:
        return Icons.family_restroom;
      case SearchField.surname:
        return Icons.group_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Search field chips ──
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: SearchField.values.map((field) {
                final isSelected = field == searchField;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    avatar: Icon(
                      _fieldIcon(field),
                      size: 16,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    label: Text(_fieldLabel(field)),
                    selected: isSelected,
                    onSelected: (_) => onFieldChanged(field),
                    selectedColor: AppColors.primarySurface,
                    backgroundColor: AppColors.surfaceVariant,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.3)
                            : AppColors.border,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // ── Search text field ──
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) {
            return TextField(
              controller: controller,
              onSubmitted: onSearch,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search by ${_fieldLabel(searchField).toLowerCase()}...',
                prefixIcon:
                    const Icon(Icons.search, color: AppColors.textTertiary),
                suffixIcon: value.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          controller.clear();
                          onSearch('');
                        },
                      )
                    : null,
              ),
            );
          },
        ),
      ],
    );
  }
}
