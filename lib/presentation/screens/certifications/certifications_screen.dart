import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../data/models/certification_model.dart';
import '../../../providers/certifications_provider.dart';
import '../../widgets/app_drawer.dart';

/// Screen that visualizes TMDB content ratings (certifications) for movies and
/// television while also providing helper tools like filtering and quick age
/// guidance cues.
class CertificationsScreen extends StatefulWidget {
  static const routeName = '/certifications';

  const CertificationsScreen({super.key});

  @override
  State<CertificationsScreen> createState() => _CertificationsScreenState();
}

class _CertificationsScreenState extends State<CertificationsScreen> {
  late final TextEditingController _searchController;
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(_handleSearchChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await context.read<CertificationsProvider>().ensureLoaded();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_handleSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  /// Keeps local search state in sync with the text field so that filtering can
  /// be performed efficiently without rebuilding the controller.
  void _handleSearchChanged() {
    final value = _searchController.text.trim().toLowerCase();
    if (value == _searchTerm) {
      return;
    }
    setState(() => _searchTerm = value);
  }

  /// Builds the scaffold body with localized copy, loading indicators, filter
  /// controls, and the tab views for movie and TV certifications.
  Widget _buildBody(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Consumer<CertificationsProvider>(
      builder: (context, provider, _) {
        final movieEntries = _buildEntries(
          provider.movieCertifications,
          provider.selectedMovieCertification,
          provider,
        );
        final tvEntries = _buildEntries(
          provider.tvCertifications,
          provider.selectedTvCertification,
          provider,
        );
        final isLoading = provider.isLoadingMovies ||
            provider.isLoadingTv ||
            provider.isLoadingCountries;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _IntroBanner(message: loc.t('certifications.info_message')),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  labelText: loc.t('certifications.search_hint'),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchTerm.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => _searchController.clear(),
                          tooltip: loc.t('common.clear'),
                        ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            _FilterBar(
              isLoading: isLoading,
              movieOptions: provider.movieCertificationOptions(),
              tvOptions: provider.tvCertificationOptions(),
              movieSelection: provider.selectedMovieCertification,
              tvSelection: provider.selectedTvCertification,
              onMovieChanged: provider.setSelectedMovieCertification,
              onTvChanged: provider.setSelectedTvCertification,
            ),
            if (provider.movieError != null ||
                provider.tvError != null ||
                provider.countryError != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: _ErrorBanner(
                  messages: [
                    if (provider.movieError != null) provider.movieError!,
                    if (provider.tvError != null) provider.tvError!,
                    if (provider.countryError != null) provider.countryError!,
                  ],
                ),
              ),
            Expanded(
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    Material(
                      color: Theme.of(context).colorScheme.surface,
                      child: TabBar(
                        tabs: [
                          Tab(text: loc.t('certifications.movies_tab')),
                          Tab(text: loc.t('certifications.tv_tab')),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          _CertificationList(
                            entries: movieEntries,
                            searchTerm: _searchTerm,
                            emptyMessage: loc.t('certifications.empty_message'),
                            onRefresh: () => provider.ensureLoaded(
                              forceRefresh: true,
                            ),
                            loc: loc,
                          ),
                          _CertificationList(
                            entries: tvEntries,
                            searchTerm: _searchTerm,
                            emptyMessage: loc.t('certifications.empty_message'),
                            onRefresh: () => provider.ensureLoaded(
                              forceRefresh: true,
                            ),
                            loc: loc,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Transforms the raw certification map into a sorted list of country entries
  /// while applying any active certification filter from the provider.
  List<_CountryEntry> _buildEntries(
    Map<String, List<Certification>> source,
    String? selectedCertification,
    CertificationsProvider provider,
  ) {
    final entries = <_CountryEntry>[];
    final filterValue = selectedCertification?.toLowerCase();

    source.forEach((code, items) {
      final filtered = filterValue == null
          ? items
          : items
              .where((cert) =>
                  (cert.certification.isEmpty ? 'nr' : cert.certification)
                      .toLowerCase() ==
                  filterValue)
              .toList();
      if (filtered.isEmpty) {
        return;
      }
      entries.add(
        _CountryEntry(
          code: code.toUpperCase(),
          name: provider.countryName(code),
          certifications: filtered,
        ),
      );
    });

    entries.sort((a, b) => a.name.compareTo(b.name));
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(loc.t('certifications.title'))),
      drawer: const AppDrawer(),
      body: _buildBody(context),
    );
  }
}

/// Presentation widget that renders the combined list of certifications per
/// country with optional pull-to-refresh support.
class _CertificationList extends StatelessWidget {
  const _CertificationList({
    required this.entries,
    required this.searchTerm,
    required this.emptyMessage,
    required this.onRefresh,
    required this.loc,
  });

  final List<_CountryEntry> entries;
  final String searchTerm;
  final String emptyMessage;
  final Future<void> Function() onRefresh;
  final AppLocalizations loc;

  /// Applies the free-text search filter against country names, ISO codes, and
  /// certification labels/meanings.
  List<_CountryEntry> _applySearchFilter() {
    if (searchTerm.isEmpty) {
      return entries;
    }
    final query = searchTerm.toLowerCase();
    return entries.where((entry) {
      if (entry.name.toLowerCase().contains(query) ||
          entry.code.toLowerCase().contains(query)) {
        return true;
      }
      return entry.certifications.any((cert) {
        final label = cert.certification.isEmpty ? 'NR' : cert.certification;
        return label.toLowerCase().contains(query) ||
            cert.meaning.toLowerCase().contains(query);
      });
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _applySearchFilter();
    final theme = Theme.of(context);

    if (filtered.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(32),
          children: [
            Icon(
              Icons.info_outline,
              size: 48,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              emptyMessage,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final entry = filtered[index];
          return _CountryCard(entry: entry, loc: loc);
        },
      ),
    );
  }
}

/// Compact information card for a single country's certifications with clear
/// age warnings based on the underlying rating labels.
class _CountryCard extends StatelessWidget {
  const _CountryCard({
    required this.entry,
    required this.loc,
  });

  final _CountryEntry entry;
  final AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        key: PageStorageKey('certifications-${entry.code}'),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16),
        title: Text('${entry.name} (${entry.code})'),
        subtitle: Text('${entry.certifications.length} ratings'),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: entry.certifications.map((cert) {
          final badge = _AgeBadge.fromCertification(cert, loc);
          final label = cert.certification.isEmpty ? 'NR' : cert.certification;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: badge.color.withOpacity(.18),
                  child: Text(
                    label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: badge.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(cert.meaning),
                subtitle: Text(badge.warning),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Simple value class used to keep a country's ISO code, human readable name,
/// and associated certifications grouped together.
class _CountryEntry {
  const _CountryEntry({
    required this.code,
    required this.name,
    required this.certifications,
  });

  final String code;
  final String name;
  final List<Certification> certifications;
}

/// Represents the severity of a certification and the recommended warning text
/// that should be shown alongside it.
class _AgeBadge {
  const _AgeBadge({required this.color, required this.warning});

  final Color color;
  final String warning;

  /// Computes an appropriate warning level using common TMDB rating labels.
  static _AgeBadge fromCertification(
    Certification certification,
    AppLocalizations loc,
  ) {
    final value = certification.certification.toUpperCase();
    if (value.contains('NC') ||
        value.contains('18') ||
        value.contains('R') ||
        value.contains('MA')) {
      return _AgeBadge(
        color: Colors.red.shade600,
        warning: loc.t('certifications.warning_mature'),
      );
    }
    if (value.contains('PG-13') ||
        value.contains('TV-14') ||
        value.contains('15')) {
      return _AgeBadge(
        color: Colors.orange.shade700,
        warning: loc.t('certifications.warning_parental'),
      );
    }
    if (value.trim().isEmpty || value == 'NR') {
      return _AgeBadge(
        color: Colors.blueGrey.shade600,
        warning: loc.t('certifications.warning_unrated'),
      );
    }
    return _AgeBadge(
      color: Colors.green.shade700,
      warning: loc.t('certifications.warning_general'),
    );
  }
}

/// Helper banner displayed at the top of the screen to provide quick context.
class _IntroBanner extends StatelessWidget {
  const _IntroBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.verified_user_outlined,
                color: theme.colorScheme.onPrimaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Displays a short, accessible error summary when certification fetches fail.
class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.messages});

  final List<String> messages;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.error;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withOpacity(.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: messages
              .where((message) => message.trim().isNotEmpty)
              .map(
                (message) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    message,
                    style: theme.textTheme.bodySmall?.copyWith(color: color),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

/// Reusable row of filter controls displayed under the search box.
class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.isLoading,
    required this.movieOptions,
    required this.tvOptions,
    required this.movieSelection,
    required this.tvSelection,
    required this.onMovieChanged,
    required this.onTvChanged,
  });

  final bool isLoading;
  final List<String> movieOptions;
  final List<String> tvOptions;
  final String? movieSelection;
  final String? tvSelection;
  final ValueChanged<String?> onMovieChanged;
  final ValueChanged<String?> onTvChanged;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    Widget buildDropdown({
      required String label,
      required List<String> items,
      required String? selection,
      required ValueChanged<String?> onChanged,
    }) {
      return Expanded(
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              isExpanded: true,
              value: selection,
              hint: Text(loc.t('certifications.filter_all')),
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text(loc.t('certifications.filter_all')),
                ),
                ...items.map(
                  (value) => DropdownMenuItem<String?>(
                    value: value,
                    child: Text(value),
                  ),
                ),
              ],
              onChanged: onChanged,
            ),
          ),
        ),
      );
      }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          if (isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          buildDropdown(
            label: loc.t('certifications.filter_label_movies'),
            items: movieOptions,
            selection: movieSelection,
            onChanged: onMovieChanged,
          ),
          const SizedBox(width: 12),
          buildDropdown(
            label: loc.t('certifications.filter_label_tv'),
            items: tvOptions,
            selection: tvSelection,
            onChanged: onTvChanged,
          ),
        ],
      ),
    );
  }
}
