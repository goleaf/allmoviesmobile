import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../data/models/episode_model.dart';
import '../../../data/models/movie_detailed_model.dart';
import '../../../data/models/saved_media_item.dart';
import '../../../data/models/season_model.dart';
import '../../../data/models/tv_detailed_model.dart';
import '../../../data/tmdb_repository.dart';
import '../../../providers/favorites_provider.dart';
import '../../../providers/genres_provider.dart';
import '../../../providers/watchlist_provider.dart';
import '../../widgets/empty_state.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  static const routeName = '/statistics';

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  Future<_DetailedStatistics>? _detailedFuture;
  String _itemsSignature = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final genres = context.read<GenresProvider>();
      if (!genres.hasMovieGenres) {
        genres.fetchMovieGenres();
      }
      if (!genres.hasTvGenres) {
        genres.fetchTvGenres();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(loc.statistics['title'] ?? 'Viewing statistics')),
      body: Consumer3<WatchlistProvider, FavoritesProvider, GenresProvider>(
        builder: (context, watchlist, favorites, genres, _) {
          final merged = _mergeSavedItems(
            watchlist.watchlistItems,
            favorites.favoriteItems,
          );
          final watchedItems =
              merged.where((item) => item.watched).toList(growable: false);

          if (watchedItems.isEmpty) {
            return EmptyState(
              icon: Icons.query_stats_outlined,
              title: loc.statistics['empty_title'] ?? 'No watch history yet',
              message: loc.statistics['empty_message'] ??
                  'Mark titles as watched from your watchlist to unlock insights.',
            );
          }

          _ensureDetailedFuture(watchedItems);

          final totalMinutes = watchedItems.fold<int>(
            0,
            (sum, item) => sum + (item.totalRuntimeEstimate ?? item.runtimeMinutes ?? 0),
          );
          final totalHours = totalMinutes / 60;
          final totalDays = totalHours / 24;
          final averageMinutes =
              watchedItems.isEmpty ? 0 : totalMinutes / watchedItems.length;
          final movieCount =
              watchedItems.where((item) => item.type == SavedMediaType.movie).length;
          final tvCount = watchedItems.length - movieCount;

          final ratingBuckets = _buildRatingBuckets(watchedItems);
          final genreBreakdown = _buildGenreBreakdown(
            watchedItems,
            genres,
            unknownLabel: loc.statistics['unknown_genre'] ?? 'Unknown',
            otherLabel: loc.statistics['other_genre'] ?? 'Other',
          );
          final releaseTimeline = _buildReleaseTimeline(watchedItems);

          final children = <Widget>[
            _StatisticSummaryRow(
              title: loc.statistics['watch_time'] ?? 'Watch time',
              primaryValue: loc.statistics['watch_time_hours']?.replaceFirst(
                    '{hours}',
                    _formatNumber(totalHours),
                  ) ??
                  '${_formatNumber(totalHours)} h',
              secondaryValue: loc.statistics['watch_time_days']?.replaceFirst(
                    '{days}',
                    _formatNumber(totalDays),
                  ) ??
                  '${_formatNumber(totalDays)} days',
              caption: loc.statistics['watch_time_caption']?.replaceFirst(
                    '{titles}',
                    watchedItems.length.toString(),
                  ) ??
                  '${watchedItems.length} titles marked as watched',
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _InsightCard(
                  icon: Icons.movie,
                  label: loc.statistics['movies_watched'] ?? 'Movies watched',
                  value: movieCount.toString(),
                ),
                _InsightCard(
                  icon: Icons.tv,
                  label: loc.statistics['series_watched'] ?? 'Series watched',
                  value: tvCount.toString(),
                ),
                _InsightCard(
                  icon: Icons.schedule,
                  label: loc.statistics['average_runtime'] ?? 'Average runtime',
                  value: '${averageMinutes.toStringAsFixed(0)} min',
                ),
              ],
            ),
            const SizedBox(height: 24),
            _SectionHeader(
              title: loc.statistics['rating_distribution'] ?? 'Rating distribution',
            ),
            const SizedBox(height: 12),
            AspectRatio(
              aspectRatio: 1.6,
              child: _RatingBarChart(buckets: ratingBuckets),
            ),
            const SizedBox(height: 24),
            _SectionHeader(
              title: loc.statistics['release_timeline'] ?? 'Release timeline',
            ),
            const SizedBox(height: 12),
            AspectRatio(
              aspectRatio: 1.6,
              child: _ReleaseTimelineChart(data: releaseTimeline),
            ),
            const SizedBox(height: 24),
            _SectionHeader(
              title: loc.statistics['genre_breakdown'] ?? 'Genre popularity',
            ),
            const SizedBox(height: 12),
            AspectRatio(
              aspectRatio: 1.2,
              child: _GenrePieChart(segments: genreBreakdown),
            ),
          ];

          children.add(
            FutureBuilder<_DetailedStatistics>(
              future: _detailedFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      _SectionHeader(
                        title: loc.statistics['box_office_trend'] ??
                            'Box office trends',
                      ),
                      const SizedBox(height: 12),
                      const _LoadingChartCard(),
                      const SizedBox(height: 24),
                      _SectionHeader(
                        title: loc.statistics['budget_vs_revenue'] ??
                            'Budget vs revenue',
                      ),
                      const SizedBox(height: 12),
                      const _LoadingChartCard(),
                      const SizedBox(height: 24),
                      _SectionHeader(
                        title: loc.statistics['actor_career_timeline'] ??
                            'Actor career timeline',
                      ),
                      const SizedBox(height: 12),
                      const _LoadingChartCard(),
                      const SizedBox(height: 24),
                      _SectionHeader(
                        title: loc.statistics['episode_ratings'] ??
                            'Episode ratings',
                      ),
                      const SizedBox(height: 12),
                      const _LoadingChartCard(),
                      const SizedBox(height: 24),
                      _SectionHeader(
                        title: loc.statistics['season_comparison'] ??
                            'Season comparison',
                      ),
                      const SizedBox(height: 12),
                      const _LoadingChartCard(),
                    ],
                  );
                }

                if (snapshot.hasError) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      _SectionHeader(
                        title: loc.statistics['advanced_insights'] ??
                            'Advanced insights',
                      ),
                      const SizedBox(height: 12),
                      _MessageCard(
                        icon: Icons.cloud_off,
                        message: loc.statistics['detail_error'] ??
                            'Unable to load extended statistics. Check your connection and try again.',
                        action: TextButton(
                          onPressed: () {
                            setState(() {
                              _detailedFuture = _loadDetailedStatistics(watchedItems);
                            });
                          },
                          child: Text(loc.common['retry'] ?? 'Retry'),
                        ),
                      ),
                    ],
                  );
                }

                final data = snapshot.data;
                if (data == null) {
                  return const SizedBox.shrink();
                }

                final widgets = <Widget>[];

                void addSection(String title, Widget child) {
                  widgets
                    ..add(const SizedBox(height: 24))
                    ..add(_SectionHeader(title: title))
                    ..add(const SizedBox(height: 12))
                    ..add(child);
                }

                if (data.errorMessage != null) {
                  widgets
                    ..add(const SizedBox(height: 24))
                    ..add(_MessageCard(
                      icon: Icons.info_outline,
                      message: data.errorMessage!,
                    ));
                }

                addSection(
                  loc.statistics['box_office_trend'] ?? 'Box office trends',
                  data.boxOfficePoints.isEmpty
                      ? _NoDataPlaceholder(
                          message: loc.statistics['no_financial_data'] ??
                              'No financial data available for watched titles.',
                        )
                      : AspectRatio(
                          aspectRatio: 1.6,
                          child: _BoxOfficeTrendChart(data: data.boxOfficePoints),
                        ),
                );

                addSection(
                  loc.statistics['budget_vs_revenue'] ?? 'Budget vs revenue',
                  data.budgetRevenuePoints.isEmpty
                      ? _NoDataPlaceholder(
                          message: loc.statistics['no_financial_data'] ??
                              'No financial data available for watched titles.',
                        )
                      : AspectRatio(
                          aspectRatio: 1.4,
                          child:
                              _BudgetRevenueScatterChart(points: data.budgetRevenuePoints),
                        ),
                );

                addSection(
                  loc.statistics['actor_career_timeline'] ??
                      'Actor career timeline',
                  data.actorSeries.isEmpty
                      ? _NoDataPlaceholder(
                          message: loc.statistics['no_actor_data'] ??
                              'Not enough cast data to build timelines yet.',
                        )
                      : AspectRatio(
                          aspectRatio: 1.6,
                          child: _ActorTimelineChart(series: data.actorSeries),
                        ),
                );

                addSection(
                  loc.statistics['episode_ratings'] ?? 'Episode ratings',
                  data.episodeStatistics == null
                      ? _NoDataPlaceholder(
                          message: loc.statistics['no_episode_data'] ??
                              'Watch more TV episodes to unlock episode insights.',
                        )
                      : AspectRatio(
                          aspectRatio: 1.6,
                          child: _EpisodeRatingsChart(stats: data.episodeStatistics!),
                        ),
                );

                addSection(
                  loc.statistics['season_comparison'] ?? 'Season comparison',
                  data.episodeStatistics == null ||
                          data.episodeStatistics!.seasonAverages.isEmpty
                      ? _NoDataPlaceholder(
                          message: loc.statistics['no_episode_data'] ??
                              'Watch more TV episodes to unlock episode insights.',
                        )
                      : AspectRatio(
                          aspectRatio: 1.5,
                          child: _SeasonComparisonChart(
                            stats: data.episodeStatistics!,
                          ),
                        ),
                );

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widgets,
                );
              },
            ),
          );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: children,
          );
        },
      ),
    );
  }

  void _ensureDetailedFuture(List<SavedMediaItem> watchedItems) {
    final signature = _buildSignature(watchedItems);
    if (signature != _itemsSignature || _detailedFuture == null) {
      _itemsSignature = signature;
      _detailedFuture = _loadDetailedStatistics(watchedItems);
    }
  }

  List<SavedMediaItem> _mergeSavedItems(
    List<SavedMediaItem> watchlist,
    List<SavedMediaItem> favorites,
  ) {
    final merged = <String, SavedMediaItem>{
      for (final item in watchlist) item.storageId: item,
    };

    for (final item in favorites) {
      merged.update(
        item.storageId,
        (existing) => _preferRuntime(existing, item),
        ifAbsent: () => item,
      );
    }

    return merged.values.toList(growable: false);
  }

  SavedMediaItem _preferRuntime(SavedMediaItem a, SavedMediaItem b) {
    final aRuntime = a.totalRuntimeEstimate ?? a.runtimeMinutes ?? 0;
    final bRuntime = b.totalRuntimeEstimate ?? b.runtimeMinutes ?? 0;
    if (bRuntime > aRuntime) {
      return b.copyWith(watched: a.watched || b.watched);
    }
    return a.copyWith(watched: a.watched || b.watched);
  }

  Map<int, int> _buildRatingBuckets(List<SavedMediaItem> items) {
    final buckets = {for (var i = 0; i <= 10; i++) i: 0};
    for (final item in items) {
      final rating = item.voteAverage;
      if (rating == null) continue;
      final bucket = rating.clamp(0, 10).floor();
      buckets[bucket] = buckets[bucket]! + 1;
    }
    return buckets;
  }

  List<_GenreSegment> _buildGenreBreakdown(
    List<SavedMediaItem> items,
    GenresProvider genresProvider,
    {required String unknownLabel, required String otherLabel},
  ) {
    final totals = <String, double>{};
    for (final item in items) {
      final runtime = (item.totalRuntimeEstimate ?? item.runtimeMinutes ?? 0).toDouble();
      if (runtime <= 0) continue;
      final names = item.genreIds.isEmpty
          ? <String>[unknownLabel]
          : item.genreIds
              .map(
                (id) => genresProvider.getGenreName(
                  id,
                  isTv: item.type == SavedMediaType.tv,
                ),
              )
              .whereType<String>()
              .toList(growable: false);
      final uniqueNames = names.isEmpty ? <String>{unknownLabel} : names.toSet();
      for (final name in uniqueNames) {
        totals[name] = (totals[name] ?? 0) + runtime;
      }
    }

    if (totals.isEmpty) {
      return const <_GenreSegment>[];
    }

    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topSegments = <_GenreSegment>[];
    for (var index = 0; index < sorted.length && index < 5; index++) {
      final entry = sorted[index];
      topSegments.add(
        _GenreSegment(
          label: entry.key,
          minutes: entry.value,
          color: _genreColorForIndex(index),
        ),
      );
    }

    if (sorted.length > 5) {
      var othersMinutes = 0.0;
      for (var i = 5; i < sorted.length; i++) {
        othersMinutes += sorted[i].value;
      }
      topSegments.add(
        _GenreSegment(
          label: otherLabel,
          minutes: othersMinutes,
          color: _genreColorForIndex(5),
        ),
      );
    }

    return topSegments;
  }

  List<_ReleaseYearCount> _buildReleaseTimeline(List<SavedMediaItem> items) {
    final counts = <int, _ReleaseYearCount>{};
    for (final item in items) {
      final year = _parseYear(item.releaseDate);
      if (year == null) continue;
      final existing = counts.putIfAbsent(
        year,
        () => _ReleaseYearCount(year: year),
      );
      if (item.type == SavedMediaType.movie) {
        existing.movieCount++;
      } else {
        existing.tvCount++;
      }
    }

    final list = counts.values.toList()
      ..sort((a, b) => a.year.compareTo(b.year));
    return list;
  }

  String _buildSignature(List<SavedMediaItem> items) {
    final sorted = items.toList()
      ..sort((a, b) => a.storageId.compareTo(b.storageId));
    final buffer = StringBuffer();
    for (final item in sorted) {
      buffer
        ..write(item.storageId)
        ..write('|')
        ..write(item.updatedAt.millisecondsSinceEpoch)
        ..write('|')
        ..write(item.watched ? '1' : '0');
    }
    return buffer.toString();
  }

  Future<_DetailedStatistics> _loadDetailedStatistics(
    List<SavedMediaItem> watchedItems,
  ) async {
    final repository = context.read<TmdbRepository>();
    final movieIds = <int>{};
    final tvIds = <int>{};

    for (final item in watchedItems) {
      if (item.type == SavedMediaType.movie) {
        movieIds.add(item.id);
      } else if (item.type == SavedMediaType.tv) {
        tvIds.add(item.id);
      }
    }

    final movies = <MovieDetailed>[];
    final shows = <TVDetailed>[];
    String? errorMessage;

    for (final id in movieIds) {
      try {
        movies.add(await repository.fetchMovieDetails(id));
      } catch (error) {
        errorMessage ??= _describeError(error);
      }
    }

    for (final id in tvIds) {
      try {
        shows.add(await repository.fetchTvDetails(id));
      } catch (error) {
        errorMessage ??= _describeError(error);
      }
    }

    _EpisodeStatistics? episodeStats;
    try {
      episodeStats = await _buildEpisodeStatistics(
        repository,
        watchedItems,
        shows,
      );
    } catch (error) {
      errorMessage ??= _describeError(error);
    }

    return _DetailedStatistics(
      boxOfficePoints: _aggregateBoxOfficeTrends(movies),
      budgetRevenuePoints: _buildBudgetRevenuePoints(movies),
      actorSeries: _buildActorTimelineSeries(movies, shows),
      episodeStatistics: episodeStats,
      errorMessage: errorMessage,
    );
  }

  String? _describeError(Object error) {
    if (error is TmdbException) {
      return error.message;
    }
    return null;
  }

  List<_YearValue> _aggregateBoxOfficeTrends(List<MovieDetailed> movies) {
    final map = <int, double>{};
    for (final movie in movies) {
      final revenue = movie.revenue ?? 0;
      if (revenue <= 0) continue;
      final year = _parseYear(movie.releaseDate);
      if (year == null) continue;
      map[year] = (map[year] ?? 0) + revenue;
    }
    final entries = map.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return [
      for (final entry in entries)
        _YearValue(year: entry.key, value: entry.value / 1000000),
    ];
  }

  List<_ScatterPoint> _buildBudgetRevenuePoints(List<MovieDetailed> movies) {
    final points = <_ScatterPoint>[];
    for (final movie in movies) {
      final budget = movie.budget ?? 0;
      final revenue = movie.revenue ?? 0;
      if (budget <= 0 || revenue <= 0) continue;
      points.add(
        _ScatterPoint(
          x: budget / 1000000,
          y: revenue / 1000000,
          label: movie.title,
        ),
      );
    }
    return points;
  }

  List<_ActorSeries> _buildActorTimelineSeries(
    List<MovieDetailed> movies,
    List<TVDetailed> shows,
  ) {
    final counts = <String, Map<int, int>>{};

    void addCredit(String name, int year) {
      final map = counts.putIfAbsent(name, () => <int, int>{});
      map[year] = (map[year] ?? 0) + 1;
    }

    for (final movie in movies) {
      final year = _parseYear(movie.releaseDate);
      if (year == null) continue;
      final cast = movie.cast.toList()
        ..sort((a, b) => a.order.compareTo(b.order));
      for (final actor in cast.take(5)) {
        addCredit(actor.name, year);
      }
    }

    for (final show in shows) {
      final year = _parseYear(show.firstAirDate);
      if (year == null) continue;
      final cast = show.cast.toList()
        ..sort((a, b) => a.order.compareTo(b.order));
      for (final actor in cast.take(5)) {
        addCredit(actor.name, year);
      }
    }

    final ranked = counts.entries.toList()
      ..sort((a, b) {
        final totalA = a.value.values.fold<int>(0, (sum, value) => sum + value);
        final totalB = b.value.values.fold<int>(0, (sum, value) => sum + value);
        return totalB.compareTo(totalA);
      });

    final palette = [
      Colors.blue,
      Colors.pink,
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.teal,
    ];

    final series = <_ActorSeries>[];
    for (var index = 0; index < ranked.length && index < palette.length; index++) {
      final entry = ranked[index];
      final points = entry.value.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));
      series.add(
        _ActorSeries(
          actor: entry.key,
          color: palette[index % palette.length],
          points: [
            for (final value in points)
              _YearValue(year: value.key, value: value.value.toDouble()),
          ],
        ),
      );
    }

    return series;
  }

  Future<_EpisodeStatistics?> _buildEpisodeStatistics(
    TmdbRepository repository,
    List<SavedMediaItem> watchedItems,
    List<TVDetailed> shows,
  ) async {
    if (shows.isEmpty) {
      return null;
    }

    final byId = {for (final show in shows) show.id: show};
    _EpisodeCandidate? best;

    for (final item in watchedItems) {
      if (item.type != SavedMediaType.tv) continue;
      final detail = byId[item.id];
      if (detail == null) continue;
      final totalEpisodes = detail.numberOfEpisodes ?? item.episodeCount ?? 0;
      if (totalEpisodes <= 0) continue;
      if (best == null || totalEpisodes > best.totalEpisodes) {
        best = _EpisodeCandidate(item: item, detail: detail, totalEpisodes: totalEpisodes);
      }
    }

    if (best == null) {
      return null;
    }

    final seasonNumbers = best.detail.seasons
        .map((season) => season.seasonNumber)
        .where((number) => number >= 0)
        .toSet()
        .toList()
      ..sort();

    if (seasonNumbers.isEmpty) {
      return null;
    }

    final fetched = <Season>[];
    for (final number in seasonNumbers.take(5)) {
      try {
        final season = await repository.fetchTvSeason(best.detail.id, number);
        if (season.episodes.isNotEmpty) {
          fetched.add(season);
        }
      } catch (_) {
        // Swallow individual season errors.
      }
    }

    if (fetched.isEmpty) {
      return null;
    }

    final episodePoints = <_EpisodePoint>[];
    final seasonAverages = <_SeasonAverage>[];
    final markers = <int, String>{};
    var index = 0;

    for (final season in fetched) {
      final ratedEpisodes = season.episodes
          .where((episode) => (episode.voteAverage ?? 0) > 0)
          .toList()
        ..sort((a, b) => a.episodeNumber.compareTo(b.episodeNumber));
      if (ratedEpisodes.isEmpty) {
        continue;
      }

      var sum = 0.0;
      var count = 0;
      for (final episode in ratedEpisodes) {
        index++;
        sum += episode.voteAverage!;
        count++;
        episodePoints.add(
          _EpisodePoint(
            index: index.toDouble(),
            rating: episode.voteAverage!,
            label: 'S${season.seasonNumber}E${episode.episodeNumber}',
          ),
        );
        if (episode == ratedEpisodes.first) {
          markers[index] = 'S${season.seasonNumber}';
        }
      }

      if (count > 0) {
        seasonAverages.add(
          _SeasonAverage(
            seasonNumber: season.seasonNumber,
            averageRating: sum / count,
            episodeCount: count,
          ),
        );
      }
    }

    if (episodePoints.isEmpty) {
      return null;
    }

    return _EpisodeStatistics(
      showTitle: best.detail.name,
      episodePoints: episodePoints,
      seasonAverages: seasonAverages,
      seasonMarkers: markers,
    );
  }

  int? _parseYear(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final yearString = value.split('-').first;
    return int.tryParse(yearString);
  }

  Color _genreColorForIndex(int index) {
    final palette = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
    ];
    return palette[index % palette.length];
  }

  String _formatNumber(double value) {
    if (value >= 100) {
      return value.toStringAsFixed(0);
    }
    if (value >= 10) {
      return value.toStringAsFixed(1);
    }
    return value.toStringAsFixed(2);
  }
}

