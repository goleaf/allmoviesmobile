import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_strings.dart';
import '../../../data/models/company_model.dart';
import '../../../providers/companies_provider.dart';
import '../../widgets/app_drawer.dart';
import 'company_detail_screen.dart';

class CompaniesScreen extends StatefulWidget {
  static const routeName = '/companies';

  const CompaniesScreen({super.key});

  @override
  State<CompaniesScreen> createState() => _CompaniesScreenState();
}

class _CompaniesScreenState extends State<CompaniesScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final GlobalKey _searchSectionKey = GlobalKey();
  final GlobalKey _countrySectionKey = GlobalKey();
  final GlobalKey _popularSectionKey = GlobalKey();
  String? _selectedCountry;

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CompaniesProvider>();
    final countries = _extractCountries(provider.companies);
    final filteredCompanies = _filterByCountry(provider.companies);
    final hasActiveCountryFilter =
        _selectedCountry != null && _selectedCountry!.isNotEmpty;
    final showInitialLoader = provider.isLoading && provider.companies.isEmpty;
    final showInitialError =
        provider.errorMessage != null && provider.companies.isEmpty;
    final popularCompanies = provider.companies.take(6).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.companies),
      ),
      drawer: const AppDrawer(),
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          final metrics = notification.metrics;
          final shouldLoadMore =
              metrics.pixels >= metrics.maxScrollExtent - 200 &&
                  provider.canLoadMore &&
                  !provider.isLoadingMore &&
                  !provider.isLoading;

          if (shouldLoadMore) {
            provider.loadMoreCompanies();
          }

          return false;
        },
        child: RefreshIndicator(
          onRefresh: provider.refreshCompanies,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              _HeaderSection(
                title: 'Browse Companies',
                subtitle:
                    'Find production houses from around the world, discover new studios, and track your favourites.',
              ),
              const SizedBox(height: 16),
              _FeatureGrid(
                features: [
                  _FeatureItem(
                    icon: Icons.search,
                    title: 'Search companies',
                    description:
                        'Look up a studio by name and jump straight to its profile.',
                    onTap: () {
                      if (_searchSectionKey.currentContext != null) {
                        Scrollable.ensureVisible(
                          _searchSectionKey.currentContext!,
                          duration: const Duration(milliseconds: 300),
                        );
                      }
                      FocusScope.of(context).requestFocus(_searchFocusNode);
                    },
                  ),
                  _FeatureItem(
                    icon: Icons.public,
                    title: 'Companies by country',
                    description:
                        'Filter the catalog to highlight studios from a specific origin.',
                    onTap: () {
                      if (_countrySectionKey.currentContext != null) {
                        Scrollable.ensureVisible(
                          _countrySectionKey.currentContext!,
                          duration: const Duration(milliseconds: 300),
                        );
                      }
                    },
                  ),
                  _FeatureItem(
                    icon: Icons.star_rate_rounded,
                    title: 'Popular production companies',
                    description:
                        'Quickly browse the standout studios surfaced from your results.',
                    onTap: () {
                      if (_popularSectionKey.currentContext != null) {
                        Scrollable.ensureVisible(
                          _popularSectionKey.currentContext!,
                          duration: const Duration(milliseconds: 300),
                        );
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _SearchField(
                key: _searchSectionKey,
                controller: _searchController,
                focusNode: _searchFocusNode,
                onSearch: (query) async {
                  await provider.searchCompanies(query);
                  if (!mounted) {
                    return;
                  }
                  if (query.trim().isEmpty) {
                    setState(() => _selectedCountry = null);
                  }
                },
                isLoading: provider.isLoading,
              ),
              const SizedBox(height: 16),
              if (countries.isNotEmpty)
                _CountryFilterSection(
                  key: _countrySectionKey,
                  countries: countries,
                  selectedCountry: _selectedCountry,
                  onCountrySelected: (country) {
                    setState(() => _selectedCountry = country);
                  },
                  onClearFilter: hasActiveCountryFilter
                      ? () => setState(() => _selectedCountry = null)
                      : null,
                ),
              if (countries.isNotEmpty) const SizedBox(height: 24),
              if (popularCompanies.isNotEmpty)
                _PopularCompaniesSection(
                  key: _popularSectionKey,
                  companies: popularCompanies,
                ),
              if (popularCompanies.isNotEmpty) const SizedBox(height: 24),
              if (showInitialLoader)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (showInitialError)
                _ErrorView(
                  message: provider.errorMessage!,
                  onRetry: provider.refreshCompanies,
                )
              else if (filteredCompanies.isEmpty)
                _EmptyView(
                  message: hasActiveCountryFilter
                      ? 'No companies match the selected country just yet.'
                      : 'No companies found. Try searching for another studio.',
                )
              else
                ...[
                  for (final company in filteredCompanies)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _CompanyCard(company: company),
                    ),
                  if (provider.isLoadingMore)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
            ],
          ),
        ),
      ),
    );
  }

  List<String> _extractCountries(List<Company> companies) {
    final countries = <String>{};
    for (final company in companies) {
      final origin = company.originCountry?.trim();
      if (origin != null && origin.isNotEmpty) {
        countries.add(origin);
      }
    }
    final sorted = countries.toList()..sort();
    if (companies.any((company) =>
        company.originCountry == null || company.originCountry!.isEmpty)) {
      sorted.add('Unknown');
    }
    return sorted;
  }

  List<Company> _filterByCountry(List<Company> companies) {
    if (_selectedCountry == null || _selectedCountry!.isEmpty) {
      return companies;
    }

    return companies.where((company) {
      final origin = company.originCountry?.trim();
      if ((origin == null || origin.isEmpty) && _selectedCountry == 'Unknown') {
        return true;
      }
      return origin == _selectedCountry;
    }).toList();
  }
}
class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onSearch,
    required this.isLoading,
    this.focusNode,
  });

  final TextEditingController controller;
  final Future<void> Function(String) onSearch;
  final bool isLoading;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        labelText: 'Search companies',
        hintText: 'e.g. Studio Ghibli',
        suffixIcon: isLoading
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => onSearch(controller.text),
              ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onSubmitted: onSearch,
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid({required this.features});

  final List<_FeatureItem> features;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        final cardWidth = isWide
            ? (constraints.maxWidth - 16) / 2
            : constraints.maxWidth;

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final feature in features)
              SizedBox(
                width: cardWidth,
                child: _FeatureCard(item: feature),
              ),
          ],
        );
      },
    );
  }
}

