import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../data/models/company_model.dart';
import '../../../data/models/configuration_model.dart';
import '../../../providers/companies_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/media_image.dart';
import '../../widgets/virtualized_list_view.dart';
import '../../../core/utils/media_image_helper.dart' as mih;
import '../company_detail/company_detail_screen.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CompaniesProvider>().ensureInitialized();
    });
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
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.t('company.companies')),
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: loc.t('search.search_people'),
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
          if (provider.isSearching) const LinearProgressIndicator(minHeight: 2),
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
              onRefresh: () => _handleRefresh(provider),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: _CountryFilter(
                      countries: provider.countries,
                      selectedCountry: provider.selectedCountry,
                      isLoading: provider.isLoadingCountries,
                      errorText: provider.countriesError,
                      onChanged: context.read<CompaniesProvider>().setCountryFilter,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: _PopularCompaniesSection(
                      companies: provider.popularCompanies,
                      isLoading: provider.isLoadingPopular && provider.popularCompanies.isEmpty,
                      error: provider.popularError,
                      onRefresh: provider.refreshPopularCompanies,
                      onCompanySelected: (company) =>
                          _handleCompanySelected(context, provider, company),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: _CompanyResultsList(
                      companies: companies,
                      onCompanySelected: (company) =>
                          _handleCompanySelected(context, provider, company),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRefresh(CompaniesProvider provider) async {
    final futures = <Future<void>>[provider.refreshPopularCompanies()];
    if (provider.lastQuery.isNotEmpty) {
      futures.add(provider.searchCompanies(provider.lastQuery));
    }
    await Future.wait(futures);
  }

  Future<void> _handleCompanySelected(
    BuildContext context,
    CompaniesProvider provider,
    Company company,
  ) async {
    final loc = AppLocalizations.of(context);
    final details = await provider.fetchCompanyDetails(company.id);
    if (!context.mounted) return;
    if (details != null) {
      _showCompanyDetails(context, details);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.t('errors.load_failed')),
        ),
      );
    }
  }

  void _showCompanyDetails(BuildContext context, Company company) {
    Navigator.pushNamed(
      context,
      CompanyDetailScreen.routeName,
      arguments: company,
    );
  }
}

class _CompanyCard extends StatelessWidget {
  const _CompanyCard({required this.company, required this.onTap});

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
              Icon(
                Icons.keyboard_arrow_right,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompanyLogo extends StatelessWidget {
  const _CompanyLogo({this.logoPath, this.size = 56});

  final String? logoPath;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: logoPath != null
          ? Padding(
              padding: const EdgeInsets.all(8),
              child: MediaImage(
                path: logoPath,
                type: mih.MediaImageType.logo,
                size: mih.MediaImageSize.w185,
                fit: BoxFit.contain,
              ),
            )
          : Icon(Icons.business, color: colorScheme.primary),
    );
  }
}

class _CountryFilter extends StatelessWidget {
  const _CountryFilter({
    required this.countries,
    required this.selectedCountry,
    required this.isLoading,
    required this.errorText,
    required this.onChanged,
  });

  final List<CountryInfo> countries;
  final String? selectedCountry;
  final bool isLoading;
  final String? errorText;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.t('company.filter_label'),
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        if (isLoading)
          const LinearProgressIndicator(minHeight: 2)
        else if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              errorText!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          )
        else if (countries.isEmpty)
          Text(
            loc.t('company.filter_empty'),
            style: theme.textTheme.bodySmall,
          )
        else
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String?>(
                  value: selectedCountry,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: loc.t('company.filter_label'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    isDense: true,
                  ),
                  hint: Text(loc.t('company.filter_all')),
                  items: [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text(loc.t('company.filter_all')),
                    ),
                    ...countries.map(
                      (country) => DropdownMenuItem<String?>(
                        value: country.code.toUpperCase(),
                        child: Text(
                          '${country.englishName} (${country.code.toUpperCase()})',
                        ),
                      ),
                    ),
                  ],
                  onChanged: onChanged,
                ),
              ),
              if (selectedCountry != null) ...[
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () => onChanged(null),
                  child: Text(loc.common['clear'] ?? 'Clear'),
                ),
              ],
            ],
          ),
      ],
    );
  }
}

