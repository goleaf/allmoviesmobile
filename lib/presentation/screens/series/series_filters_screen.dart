import 'dart:async';
import 'dart:ui' as dart_ui;


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../data/models/tv_filter_preset.dart';
import '../../widgets/filters/watch_provider_selector.dart';
import '../../../data/models/discover_filters_model.dart';
import '../../widgets/filters/sort_by_dropdown.dart';
import '../../../data/models/network_detailed_model.dart';
import '../../../data/tmdb_repository.dart';
import '../../../data/tv_filter_presets_repository.dart';
import '../../../providers/watch_region_provider.dart';

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

  const SeriesFiltersScreen({
    super.key,
    this.initialFilters,
    this.presetSaved = false,
  });

  final Map<String, String>? initialFilters;
  final bool presetSaved;

  @override
  State<SeriesFiltersScreen> createState() => _SeriesFiltersScreenState();
}

class _SeriesFiltersScreenState extends State<SeriesFiltersScreen> {
  // Filters
  SortBy sortBy = SortBy.popularityDesc;
  final Set<int> networks = <int>{};
  final Map<int, String> networkNames = {}; // To display names of selected networks
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
  final Set<int> selectedProviderIds = <int>{};
  final Set<String> monetization = <String>{'flatrate', 'rent', 'buy'};
  double voteMin = 5.0;
  double voteMax = 9.5;
  int runtimeMin = 20;
  int runtimeMax = 90;
  int voteCountMin = 50;
  String? certification;
  String withCast = '';
  String withCrew = '';
  String withCompanies = '';
  String withKeywords = '';

  final TextEditingController _timezoneController = TextEditingController();
  final TextEditingController _networkSearchController = TextEditingController();
  Timer? _debounce;

  bool _suspendTextNotifications = false;
  bool _didLoadInitialFilters = false;
  String? _currentPresetName;

  // Data
  List<NetworkDetailed> _networkSearchResults = [];
  bool _isSearchingNetworks = false;

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
    _networkSearchController.dispose();
    _debounce?.cancel();
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



