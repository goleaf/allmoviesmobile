import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../providers/statistics_provider.dart';
import '../../widgets/empty_state.dart';

/// Presents an analytics dashboard summarizing the user's saved titles.
///
/// Every section in this screen is powered by the offline snapshots served by
/// [StatisticsProvider], which in turn derives its data from favorites and
/// watchlist entries cached by [LocalStorageService]. The JSON payloads backing
/// the charts ultimately originate from TMDB V3 endpoints such as:
/// * `GET /3/movie/{id}` (runtime, votes, popularity)
/// * `GET /3/tv/{id}` (episode counts, season totals)
/// * `GET /3/discover/movie` (genre identifiers persisted locally)
/// * `GET /3/discover/tv` (genre identifiers persisted locally)
/// Those payloads are normalized into [SavedMediaItem] objects before reaching
/// this screen, allowing us to render charts even while offline.
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  static const String routeName = '/statistics';

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final strings = loc.statistics;
    final chartPlaceholder =
        strings['chart_placeholder'] as String? ?? 'Add more items to unlock this chart.';

    return Scaffold(
      appBar: AppBar(
        title: Text(strings['title'] as String? ?? 'Statistics'),
      ),
      body: Consumer<StatisticsProvider>(
        builder: (context, provider, _) {
          final snapshot = provider.snapshot;
          final formattedTimestamp = _formatTimestamp(context, snapshot.generatedAt);
          final updatedTemplate =
              strings['updated_at'] as String? ?? 'Last updated {timestamp}';
          final updatedLabel =
              updatedTemplate.replaceAll('{timestamp}', formattedTimestamp);

          if (!snapshot.hasContent) {
            final emptyTitle = strings['empty_title'] as String? ?? 'No insights yet';
            final emptyMessage =
                strings['empty_message'] as String? ??
                    'Add favorites or watchlist entries to unlock personalized charts.';
            final actionLabel = strings['empty_action'] as String? ?? 'Refresh';

            return RefreshIndicator(
              onRefresh: () async {
                provider.forceRefresh();
              },
              child: ListView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: EmptyState(
                      icon: Icons.insights_outlined,
                      title: emptyTitle,
                      message: emptyMessage,
                      actionLabel: actionLabel,
                      onAction: provider.forceRefresh,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              provider.forceRefresh();
            },
            child: ListView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                Text(
                  updatedLabel,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                _StatisticsSection(
                  title: strings['watch_time_title'] as String? ?? 'Watch time overview',
                  child: _WatchTimeCard(
                    stats: snapshot.watchTime,
                    strings: strings,
                  ),
                ),
                const SizedBox(height: 24),
                _StatisticsSection(
                  title: strings['rating_distribution'] as String? ?? 'Rating distribution',
                  child: _RatingDistributionChart(
                    buckets: snapshot.ratingBuckets,
                    placeholder: chartPlaceholder,
                  ),
                ),
                const SizedBox(height: 24),
                _StatisticsSection(
                  title: strings['actor_timeline'] as String? ?? 'Actor career timeline',
                  child: _ActorTimelineChart(
                    entries: snapshot.actorTimeline,
                    placeholder: chartPlaceholder,
                  ),
                ),
                const SizedBox(height: 24),
                _StatisticsSection(
                  title: strings['release_timeline'] as String? ?? 'Release timeline',
                  child: _ReleaseTimelineChart(
                    entries: snapshot.releaseTimeline,
                    placeholder: chartPlaceholder,
                  ),
                ),
                const SizedBox(height: 24),
                _StatisticsSection(
                  title: strings['genre_popularity'] as String? ?? 'Genre popularity',
                  child: _GenrePieChart(
                    buckets: snapshot.genreBreakdown,
                    placeholder: chartPlaceholder,
                  ),
                ),
                const SizedBox(height: 24),
                _StatisticsSection(
                  title:
                      strings['box_office_trend'] as String? ?? 'Box office trend (vote count proxy)',
                  child: _BoxOfficeTrendChart(
                    entries: snapshot.boxOfficeTrend,
                    placeholder: chartPlaceholder,
                  ),
                ),
                const SizedBox(height: 24),
                _StatisticsSection(
                  title: strings['budget_vs_revenue'] as String? ??
                      'Budget vs revenue (runtime vs votes)',
                  child: _BudgetRevenueScatterChart(
                    points: snapshot.budgetVsRevenue,
                    placeholder: chartPlaceholder,
                    strings: strings,
                  ),
                ),
                const SizedBox(height: 24),
                _StatisticsSection(
                  title: strings['episode_ratings'] as String? ?? 'Episode ratings by series',
                  child: _EpisodeRatingsChart(
                    points: snapshot.episodeRatings,
                    placeholder: chartPlaceholder,
                    strings: strings,
                  ),
                ),
                const SizedBox(height: 24),
                _StatisticsSection(
                  title: strings['season_comparison'] as String? ?? 'Season comparison',
                  child: _SeasonComparisonChart(
                    comparisons: snapshot.seasonComparisons,
                    placeholder: chartPlaceholder,
                    strings: strings,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatTimestamp(BuildContext context, DateTime timestamp) {
    if (timestamp.millisecondsSinceEpoch == 0) {
      return '-';
    }
    final locale = Localizations.localeOf(context).toLanguageTag();
    final format = DateFormat.yMMMd(locale).add_Hm();
    return format.format(timestamp);
  }
}

class _StatisticsSection extends StatelessWidget {
  const _StatisticsSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style:
              theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: child,
          ),
        ),
      ],
    );
  }
}

class _WatchTimeCard extends StatelessWidget {
  const _WatchTimeCard({required this.stats, required this.strings});

  final WatchTimeStatistics stats;
  final Map<String, dynamic> strings;

  @override
  Widget build(BuildContext context) {
    final chipStrings = <_ChipMetricData>[
      _ChipMetricData(
        icon: Icons.movie_outlined,
        label: strings['watch_time_movies'] as String? ?? 'Movies',
        value: stats.movieCount.toString(),
      ),
      _ChipMetricData(
        icon: Icons.tv_outlined,
        label: strings['watch_time_tv'] as String? ?? 'TV shows',
        value: stats.tvCount.toString(),
      ),
      _ChipMetricData(
        icon: Icons.visibility_outlined,
        label: strings['watch_time_watched_count'] as String? ?? 'Watched titles',
        value: stats.watchedCount.toString(),
      ),
      _ChipMetricData(
        icon: Icons.schedule_outlined,
        label: strings['watch_time_unwatched_count'] as String? ?? 'Queued titles',
        value: stats.unwatchedCount.toString(),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 24,
          runSpacing: 16,
          children: [
            _MetricTile(
              label: strings['watch_time_total'] as String? ?? 'Total planned',
              value: _formatHours(stats.totalHours),
            ),
            _MetricTile(
              label: strings['watch_time_watched'] as String? ?? 'Watched',
              value: _formatHours(stats.watchedHours),
            ),
            _MetricTile(
              label: strings['watch_time_remaining'] as String? ?? 'Remaining',
              value: _formatHours(stats.plannedHours),
            ),
            _MetricTile(
              label: strings['watch_time_completion'] as String? ?? 'Completion rate',
              value: '${(stats.completionRate * 100).clamp(0, 100).toStringAsFixed(1)}%',
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: chipStrings
              .map((chip) => _ChipMetric(icon: chip.icon, label: chip.label, value: chip.value))
              .toList(growable: false),
        ),
      ],
    );
  }

  String _formatHours(double hours) {
    if (hours == 0) {
      return '0 h';
    }
    if (hours >= 100) {
      return '${hours.toStringAsFixed(0)} h';
    }
    return '${hours.toStringAsFixed(1)} h';
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _ChipMetricData {
  const _ChipMetricData({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

class _ChipMetric extends StatelessWidget {
  const _ChipMetric({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text('$label · $value'),
    );
  }
}

class _RatingDistributionChart extends StatelessWidget {
  const _RatingDistributionChart({required this.buckets, required this.placeholder});

  final List<ChartBucket> buckets;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    if (buckets.isEmpty) {
      return _ChartPlaceholder(message: placeholder);
    }

    final theme = Theme.of(context);
    final maxY = buckets.fold<double>(0, (value, bucket) => math.max(value, bucket.value));
    final groups = <BarChartGroupData>[];
    for (var i = 0; i < buckets.length; i++) {
      final bucket = buckets[i];
      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: bucket.value,
              width: 14,
              borderRadius: BorderRadius.circular(6),
              color: theme.colorScheme.primary,
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 240,
      child: BarChart(
        BarChartData(
          maxY: maxY == 0 ? 1 : maxY * 1.2,
          gridData: FlGridData(show: true, drawVerticalLine: false),
          borderData: FlBorderData(show: false),
          barGroups: groups,
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (value, meta) => Text(
                  value.toStringAsFixed(0),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= buckets.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      buckets[index].label,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReleaseTimelineChart extends StatelessWidget {
  const _ReleaseTimelineChart({required this.entries, required this.placeholder});

  final List<TimelineEntry> entries;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return _ChartPlaceholder(message: placeholder);
    }

    final theme = Theme.of(context);
    final step = (entries.length / 6).ceil().clamp(1, entries.length);
    final spots = <FlSpot>[];
    for (var i = 0; i < entries.length; i++) {
      spots.add(FlSpot(i.toDouble(), entries[i].value));
    }
    final maxY = entries.fold<double>(0, (value, entry) => math.max(value, entry.value));

    return SizedBox(
      height: 240,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY == 0 ? 1 : maxY * 1.2,
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              isCurved: true,
              color: theme.colorScheme.primary,
              barWidth: 3,
              spots: spots,
              dotData: FlDotData(show: true),
            ),
          ],
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) => Text(
                  value.toStringAsFixed(0),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.round();
                  if (index < 0 || index >= entries.length) {
                    return const SizedBox.shrink();
                  }
                  if (index % step != 0 && index != entries.length - 1) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      entries[index].label,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActorTimelineChart extends StatelessWidget {
  const _ActorTimelineChart({required this.entries, required this.placeholder});

  final List<TimelineEntry> entries;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return _ChartPlaceholder(message: placeholder);
    }

    final theme = Theme.of(context);
    final step = (entries.length / 6).ceil().clamp(1, entries.length);
    final spots = <FlSpot>[];
    for (var i = 0; i < entries.length; i++) {
      spots.add(FlSpot(i.toDouble(), entries[i].value));
    }
    final maxY = entries.fold<double>(0, (value, entry) => math.max(value, entry.value));

    return SizedBox(
      height: 240,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY == 0 ? 1 : maxY * 1.2,
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              isCurved: true,
              color: theme.colorScheme.primaryContainer,
              barWidth: 3,
              spots: spots,
              dotData: FlDotData(show: true),
            ),
          ],
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (value, meta) => Text(
                  value.toStringAsFixed(0),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.round();
                  if (index < 0 || index >= entries.length) {
                    return const SizedBox.shrink();
                  }
                  if (index % step != 0 && index != entries.length - 1) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      entries[index].label,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GenrePieChart extends StatelessWidget {
  const _GenrePieChart({required this.buckets, required this.placeholder});

  final List<ChartBucket> buckets;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    if (buckets.isEmpty) {
      return _ChartPlaceholder(message: placeholder);
    }

    final theme = Theme.of(context);
    final total = buckets.fold<double>(0, (value, bucket) => value + bucket.value);
    final palette = _buildPalette(theme, buckets.length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 260,
          child: PieChart(
            PieChartData(
              sections: [
                for (var i = 0; i < buckets.length; i++)
                  PieChartSectionData(
                    color: palette[i % palette.length],
                    value: buckets[i].value,
                    radius: 90,
                    title: total == 0
                        ? ''
                        : '${(buckets[i].value / total * 100).toStringAsFixed(0)}%',
                    titleStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
              sectionsSpace: 2,
              centerSpaceRadius: 48,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            for (var i = 0; i < buckets.length; i++)
              _LegendChip(color: palette[i % palette.length], label: buckets[i].label),
          ],
        ),
      ],
    );
  }
}

class _BoxOfficeTrendChart extends StatelessWidget {
  const _BoxOfficeTrendChart({required this.entries, required this.placeholder});

  final List<TimelineEntry> entries;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return _ChartPlaceholder(message: placeholder);
    }

    final theme = Theme.of(context);
    final step = (entries.length / 6).ceil().clamp(1, entries.length);
    final spots = <FlSpot>[];
    for (var i = 0; i < entries.length; i++) {
      spots.add(FlSpot(i.toDouble(), entries[i].value));
    }
    final maxY = entries.fold<double>(0, (value, entry) => math.max(value, entry.value));

    return SizedBox(
      height: 240,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY == 0 ? 1 : maxY * 1.2,
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              isCurved: true,
              color: theme.colorScheme.secondary,
              barWidth: 3,
              spots: spots,
              dotData: FlDotData(show: true),
            ),
          ],
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) => Text(
                  value.toStringAsFixed(0),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.round();
                  if (index < 0 || index >= entries.length) {
                    return const SizedBox.shrink();
                  }
                  if (index % step != 0 && index != entries.length - 1) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      entries[index].label,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BudgetRevenueScatterChart extends StatelessWidget {
  const _BudgetRevenueScatterChart({
    required this.points,
    required this.placeholder,
    required this.strings,
  });

  final List<ScatterPoint> points;
  final String placeholder;
  final Map<String, dynamic> strings;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return _ChartPlaceholder(message: placeholder);
    }

    final theme = Theme.of(context);
    final maxX = points.fold<double>(0, (value, point) => math.max(value, point.x));
    final maxY = points.fold<double>(0, (value, point) => math.max(value, point.y));

    final xLabel = strings['budget_vs_revenue_x_label'] as String? ?? 'Runtime (minutes)';
    final yLabel = strings['budget_vs_revenue_y_label'] as String? ?? 'Vote count';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 260,
          child: ScatterChart(
            ScatterChartData(
              minX: 0,
              minY: 0,
              maxX: maxX == 0 ? 1 : maxX * 1.1,
              maxY: maxY == 0 ? 1 : maxY * 1.1,
              gridData: FlGridData(show: true),
              borderData: FlBorderData(show: true),
              scatterSpots: points
                  .map(
                    (point) => ScatterSpot(point.x, point.y),
                  )
                  .toList(growable: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  axisNameWidget: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(xLabel),
                  ),
                  axisNameSize: 28,
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    getTitlesWidget: (value, meta) => Text(
                      value.toStringAsFixed(0),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
                leftTitles: AxisTitles(
                  axisNameWidget: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(yLabel),
                  ),
                  axisNameSize: 32,
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 48,
                    getTitlesWidget: (value, meta) => Text(
                      value.toStringAsFixed(0),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: points
              .take(6)
              .map(
                (point) => Chip(
                  avatar: const Icon(Icons.movie_creation_outlined, size: 16),
                  label: Text('${point.label} • ${point.y.toStringAsFixed(0)}'),
                ),
              )
              .toList(growable: false),
        ),
      ],
    );
  }
}

class _EpisodeRatingsChart extends StatelessWidget {
  const _EpisodeRatingsChart({
    required this.points,
    required this.placeholder,
    required this.strings,
  });

  final List<EpisodeRatingPoint> points;
  final String placeholder;
  final Map<String, dynamic> strings;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return _ChartPlaceholder(message: placeholder);
    }

    final theme = Theme.of(context);
    final spots = points
        .map((point) => FlSpot(point.x, point.y))
        .toList(growable: false);
    final maxY = points.fold<double>(0, (value, point) => math.max(value, point.y));

    final xLabel = strings['episode_ratings_x_label'] as String? ?? 'Episode index';
    final yLabel = strings['episode_ratings_y_label'] as String? ?? 'Average rating';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 240,
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: maxY == 0 ? 10 : math.min(10, maxY * 1.1),
              gridData: FlGridData(show: true),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  isCurved: true,
                  color: theme.colorScheme.tertiary ?? theme.colorScheme.primary,
                  barWidth: 3,
                  spots: spots,
                  dotData: FlDotData(show: true),
                ),
              ],
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  axisNameWidget: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(xLabel),
                  ),
                  axisNameSize: 28,
                  sideTitles: const SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  axisNameWidget: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(yLabel),
                  ),
                  axisNameSize: 32,
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) => Text(
                      value.toStringAsFixed(0),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: points
              .take(6)
              .map(
                (point) => Chip(
                  avatar: const Icon(Icons.tv_outlined, size: 16),
                  label: Text('${point.seriesTitle} • ${point.y.toStringAsFixed(1)}'),
                ),
              )
              .toList(growable: false),
        ),
      ],
    );
  }
}

class _SeasonComparisonChart extends StatelessWidget {
  const _SeasonComparisonChart({
    required this.comparisons,
    required this.placeholder,
    required this.strings,
  });

  final List<SeasonComparison> comparisons;
  final String placeholder;
  final Map<String, dynamic> strings;

  @override
  Widget build(BuildContext context) {
    if (comparisons.isEmpty) {
      return _ChartPlaceholder(message: placeholder);
    }

    final theme = Theme.of(context);
    final maxY = comparisons
        .fold<double>(0, (value, comparison) => math.max(value, comparison.averageEpisodesPerSeason));
    final step = (comparisons.length / 5).ceil().clamp(1, comparisons.length);
    final bars = <BarChartGroupData>[];
    for (var i = 0; i < comparisons.length; i++) {
      final item = comparisons[i];
      bars.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: item.averageEpisodesPerSeason,
              width: 18,
              color: theme.colorScheme.tertiary ?? theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(6),
            ),
          ],
        ),
      );
    }

    final seasonLabel = strings['season_label'] as String? ?? 'seasons';
    final episodeLabel = strings['episode_label'] as String? ?? 'episodes';
    final yLabel = strings['season_comparison_y_label'] as String? ?? 'Avg episodes / season';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 240,
          child: BarChart(
            BarChartData(
              maxY: maxY == 0 ? 1 : maxY * 1.2,
              gridData: FlGridData(show: true, drawVerticalLine: false),
              borderData: FlBorderData(show: false),
              barGroups: bars,
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  axisNameWidget: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(yLabel),
                  ),
                  axisNameSize: 32,
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 42,
                    getTitlesWidget: (value, meta) => Text(
                      value.toStringAsFixed(0),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= comparisons.length) {
                        return const SizedBox.shrink();
                      }
                      if (index % step != 0 && index != comparisons.length - 1) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          comparisons[index].title,
                          style: Theme.of(context).textTheme.bodySmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: comparisons
              .take(6)
              .map(
                (item) => Chip(
                  avatar: const Icon(Icons.layers_outlined, size: 16),
                  label: Text(
                    '${item.title} • ${item.seasonCount} $seasonLabel, ${item.episodeCount} $episodeLabel',
                  ),
                ),
              )
              .toList(growable: false),
        ),
      ],
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: CircleAvatar(backgroundColor: color, radius: 8),
      label: Text(label),
    );
  }
}

class _ChartPlaceholder extends StatelessWidget {
  const _ChartPlaceholder({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }
}

List<Color> _buildPalette(ThemeData theme, int count) {
  final candidates = <Color?>[
    theme.colorScheme.primary,
    theme.colorScheme.secondary,
    theme.colorScheme.tertiary,
    theme.colorScheme.primaryContainer,
    theme.colorScheme.secondaryContainer,
    theme.colorScheme.tertiaryContainer,
  ].whereType<Color>().toList(growable: false);

  if (candidates.isEmpty) {
    const fallback = <Color>[
      Colors.blueGrey,
      Colors.indigo,
      Colors.teal,
      Colors.deepPurple,
      Colors.cyan,
      Colors.amber,
    ];
    return List<Color>.generate(
      count,
      (index) => fallback[index % fallback.length].withOpacity(0.85),
    );
  }

  return List<Color>.generate(
    count,
    (index) => candidates[index % candidates.length].withOpacity(0.85),
  );
}
