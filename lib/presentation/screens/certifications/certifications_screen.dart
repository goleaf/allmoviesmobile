import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../providers/certifications_provider.dart';

/// Displays the TMDB certification catalog for both movies and television.
/// Users can drill down by country, search for specific ratings, and apply
/// coarse age filters derived from the official guidance strings provided by
/// TMDB.
class CertificationsScreen extends StatefulWidget {
  static const String routeName = '/certifications';

  const CertificationsScreen({super.key});

  @override
  State<CertificationsScreen> createState() => _CertificationsScreenState();
}

class _CertificationsScreenState extends State<CertificationsScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    // Trigger the initial data load after the first frame so that the provider
    // has access to the ambient BuildContext.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CertificationsProvider>().ensureLoaded();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(loc.t('certifications.title')),
          bottom: TabBar(
            tabs: [
              Tab(text: loc.t('certifications.movie_tab')),
              Tab(text: loc.t('certifications.tv_tab')),
            ],
          ),
        ),
        body: Consumer<CertificationsProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && !provider.hasLoaded) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.errorMessage != null && !provider.hasLoaded) {
              return _ErrorState(
                message: provider.errorMessage!,
                onRetry: () =>
                    context.read<CertificationsProvider>().ensureLoaded(
                          forceRefresh: true,
                        ),
              );
            }

            final hasFilters = provider.activeAgeBracket != null ||
                provider.selectedCountryCode != null ||
                provider.searchQuery.isNotEmpty;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (provider.isLoading)
                  const LinearProgressIndicator(minHeight: 2),
                _FiltersPanel(
                  searchController: _searchController,
                  provider: provider,
                  loc: loc,
                ),
                if (hasFilters)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Text(
                      loc.t('certifications.active_filters_hint'),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _CertificationList(
                        entries: provider.filteredMovieEntries,
                        provider: provider,
                        loc: loc,
                        emptyLabel: loc.t('certifications.empty_state'),
                      ),
                      _CertificationList(
                        entries: provider.filteredTvEntries,
                        provider: provider,
                        loc: loc,
                        emptyLabel: loc.t('certifications.empty_state'),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FiltersPanel extends StatelessWidget {
  const _FiltersPanel({
    required this.searchController,
    required this.provider,
    required this.loc,
  });

  final TextEditingController searchController;
  final CertificationsProvider provider;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    final countries = provider.countries;
    final theme = Theme.of(context);
    final selectedCountry = provider.selectedCountryCode;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              labelText: loc.t('certifications.search_label'),
              hintText: loc.t('certifications.search_hint'),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: provider.searchQuery.isEmpty
                  ? null
                  : IconButton(
                      tooltip: loc.t('common.clear'),
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        searchController.clear();
                        provider.updateSearchQuery('');
                      },
                    ),
            ),
            textInputAction: TextInputAction.search,
            onChanged: provider.updateSearchQuery,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: selectedCountry,
            decoration: InputDecoration(
              labelText: loc.t('certifications.country_label'),
              border: const OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem<String>(
                value: null,
                child: Text(loc.t('certifications.country_all')),
              ),
              ...countries.map(
                (country) => DropdownMenuItem<String>(
                  value: country.code.toUpperCase(),
                  child: Text('${country.englishName} (${country.code})'),
                ),
              ),
            ],
            onChanged: provider.selectCountry,
          ),
          const SizedBox(height: 12),
          Text(
            loc.t('certifications.filter_header'),
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: Text(loc.t('certifications.age_all')),
                selected: provider.activeAgeBracket == null,
                onSelected: (_) => provider.setAgeBracketFilter(null),
              ),
              ...CertificationAgeBracket.values.map((bracket) {
                final localizedLabel = _localizedBracketLabel(loc, bracket);
                return FilterChip(
                  label: Text(localizedLabel),
                  selected: provider.activeAgeBracket == bracket,
                  onSelected: (_) => provider.setAgeBracketFilter(bracket),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  String _localizedBracketLabel(
    AppLocalizations loc,
    CertificationAgeBracket bracket,
  ) {
    switch (bracket) {
      case CertificationAgeBracket.everyone:
        return loc.t('certifications.age_everyone');
      case CertificationAgeBracket.parentalGuidance:
        return loc.t('certifications.age_pg');
      case CertificationAgeBracket.teens:
        return loc.t('certifications.age_teens');
      case CertificationAgeBracket.mature:
        return loc.t('certifications.age_mature');
      case CertificationAgeBracket.adultsOnly:
        return loc.t('certifications.age_adults');
    }
  }
}

class _CertificationList extends StatelessWidget {
  const _CertificationList({
    required this.entries,
    required this.provider,
    required this.loc,
    required this.emptyLabel,
  });

  final List<CountryCertificationEntry> entries;
  final CertificationsProvider provider;
  final AppLocalizations loc;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            emptyLabel,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          context.read<CertificationsProvider>().ensureLoaded(forceRefresh: true),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 24),
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final entry = entries[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: ExpansionTile(
                title: Text('${entry.countryName} (${entry.countryCode})'),
                children: entry.certifications.map((certification) {
                  final bracket = provider.bracketFor(certification);
                  final bracketLabel = _localizedBracketLabel(loc, bracket);
                  final warning = provider.buildAgeWarning(
                    certification,
                    bracketLabelOverride: bracketLabel,
                  );
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      child: Text(
                        certification.certification.isEmpty
                            ? '—'
                            : certification.certification,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    title: Text(
                      certification.meaning.isEmpty
                          ? loc.t('certifications.no_description')
                          : certification.meaning,
                    ),
                    subtitle: Text('${loc.t('certifications.warning_label')}: $warning'),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  String _localizedBracketLabel(
    AppLocalizations loc,
    CertificationAgeBracket bracket,
  ) {
    switch (bracket) {
      case CertificationAgeBracket.everyone:
        return loc.t('certifications.age_everyone');
      case CertificationAgeBracket.parentalGuidance:
        return loc.t('certifications.age_pg');
      case CertificationAgeBracket.teens:
        return loc.t('certifications.age_teens');
      case CertificationAgeBracket.mature:
        return loc.t('certifications.age_mature');
      case CertificationAgeBracket.adultsOnly:
        return loc.t('certifications.age_adults');
    }
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(loc.t('common.retry')),
            ),
          ],
        ),
      ),
    );
  }
}
