import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';

class SeriesFiltersScreen extends StatefulWidget {
  static const routeName = '/series/filters';

  const SeriesFiltersScreen({super.key});

  @override
  State<SeriesFiltersScreen> createState() => _SeriesFiltersScreenState();
}

class _SeriesFiltersScreenState extends State<SeriesFiltersScreen> {
  final Set<int> networks = <int>{};
  String? status;
  String? type;
  DateTime? airFrom;
  DateTime? airTo;
  String language = '';
  int? firstAirYear;
  final Set<int> genres = <int>{};
  bool includeNullFirstAirDates = false;
  bool screenedTheatrically = false;
  String timezone = '';
  String watchProviders = '';
  final Set<String> monetization = <String>{'flatrate', 'rent', 'buy'};
  double voteMin = 5.0;
  double voteMax = 9.5;
  int runtimeMin = 20;
  int runtimeMax = 90;
  int voteCountMin = 50;

  void _reset() {
    setState(() {
      networks.clear();
      status = null;
      type = null;
      airFrom = null;
      airTo = null;
      language = '';
      firstAirYear = null;
      genres.clear();
      includeNullFirstAirDates = false;
      screenedTheatrically = false;
      timezone = '';
      watchProviders = '';
      monetization
        ..clear()
        ..addAll({'flatrate', 'rent', 'buy'});
      voteMin = 5.0;
      voteMax = 9.5;
      runtimeMin = 20;
      runtimeMax = 90;
      voteCountMin = 50;
    });
  }

  void _apply() {
    final filters = <String, String>{
      if (airFrom != null) 'first_air_date.gte': airFrom!.toIso8601String().split('T').first,
      if (airTo != null) 'first_air_date.lte': airTo!.toIso8601String().split('T').first,
      if (includeNullFirstAirDates) 'include_null_first_air_dates': 'true',
      if (screenedTheatrically) 'screened_theatrically': 'true',
      if (timezone.isNotEmpty) 'timezone': timezone,
      if (watchProviders.isNotEmpty) 'with_watch_providers': watchProviders,
      if (monetization.isNotEmpty) 'with_watch_monetization_types': monetization.join('|'),
      if (language.isNotEmpty) 'with_original_language': language,
      if (firstAirYear != null) 'first_air_date_year': '$firstAirYear',
      if (genres.isNotEmpty) 'with_genres': genres.join(','),
      if (status != null) 'with_status': status!,
      if (type != null) 'with_type': type!,
      'vote_average.gte': voteMin.toStringAsFixed(1),
      'vote_average.lte': voteMax.toStringAsFixed(1),
      'with_runtime.gte': '$runtimeMin',
      'with_runtime.lte': '$runtimeMax',
      'vote_count.gte': '$voteCountMin',
    };

    Navigator.pop(context, filters);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              const Icon(Icons.hub_outlined),
              const SizedBox(width: 8),
              Text(
                AppStrings.series,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('Networks', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final entry in const [
                {'id': 213, 'name': 'Netflix'},
                {'id': 49, 'name': 'HBO'},
                {'id': 1024, 'name': 'Amazon'},
                {'id': 2131, 'name': 'Disney+'},
                {'id': 2552, 'name': 'Apple TV+'},
              ])
                FilterChip(
                  label: Text(entry['name'] as String),
                  selected: networks.contains(entry['id']),
                  onSelected: (v) {
                    setState(() {
                      final id = entry['id'] as int;
                      if (v) networks.add(id); else networks.remove(id);
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Status', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final s in ['Returning Series', 'Ended', 'Canceled', 'In Production'])
                FilterChip(
                  label: Text(s),
                  selected: status == s,
                  onSelected: (v) => setState(() => status = v ? s : null),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Type', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final t in ['Scripted', 'Reality', 'Documentary', 'News', 'Talk Show', 'Miniseries'])
                FilterChip(
                  label: Text(t),
                  selected: type == t,
                  onSelected: (v) => setState(() => type = v ? t : null),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Air Date Range', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.date_range),
                  label: Text(airFrom == null ? 'From' : airFrom!.toIso8601String().split('T').first),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: airFrom ?? DateTime.now().subtract(const Duration(days: 3650)),
                      firstDate: DateTime(1950),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setState(() => airFrom = picked);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.event),
                  label: Text(airTo == null ? 'To' : airTo!.toIso8601String().split('T').first),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: airTo ?? DateTime.now(),
                      firstDate: DateTime(1950),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) setState(() => airTo = picked);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Original Language', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final lang in ['en','es','fr','de','it','ja','ko'])
                FilterChip(
                  label: Text(lang.toUpperCase()),
                  selected: language == lang,
                  onSelected: (v) => setState(() => language = v ? lang : ''),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text('First Air Date Year', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final y in [1990, 2000, 2010, 2020, 2024])
                FilterChip(
                  label: Text('$y'),
                  selected: firstAirYear == y,
                  onSelected: (v) => setState(() => firstAirYear = v ? y : null),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Genres', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final g in const [
                {'id': 18, 'name': 'Drama'},
                {'id': 35, 'name': 'Comedy'},
                {'id': 80, 'name': 'Crime'},
                {'id': 16, 'name': 'Animation'},
                {'id': 10759, 'name': 'Action & Adventure'},
                {'id': 10765, 'name': 'Sci-Fi & Fantasy'},
                {'id': 99, 'name': 'Documentary'},
              ])
                FilterChip(
                  label: Text(g['name'] as String),
                  selected: genres.contains(g['id']),
                  onSelected: (v) {
                    setState(() {
                      final id = g['id'] as int;
                      if (v) genres.add(id); else genres.remove(id);
                    });
                  },
                ),
            ],
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Include Null First Air Dates'),
            value: includeNullFirstAirDates,
            onChanged: (v) => setState(() => includeNullFirstAirDates = v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Screened Theatrically'),
            value: screenedTheatrically,
            onChanged: (v) => setState(() => screenedTheatrically = v),
          ),
          const SizedBox(height: 8),
          Text('Timezone', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            decoration: const InputDecoration(hintText: 'e.g., America/New_York'),
            onChanged: (v) => setState(() => timezone = v.trim()),
          ),
          const SizedBox(height: 16),
          Text('Watch Providers (IDs)', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            decoration: const InputDecoration(hintText: 'Comma-separated provider IDs'),
            onChanged: (v) => setState(() => watchProviders = v.replaceAll(' ', '')),
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
            max: 180,
            divisions: 18,
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
          const SizedBox(height: 24),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: const ValueKey('seriesApplyFilters'),
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