class _StatisticSummaryRow extends StatelessWidget {
  const _StatisticSummaryRow({
    required this.title,
    required this.primaryValue,
    required this.secondaryValue,
    required this.caption,
  });

  final String title;
  final String primaryValue;
  final String secondaryValue;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    primaryValue,
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    secondaryValue,
                    style: theme.textTheme.titleLarge,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              caption,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 180,
      child: Card(
        elevation: 0,
        color: theme.colorScheme.surfaceContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(height: 12),
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

class _RatingBarChart extends StatelessWidget {
  const _RatingBarChart({required this.buckets});

  final Map<int, int> buckets;

  @override
  Widget build(BuildContext context) {
    final maxValue =
        buckets.values.fold<int>(0, math.max).clamp(1, double.infinity).toDouble();
    final barGroups = buckets.entries
        .map(
          (entry) => BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.toDouble(),
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(4),
                width: 12,
              ),
            ],
          ),
        )
        .toList(growable: false);

    return BarChart(
      BarChartData(
        maxY: maxValue,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                if (value % 2 != 0) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('${value.toInt()}'),
                );
              },
            ),
          ),
        ),
        barGroups: barGroups,
      ),
    );
  }
}

class _GenreSegment {
  const _GenreSegment({
    required this.label,
    required this.minutes,
    required this.color,
  });

