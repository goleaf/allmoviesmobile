import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_strings.dart';
import '../../../data/models/movie.dart';
import '../../../providers/series_provider.dart';
import '../../screens/movie_detail/movie_detail_screen.dart';
import '../../widgets/app_drawer.dart';
import '../../../providers/watch_region_provider.dart';

class SeriesScreen extends StatefulWidget {
  static const routeName = '/series';

  const SeriesScreen({super.key});

  @override
  State<SeriesScreen> createState() => _SeriesScreenState();
}

class _SeriesScreenState extends State<SeriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SeriesProvider>().refresh();
    });
  }

  Future<void> _refreshAll(BuildContext context) {
    return context.read<SeriesProvider>().refresh(force: true);
  }

  @override
  Widget build(BuildContext context) {
    final sections = SeriesSection.values;

    return DefaultTabController(
      length: sections.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.series),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              for (final section in sections) Tab(text: _labelForSection(section)),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Filter by Network',
              icon: const Icon(Icons.hub_outlined),
              onPressed: _openNetworkFilter,
            ),
          ],
        ),
        drawer: const AppDrawer(),
        body: TabBarView(
          children: [
            for (final section in sections)
              _SeriesSectionView(
                section: section,
                onRefreshAll: _refreshAll,
              ),
          ],
        ),
      ),
    );
  }

  String _labelForSection(SeriesSection section) {
    switch (section) {
      case SeriesSection.trending:
        return AppStrings.trending;
      case SeriesSection.popular:
        return AppStrings.popular;
      case SeriesSection.topRated:
        return AppStrings.topRated;
      case SeriesSection.airingToday:
        return AppStrings.airingToday;
      case SeriesSection.onTheAir:
        return AppStrings.onTheAir;
    }
  }
}

