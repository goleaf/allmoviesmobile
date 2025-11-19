import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../data/models/discover_filters_model.dart';
import '../../../data/models/watch_provider_model.dart';
import '../../../data/tmdb_repository.dart';
import '../../../providers/watch_region_provider.dart';

class MoviesFiltersScreen extends StatefulWidget {
  static const routeName = '/movies/filters';

  const MoviesFiltersScreen({super.key, this.initial});

  final DiscoverFilters? initial;

  @override
  State<MoviesFiltersScreen> createState() => _MoviesFiltersScreenState();
}

class _MoviesFiltersScreenState extends State<MoviesFiltersScreen> {
  late bool includeAdult;
  late SortBy sortBy;
  String? certificationLte;
  DateTime? releaseFrom;
  DateTime? releaseTo;
  double voteMin = 5.0;
  double voteMax = 9.5;
  int runtimeMin = 60;
  int runtimeMax = 180;
  int voteCountMin = 100;
  final Set<String> monetization = <String>{'flatrate', 'rent', 'buy'};
  final Set<int> selectedProviderIds = <int>{};
  int? releaseType;
  String withCast = '';
  String withCrew = '';
  String withCompanies = '';
  String withKeywords = '';

  // Watch Providers State
  List<WatchProvider> _availableProviders = [];
  bool _isLoadingProviders = false;