  final String label;
  final double minutes;
  final Color color;
}

class _GenrePieChart extends StatelessWidget {
  const _GenrePieChart({required this.segments});

  final List<_GenreSegment> segments;

  @override
  Widget build(BuildContext context) {
    final total = segments.fold<double>(0, (sum, segment) => sum + segment.minutes);
    if (total <= 0 || segments.isEmpty) {
      final loc = AppLocalizations.of(context);
      return Center(
        child: Text(
          loc.statistics['genre_empty'] ?? 'Insufficient data to show genres',
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final legend = Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            for (final segment in segments)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: segment.color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(segment.label),
                ],
              ),
          ],
        );

        return Column(
          children: [
            Expanded(
              child: PieChart(
                PieChartData(
                  sections: [
                    for (final segment in segments)
                      PieChartSectionData(
                        value: segment.minutes,
                        color: segment.color,
                        title: '${(segment.minutes / total * 100).toStringAsFixed(1)}%',
                        radius: math.min(constraints.maxWidth, 220) / 2.4,
                        titleStyle: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                  ],
                  sectionsSpace: 1,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 16),
            legend,
          ],
        );
      },
    );
  }
}

class _ReleaseYearCount {
  _ReleaseYearCount({required this.year});

  final int year;
  int movieCount = 0;
  int tvCount = 0;
}

