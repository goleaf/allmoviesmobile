import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/certifications_provider.dart';
import '../../widgets/app_drawer.dart';

/// Full-screen overview of TMDB certification reference data for movies and TV.
/// Users can filter by country, rating token, or look up detailed guidance for
/// parental advisories.
class CertificationsScreen extends StatefulWidget {
  const CertificationsScreen({super.key});

  static const routeName = '/certifications';

  @override
  State<CertificationsScreen> createState() => _CertificationsScreenState();
}

class _CertificationsScreenState extends State<CertificationsScreen>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _searchController;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = context.read<CertificationsProvider>();
      provider.ensureInitialized();
      _searchController.text = provider.query;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tabController ??= TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Certifications & ratings'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Movies'),
            Tab(text: 'TV'),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: Consumer<CertificationsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && !provider.hasLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.hasError && !provider.hasLoaded) {
            return _ErrorView(
              message: provider.errorMessage ?? 'Unable to load certifications.',
              onRetry: provider.refresh,
            );
          }

          final focus = provider.focusSummary;

          return TabBarView(
            controller: _tabController,
            children: [
              _CertificationsTab(
                searchController: _searchController,
                entries: provider.movieEntries,
                provider: provider,
                focus: focus,
              ),
              _CertificationsTab(
                searchController: _searchController,
                entries: provider.tvEntries,
                provider: provider,
                focus: focus,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CertificationsTab extends StatelessWidget {
  const _CertificationsTab({
    required this.searchController,
    required this.entries,
    required this.provider,
    required this.focus,
  });

  final TextEditingController searchController;
  final List<CertificationCountryEntry> entries;
  final CertificationsProvider provider;
  final CertificationFocusSummary? focus;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: _SearchAndFilterBar(
            controller: searchController,
            provider: provider,
          ),
        ),
        if (focus != null)
          _FocusSummaryCard(
            focus: focus!,
            provider: provider,
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: provider.refresh,
            child: entries.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            'No certifications found. Try adjusting your filters.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return _CountryCertificationsCard(entry: entry);
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

class _SearchAndFilterBar extends StatelessWidget {
  const _SearchAndFilterBar({
    required this.controller,
    required this.provider,
  });

  final TextEditingController controller;
  final CertificationsProvider provider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = provider.selectedCertification;
    final available = provider.availableCertifications;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Search countries, ratings, or warnings',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: controller.text.isEmpty
                ? null
                : IconButton(
                    onPressed: () {
                      controller.clear();
                      provider.updateQuery('');
                    },
                    icon: const Icon(Icons.clear),
                    tooltip: 'Clear search',
                  ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          textInputAction: TextInputAction.search,
          onChanged: provider.updateQuery,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              'Filter by certification',
              style: theme.textTheme.titleSmall,
            ),
            const Spacer(),
            if (selected != null)
              TextButton.icon(
                onPressed: () {
                  controller.clear();
                  provider.clearFilters();
                },
                icon: const Icon(Icons.clear_all),
                label: const Text('Clear filters'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (available.isEmpty)
          Text(
            'No certification filters available yet.',
            style: theme.textTheme.bodySmall,
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: available.map((rating) {
                final isSelected = rating == selected;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(rating),
                    onSelected: (_) => provider.toggleCertification(rating),
                    avatar: CircleAvatar(
                      backgroundColor:
                          _CertificationColors.backgroundFor(context, rating),
                      child: Text(
                        rating,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color:
                              _CertificationColors.foregroundFor(context, rating),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

class _CountryCertificationsCard extends StatelessWidget {
  const _CountryCertificationsCard({required this.entry});

  final CertificationCountryEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ExpansionTile(
        title: Text('${entry.name} (${entry.code})'),
        subtitle: Text('${entry.certifications.length} certifications'),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Text(
            entry.code,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        children: entry.certifications.map((cert) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor:
                  _CertificationColors.backgroundFor(context, cert.certification),
              child: Text(
                cert.certification,
                style: theme.textTheme.labelMedium?.copyWith(
                  color:
                      _CertificationColors.foregroundFor(context, cert.certification),
                ),
              ),
            ),
            title: Text(cert.meaning),
            subtitle: Text('Content order: ${cert.order}'),
          );
        }).toList(),
      ),
    );
  }
}

class _FocusSummaryCard extends StatelessWidget {
  const _FocusSummaryCard({required this.focus, required this.provider});

  final CertificationFocusSummary focus;
  final CertificationsProvider provider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor:
                        _CertificationColors.backgroundFor(context, focus.rating),
                    child: Text(
                      focus.rating,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color:
                            _CertificationColors.foregroundFor(context, focus.rating),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${focus.rating} overview',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${focus.totalCountries} countries • ${focus.movieCountries.length} movie regions • ${focus.tvCountries.length} TV regions',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => provider.toggleCertification(null),
                    icon: const Icon(Icons.close),
                    tooltip: 'Clear certification filter',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (focus.meanings.isNotEmpty) ...[
                Text(
                  'Age-appropriate guidance',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                ...focus.meanings.map(
                  (meaning) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.warning_amber_outlined, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            meaning,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (focus.movieCountries.isNotEmpty) ...[
                Text(
                  'Movie regions',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: focus.movieCountries
                      .map((country) => Chip(label: Text(country)))
                      .toList(),
                ),
                const SizedBox(height: 12),
              ],
              if (focus.tvCountries.isNotEmpty) ...[
                Text(
                  'TV regions',
                  style: theme.textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      focus.tvCountries.map((country) => Chip(label: Text(country))).toList(),
                ),
              ],
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
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CertificationColors {
  static Color backgroundFor(BuildContext context, String rating) {
    final upper = rating.toUpperCase();
    final scheme = Theme.of(context).colorScheme;

    if (_isMature(upper)) {
      return scheme.errorContainer;
    }
    if (_isTeen(upper)) {
      return scheme.tertiaryContainer;
    }
    if (_isGuidance(upper)) {
      return scheme.secondaryContainer;
    }
    return scheme.primaryContainer;
  }

  static Color foregroundFor(BuildContext context, String rating) {
    final upper = rating.toUpperCase();
    final scheme = Theme.of(context).colorScheme;

    if (_isMature(upper)) {
      return scheme.onErrorContainer;
    }
    if (_isTeen(upper)) {
      return scheme.onTertiaryContainer;
    }
    if (_isGuidance(upper)) {
      return scheme.onSecondaryContainer;
    }
    return scheme.onPrimaryContainer;
  }

  static bool _isMature(String value) {
    return value.contains('18') ||
        value.contains('R') ||
        value.contains('NC') ||
        value.contains('X') ||
        value.contains('MA');
  }

  static bool _isTeen(String value) {
    return value.contains('16') ||
        value.contains('15') ||
        value.contains('14') ||
        value.contains('M');
  }

  static bool _isGuidance(String value) {
    return value.contains('PG') ||
        value.contains('12') ||
        value.contains('UA') ||
        value.contains('B');
  }
}
