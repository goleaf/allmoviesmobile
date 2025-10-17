import 'package:flutter/material.dart';

import '../../../data/models/certification_model.dart';
import '../../../data/models/configuration_model.dart';

class ContentRatingsScreen extends StatefulWidget {
  const ContentRatingsScreen({
    super.key,
    required this.countries,
    required this.movieCertifications,
    required this.tvCertifications,
    this.initialTab = 0,
  });

  final List<CountryInfo> countries;
  final Map<String, List<Certification>> movieCertifications;
  final Map<String, List<Certification>> tvCertifications;
  final int initialTab;

  @override
  State<ContentRatingsScreen> createState() => _ContentRatingsScreenState();
}

class _ContentRatingsScreenState extends State<ContentRatingsScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final Map<String, String> _countryMap;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _countryMap = {
      for (final country in widget.countries)
        country.code.toUpperCase(): country.englishName,
    };
    _searchController.addListener(_handleQueryChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_handleQueryChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _handleQueryChanged() {
    final value = _searchController.text.trim().toLowerCase();
    if (value == _query) {
      return;
    }
    setState(() {
      _query = value;
    });
  }

  List<_CountryCertification> _buildEntries(
    Map<String, List<Certification>> certifications,
  ) {
    final entries = <_CountryCertification>[];

    certifications.forEach((code, items) {
      if (items.isEmpty) {
        return;
      }
      final normalizedCode = code.toUpperCase();
      entries.add(
        _CountryCertification(
          code: normalizedCode,
          name: _countryMap[normalizedCode] ?? normalizedCode,
          certifications: List<Certification>.unmodifiable(items),
        ),
      );
    });

    entries.sort((a, b) => a.name.compareTo(b.name));

    if (_query.isEmpty) {
      return entries;
    }

    return entries.where((entry) {
      final lowerName = entry.name.toLowerCase();
      final lowerCode = entry.code.toLowerCase();

      if (lowerName.contains(_query) || lowerCode.contains(_query)) {
        return true;
      }

      for (final cert in entry.certifications) {
        final certValue = cert.certification.toLowerCase();
        final meaning = cert.meaning.toLowerCase();
        if (certValue.contains(_query) || meaning.contains(_query)) {
          return true;
        }
      }

      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final movieEntries = _buildEntries(widget.movieCertifications);
    final tvEntries = _buildEntries(widget.tvCertifications);
    final initialIndex = widget.initialTab.clamp(0, 1);

    return DefaultTabController(
      length: 2,
      initialIndex: initialIndex,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Content ratings by country'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Movies'),
              Tab(text: 'TV'),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search countries, codes, or ratings',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () => _searchController.clear(),
                          icon: const Icon(Icons.clear),
                        ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Tap a country to view its official content ratings and descriptions.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TabBarView(
                children: [
                  _ContentRatingsList(entries: movieEntries),
                  _ContentRatingsList(entries: tvEntries),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContentRatingsList extends StatelessWidget {
  const _ContentRatingsList({required this.entries});

  final List<_CountryCertification> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No content ratings found. Try adjusting your search.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final theme = Theme.of(context);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: ExpansionTile(
              key: PageStorageKey('content-rating-${entry.code}'),
              tilePadding: const EdgeInsets.symmetric(horizontal: 16),
              childrenPadding: const EdgeInsets.only(bottom: 12),
              title: Text(
                '${entry.name} (${entry.code})',
                style: theme.textTheme.titleMedium,
              ),
              subtitle: Text(
                '${entry.certifications.length} ratings',
                style: theme.textTheme.bodySmall,
              ),
              children: entry.certifications.map((cert) {
                final label = cert.certification.isEmpty
                    ? 'NR'
                    : cert.certification;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Text(
                      label,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  title: Text(cert.meaning),
                  subtitle: Text('Order: ${cert.order}'),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

class _CountryCertification {
  const _CountryCertification({
    required this.code,
    required this.name,
    required this.certifications,
  });

  final String code;
  final String name;
  final List<Certification> certifications;
}