class _ReleaseTimelineChart extends StatelessWidget {
  const _ReleaseTimelineChart({required this.data});

  final List<_ReleaseYearCount> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return _NoDataPlaceholder(
        message: AppLocalizations.of(context).statistics['release_empty'] ??
            'No release dates available yet.',
      );
    }

    final theme = Theme.of(context);
    final years = data.map((e) => e.year).toList()
      ..sort();
    final movieSpots = data
        .map((entry) => FlSpot(entry.year.toDouble(), entry.movieCount.toDouble()))
        .toList();
    final tvSpots = data
        .map((entry) => FlSpot(entry.year.toDouble(), entry.tvCount.toDouble()))
        .toList();

    final minYear = years.first;
    final maxYear = years.last;
    final maxValue = [
      ...movieSpots.map((spot) => spot.y),
      ...tvSpots.map((spot) => spot.y),
      1,
    ].reduce(math.max);

    return LineChart(
      LineChartData(
        minX: minYear.toDouble(),
        maxX: maxYear.toDouble(),
        minY: 0,
        maxY: maxValue,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(enabled: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: math.max(1, (maxValue / 4).floorToDouble()),
              getTitlesWidget: (value, meta) {
                if (value == 0) {
                  return const SizedBox.shrink();
                }
                return Text(value.toInt().toString());
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: math.max(1, ((maxYear - minYear) / 5).floorToDouble()),
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value < minYear || value > maxYear) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(value.toInt().toString()),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: movieSpots,
            isCurved: true,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            color: theme.colorScheme.primary,
          ),
          LineChartBarData(
            spots: tvSpots,
            isCurved: true,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            color: theme.colorScheme.tertiary,
          ),
        ],
      ),
    );
  }
}