class _FeatureItem {
  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.item});

  final _FeatureItem item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceVariant,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                item.icon,
                size: 28,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                item.title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                item.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountryFilterSection extends StatelessWidget {
  const _CountryFilterSection({
    super.key,
    required this.countries,
    required this.selectedCountry,
    required this.onCountrySelected,
    this.onClearFilter,
  });

  final List<String> countries;
  final String? selectedCountry;
  final ValueChanged<String?> onCountrySelected;
  final VoidCallback? onClearFilter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Companies by country',
                style: theme.textTheme.titleMedium,
              ),
            ),
            if (onClearFilter != null)
              TextButton(
                onPressed: onClearFilter,
                child: const Text('Clear'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Tap a country to narrow the list to studios from that region.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ChoiceChip(
              label: const Text('All'),
              selected: selectedCountry == null || selectedCountry!.isEmpty,
              onSelected: (_) => onCountrySelected(null),
            ),
            for (final country in countries)
              ChoiceChip(
                label: Text(country),
                selected: selectedCountry == country,
                onSelected: (_) => onCountrySelected(country),
              ),
          ],
        ),
      ],
    );
  }
}

class _PopularCompaniesSection extends StatelessWidget {
  const _PopularCompaniesSection({super.key, required this.companies});

  final List<Company> companies;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Popular production companies',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Here are a few highlights from the current results.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: companies.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final company = companies[index];
              return _PopularCompanyCard(company: company);
            },
          ),
        ),
      ],
    );
  }
}

class _PopularCompanyCard extends StatelessWidget {
  const _PopularCompanyCard({required this.company});

  final Company company;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final origin = company.originCountry?.isNotEmpty == true
        ? company.originCountry!
        : 'Unknown origin';

    return SizedBox(
      width: 220,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.apartment_outlined,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                company.name,
                style: theme.textTheme.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                origin,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompanyCard extends StatelessWidget {
  const _CompanyCard({required this.company});

  final Company company;

  @override
  Widget build(BuildContext context) {
    final subtitleParts = <String>[];
    if (company.originCountry != null && company.originCountry!.isNotEmpty) {
      subtitleParts.add(company.originCountry!);
    }
    if (company.homepage != null && company.homepage!.isNotEmpty) {
      subtitleParts.add(company.homepage!);
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CompanyDetailScreen(company: company),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.business_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          company.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitleParts.join(' • '),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                (company.description?.isNotEmpty ?? false)
                    ? company.description!
                    : 'No description available.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
