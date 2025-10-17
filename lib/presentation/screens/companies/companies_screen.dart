import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_strings.dart';
import '../../../data/models/company_model.dart';
import '../../../providers/companies_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/media_image.dart';
import '../../../core/utils/media_image_helper.dart';
import '../../../core/utils/media_image_helper.dart';

class CompaniesScreen extends StatefulWidget {
  static const routeName = '/companies';

  const CompaniesScreen({super.key});

  @override
  State<CompaniesScreen> createState() => _CompaniesScreenState();
}

class _CompaniesScreenState extends State<CompaniesScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    await context.read<CompaniesProvider>().searchCompanies(query);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CompaniesProvider>();
    final companies = provider.searchResults;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.companies),
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search production companies',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                isDense: true,
              ),
              onSubmitted: _performSearch,
              onChanged: (value) {
                if (value.isEmpty) {
                  context.read<CompaniesProvider>().clear();
                }
              },
            ),
          ),
          if (provider.isSearching)
            const LinearProgressIndicator(minHeight: 2),
          if (provider.errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  provider.errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _performSearch(provider.lastQuery),
              child: _CompanyList(
                companies: companies,
                onCompanySelected: (company) async {
                  final details = await provider.fetchCompanyDetails(company.id);
                  if (!context.mounted) return;
                  if (details != null) {
                    _showCompanyDetails(context, details);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Unable to load company details')), 
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCompanyDetails(BuildContext context, Company company) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final padding = MediaQuery.of(context).viewInsets;
        return Padding(
          padding: EdgeInsets.only(bottom: padding.bottom),
          child: _CompanyDetailSheet(company: company),
        );
      },
    );
  }
}

class _CompanyList extends StatelessWidget {
  const _CompanyList({
    required this.companies,
    required this.onCompanySelected,
  });

  final List<Company> companies;
  final ValueChanged<Company> onCompanySelected;

  @override
  Widget build(BuildContext context) {
    if (companies.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 120),
          Icon(
            Icons.business_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Search for companies using the field above.',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: companies.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final company = companies[index];
        return _CompanyCard(
          company: company,
          onTap: () => onCompanySelected(company),
        );
      },
    );
  }
}

class _CompanyCard extends StatelessWidget {
  const _CompanyCard({
    required this.company,
    required this.onTap,
  });

  final Company company;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CompanyLogo(logoPath: company.logoPath),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if ((company.originCountry ?? '').isNotEmpty)
                      Text(
                        company.originCountry!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    if ((company.headquarters ?? '').isNotEmpty)
                      Text(
                        company.headquarters!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
              Icon(Icons.keyboard_arrow_right, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompanyLogo extends StatelessWidget {
  const _CompanyLogo({this.logoPath});

  final String? logoPath;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: logoPath != null
          ? Padding(
              padding: const EdgeInsets.all(8),
              child: MediaImage(
                path: logoPath,
                type: MediaImageType.logo,
                size: MediaImageSize.w185,
                fit: BoxFit.contain,
              ),
            )
          : Icon(Icons.business, color: colorScheme.primary),
    );
  }
}

class _CompanyDetailSheet extends StatelessWidget {
  const _CompanyDetailSheet({required this.company});

  final Company company;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CompanyLogo(logoPath: company.logoPath),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        company.name,
                        style: theme.textTheme.headlineSmall,
                      ),
                      if ((company.originCountry ?? '').isNotEmpty)
                        Text(
                          'Country: ${company.originCountry}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      if ((company.headquarters ?? '').isNotEmpty)
                        Text(
                          'HQ: ${company.headquarters}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      if ((company.homepage ?? '').isNotEmpty)
                        Text(
                          company.homepage!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if ((company.description ?? '').isNotEmpty) ...[
              Text(
                'Description',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                company.description!,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
            ],
            if (company.producedMovies.isNotEmpty) ...[
              Text(
                'Produced movies (${company.producedMovies.length})',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              _ReferenceList(items: company.producedMovies),
              const SizedBox(height: 16),
            ],
            if (company.producedSeries.isNotEmpty) ...[
              Text(
                'Produced series (${company.producedSeries.length})',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              _ReferenceList(items: company.producedSeries),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReferenceList extends StatelessWidget {
  const _ReferenceList({required this.items});

  final List<dynamic> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final item in items.take(12))
          Chip(
            label: Text(
              item is Map<String, dynamic>
                  ? (item['title'] ?? item['name'] ?? 'Unknown') as String
                  : '$item',
            ),
          ),
      ],
    );
  }
}
