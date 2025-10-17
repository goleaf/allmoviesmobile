import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/models/series_filter_preset.dart';
import '../../../providers/preferences_provider.dart';

/// Arguments passed when navigating to [SeriesFiltersScreen].
class SeriesFiltersScreenArguments {
  const SeriesFiltersScreenArguments({
    this.initialFilters,
    this.initialPresetName,
  });

  final Map<String, String>? initialFilters;
  final String? initialPresetName;
}

/// Result returned from the filter screen back to the series list.
class SeriesFilterResult {
  const SeriesFilterResult({required this.filters, this.presetName});

  final Map<String, String> filters;
  final String? presetName;
}

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

  final TextEditingController _timezoneController = TextEditingController();
  final TextEditingController _watchProvidersController =
      TextEditingController();

  bool _suspendTextNotifications = false;
  bool _didLoadInitialFilters = false;
  String? _currentPresetName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _timezoneController.dispose();
    _watchProvidersController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    if (!mounted || _didLoadInitialFilters) {
      return;
    }
    _didLoadInitialFilters = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    final parsedArgs =
        args is SeriesFiltersScreenArguments ? args : null;

    if (parsedArgs?.initialFilters != null) {
      _loadFromFilters(
        parsedArgs!.initialFilters!,
        presetName: parsedArgs.initialPresetName,
      );
    }
  }

  void _updateState(
    VoidCallback updates, {
    String? presetNameOverride,
    bool resetPreset = true,
  }) {
    if (!mounted) return;
    setState(() {
      updates();
      if (presetNameOverride != null) {
        _currentPresetName = presetNameOverride;
      } else if (resetPreset) {
        _currentPresetName = null;
      }
    });
  }

  void _reset() {
    _updateState(() {
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
    _updateTextControllers('', '');
  }

  Map<String, String> _buildFilters() {
    final filters = <String, String>{
      if (airFrom != null)
        'first_air_date.gte': _formatDate(airFrom!),
      if (airTo != null)
        'first_air_date.lte': _formatDate(airTo!),
      if (includeNullFirstAirDates) 'include_null_first_air_dates': 'true',
      if (screenedTheatrically) 'screened_theatrically': 'true',
      if (timezone.isNotEmpty) 'timezone': timezone,
      if (watchProviders.isNotEmpty)
        'with_watch_providers': watchProviders.replaceAll(' ', ''),
      if (monetization.isNotEmpty)
        'with_watch_monetization_types':
            (monetization.toList()..sort()).join('|'),
      if (language.isNotEmpty) 'with_original_language': language,
      if (firstAirYear != null) 'first_air_date_year': '$firstAirYear',
      if (genres.isNotEmpty)
        'with_genres': (genres.toList()..sort()).join(','),
      if (networks.isNotEmpty)
        'with_networks': (networks.toList()..sort()).join('|'),
      if (status != null) 'with_status': status!,
      if (type != null) 'with_type': type!,
      'vote_average.gte': voteMin.toStringAsFixed(1),
      'vote_average.lte': voteMax.toStringAsFixed(1),
      'with_runtime.gte': '$runtimeMin',
      'with_runtime.lte': '$runtimeMax',
      'vote_count.gte': '$voteCountMin',
    };
    return filters;
  }

  void _apply() {
    final filters = _buildFilters();
    _submitWithFilters(filters, presetName: _currentPresetName);
  }

  void _submitWithFilters(
    Map<String, String> filters, {
    String? presetName,
  }) {
    Navigator.pop(
      context,
      SeriesFilterResult(filters: filters, presetName: presetName),
    );
  }

  void _updateTextControllers(String timezoneValue, String providersValue) {
    _suspendTextNotifications = true;
    _timezoneController.text = timezoneValue;
    _watchProvidersController.text = providersValue;
    _suspendTextNotifications = false;
  }

  void _loadFromFilters(
    Map<String, String> filters, {
    String? presetName,
  }) {
    _updateState(
      () {
        networks
          ..clear()
          ..addAll(_parseIntList(filters['with_networks']));
        status = filters['with_status'];
        type = filters['with_type'];
        airFrom = _tryParseDate(filters['first_air_date.gte']);
        airTo = _tryParseDate(filters['first_air_date.lte']);
        language = filters['with_original_language'] ?? '';
        firstAirYear = _tryParseInt(filters['first_air_date_year']);
        genres
          ..clear()
          ..addAll(_parseIntList(filters['with_genres'], separator: ','));
        includeNullFirstAirDates =
            _tryParseBool(filters['include_null_first_air_dates']);
        screenedTheatrically =
            _tryParseBool(filters['screened_theatrically']);
        timezone = filters['timezone'] ?? '';
        watchProviders = filters['with_watch_providers'] ?? '';
        monetization
          ..clear()
          ..addAll(
            _parseStringSet(
              filters['with_watch_monetization_types'],
              separator: '|',
            ),
          );
        voteMin = _tryParseDouble(filters['vote_average.gte']) ?? 5.0;
        voteMax = _tryParseDouble(filters['vote_average.lte']) ?? 9.5;
        runtimeMin = _tryParseInt(filters['with_runtime.gte']) ?? 20;
        runtimeMax = _tryParseInt(filters['with_runtime.lte']) ?? 90;
        voteCountMin = _tryParseInt(filters['vote_count.gte']) ?? 50;
      },
      presetNameOverride: presetName,
      resetPreset: false,
    );
    _updateTextControllers(timezone, watchProviders);
  }

  Future<void> _savePreset() async {
    final filters = _buildFilters();
    if (filters.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one filter first.')),
      );
      return;
    }
    final name = await _promptPresetName();
    if (name == null) {
      return;
    }
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return;
    }

    final prefs = context.read<PreferencesProvider>();
    await prefs.saveSeriesFilterPreset(
      SeriesFilterPreset(name: trimmed, filters: filters),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved preset "$trimmed".')),
    );
    _updateState(
      () {},
      presetNameOverride: trimmed,
      resetPreset: false,
    );
  }

  Future<String?> _promptPresetName() async {
    final prefs = context.read<PreferencesProvider>();
    final existing = prefs.seriesFilterPresets;
    final defaultName = _currentPresetName ??
        'Preset ${existing.length + 1}';
    final controller = TextEditingController(text: defaultName);
    final l = AppLocalizations.of(context);

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Save preset'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Preset name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l.t('common.cancel')),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(controller.text.trim());
              },
              child: const Text(AppStrings.save),
            ),
          ],
        );
      },
    );
    controller.dispose();
    return result;
  }

  Future<void> _showPresetsSheet() async {
    final prefs = context.read<PreferencesProvider>();
    final presets = prefs.seriesFilterPresets;
    if (presets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No saved presets yet.')),
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemBuilder: (_, index) {
            final preset = presets[index];
            return ListTile(
              title: Text(preset.name),
              subtitle: Text('${preset.filters.length} filters'),
              onTap: () {
                Navigator.of(sheetContext).pop();
                _loadFromFilters(
                  preset.filters,
                  presetName: preset.name,
                );
              },
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Apply preset',
                    icon: const Icon(Icons.playlist_add_check),
                    onPressed: () {
                      Navigator.of(sheetContext).pop();
                      _submitWithFilters(
                        preset.filters,
                        presetName: preset.name,
                      );
                    },
                  ),
                  IconButton(
                    tooltip: 'Delete preset',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) {
                          return AlertDialog(
                            title: const Text('Delete preset'),
                            content: Text(
                              'Remove "${preset.name}" from saved presets?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(dialogContext).pop(false),
                                child: Text(
                                  AppLocalizations.of(context)
                                      .t('common.cancel'),
                                ),
                              ),
                              FilledButton(
                                onPressed: () =>
                                    Navigator.of(dialogContext).pop(true),
                                child: const Text(AppStrings.delete),
                              ),
                            ],
                          );
                        },
                      );
                      if (confirm == true) {
                        Navigator.of(sheetContext).pop();
                        await _deletePreset(preset.name);
                      }
                    },
                  ),
                ],
              ),
            );
          },
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemCount: presets.length,
        );
      },
    );
  }

  Future<void> _deletePreset(String name) async {
    final prefs = context.read<PreferencesProvider>();
    await prefs.deleteSeriesFilterPreset(name);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Deleted preset "$name".')),
    );
    if (_currentPresetName != null &&
        _currentPresetName!.toLowerCase() == name.toLowerCase()) {
      _updateState(() {}, presetNameOverride: null);
    } else {
      setState(() {});
    }
  }

  List<int> _parseIntList(String? raw, {String separator = '|'}) {
    if (raw == null || raw.isEmpty) {
      return const <int>[];
    }
    final pattern = separator == '|'
        ? RegExp('[,|]')
        : RegExp(RegExp.escape(separator));
    return raw
        .split(pattern)
        .map((value) => int.tryParse(value.trim()))
        .whereType<int>()
        .toList();
  }

  Set<String> _parseStringSet(String? raw, {String separator = ','}) {
    if (raw == null || raw.isEmpty) {
      return <String>{};
    }
    return raw
        .split(separator)
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet();
  }

  DateTime? _tryParseDate(String? raw) {
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      return DateTime.parse(raw);
    } catch (_) {
      return null;
    }
  }

  int? _tryParseInt(String? raw) => raw == null ? null : int.tryParse(raw);

  double? _tryParseDouble(String? raw) =>
      raw == null ? null : double.tryParse(raw);

  bool _tryParseBool(String? raw) => raw == 'true';

  String _formatDate(DateTime value) => value.toIso8601String().split('T').first;

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
            tooltip: 'Saved presets',
            icon: const Icon(Icons.bookmarks_outlined),
            onPressed: _showPresetsSheet,
          ),
          TextButton(onPressed: _reset, child: Text(l.t('common.reset'))),
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
                AppLocalizations.of(context).t('tv.series'),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          if (_currentPresetName != null) ...[
            const SizedBox(height: 12),
            InputChip(
              label: Text('Preset: $_currentPresetName'),
              onDeleted: () =>
                  _updateState(() {}, presetNameOverride: null),
            ),
          ],
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
                    _updateState(() {
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
                  onSelected: (v) =>
                      _updateState(() => status = v ? s : null),
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
                  onSelected: (v) =>
                      _updateState(() => type = v ? t : null),
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
                        : _formatDate(airFrom!),
                  ),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: airFrom ??
                          DateTime.now().subtract(const Duration(days: 3650)),
                      firstDate: DateTime(1950),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      _updateState(() => airFrom = picked);
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.event),
                  label: Text(
                    airTo == null ? 'To' : _formatDate(airTo!),
                  ),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: airTo ?? DateTime.now(),
                      firstDate: DateTime(1950),
                      lastDate:
                          DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      _updateState(() => airTo = picked);
                    }
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
                  onSelected: (v) =>
                      _updateState(() => language = v ? lang : ''),
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
                      _updateState(() => firstAirYear = v ? y : null),
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
                    _updateState(() {
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
            onChanged: (v) =>
                _updateState(() => includeNullFirstAirDates = v),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Screened Theatrically'),
            value: screenedTheatrically,
            onChanged: (v) =>
                _updateState(() => screenedTheatrically = v),
          ),
          const SizedBox(height: 8),
          Text('Timezone', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _timezoneController,
            decoration: const InputDecoration(
              hintText: 'e.g., America/New_York',
            ),
            onChanged: (v) {
              if (_suspendTextNotifications) return;
              _updateState(() => timezone = v.trim());
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Watch Providers (IDs)',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _watchProvidersController,
            decoration: const InputDecoration(
              hintText: 'Comma-separated provider IDs',
            ),
            onChanged: (v) {
              if (_suspendTextNotifications) return;
              _updateState(() => watchProviders = v.replaceAll(' ', ''));
            },
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
                    _updateState(() {
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
              _updateState(() {
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
            values: RangeValues(
              runtimeMin.toDouble(),
              runtimeMax.toDouble(),
            ),
            min: 0,
            max: 180,
            divisions: 18,
            labels: RangeLabels('$runtimeMin', '$runtimeMax'),
            onChanged: (values) {
              _updateState(() {
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
                  onChanged: (v) =>
                      _updateState(() => voteCountMin = v.round()),
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
                child: OutlinedButton.icon(
                  onPressed: _savePreset,
                  icon: const Icon(Icons.bookmark_add_outlined),
                  label: const Text('Save preset'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  key: const ValueKey('seriesApplyFilters'),
                  onPressed: _apply,
                  icon: const Icon(Icons.check),
                  label: const Text(AppStrings.apply),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
