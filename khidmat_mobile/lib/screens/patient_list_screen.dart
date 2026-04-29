import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/app_theme.dart';
import '../models/patient.dart';
import '../providers/auth_provider.dart';
import '../providers/patient_provider.dart';
import '../widgets/search_bar.dart';
import '../widgets/patient_card.dart';
import 'patient_detail_screen.dart';
import 'add_patient_screen.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(() {
      if (!mounted) return;
      context.read<PatientProvider>().fetchAll();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final provider = context.read<PatientProvider>();
      if (provider.hasMore && !provider.isLoading) {
        provider.loadMore();
      }
    }
  }

  void _onSearch(String query) {
    context.read<PatientProvider>().search(query);
  }

  void _onFieldChanged(SearchField field) {
    final provider = context.read<PatientProvider>();
    provider.setSearchField(field);
    // Re-search with current query using new field
    if (_searchController.text.isNotEmpty) {
      provider.search(_searchController.text);
    }
  }

  Future<void> _onRefresh() async {
    final provider = context.read<PatientProvider>();
    if (provider.searchQuery.isNotEmpty) {
      await provider.search(provider.searchQuery);
    } else {
      await provider.fetchAll();
    }
  }

  void _navigateToDetail(Patient patient) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PatientDetailScreen(hospitalId: patient.hospitalId),
      ),
    );
    if (result == true && mounted) {
      _onSearch(_searchController.text);
    }
  }

  Future<void> _logout() async {
    final auth = context.read<AuthProvider>();
    await auth.logout();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PatientProvider>();
    final theme = Theme.of(context);
    final showFullScreenLoader = provider.isLoading && provider.patients.isEmpty;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Naya Zehan',
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Patient Records',
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 12,
              ),
            ),
          ],
        ),
        toolbarHeight: 72,
        actions: [
          IconButton(
            icon: const Icon(Icons.people_outline),
            tooltip: 'Admissions',
            onPressed: () => Navigator.pushNamed(context, '/admissions'),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: PatientSearchBar(
              controller: _searchController,
              searchField: provider.searchField,
              onFieldChanged: _onFieldChanged,
              onSearch: _onSearch,
            ),
          ),
          if (provider.searchQuery.isNotEmpty || provider.patients.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    provider.searchQuery.isNotEmpty
                        ? 'Results'
                        : 'All Patients',
                    style: theme.textTheme.titleMedium,
                  ),
                  Row(
                    children: [
                      if (provider.isRefreshing)
                        const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      if (provider.totalCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${provider.totalCount} found',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          Expanded(
            child: showFullScreenLoader
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : provider.error != null && provider.patients.isEmpty
                    ? _buildErrorState(provider.error!)
                    : provider.patients.isEmpty
                        ? _buildEmptyState(provider.searchQuery)
                        : RefreshIndicator(
                            onRefresh: _onRefresh,
                            child: ListView.builder(
                              controller: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: provider.patients.length + 1,
                              itemBuilder: (context, index) {
                                if (index == provider.patients.length) {
                                  return provider.hasMore
                                      ? const Padding(
                                          padding: EdgeInsets.all(20),
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              color: AppColors.primary,
                                              strokeWidth: 2.5,
                                            ),
                                          ),
                                        )
                                      : const SizedBox(height: 20);
                                }

                                final patient = provider.patients[index];
                                return PatientCard(
                                  patient: patient,
                                  onTap: () => _navigateToDetail(patient),
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
            MaterialPageRoute(builder: (_) => const AddPatientScreen()),
          );
          if (added == true && mounted) {
            _onSearch(_searchController.text);
          }
        },
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Add Patient'),
      ),
    );
  }

  Widget _buildEmptyState(String query) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                query.isEmpty ? Icons.search_rounded : Icons.search_off_rounded,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              query.isEmpty ? 'Search Patients' : 'No Results',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              query.isEmpty
                  ? 'Start typing to search by Hospital ID,\nname, father\'s name, or surname'
                  : 'No patients match "$query".\nTry a different search term.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: 16),
            Text(error, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _onSearch(_searchController.text),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