  @override
  void initState() {
    super.initState();
    final init = widget.initial;
    includeAdult = init?.includeAdult ?? false;
    sortBy = init?.sortBy ?? SortBy.popularityDesc;
    certificationLte = init?.certificationLte;
    if (init?.releaseDateGte != null) {
      releaseFrom = DateTime.tryParse('${init!.releaseDateGte}');
    }
    if (init?.releaseDateLte != null) {
      releaseTo = DateTime.tryParse('${init!.releaseDateLte}');
    }
    voteMin = init?.voteAverageGte ?? voteMin;
    voteMax = init?.voteAverageLte ?? voteMax;
    runtimeMin = init?.runtimeGte ?? runtimeMin;
    runtimeMax = init?.runtimeLte ?? runtimeMax;
    voteCountMin = init?.voteCountGte ?? voteCountMin;
    if ((init?.withWatchMonetizationTypes ?? '').isNotEmpty) {
      monetization
        ..clear()
        ..addAll((init!.withWatchMonetizationTypes!).split('|'));
    }
    
    if ((init?.withWatchProviders ?? '').isNotEmpty) {
      final ids = init!.withWatchProviders!.split('|');
      for (final id in ids) {
        final parsed = int.tryParse(id);
        if (parsed != null) selectedProviderIds.add(parsed);
      }
    }

    releaseType = int.tryParse(init?.withReleaseType ?? '');
    withCast = init?.withCast ?? '';
    withCrew = init?.withCrew ?? '';
    withCompanies = init?.withCompanies ?? '';
    withKeywords = init?.withKeywords ?? '';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWatchProviders();
    });
  }

  Future<void> _loadWatchProviders() async {
    if (!mounted) return;
    setState(() => _isLoadingProviders = true);

    try {
      final region = context.read<WatchRegionProvider?>()?.region ?? 'US';
      final repo = context.read<TmdbRepository>();
      final providers = await repo.fetchAvailableWatchProviders(
        mediaType: 'movie',
        region: region,
      );
      
      // Filter to only show popular/major providers to avoid clutter
      // or sort by display priority
      providers.sort((a, b) => (a.displayPriority ?? 999).compareTo(b.displayPriority ?? 999));

      if (mounted) {
        setState(() {
          _availableProviders = providers;
          _isLoadingProviders = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingProviders = false);
      }
    }
  }

  void _reset() {
    setState(() {
      includeAdult = false;
      sortBy = SortBy.popularityDesc;
      certificationLte = null;
      releaseFrom = null;
      releaseTo = null;
      voteMin = 5.0;
      voteMax = 9.5;
      runtimeMin = 60;
      runtimeMax = 180;
      voteCountMin = 100;
      monetization
        ..clear()
        ..addAll({'flatrate', 'rent', 'buy'});
      selectedProviderIds.clear();
      releaseType = null;
      withCast = '';
      withCrew = '';
      withCompanies = '';
      withKeywords = '';
    });
  }

  void _apply() {
    final region = context.read<WatchRegionProvider?>()?.region;
    final filters = DiscoverFilters().copyWith(
      includeAdult: includeAdult,
      sortBy: sortBy,
      certificationCountry: region,
      certificationLte: certificationLte,
      releaseDateGte: releaseFrom != null
          ? releaseFrom!.toIso8601String().split('T').first
          : null,
      releaseDateLte: releaseTo != null
          ? releaseTo!.toIso8601String().split('T').first
          : null,
      voteAverageGte: voteMin,
      voteAverageLte: voteMax,
      runtimeGte: runtimeMin,
      runtimeLte: runtimeMax,
      voteCountGte: voteCountMin,
      withWatchMonetizationTypes: monetization.isNotEmpty
          ? monetization.join('|')
          : null,
      withWatchProviders: selectedProviderIds.isNotEmpty 
          ? selectedProviderIds.join('|') 
          : null,
      watchRegion: region,
      withReleaseType: releaseType != null ? '$releaseType' : null,
      withCast: withCast.isNotEmpty ? withCast : null,
      withCrew: withCrew.isNotEmpty ? withCrew : null,
      withCompanies: withCompanies.isNotEmpty ? withCompanies : null,
      withKeywords: withKeywords.isNotEmpty ? withKeywords : null,
    );
    Navigator.pop(context, filters);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final region = context.watch<WatchRegionProvider?>()?.region;
    return Scaffold(
      key: const ValueKey('moviesFiltersScaffold'),
      appBar: AppBar(
        title: Text(l.t('discover.filters')),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(onPressed: _reset, child: Text(l.t('common.reset'))),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              const Icon(Icons.filter_list),
              const SizedBox(width: 8),
              Text(
                l.t('discover.title'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              if (region != null)
                Chip(label: Text('${l.t('settings.region')}: $region')),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l.t('discover.sortBy'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<SortBy>(
            value: sortBy,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: [
              DropdownMenuItem(
                value: SortBy.popularityDesc,
                child: Text(l.t('discover.sort.popularityDesc')),
              ),
              DropdownMenuItem(
                value: SortBy.popularityAsc,
                child: Text(l.t('discover.sort.popularityAsc')),
              ),
              DropdownMenuItem(
                value: SortBy.revenueDesc,
                child: Text(l.t('discover.sort.revenueDesc')),
              ),
              DropdownMenuItem(
                value: SortBy.revenueAsc,
                child: Text(l.t('discover.sort.revenueAsc')),
              ),
              DropdownMenuItem(
                value: SortBy.ratingDesc,
                child: Text(l.t('discover.sort.ratingDesc')),
              ),
              DropdownMenuItem(
                value: SortBy.ratingAsc,
                child: Text(l.t('discover.sort.ratingAsc')),
              ),
              DropdownMenuItem(
                value: SortBy.releaseDateDesc,
                child: Text(l.t('discover.sort.releaseDateDesc')),
              ),
              DropdownMenuItem(
                value: SortBy.releaseDateAsc,
                child: Text(l.t('discover.sort.releaseDateAsc')),
              ),
              DropdownMenuItem(
                value: SortBy.titleAsc,
                child: Text(l.t('discover.sort.titleAsc')),
              ),
              DropdownMenuItem(
                value: SortBy.titleDesc,
                child: Text(l.t('discover.sort.titleDesc')),
              ),
            ],
            onChanged: (v) {
              if (v != null) setState(() => sortBy = v);
            },
          ),
          const SizedBox(height: 16),
          Text(
            l.t('discover.byDecade'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final start in [1960, 1970, 1980, 1990, 2000, 2010, 2020])
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      releaseFrom = DateTime(start, 1, 1);
                      releaseTo = DateTime(start + 9, 12, 31);
                    });
                  },
                  child: Text('${start}s'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            l.t('discover.certification'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final cert in ['G', 'PG', 'PG-13', 'R', 'NC-17'])
                FilterChip(
                  label: Text(cert),
                  selected: certificationLte == cert,
                  onSelected: (v) {
                    setState(() => certificationLte = v ? cert : null);
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            l.t('discover.releaseDateRange'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.date_range),
                  label: Text(
                    releaseFrom == null
                        ? l.t('common.from')
                        : releaseFrom!.toIso8601String().split('T').first,
                  ),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate:
                          releaseFrom ??
                          DateTime.now().subtract(const Duration(days: 3650)),
                      firstDate: DateTime(1950),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setState(() => releaseFrom = picked);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.event),
                  label: Text(
                    releaseTo == null
                        ? l.t('common.to')
                        : releaseTo!.toIso8601String().split('T').first,
                  ),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: releaseTo ?? DateTime.now(),
                      firstDate: DateTime(1950),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) setState(() => releaseTo = picked);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            l.t('discover.voteAverage'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          RangeSlider(
            values: RangeValues(voteMin, voteMax),
            min: 0,
            max: 10,
            divisions: 20,
            labels: RangeLabels(
              voteMin.toStringAsFixed(1),
              voteMax.toStringAsFixed(1),
            ),
            onChanged: (values) {
              setState(() {
                voteMin = values.start;
                voteMax = values.end;
              });
            },
          ),
          const SizedBox(height: 8),
          Text(
            l.t('discover.runtimeMinutes'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          RangeSlider(
            values: RangeValues(runtimeMin.toDouble(), runtimeMax.toDouble()),
            min: 0,
            max: 300,
            divisions: 30,
            labels: RangeLabels('$runtimeMin', '$runtimeMax'),
            onChanged: (values) {
              setState(() {
                runtimeMin = values.start.round();
                runtimeMax = values.end.round();
              });
            },
          ),
          const SizedBox(height: 8),
          Text(
            l.t('discover.voteCountMinimum'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: voteCountMin.toDouble(),
                  min: 0,
                  max: 5000,
                  divisions: 50,
                  label: '$voteCountMin',
                  onChanged: (v) => setState(() => voteCountMin = v.round()),
                ),
              ),
              SizedBox(
                width: 64,
                child: Text('$voteCountMin', textAlign: TextAlign.end),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l.t('discover.monetizationTypes'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final type in ['flatrate', 'rent', 'buy', 'ads', 'free'])
                FilterChip(
                  label: Text(type),
                  selected: monetization.contains(type),
                  onSelected: (value) {
                    setState(() {
                      if (value) {
                        monetization.add(type);
                      } else {
                        monetization.remove(type);
                      }
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l.t('discover.watchProvidersIds'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (_isLoadingProviders)
            const Center(child: CircularProgressIndicator())
          else if (_availableProviders.isEmpty)
            const Text('No providers found for this region.')
          else
            SizedBox(
              height: 200,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _availableProviders.length,
                itemBuilder: (context, index) {
                  final provider = _availableProviders[index];
                  final isSelected = selectedProviderIds.contains(provider.providerId);
                  return InkWell(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          selectedProviderIds.remove(provider.providerId);
                        } else {
                          if (provider.providerId != null) {
                            selectedProviderIds.add(provider.providerId!);
                          }
                        }
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (provider.logoPath != null)
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: 'https://image.tmdb.org/t/p/original${provider.logoPath}',
                                  fit: BoxFit.contain,
                                  errorWidget: (_, __, ___) => const Icon(Icons.tv),
                                ),
                              ),
                            ),
                          const SizedBox(height: 4),
                          Text(
                            provider.providerName ?? '',
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 12),
          Text(
            l.t('discover.releaseType'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final entry in [
                {'id': 1, 'name': 'Premiere'},
                {'id': 2, 'name': 'Theatrical (Limited)'},
                {'id': 3, 'name': 'Theatrical'},
                {'id': 4, 'name': 'Digital'},
                {'id': 5, 'name': 'Physical'},
                {'id': 6, 'name': 'TV'},
              ])
                FilterChip(
                  label: Text(entry['name'] as String),
                  selected: releaseType == entry['id'],
                  onSelected: (val) {
                    setState(
                      () => releaseType = val ? entry['id'] as int : null,
                    );
                  },
                ),
            ],
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l.t('discover.includeAdultContent')),
            value: includeAdult,
            onChanged: (v) => setState(() => includeAdult = v),
          ),
          const SizedBox(height: 12),
          Text(
            l.t('discover.peopleCompaniesKeywords'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(hintText: l.t('discover.hintWithCast')),
            onChanged: (v) => setState(() => withCast = v.replaceAll(' ', '')),
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(hintText: l.t('discover.hintWithCrew')),
            onChanged: (v) => setState(() => withCrew = v.replaceAll(' ', '')),
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              hintText: l.t('discover.hintWithCompanies'),
            ),
            onChanged: (v) =>
                setState(() => withCompanies = v.replaceAll(' ', '')),
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              hintText: l.t('discover.hintWithKeywords'),
            ),
            onChanged: (v) =>
                setState(() => withKeywords = v.replaceAll(' ', '')),
          ),
          const SizedBox(height: 24),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: const ValueKey('moviesApplyFilters'),
              onPressed: _apply,
              icon: const Icon(Icons.check),
              label: Text(AppLocalizations.of(context).t('common.apply')),
            ),
          ),
        ),
      ),
    );
  }
}
