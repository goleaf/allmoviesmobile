import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/models/discover_filters_model.dart';
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
  String? certificationLte;
  DateTime? releaseFrom;
  DateTime? releaseTo;
  double voteMin = 5.0;
  double voteMax = 9.5;
  int runtimeMin = 60;
  int runtimeMax = 180;
  int voteCountMin = 100;
  final Set<String> monetization = <String>{'flatrate', 'rent', 'buy'};
  String watchProviders = '';
  int? releaseType;
  String withCast = '';
  String withCrew = '';
  String withCompanies = '';
  String withKeywords = '';

  @override
  void initState() {
    super.initState();
    final init = widget.initial;
    includeAdult = init?.includeAdult ?? false;
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
    watchProviders = init?.withWatchProviders ?? '';
    releaseType = int.tryParse(init?.withReleaseType ?? '');
    withCast = init?.withCast ?? '';
    withCrew = init?.withCrew ?? '';
    withCompanies = init?.withCompanies ?? '';
    withKeywords = init?.withKeywords ?? '';
  }

  void _reset() {
    setState(() {
      includeAdult = false;
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
      watchProviders = '';
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
      certificationCountry: region,
      certificationLte: certificationLte,
      releaseDateGte: releaseFrom != null
          ? releaseFrom!.toIso8601String().split('T').first
          : null,
      releaseDateLte:
          releaseTo != null ? releaseTo!.toIso8601String().split('T').first : null,
      voteAverageGte: voteMin,
      voteAverageLte: voteMax,
      runtimeGte: runtimeMin,
      runtimeLte: runtimeMax,
      voteCountGte: voteCountMin,
      withWatchMonetizationTypes:
          monetization.isNotEmpty ? monetization.join('|') : null,
      withWatchProviders: watchProviders.isNotEmpty ? watchProviders : null,
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
    final region = context.watch<WatchRegionProvider?>()?.region;
    return Scaffold(
      key: const ValueKey('moviesFiltersScaffold'),
      appBar: AppBar(
        title: const Text(AppStrings.filters),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _reset,
            child: const Text(AppStrings.reset),
          ),
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
                AppStrings.discover,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              if (region != null) Chip(label: Text('Region: $region')),
            ],
          ),
          const SizedBox(height: 12),
          Text('By Decade', style: Theme.of(context).textTheme.titleMedium),
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
          Text('Certification', style: Theme.of(context).textTheme.titleMedium),
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
          Text('Release Date Range', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.date_range),
                  label: Text(releaseFrom == null
                      ? 'From'
                      : releaseFrom!.toIso8601String().split('T').first),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: releaseFrom ?? DateTime.now().subtract(const Duration(days: 3650)),
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
                  label: Text(releaseTo == null
                      ? 'To'
                      : releaseTo!.toIso8601String().split('T').first),
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
          Text('Vote Average', style: Theme.of(context).textTheme.titleMedium),
          RangeSlider(
            values: RangeValues(voteMin, voteMax),
            min: 0,
            max: 10,
            divisions: 20,
            labels: RangeLabels(voteMin.toStringAsFixed(1), voteMax.toStringAsFixed(1)),
            onChanged: (values) {
              setState(() {
                voteMin = values.start;
                voteMax = values.end;
              });
            },
          ),
          const SizedBox(height: 8),
          Text('Runtime (minutes)', style: Theme.of(context).textTheme.titleMedium),
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
          Text('Vote Count Minimum', style: Theme.of(context).textTheme.titleMedium),
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
          Text('Monetization Types', style: Theme.of(context).textTheme.titleMedium),
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
          Text('Watch Providers (IDs)', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            decoration: const InputDecoration(hintText: 'Comma-separated provider IDs, e.g., 8,9,337'),
            onChanged: (v) => setState(() => watchProviders = v.replaceAll(' ', '')),
          ),
          const SizedBox(height: 12),
          Text('Release Type', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final entry in const [
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
                    setState(() => releaseType = val ? entry['id'] as int : null);
                  },
                ),
            ],
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Include Adult Content'),
            value: includeAdult,
            onChanged: (v) => setState(() => includeAdult = v),
          ),
          const SizedBox(height: 12),
          Text('People & Companies & Keywords', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            decoration: const InputDecoration(hintText: 'With Cast (comma-separated person IDs)'),
            onChanged: (v) => setState(() => withCast = v.replaceAll(' ', '')),
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: const InputDecoration(hintText: 'With Crew (comma-separated person IDs)'),
            onChanged: (v) => setState(() => withCrew = v.replaceAll(' ', '')),
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: const InputDecoration(hintText: 'With Companies (comma-separated company IDs)'),
            onChanged: (v) => setState(() => withCompanies = v.replaceAll(' ', '')),
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: const InputDecoration(hintText: 'With Keywords (comma-separated keyword IDs)'),
            onChanged: (v) => setState(() => withKeywords = v.replaceAll(' ', '')),
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
              label: const Text(AppStrings.apply),
            ),
          ),
        ),
      ),
    );
  }
}