extension on _SeriesScreenState {
  void _openNetworkFilter() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final provider = context.read<SeriesProvider>();
        final region = context.read<WatchRegionProvider>().region;
        final selected = <int>{};
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.hub_outlined),
                        const SizedBox(width: 8),
                        Text(
                          'Filter TV',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Spacer(),
                        if (provider.activeNetworkId != null)
                          TextButton.icon(
                            onPressed: () async {
                              Navigator.pop(context);
                              await provider.clearNetworkFilter();
                            },
                            icon: const Icon(Icons.clear),
                            label: const Text('Clear'),
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
                            selected: selected.contains(entry['id']),
                            onSelected: (value) {
                              setState(() {
                                final id = entry['id'] as int;
                                if (value) {
                                  selected.add(id);
                                } else {
                                  selected.remove(id);
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
                        for (final status in ['Returning Series', 'Ended', 'Canceled', 'In Production'])
                          OutlinedButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              await provider.applyTvFilters({'with_status': status});
                              final controller = DefaultTabController.of(context);
                              controller?.animateTo(SeriesSection.values.indexOf(SeriesSection.popular));
                            },
                            child: Text(status),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('Type', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final type in ['Scripted', 'Reality', 'Documentary', 'News', 'Talk Show', 'Miniseries'])
                          OutlinedButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              await provider.applyTvFilters({'with_type': type});
                              final controller = DefaultTabController.of(context);
                              controller?.animateTo(SeriesSection.values.indexOf(SeriesSection.popular));
                            },
                            child: Text(type),
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
                            label: const Text('From'),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now().subtract(const Duration(days: 3650)),
                                firstDate: DateTime(1950),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) {
                                setState(() => _TvFilterState.startDate = picked);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.event),
                            label: const Text('To'),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1950),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (picked != null) {
                                setState(() => _TvFilterState.endDate = picked);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    if (_TvFilterState.startDate != null || _TvFilterState.endDate != null)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => setState(() { _TvFilterState.startDate = null; _TvFilterState.endDate = null; }),
                          child: const Text('Clear dates'),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text('Original Language', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        for (final lang in ['en','es','fr','de','it','ja','ko'])
                          OutlinedButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              await provider.applyTvFilters({'with_original_language': lang});
                              final controller = DefaultTabController.of(context);
                              controller?.animateTo(SeriesSection.values.indexOf(SeriesSection.popular));
                            },
                            child: Text(lang.toUpperCase()),
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
                          OutlinedButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              await provider.applyTvFilters({'first_air_date_year': '$y'});
                              final controller = DefaultTabController.of(context);
                              controller?.animateTo(SeriesSection.values.indexOf(SeriesSection.popular));
                            },
                            child: Text('$y'),
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
                            selected: _TvFilterState.genres.contains(g['id']),
                            onSelected: (value) {
                              setState(() {
                                final id = g['id'] as int;
                                if (value) {
                                  _TvFilterState.genres.add(id);
                                } else {
                                  _TvFilterState.genres.remove(id);
                                }
                              });
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          Navigator.pop(context);
                          await provider.applyTvFilters({'with_genres': _TvFilterState.genres.join(',')});
                          final controller = DefaultTabController.of(context);
                          controller?.animateTo(SeriesSection.values.indexOf(SeriesSection.popular));
                        },
                        icon: const Icon(Icons.check),
                        label: const Text('Apply Genres'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Include Null First Air Dates'),
                      value: _TvFilterState.includeNullFirstAirDates,
                      onChanged: (v) => setState(() => _TvFilterState.includeNullFirstAirDates = v),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Screened Theatrically'),
                      value: _TvFilterState.screenedTheatrically,
                      onChanged: (v) => setState(() => _TvFilterState.screenedTheatrically = v),
                    ),
                    const SizedBox(height: 8),
                    Text('Timezone', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: const InputDecoration(hintText: 'e.g., America/New_York'),
                      onChanged: (v) => _TvFilterState.timezone = v.trim(),
                    ),
                    const SizedBox(height: 16),
                    Text('Watch Providers (IDs)', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: const InputDecoration(hintText: 'Comma-separated provider IDs'),
                      onChanged: (v) => _TvFilterState.watchProviders = v.replaceAll(' ', ''),
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
                            selected: _TvFilterState.monetization.contains(type),
                            onSelected: (value) {
                              setState(() {
                                if (value) {
                                  _TvFilterState.monetization.add(type);
                                } else {
                                  _TvFilterState.monetization.remove(type);
                                }
                              });
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: () async {
                          Navigator.pop(context);
                          final filters = <String, String>{
                            if (_TvFilterState.startDate != null) 'first_air_date.gte': _TvFilterState.startDate!.toIso8601String().split('T').first,
                            if (_TvFilterState.endDate != null) 'first_air_date.lte': _TvFilterState.endDate!.toIso8601String().split('T').first,
                            if (_TvFilterState.includeNullFirstAirDates) 'include_null_first_air_dates': 'true',
                            if (_TvFilterState.screenedTheatrically) 'screened_theatrically': 'true',
                            if (_TvFilterState.timezone.isNotEmpty) 'timezone': _TvFilterState.timezone,
                            if (_TvFilterState.watchProviders.isNotEmpty) 'with_watch_providers': _TvFilterState.watchProviders,
                            if (_TvFilterState.monetization.isNotEmpty) 'with_watch_monetization_types': _TvFilterState.monetization.join('|'),
                            'watch_region': region,
                          };
                          await provider.applyTvFilters(filters);
                          final controller = DefaultTabController.of(context);
                          controller?.animateTo(SeriesSection.values.indexOf(SeriesSection.popular));
                        },
                        icon: const Icon(Icons.playlist_add_check),
                        label: const Text('Apply Watch/Time Filters'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    StatefulBuilder(
                      builder: (context, setStateSB) {
                        double voteMin = 5.0;
                        double voteMax = 9.5;
                        int runtimeMin = 20;
                        int runtimeMax = 90;
                        int voteCountMin = 50;
                        Future<void> applyCurrent() async {
                          Navigator.pop(context);
                          await provider.applyTvFilters({
                            'vote_average.gte': voteMin.toStringAsFixed(1),
                            'vote_average.lte': voteMax.toStringAsFixed(1),
                            'with_runtime.gte': '$runtimeMin',
                            'with_runtime.lte': '$runtimeMax',
                            'vote_count.gte': '$voteCountMin',
                          });
                          final controller = DefaultTabController.of(context);
                          controller?.animateTo(SeriesSection.values.indexOf(SeriesSection.popular));
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Vote Average', style: Theme.of(context).textTheme.titleMedium),
                            RangeSlider(
                              values: RangeValues(voteMin, voteMax),
                              min: 0,
                              max: 10,
                              divisions: 20,
                              labels: RangeLabels(voteMin.toStringAsFixed(1), voteMax.toStringAsFixed(1)),
                              onChanged: (values) {
                                setStateSB(() {
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
                                setStateSB(() {
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
                                    onChanged: (v) {
                                      setStateSB(() => voteCountMin = v.round());
                                    },
                                  ),
                                ),
                                SizedBox(
                                  width: 64,
                                  child: Text('$voteCountMin', textAlign: TextAlign.end),
                                ),
                              ],
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: FilledButton.icon(
                                onPressed: applyCurrent,
                                icon: const Icon(Icons.check),
                                label: const Text('Apply Sliders'),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _NetworkChip extends StatelessWidget {
  const _NetworkChip({required this.id, required this.name});

  final int id;
  final String name;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () async {
        Navigator.pop(context);
        await context.read<SeriesProvider>().applyNetworkFilter(id);
        final controller = DefaultTabController.of(context);
        if (controller != null) {
          controller.animateTo(SeriesSection.values.indexOf(SeriesSection.popular));
        }
      },
      icon: const Icon(Icons.tv),
      label: Text(name),
    );
  }
}

class _SeriesSectionView extends StatelessWidget {
  const _SeriesSectionView({
    required this.section,
    required this.onRefreshAll,
  });

  final SeriesSection section;
  final Future<void> Function(BuildContext context) onRefreshAll;

  @override
  Widget build(BuildContext context) {
    return Consumer<SeriesProvider>(
      builder: (context, provider, _) {
        final state = provider.sectionState(section);
        if (state.isLoading && state.items.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.errorMessage != null && state.items.isEmpty) {
          return _ErrorView(
            message: state.errorMessage!,
            onRetry: () => onRefreshAll(context),
          );
        }

        return RefreshIndicator(
          onRefresh: () => onRefreshAll(context),
          child: _SeriesList(
            series: state.items,
          ),
        );
      },
    );
  }
}

class _SeriesList extends StatelessWidget {
  const _SeriesList({required this.series});

  final List<Movie> series;

  @override
  Widget build(BuildContext context) {
    if (series.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 120),
          Icon(
            Icons.live_tv_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              AppStrings.noResultsFound,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: series.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final show = series[index];
        return _SeriesCard(show: show);
      },
    );
  }
}

class _SeriesCard extends StatelessWidget {
  const _SeriesCard({required this.show});

  final Movie show;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MovieDetailScreen(movie: show),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    child: Icon(
                      Icons.live_tv_outlined,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          show.title,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _buildSubtitle(show),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (show.voteAverage != null)
                    Chip(
                      label: Text(show.formattedRating),
                      backgroundColor: colorScheme.secondaryContainer,
                    ),
                ],
              ),
              if ((show.overview ?? '').isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  show.overview!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _buildSubtitle(Movie show) {
    final buffer = <String>[];
    if (show.releaseYear != null && show.releaseYear!.isNotEmpty) {
      buffer.add(show.releaseYear!);
    }
    if (show.genresText.isNotEmpty) {
      buffer.add(show.genresText);
    }
    return buffer.join(' • ');
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 120),
        Icon(
          Icons.error_outline,
          size: 48,
          color: Theme.of(context).colorScheme.error,
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text(AppStrings.retry),
          ),
        ),
      ],
    );
  }
}

class _TvFilterState {
  static DateTime? startDate;
  static DateTime? endDate;
  static final Set<int> genres = <int>{};
  static bool includeNullFirstAirDates = false;
  static bool screenedTheatrically = false;
  static String timezone = '';
  static String watchProviders = '';
  static final Set<String> monetization = <String>{'flatrate','rent','buy'};
}