class _YearValue {
  const _YearValue({required this.year, required this.value});

  final int year;
  final double value;
}

class _BoxOfficeTrendChart extends StatelessWidget {
  const _BoxOfficeTrendChart({required this.data});

  final List<_YearValue> data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spots = data
        .map((entry) => FlSpot(entry.year.toDouble(), entry.value))
        .toList(growable: false);
    final minYear = data.first.year.toDouble();
    final maxYear = data.last.year.toDouble();
    final maxValue = data.map((entry) => entry.value).fold<double>(0, math.max);

    return LineChart(
      LineChartData(
        minX: minYear,
        maxX: maxYear,
        minY: 0,
        maxY: maxValue == 0 ? 1 : maxValue,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(enabled: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              interval: math.max(1, (maxValue / 4).ceilToDouble()),
              getTitlesWidget: (value, meta) {
                if (maxValue == 0) {
                  return const SizedBox.shrink();
                }
                return Text('USD ${value.toStringAsFixed(0)}M');
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: math.max(1, ((maxYear - minYear) / 5).floorToDouble()),
              reservedSize: 30,
              getTitlesWidget: (value, meta) => Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(value.toInt().toString()),
              ),
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            barWidth: 3,
            color: theme.colorScheme.primary,
            dotData: const FlDotData(show: true),
          ),
        ],
      ),
    );
  }
}

