import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../providers/preferences_provider.dart';
import '../../../providers/series_provider.dart';

class SeriesFiltersScreen extends StatefulWidget {
  static const routeName = '/series/filters';

  const SeriesFiltersScreen({super.key});

  @override
  State<SeriesFiltersScreen> createState() => _SeriesFiltersScreenState();
}

class _SeriesFiltersScreenState extends State<SeriesFiltersScreen> {
  final TextEditingController _timezoneController = TextEditingController();
  final TextEditingController _watchProvidersController = TextEditingController();

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

  Map<String, Map<String, String>> _presets = <String, Map<String, String>>{};
  String? _selectedPresetName;
  bool _isLoadingPresets = false;

  @override
  void initState() {
    super.initState();
    _timezoneController.text = timezone;
    _watchProvidersController.text = watchProviders;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPresets();
    });
  }

  @override
  void dispose() {
    _timezoneController.dispose();
    _watchProvidersController.dispose();
    super.dispose();
  }

  Future<void> _loadPresets() async {
    final preferences = context.read<PreferencesProvider>();
    setState(() {
      _isLoadingPresets = true;
    });
    final presets = await preferences.loadTvFilterPresets();
    if (!mounted) return;
    setState(() {
      _presets = presets;
      if (_selectedPresetName != null && !_presets.containsKey(_selectedPresetName)) {
        _selectedPresetName = null;
      }
      _isLoadingPresets = false;
    });
  }

  Future<void> _saveCurrentPreset() async {
    final name = await _promptForPresetName();
    if (name == null) return;

    final preferences = context.read<PreferencesProvider>();
    await preferences.saveTvFilterPreset(name, _buildFilters());
    if (!mounted) return;
    await _loadPresets();
    if (!mounted) return;
    setState(() {
      _selectedPresetName = name;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Preset "$name" saved.')),
    );
  }

  Future<void> _deleteSelectedPreset() async {
    final name = _selectedPresetName;
    if (name == null) return;
    final preferences = context.read<PreferencesProvider>();
    await preferences.deleteTvFilterPreset(name);
    if (!mounted) return;
    await _loadPresets();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Preset "$name" deleted.')),
    );
  }

  Future<void> _applySelectedPreset() async {
    final name = _selectedPresetName;
    if (name == null) return;
    final filters = _presets[name];
    if (filters == null) return;
    _loadFromFilters(filters);
    final appliedFilters = Map<String, String>.from(filters);
    await context.read<SeriesProvider>().applyTvFilters(appliedFilters);
    if (!mounted) return;
    Navigator.pop(context, appliedFilters);
  }

  Future<String?> _promptForPresetName() async {
    final controller = TextEditingController(text: _selectedPresetName ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Save preset'),
          content: TextField(
            key: const ValueKey('presetNameField'),
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Preset name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(AppStrings.cancel),
            ),
            TextButton(
              onPressed: () {
                final trimmed = controller.text.trim();
                if (trimmed.isEmpty) {
                  Navigator.of(context).pop();
                } else {
                  Navigator.of(context).pop(trimmed);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    controller.dispose();
    if (result == null || result.trim().isEmpty) return null;
    return result.trim();
  }

  void _loadFromFilters(Map<String, String> filters) {
    setState(() {
      networks
        ..clear()
        ..addAll(_parseIntList(filters['with_networks']));
      status = filters['with_status'];
      type = filters['with_type'];
      airFrom = _parseDate(filters['first_air_date.gte']);
      airTo = _parseDate(filters['first_air_date.lte']);
      language = filters['with_original_language'] ?? '';
      firstAirYear = int.tryParse(filters['first_air_date_year'] ?? '');
      genres
        ..clear()
        ..addAll(_parseIntList(filters['with_genres']));
      includeNullFirstAirDates =
          _parseBool(filters['include_null_first_air_dates']);
      screenedTheatrically = _parseBool(filters['screened_theatrically']);
      timezone = filters['timezone'] ?? '';
      _timezoneController.text = timezone;
      watchProviders = filters['with_watch_providers'] ?? '';
      _watchProvidersController.text = watchProviders;
      monetization
        ..clear()
        ..addAll(_parseStringList(filters['with_watch_monetization_types'],
            separator: '|'));
      voteMin = double.tryParse(filters['vote_average.gte'] ?? '') ?? 5.0;
      voteMax = double.tryParse(filters['vote_average.lte'] ?? '') ?? 9.5;
      runtimeMin = int.tryParse(filters['with_runtime.gte'] ?? '') ?? 20;
      runtimeMax = int.tryParse(filters['with_runtime.lte'] ?? '') ?? 90;
      voteCountMin = int.tryParse(filters['vote_count.gte'] ?? '') ?? 50;
    });
  }

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
      _timezoneController.clear();
      _watchProvidersController.clear();
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

  Map<String, String> _buildFilters() {
    return <String, String>{
      if (airFrom != null)
        'first_air_date.gte': airFrom!.toIso8601String().split('T').first,
      if (airTo != null)
        'first_air_date.lte': airTo!.toIso8601String().split('T').first,
      if (includeNullFirstAirDates) 'include_null_first_air_dates': 'true',
      if (screenedTheatrically) 'screened_theatrically': 'true',
      if (timezone.isNotEmpty) 'timezone': timezone,
      if (watchProviders.isNotEmpty) 'with_watch_providers': watchProviders,
      if (monetization.isNotEmpty)
        'with_watch_monetization_types':
            _sortedStrings(monetization).join('|'),
      if (language.isNotEmpty) 'with_original_language': language,
      if (firstAirYear != null) 'first_air_date_year': '$firstAirYear',
      if (genres.isNotEmpty) 'with_genres': _sortedInts(genres).join(','),
      if (networks.isNotEmpty)
        'with_networks': _sortedInts(networks).join(','),
      if (status != null) 'with_status': status!,
      if (type != null) 'with_type': type!,
      'vote_average.gte': voteMin.toStringAsFixed(1),
      'vote_average.lte': voteMax.toStringAsFixed(1),
      'with_runtime.gte': '$runtimeMin',
      'with_runtime.lte': '$runtimeMax',
      'vote_count.gte': '$voteCountMin',
    };
  }

  void _apply() {
    final filters = _buildFilters();
    Navigator.pop(context, filters);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.t('discover.filters')),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            key: const ValueKey('savePresetButton'),
            tooltip: 'Save preset',
            onPressed: _saveCurrentPreset,
            icon: const Icon(Icons.save_alt),
          ),
          TextButton(
            onPressed: _reset,
            child: Text(l.t('common.reset')),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildPresetsSection(),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.hub_outlined),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context).t('tv.series'),
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
              for (final entry in [
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
                      if (v) {
                        networks.add(id);
                      } else {
                        networks.remove(id);
                      }
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
              for (final s in [
                'Returning Series',
                'Ended',
                'Canceled',
                'In Production',
              ])
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
              for (final t in [
                'Scripted',
                'Reality',
                'Documentary',
                'News',
                'Talk Show',
                'Miniseries',
              ])
                FilterChip(
                  label: Text(t),
                  selected: type == t,
                  onSelected: (v) => setState(() => type = v ? t : null),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Air Date Range',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.date_range),
                  label: Text(
                    airFrom == null
                        ? 'From'
                        : airFrom!.toIso8601String().split('T').first,
                  ),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate:
                          airFrom ??
                          DateTime.now().subtract(const Duration(days: 3650)),
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
                  label: Text(
                    airTo == null
                        ? 'To'
                        : airTo!.toIso8601String().split('T').first,
                  ),
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
          Text(
            'Original Language',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final lang in ['en', 'es', 'fr', 'de', 'it', 'ja', 'ko'])
                FilterChip(
                  label: Text(lang.toUpperCase()),
                  selected: language == lang,
                  onSelected: (v) => setState(() => language = v ? lang : ''),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'First Air Date Year',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final y in [1990, 2000, 2010, 2020, 2024])
                FilterChip(
                  label: Text('$y'),
                  selected: firstAirYear == y,
                  onSelected: (v) =>
                      setState(() => firstAirYear = v ? y : null),
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
              for (final g in [
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
                      if (v) {
                        genres.add(id);
                      } else {
                        genres.remove(id);
                      }
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
            key: const ValueKey('timezoneField'),
            controller: _timezoneController,
            decoration: const InputDecoration(
              hintText: 'e.g., America/New_York',
            ),
            onChanged: (v) => setState(() => timezone = v.trim()),
          ),
          const SizedBox(height: 16),
          Text(
            'Watch Providers (IDs)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          TextField(
            key: const ValueKey('watchProvidersField'),
            controller: _watchProvidersController,
            decoration: const InputDecoration(
              hintText: 'Comma-separated provider IDs',
            ),
            onChanged: (v) =>
                setState(() => watchProviders = v.replaceAll(' ', '')),
          ),
          const SizedBox(height: 8),
          Text(
            'Monetization Types',
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
          const SizedBox(height: 16),
          Text('Vote Average', style: Theme.of(context).textTheme.titleMedium),
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
            'Runtime (minutes)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
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
          Text(
            'Vote Count Minimum',
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
          const SizedBox(height: 24),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  key: const ValueKey('seriesApplyFilters'),
                  onPressed: _apply,
                  icon: const Icon(Icons.check),
                  label: const Text(AppStrings.apply),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                key: const ValueKey('applyPresetButton'),
                tooltip: 'Apply preset',
                onPressed:
                    _selectedPresetName == null ? null : _applySelectedPreset,
                icon: const Icon(Icons.playlist_add_check),
              ),
              IconButton(
                key: const ValueKey('deletePresetButton'),
                tooltip: 'Delete preset',
                onPressed:
                    _selectedPresetName == null ? null : _deleteSelectedPreset,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPresetsSection() {
    if (_isLoadingPresets) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [CircularProgressIndicator()],
          ),
        ),
      );
    }

    final hasPresets = _presets.isNotEmpty;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Presets',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              key: const ValueKey('tvPresetPicker'),
              value: hasPresets ? _selectedPresetName : null,
              hint: const Text('Select a preset'),
              items: [
                for (final entry in _presets.entries)
                  DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.key),
                  ),
              ],
              onChanged: hasPresets
                  ? (value) {
                      if (value == null) return;
                      final filters = _presets[value];
                      if (filters == null) return;
                      setState(() {
                        _selectedPresetName = value;
                      });
                      _loadFromFilters(filters);
                    }
                  : null,
            ),
            if (!hasPresets) ...[
              const SizedBox(height: 12),
              Text(
                'No presets saved yet.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Iterable<int> _parseIntList(String? source) {
    if (source == null || source.isEmpty) return const <int>[];
    return source
        .split(',')
        .map((value) => int.tryParse(value.trim()))
        .whereType<int>();
  }

  Iterable<String> _parseStringList(String? source, {String separator = ','}) {
    if (source == null || source.isEmpty) return const <String>[];
    return source
        .split(separator)
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty);
  }

  DateTime? _parseDate(String? source) {
    if (source == null || source.isEmpty) return null;
    return DateTime.tryParse(source);
  }

  bool _parseBool(String? source) {
    if (source == null) return false;
    return source.toLowerCase() == 'true';
  }

  List<int> _sortedInts(Set<int> values) {
    final list = values.toList()..sort();
    return list;
  }

  List<String> _sortedStrings(Set<String> values) {
    final list = values.toList()..sort();
    return list;
  }
}
