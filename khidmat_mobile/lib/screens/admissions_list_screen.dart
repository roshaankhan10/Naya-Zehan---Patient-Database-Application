import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/admission.dart';
import '../services/api_service.dart';
import 'admission_detail_screen.dart';
import 'add_admission_screen.dart';

class AdmissionsListScreen extends StatefulWidget {
  const AdmissionsListScreen({super.key});

  @override
  State<AdmissionsListScreen> createState() => _AdmissionsListScreenState();
}

class _AdmissionsListScreenState extends State<AdmissionsListScreen> {
  bool _loading = true;
  String? _error;
  List<Admission> _admissions = [];
  List<Admission> _filtered = [];
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAdmissions();
    _searchCtrl.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchAdmissions() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await ApiService.getAdmissions();
      setState(() {
        _admissions = result.results;
        _filtered = result.results;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _applyFilter() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = _admissions.where((a) {
        return a.wardNo.toLowerCase().contains(q) ||
            (a.refSource?.toLowerCase().contains(q) ?? false) ||
            (a.patientName?.toLowerCase().contains(q) ?? false) ||
            a.patientHospitalId.toLowerCase().contains(q);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admissions'),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: const TextStyle(color: AppColors.error)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                          onPressed: _fetchAdmissions,
                          child: const Text('Retry')),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Search
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: TextField(
                        controller: _searchCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Filter by ward, patient, or reference...',
                          prefixIcon:
                              Icon(Icons.search, color: AppColors.textTertiary),
                        ),
                      ),
                    ),

                    // Results count
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Records',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primarySurface,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_filtered.length}',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // List
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _fetchAdmissions,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: _filtered.length,
                          itemBuilder: (context, index) {
                            final adm = _filtered[index];
                            return Card(
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                leading: Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: adm.isCurrent
                                        ? AppColors.success.withOpacity(0.1)
                                        : AppColors.primarySurface,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    adm.isCurrent
                                        ? Icons.check_circle_outline
                                        : Icons.medical_services_outlined,
                                    color: adm.isCurrent
                                        ? AppColors.success
                                        : AppColors.primary,
                                    size: 20,
                                  ),
                                ),
                                title: Text(
                                  adm.patientName ?? adm.patientHospitalId,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text(
                                  'Ward ${adm.wardNo} • ${adm.formattedDate}',
                                  style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13),
                                ),
                                trailing: const Icon(Icons.chevron_right,
                                    color: AppColors.textTertiary),
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AdmissionDetailScreen(
                                          admission: adm),
                                    ),
                                  );
                                  _fetchAdmissions();
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final added = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const AddAdmissionScreen(hospitalId: '')),
          );
          if (added == true) _fetchAdmissions();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Admission'),
      ),
    );
  }
}
