import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_strings.dart';
import '../../../data/models/movie.dart';
import '../../../providers/movies_provider.dart';
import '../../../data/models/discover_filters_model.dart';
import '../../screens/movie_detail/movie_detail_screen.dart';
import '../../widgets/app_drawer.dart';
import '../../../providers/watch_region_provider.dart';

class MoviesScreen extends StatefulWidget {
  static const routeName = '/movies';

  const MoviesScreen({super.key});

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  late final TextEditingController _searchController;
  List<Movie> _searchResults = const [];
  bool _isSearching = false;
  String? _searchError;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MoviesProvider>().refresh();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleSearch(String query) async {
    final provider = context.read<MoviesProvider>();
    final normalized = query.trim();

    if (normalized.isEmpty) {
      setState(() {
        _searchResults = const [];
        _searchError = null;
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _searchError = null;
    });

    try {
      final results = await provider.search(normalized);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _searchError = null;
          _isSearching = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _searchResults = const [];
          _searchError = '$error';
          _isSearching = false;
        });
      }
    }
  }

  Future<void> _refreshAll(BuildContext context) {
    return context.read<MoviesProvider>().refresh(force: true);
  }

  @override
  Widget build(BuildContext context) {
    final sections = MovieSection.values;
    final hasQuery = _searchController.text.trim().isNotEmpty;

    return DefaultTabController(
      length: sections.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.movies),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              for (final section in sections) Tab(text: _labelForSection(section)),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Filters',
              icon: const Icon(Icons.filter_list),
              onPressed: _openFilters,
            ),
            PopupMenuButton<String>(
              tooltip: 'Trending Window',
              onSelected: (value) {
                context.read<MoviesProvider>().setTrendingWindow(value);
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'day', child: Text('Trending: Day')),
                const PopupMenuItem(value: 'week', child: Text('Trending: Week')),
              ],
              icon: const Icon(Icons.schedule),
            ),
          ],
        ),
        drawer: const AppDrawer(),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: AppStrings.searchMovies,
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  isDense: true,
                ),
                onChanged: _handleSearch,
              ),
            ),
            if (_isSearching)
              const LinearProgressIndicator(minHeight: 2),
            if (_searchError != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _searchError!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ),
            if (hasQuery)
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => _handleSearch(_searchController.text),
                  child: _MoviesList(
                    movies: _searchResults,
                    emptyMessage: AppStrings.noResultsFound,
                  ),
                ),
              )
            else
              Expanded(
                child: TabBarView(
                  children: [
                    for (final section in sections)
                      _MoviesSectionView(
                        section: section,
                        onRefreshAll: _refreshAll,
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _labelForSection(MovieSection section) {
    switch (section) {
      case MovieSection.trending:
        return AppStrings.trending;
      case MovieSection.nowPlaying:
        return AppStrings.nowPlaying;
      case MovieSection.popular:
        return AppStrings.popular;
      case MovieSection.topRated:
        return AppStrings.topRated;
      case MovieSection.upcoming:
        return AppStrings.upcoming;
      case MovieSection.discover:
        return AppStrings.discover;
    }
  }
}

extension on _MoviesScreenState {
  void _openFilters() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final region = context.read<WatchRegionProvider>().region;
        final moviesProvider = context.read<MoviesProvider>();
        return Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.filter_list),
                    const SizedBox(width: 8),
                    Text(
                      'Discover Filters',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    Chip(label: Text('Region: $region')),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'By Decade',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final start in [1960, 1970, 1980, 1990, 2000, 2010, 2020])
                      OutlinedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await context.read<MoviesProvider>().applyDecadeFilter(start);
                          if (mounted) {
                            DefaultTabController.of(context).animateTo(MovieSection.values.indexOf(MovieSection.discover));
                          }
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
                      OutlinedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await moviesProvider.applyFilters(
                            DiscoverFilters().copyWith(
                              certificationCountry: region,
                              certificationLte: cert,
                            ),
                          );
                          if (mounted) {
                            DefaultTabController.of(context).animateTo(MovieSection.values.indexOf(MovieSection.discover));
                          }
                        },
                        child: Text(cert),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Release Date Range', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                StatefulBuilder(
                  builder: (context, setStateDates) {
                    DateTime? fromDate;
                    DateTime? toDate;
                    Future<void> applyDates() async {
                      Navigator.pop(context);
                      await moviesProvider.applyFilters(
                        DiscoverFilters().copyWith(
                          releaseDateGte: fromDate != null ? fromDate!.toIso8601String().split('T').first : null,
                          releaseDateLte: toDate != null ? toDate!.toIso8601String().split('T').first : null,
                        ),
                      );
                      if (mounted) {
                        DefaultTabController.of(context).animateTo(MovieSection.values.indexOf(MovieSection.discover));
                      }
                    }
                    return Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.date_range),
                            label: Text(fromDate == null ? 'From' : fromDate!.toIso8601String().split('T').first),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now().subtract(const Duration(days: 3650)),
                                firstDate: DateTime(1950),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null) setStateDates(() => fromDate = picked);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.event),
                            label: Text(toDate == null ? 'To' : toDate!.toIso8601String().split('T').first),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1950),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (picked != null) setStateDates(() => toDate = picked);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: applyDates,
                          child: const Text('Apply'),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                StatefulBuilder(
                  builder: (context, setStateSB) {
                    double voteMin = 5.0;
                    double voteMax = 9.5;
                    int runtimeMin = 60;
                    int runtimeMax = 180;
                    int voteCountMin = 100;
                    bool includeAdult = false;
                    final monetization = <String>{'flatrate', 'rent', 'buy'};
                    String watchProviders = '';
                    int? releaseType; // 1=Premiere,2=Theatrical (limited),3=Theatrical,4=Digital,5=Physical,6=TV
                    String withCast = '';
                    String withCrew = '';
                    String withCompanies = '';
                    String withKeywords = '';
                    void applyCurrent() async {
                      Navigator.pop(context);
                       await moviesProvider.applyFilters(
                         DiscoverFilters().copyWith(
                          voteAverageGte: voteMin,
                          voteAverageLte: voteMax,
                          runtimeGte: runtimeMin,
                          runtimeLte: runtimeMax,
                          voteCountGte: voteCountMin,
                          withWatchMonetizationTypes: monetization.join('|'),
                          includeAdult: includeAdult,
                          withWatchProviders: watchProviders.isNotEmpty ? watchProviders : null,
                          withReleaseType: releaseType != null ? '$releaseType' : null,
                          withCast: withCast.isNotEmpty ? withCast : null,
                          withCrew: withCrew.isNotEmpty ? withCrew : null,
                          withCompanies: withCompanies.isNotEmpty ? withCompanies : null,
                          withKeywords: withKeywords.isNotEmpty ? withKeywords : null,
                        ),
                      );
                      if (mounted) {
                        DefaultTabController.of(context).animateTo(MovieSection.values.indexOf(MovieSection.discover));
                      }
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text('People & Companies & Keywords', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        TextField(
                          decoration: const InputDecoration(hintText: 'With Cast (comma-separated person IDs)'),
                          onChanged: (v) => setStateSB(() => withCast = v.replaceAll(' ', '')),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          decoration: const InputDecoration(hintText: 'With Crew (comma-separated person IDs)'),
                          onChanged: (v) => setStateSB(() => withCrew = v.replaceAll(' ', '')),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          decoration: const InputDecoration(hintText: 'With Companies (comma-separated company IDs)'),
                          onChanged: (v) => setStateSB(() => withCompanies = v.replaceAll(' ', '')),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          decoration: const InputDecoration(hintText: 'With Keywords (comma-separated keyword IDs)'),
                          onChanged: (v) => setStateSB(() => withKeywords = v.replaceAll(' ', '')),
                        ),
                        const SizedBox(height: 12),
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
                          max: 300,
                          divisions: 30,
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
                                  setStateSB(() {
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
                          onChanged: (v) => setStateSB(() => watchProviders = v.replaceAll(' ', '')),
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
                                  setStateSB(() => releaseType = val ? entry['id'] as int : null);
                                },
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Include Adult Content'),
                          value: includeAdult,
                          onChanged: (v) => setStateSB(() => includeAdult = v),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton.icon(
                            onPressed: applyCurrent,
                            icon: const Icon(Icons.check),
                            label: const Text('Apply Filters'),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MoviesSectionView extends StatelessWidget {
  const _MoviesSectionView({
    required this.section,
    required this.onRefreshAll,
  });

  final MovieSection section;
  final Future<void> Function(BuildContext context) onRefreshAll;

  @override
  Widget build(BuildContext context) {
    return Consumer<MoviesProvider>(
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
          child: _MoviesList(
            movies: state.items,
            emptyMessage: AppStrings.noResultsFound,
          ),
        );
      },
    );
  }
}

class _MoviesList extends StatelessWidget {
  const _MoviesList({
    required this.movies,
    required this.emptyMessage,
  });

  final List<Movie> movies;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 120),
          Icon(
            Icons.movie_filter_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              emptyMessage,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: movies.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final movie = movies[index];
        return _MovieCard(movie: movie);
      },
    );
  }
}

class _MovieCard extends StatelessWidget {
  const _MovieCard({required this.movie});

  final Movie movie;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MovieDetailScreen(movie: movie),
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
                      Icons.movie_creation_outlined,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movie.title,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _buildSubtitle(movie),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (movie.voteAverage != null)
                    Chip(
                      label: Text(movie.formattedRating),
                      backgroundColor: colorScheme.secondaryContainer,
                    ),
                ],
              ),
              if ((movie.overview ?? '').isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  movie.overview!,
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

  String _buildSubtitle(Movie movie) {
    final buffer = <String>[];
    if (movie.releaseYear != null && movie.releaseYear!.isNotEmpty) {
      buffer.add(movie.releaseYear!);
    }
    if (movie.genresText.isNotEmpty) {
      buffer.add(movie.genresText);
    }
    if (movie.formattedPopularity.isNotEmpty) {
      buffer.add('Popularity ${movie.formattedPopularity}');
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