class _ScatterPoint {
  const _ScatterPoint({
    required this.x,
    required this.y,
    required this.label,
  });

  final double x;
  final double y;
  final String label;
}

class _BudgetRevenueScatterChart extends StatelessWidget {
  const _BudgetRevenueScatterChart({required this.points});

  final List<_ScatterPoint> points;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxX = points.map((e) => e.x).fold<double>(0, math.max);
    final maxY = points.map((e) => e.y).fold<double>(0, math.max);

    return ScatterChart(
      ScatterChartData(
        minX: 0,
        minY: 0,
        maxX: maxX == 0 ? 1 : maxX,
        maxY: maxY == 0 ? 1 : maxY,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
              interval: math.max(1, (maxY / 4).ceilToDouble()),
              getTitlesWidget: (value, meta) => Text('USD ${value.toStringAsFixed(0)}M'),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: math.max(1, (maxX / 4).ceilToDouble()),
              getTitlesWidget: (value, meta) => Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text('USD ${value.toStringAsFixed(0)}M'),
              ),
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        scatterTouchData: ScatterTouchData(
          enabled: true,
          handleBuiltInTouches: true,
          touchTooltipData: ScatterTouchTooltipData(
            getTooltipItems: (spots) {
              return spots.map((spot) {
                final point = points[spot.spotIndex];
                return ScatterTooltipItem(
                  '${point.label}
Budget: USD ${point.x.toStringAsFixed(0)}M
Revenue: USD ${point.y.toStringAsFixed(0)}M',
                  textStyle: theme.textTheme.bodySmall,
                );
              }).toList();
            },
          ),
        ),
        scatterSpots: [
          for (var i = 0; i < points.length; i++)
            ScatterSpot(
              points[i].x,
              points[i].y,
              color: theme.colorScheme.primary,
              radius: 6,
            ),
        ],
      ),
    );
  }
}