class _PopularCompaniesSection extends StatelessWidget {
  const _PopularCompaniesSection({
    required this.companies,
    required this.isLoading,
    required this.error,
    required this.onRefresh,
    required this.onCompanySelected,
  });

  final List<Company> companies;
  final bool isLoading;
  final String? error;
  final Future<void> Function() onRefresh;
  final ValueChanged<Company> onCompanySelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.t('company.popular_title'),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    loc.t('company.popular_subtitle'),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: isLoading ? null : () => onRefresh(),
              icon: const Icon(Icons.refresh),
              tooltip: loc.common['refresh'] ?? 'Refresh',
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: CircularProgressIndicator(),
            ),
          )
        else if (error != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  error!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => onRefresh(),
                  icon: const Icon(Icons.refresh),
                  label: Text(loc.common['retry'] ?? 'Retry'),
                ),
              ],
            ),
          )
        else if (companies.isEmpty)
          Text(
            loc.t('company.popular_empty'),
            style: theme.textTheme.bodySmall,
          )
        else
          SizedBox(
            height: 180,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: companies.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final company = companies[index];
                return _PopularCompanyCard(
                  company: company,
                  onTap: () => onCompanySelected(company),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _PopularCompanyCard extends StatelessWidget {
  const _PopularCompanyCard({required this.company, required this.onTap});

  final Company company;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);

    return SizedBox(
      width: 160,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _CompanyLogo(logoPath: company.logoPath, size: 72),
                const SizedBox(height: 12),
                Text(
                  company.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  (company.originCountry?.isNotEmpty ?? false)
                      ? company.originCountry!
                      : (loc.common['unknown'] ?? 'Unknown'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CompanyResultsList extends StatelessWidget {
  const _CompanyResultsList({
    required this.companies,
    required this.onCompanySelected,
  });

  final List<Company> companies;
  final ValueChanged<Company> onCompanySelected;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CompaniesProvider>();
    if (companies.isEmpty) {
      final loc = AppLocalizations.of(context);
      final theme = Theme.of(context);
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            Icon(
              Icons.business_outlined,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              loc.t('company.empty_prompt'),
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final trailingItems = <Widget>[];
    if (provider.isSearching) {
      trailingItems.add(
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final errorMessage = provider.errorMessage;
    if (errorMessage != null && errorMessage.isNotEmpty) {
      final theme = Theme.of(context);
      trailingItems.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              errorMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ),
      );
    }

    final itemCount = companies.length + trailingItems.length;

    return VirtualizedSeparatedListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      separatorBuilder: (context, index) {
        final bool isBetweenCompanies = index < companies.length - 1;
        if (isBetweenCompanies) {
          return const SizedBox(height: 12);
        }
        return const SizedBox(height: 16);
      },
      itemBuilder: (context, index) {
        if (index < companies.length) {
          final company = companies[index];
          return _CompanyCard(
            company: company,
            onTap: () => onCompanySelected(company),
          );
        }

        final trailingIndex = index - companies.length;
        return trailingItems[trailingIndex];
      },
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
                      Text(company.name, style: theme.textTheme.headlineSmall),
                      if ((company.originCountry ?? '').isNotEmpty)
                        Text(
                          '${AppLocalizations.of(context).t('company.origin_country')}: ${company.originCountry}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      if ((company.headquarters ?? '').isNotEmpty)
                        Text(
                          '${AppLocalizations.of(context).t('company.headquarters')}: ${company.headquarters}',
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
                AppLocalizations.of(context).t('company.description'),
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(company.description!, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 16),
            ],
            if (company.producedMovies.isNotEmpty) ...[
              Text(
                '${AppLocalizations.of(context).t('company.produced_movies')} (${company.producedMovies.length})',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              _ReferenceList(items: company.producedMovies),
              const SizedBox(height: 16),
            ],
            if (company.producedSeries.isNotEmpty) ...[
              Text(
                '${AppLocalizations.of(context).t('company.produced_series')} (${company.producedSeries.length})',
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
