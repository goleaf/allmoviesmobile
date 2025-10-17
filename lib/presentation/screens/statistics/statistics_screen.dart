import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../data/models/saved_media_item.dart';
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
          final watchedItems = merged.where((item) => item.watched).toList(growable: false);

          if (watchedItems.isEmpty) {
            return EmptyState(
              icon: Icons.query_stats_outlined,
              title: loc.statistics['empty_title'] ?? 'No watch history yet',
              message: loc.statistics['empty_message'] ??
                  'Mark titles as watched from your watchlist to unlock insights.',
            );
          }

          final totalMinutes = watchedItems.fold<int>(
            0,
            (sum, item) => sum + (item.totalRuntimeEstimate ?? item.runtimeMinutes ?? 0),
          );
          final totalHours = totalMinutes / 60;
          final totalDays = totalHours / 24;
          final averageMinutes = totalMinutes / watchedItems.length;
          final movieCount = watchedItems.where((item) => item.type == SavedMediaType.movie).length;
          final tvCount = watchedItems.length - movieCount;

          final ratingBuckets = _buildRatingBuckets(watchedItems);
          final genreBreakdown = _buildGenreBreakdown(
            watchedItems,
            genres,
            unknownLabel: loc.statistics['unknown_genre'] ?? 'Unknown',
            otherLabel: loc.statistics['other_genre'] ?? 'Other',
          );

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
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
              _SectionHeader(title: loc.statistics['genre_breakdown'] ?? 'Genre popularity'),
              const SizedBox(height: 12),
              AspectRatio(
                aspectRatio: 1.2,
                child: _GenrePieChart(segments: genreBreakdown),
              ),
            ],
          );
        },
      ),
    );
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
    {required String unknownLabel, required String otherLabel}
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
    final maxValue = buckets.values.fold<int>(0, math.max).clamp(1, double.infinity).toDouble();
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