class _ActorSeries {
  const _ActorSeries({
    required this.actor,
    required this.points,
    required this.color,
  });

  final String actor;
  final List<_YearValue> points;
  final Color color;
}

class _ActorTimelineChart extends StatelessWidget {
  const _ActorTimelineChart({required this.series});

  final List<_ActorSeries> series;

  @override
  Widget build(BuildContext context) {
    final allYears = <int>{};
    var maxValue = 1.0;
    for (final entry in series) {
      for (final point in entry.points) {
        allYears.add(point.year);
        if (point.value > maxValue) {
          maxValue = point.value;
        }
      }
    }
    final years = allYears.toList()
      ..sort();
    final minYear = years.isEmpty ? 0 : years.first;
    final maxYear = years.isEmpty ? 1 : years.last;

    return Column(
      children: [
        Expanded(
          child: LineChart(
            LineChartData(
              minX: minYear.toDouble(),
              maxX: maxYear.toDouble(),
              minY: 0,
              maxY: maxValue,
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              lineTouchData: LineTouchData(enabled: true),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: math.max(1, (maxValue / 4).ceilToDouble()),
                    getTitlesWidget: (value, meta) => Text(value.toInt().toString()),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval:
                        math.max(1, ((maxYear - minYear) / 5).floorToDouble()),
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) => Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(value.toInt().toString()),
                    ),
                  ),
                ),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              lineBarsData: [
                for (final entry in series)
                  LineChartBarData(
                    spots: [
                      for (final point in entry.points)
                        FlSpot(point.year.toDouble(), point.value),
                    ],
                    isCurved: true,
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    color: entry.color,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            for (final entry in series)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: entry.color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(entry.actor),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

class _EpisodeCandidate {
  const _EpisodeCandidate({
    required this.item,
    required this.detail,
    required this.totalEpisodes,
  });

  final SavedMediaItem item;
  final TVDetailed detail;
  final int totalEpisodes;
}

class _EpisodePoint {
  const _EpisodePoint({
    required this.index,
    required this.rating,
    required this.label,
  });

  final double index;
  final double rating;
  final String label;
}

class _SeasonAverage {
  const _SeasonAverage({
    required this.seasonNumber,
    required this.averageRating,
    required this.episodeCount,
  });

  final int seasonNumber;
  final double averageRating;
  final int episodeCount;
}

class _EpisodeStatistics {
  const _EpisodeStatistics({
    required this.showTitle,
    required this.episodePoints,
    required this.seasonAverages,
    required this.seasonMarkers,
  });

  final String showTitle;
  final List<_EpisodePoint> episodePoints;
  final List<_SeasonAverage> seasonAverages;
  final Map<int, String> seasonMarkers;
}

class _EpisodeRatingsChart extends StatelessWidget {
  const _EpisodeRatingsChart({required this.stats});

  final _EpisodeStatistics stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spots = stats.episodePoints
        .map((point) => FlSpot(point.index, point.rating))
        .toList(growable: false);
    final maxX = spots.map((spot) => spot.x).fold<double>(0, math.max);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          stats.showTitle,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: LineChart(
            LineChartData(
              minX: 1,
              maxX: maxX,
              minY: 0,
              maxY: 10,
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              lineTouchData: LineTouchData(enabled: true),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 2,
                    reservedSize: 32,
                    getTitlesWidget: (value, meta) => Text(value.toStringAsFixed(0)),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    interval: math.max(1, (maxX / 6).floorToDouble()),
                    getTitlesWidget: (value, meta) {
                      final marker = stats.seasonMarkers[value.round()];
                      if (marker == null) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(marker),
                      );
                    },
                  ),
                ),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  barWidth: 3,
                  dotData: const FlDotData(show: true),
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SeasonComparisonChart extends StatelessWidget {
  const _SeasonComparisonChart({required this.stats});

  final _EpisodeStatistics stats;

  @override
  Widget build(BuildContext context) {
    final bars = stats.seasonAverages
        .map(
          (season) => BarChartGroupData(
            x: season.seasonNumber,
            barRods: [
              BarChartRodData(
                toY: season.averageRating,
                width: 18,
                color: Theme.of(context).colorScheme.tertiary,
                borderRadius: BorderRadius.circular(6),
              ),
            ],
          ),
        )
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          stats.showTitle,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: BarChart(
            BarChartData(
              maxY: 10,
              minY: 0,
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 2,
                    reservedSize: 36,
                    getTitlesWidget: (value, meta) => Text(value.toStringAsFixed(0)),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    getTitlesWidget: (value, meta) => Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text('S${value.toInt()}'),
                    ),
                  ),
                ),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              barGroups: bars,
            ),
          ),
        ),
      ],
    );
  }
}

class _LoadingChartCard extends StatelessWidget {
  const _LoadingChartCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: CircularProgressIndicator(color: theme.colorScheme.primary),
    );
  }
}

class _NoDataPlaceholder extends StatelessWidget {
  const _NoDataPlaceholder({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      child: Text(
        message,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.icon,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(height: 12),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (action != null) ...[
            const SizedBox(height: 12),
            action!,
          ],
        ],
      ),
    );
  }
}

class _DetailedStatistics {
  const _DetailedStatistics({
    required this.boxOfficePoints,
    required this.budgetRevenuePoints,
    required this.actorSeries,
    required this.episodeStatistics,
    this.errorMessage,
  });

  final List<_YearValue> boxOfficePoints;
  final List<_ScatterPoint> budgetRevenuePoints;
  final List<_ActorSeries> actorSeries;
  final _EpisodeStatistics? episodeStatistics;
  final String? errorMessage;
}