  void _onNetworkSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchNetworks(query);
    });
  }

  Future<void> _searchNetworks(String query) async {
    if (query.isEmpty) {
      setState(() {
        _networkSearchResults = [];
        _isSearchingNetworks = false;
      });
      return;
    }

    setState(() => _isSearchingNetworks = true);
    try {
      final repo = context.read<TmdbRepository>();
      final response = await repo.searchNetworks(query);
      if (mounted) {
        setState(() {
          _networkSearchResults = response.results;
          _isSearchingNetworks = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isSearchingNetworks = false);
      }
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
      sortBy = SortBy.popularityDesc;
      networks.clear();
      networkNames.clear();
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
      selectedProviderIds.clear();
      monetization
        ..clear()
        ..addAll({'flatrate', 'rent', 'buy'});
      voteMin = 5.0;
      voteMax = 9.5;
      runtimeMin = 20;
      runtimeMax = 90;
      voteCountMin = 50;
      certification = null;
      withCast = '';
      withCrew = '';
      withCompanies = '';
      withKeywords = '';
    });
    _updateTextControllers('');
  }

  Map<String, String> _buildFilters() {
    final region = context.read<WatchRegionProvider?>()?.region;
    final filters = <String, String>{
      'sort_by': sortBy.value,
      if (airFrom != null)
        'first_air_date.gte': _formatDate(airFrom!),
      if (airTo != null)
        'first_air_date.lte': _formatDate(airTo!),
      if (includeNullFirstAirDates) 'include_null_first_air_dates': 'true',
      if (screenedTheatrically) 'screened_theatrically': 'true',
      if (timezone.isNotEmpty) 'timezone': timezone,
      if (selectedProviderIds.isNotEmpty)
        'with_watch_providers': selectedProviderIds.join('|'),
      if (region != null) 'watch_region': region,
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
      if (certification != null) ...{
        'certification_country': region ?? 'US',
        'certification': certification!,
      },
      if (withCast.isNotEmpty) 'with_cast': withCast,
      if (withCrew.isNotEmpty) 'with_crew': withCrew,
      if (withCompanies.isNotEmpty) 'with_companies': withCompanies,
      if (withKeywords.isNotEmpty) 'with_keywords': withKeywords,
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

  void _updateTextControllers(String timezoneValue) {
    _suspendTextNotifications = true;
    _timezoneController.text = timezoneValue;
    _suspendTextNotifications = false;
  }

  void _loadFromFilters(
    Map<String, String> filters, {
    String? presetName,
  }) {
    _updateState(
      () {
        sortBy = SortByExtension.fromString(filters['sort_by']);
        networks
          ..clear()
          ..addAll(_parseIntList(filters['with_networks']));
        // Note: We can't easily restore network names from IDs without fetching them.
        // For now, we just restore IDs.
        
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
        
        selectedProviderIds.clear();
        final providerIds = _parseIntList(filters['with_watch_providers'], separator: '|');
        selectedProviderIds.addAll(providerIds);

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
        certification = filters['certification'];
        withCast = filters['with_cast'] ?? '';
        withCrew = filters['with_crew'] ?? '';
        withCompanies = filters['with_companies'] ?? '';
        withKeywords = filters['with_keywords'] ?? '';
      },
      presetNameOverride: presetName,
      resetPreset: false,
    );
    _updateTextControllers(timezone);
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

    final repository = context.read<TvFilterPresetsRepository>();
    await repository.savePreset(
      TvFilterPreset(name: trimmed, filters: filters),
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
    final repository = context.read<TvFilterPresetsRepository>();
    final existing = await repository.loadPresets();
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
    final repository = context.read<TvFilterPresetsRepository>();
    final presets = await repository.loadPresets();
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
    final repository = context.read<TvFilterPresetsRepository>();
    await repository.deletePreset(name);
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
    final region = context.watch<WatchRegionProvider?>()?.region;
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface.withOpacity(0.7),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: dart_ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        title: Text(
          l.t('discover.filters'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            tooltip: 'Saved presets',
            icon: const Icon(Icons.bookmarks_outlined),
            onPressed: _showPresetsSheet,
          ),
          TextButton(
            onPressed: _reset,
            child: Text(
              l.t('common.reset'),
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
              theme.colorScheme.primaryContainer.withOpacity(0.1),
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 100, 16, 16),
          children: [
            _buildHeaderSection(context, region, l),
            const SizedBox(height: 16),
            if (_currentPresetName != null) ...[
              _buildPresetChip(),
              const SizedBox(height: 16),
            ],
            _buildSection(
              context,
              title: l.t('discover.sortBy'),
              child: SortByDropdown(
                value: sortBy,
                onChanged: (v) => setState(() => sortBy = v),
                isTv: true,
              ),
            ),
            _buildSection(
              context,
              title: 'Networks',
              child: Column(
                children: [
                  TextField(
                    controller: _networkSearchController,
                    decoration: InputDecoration(
                      hintText: 'Search networks...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: theme.colorScheme.surface.withOpacity(0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: _isSearchingNetworks
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: Padding(
                                padding: EdgeInsets.all(12.0),
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : null,
                    ),
                    onChanged: _onNetworkSearchChanged,
                  ),
                  if (_networkSearchResults.isNotEmpty)
                    Container(
                      height: 150,
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: ListView.builder(
                          itemCount: _networkSearchResults.length,
                          itemBuilder: (context, index) {
                            final network = _networkSearchResults[index];
                            final isSelected = networks.contains(network.id);
                            return ListTile(
                              leading: network.logoPath != null
                                  ? CachedNetworkImage(
                                      imageUrl:
                                          'https://image.tmdb.org/t/p/w92${network.logoPath}',
                                      width: 40,
                                      fit: BoxFit.contain,
                                      errorWidget: (_, __, ___) =>
                                          const Icon(Icons.tv),
                                    )
                                  : const Icon(Icons.tv),
                              title: Text(network.name),
                              trailing: isSelected
                                  ? Icon(Icons.check_circle,
                                      color: theme.colorScheme.primary)
                                  : null,
                              onTap: () {
                                _updateState(() {
                                  if (isSelected) {
                                    networks.remove(network.id);
                                    networkNames.remove(network.id);
                                  } else {
                                    networks.add(network.id);
                                    networkNames[network.id] = network.name;
                                  }
                                  _networkSearchResults = [];
                                  _networkSearchController.clear();
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  if (networks.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final id in networks)
                          InputChip(
                            label: Text(networkNames[id] ?? 'Network $id'),
                            onDeleted: () {
                              _updateState(() {
                                networks.remove(id);
                                networkNames.remove(id);
                              });
                            },
                            backgroundColor:
                                theme.colorScheme.primaryContainer.withOpacity(0.5),
                            deleteIconColor: theme.colorScheme.onPrimaryContainer,
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            _buildSection(
              context,
              title: 'Status',
              child: Wrap(
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
            ),
            _buildSection(
              context,
              title: 'Type',
              child: Wrap(
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
            ),
            _buildSection(
              context,
              title: l.t('discover.certification'),
              child: Wrap(
                spacing: 8,
                children: [
                  for (final cert in [
                    'TV-Y',
                    'TV-Y7',
                    'TV-G',
                    'TV-PG',
                    'TV-14',
                    'TV-MA'
                  ])
                    FilterChip(
                      label: Text(cert),
                      selected: certification == cert,
                      onSelected: (v) {
                        setState(() => certification = v ? cert : null);
                      },
                    ),
                ],
              ),
            ),
            _buildSection(
              context,
              title: 'Air Date Range',
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.date_range),
                      label: Text(
                        airFrom == null ? 'From' : _formatDate(airFrom!),
                      ),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: airFrom ??
                              DateTime.now()
                                  .subtract(const Duration(days: 3650)),
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
                          lastDate: DateTime.now()
                              .add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          _updateState(() => airTo = picked);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            _buildSection(
              context,
              title: l.t('discover.byDecade'),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final start in [
                    1960,
                    1970,
                    1980,
                    1990,
                    2000,
                    2010,
                    2020
                  ])
                    OutlinedButton(
                      onPressed: () {
                        _updateState(() {
                          airFrom = DateTime(start, 1, 1);
                          airTo = DateTime(start + 9, 12, 31);
                        });
                      },
                      child: Text('${start}s'),
                    ),
                ],
              ),
            ),
            _buildSection(
              context,
              title: 'Original Language',
              child: Wrap(
                spacing: 8,
                children: [
                  for (final lang in [
                    'en',
                    'es',
                    'fr',
                    'de',
                    'it',
                    'ja',
                    'ko'
                  ])
                    FilterChip(
                      label: Text(lang.toUpperCase()),
                      selected: language == lang,
                      onSelected: (v) =>
                          _updateState(() => language = v ? lang : ''),
                    ),
                ],
              ),
            ),
            _buildSection(
              context,
              title: 'First Air Date Year',
              child: Wrap(
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
            ),
            _buildSection(
              context,
              title: 'Genres',
              child: Wrap(
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
            ),
            _buildSection(
              context,
              title: 'Other Options',
              child: Column(
                children: [
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
                ],
              ),
            ),
            _buildSection(
              context,
              title: 'Timezone',
              child: TextField(
                controller: _timezoneController,
                decoration: InputDecoration(
                  hintText: 'e.g., America/New_York',
                  filled: true,
                  fillColor: theme.colorScheme.surface.withOpacity(0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (v) {
                  if (_suspendTextNotifications) return;
                  _updateState(() => timezone = v.trim());
                },
              ),
            ),
            _buildSection(
              context,
              title: l.t('discover.watchProvidersIds'),
              child: WatchProviderSelector(
                mediaType: 'tv',
                selectedProviderIds: selectedProviderIds,
                onProvidersChanged: (newSelection) {
                  setState(() => selectedProviderIds = newSelection);
                },
              ),
            ),
            _buildSection(
              context,
              title: 'Monetization Types',
              child: Wrap(
                spacing: 8,
                children: [
                  for (final type in [
                    'flatrate',
                    'rent',
                    'buy',
                    'ads',
                    'free'
                  ])
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
            ),
            _buildSection(
              context,
              title: 'Vote Average',
              child: Column(
                children: [
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(voteMin.toStringAsFixed(1)),
                        Text(voteMax.toStringAsFixed(1)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _buildSection(
              context,
              title: 'Runtime (minutes)',
              child: Column(
                children: [
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('$runtimeMin min'),
                        Text('$runtimeMax min'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _buildSection(
              context,
              title: 'Vote Count Minimum',
              child: Row(
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
            ),
            _buildSection(
              context,
              title: l.t('discover.peopleCompaniesKeywords'),
              child: Column(
                children: [
                  TextField(
                    controller: TextEditingController(text: withCast),
                    decoration: InputDecoration(
                      hintText: l.t('discover.hintWithCast'),
                      filled: true,
                      fillColor: theme.colorScheme.surface.withOpacity(0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (v) {
                      if (_suspendTextNotifications) return;
                      withCast = v.replaceAll(' ', '');
                    },
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: TextEditingController(text: withCrew),
                    decoration: InputDecoration(
                      hintText: l.t('discover.hintWithCrew'),
                      filled: true,
                      fillColor: theme.colorScheme.surface.withOpacity(0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (v) {
                      if (_suspendTextNotifications) return;
                      withCrew = v.replaceAll(' ', '');
                    },
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: TextEditingController(text: withCompanies),
                    decoration: InputDecoration(
                      hintText: l.t('discover.hintWithCompanies'),
                      filled: true,
                      fillColor: theme.colorScheme.surface.withOpacity(0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (v) {
                      if (_suspendTextNotifications) return;
                      withCompanies = v.replaceAll(' ', '');
                    },
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: TextEditingController(text: withKeywords),
                    decoration: InputDecoration(
                      hintText: l.t('discover.hintWithKeywords'),
                      filled: true,
                      fillColor: theme.colorScheme.surface.withOpacity(0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (v) {
                      if (_suspendTextNotifications) return;
                      withKeywords = v.replaceAll(' ', '');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: _apply,
                icon: const Icon(Icons.check),
                label: Text(
                  l.t('common.apply'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: _savePreset,
                icon: const Icon(Icons.save),
                label: const Text(AppStrings.savePreset),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  side: BorderSide(color: theme.colorScheme.primary),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(
      BuildContext context, String? region, AppLocalizations l) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.hub_outlined, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Text(
            AppLocalizations.of(context).t('tv.series'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const Spacer(),
          if (region != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                ),
              ),
              child: Text(
                '${l.t('settings.region')}: $region',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPresetChip() {
    return InputChip(
      label: Text('Preset: $_currentPresetName'),
      onDeleted: () => _updateState(() {}, presetNameOverride: null),
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      deleteIconColor: Theme.of(context).colorScheme.onSecondaryContainer,
    );
  }

  Widget _buildSection(BuildContext context,
      {required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

