import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../data/models/saved_media_item.dart';
import '../data/utils/genre_catalog.dart';

/// Aggregates locally cached favorites and watchlist entries into a set of
/// visualization-ready metrics for the statistics dashboard.
///
/// The provider works entirely with the offline-friendly snapshots exposed by
/// [LocalStorageService] via [FavoritesProvider] and [WatchlistProvider]; this
/// keeps the dashboard responsive even when the TMDB API is not reachable.
class StatisticsProvider extends ChangeNotifier {
  StatisticsProvider();

  StatisticsSnapshot _snapshot = StatisticsSnapshot.empty();
  List<SavedMediaItem> _currentItems = const <SavedMediaItem>[];
  int _lastSignature = 0;
  bool _hasComputed = false;

  /// Latest aggregated statistics ready to render in the UI.
  StatisticsSnapshot get snapshot => _snapshot;

  /// Whether at least one title is available to build charts for.
  bool get hasContent => _snapshot.hasContent;

  /// Ingests the latest favorites and watchlist payloads and recomputes the
  /// derived statistics if anything changed.
  ///
  /// Each call merges duplicated items (e.g. a title that exists in both the
  /// favorites set and the watchlist) and produces a stable signature based on
  /// every item's metadata. When the signature remains unchanged we skip the
  /// expensive recomputation so rebuilds stay cheap for the UI.
  void updateSources({
    required List<SavedMediaItem> favorites,
    required List<SavedMediaItem> watchlist,
  }) {
    final merged = _mergeSources(favorites, watchlist);
    final signature = _signatureFor(merged);
    final hasChanged = !_hasComputed || signature != _lastSignature;
    if (!hasChanged) {
      return;
    }

    _currentItems = merged;
    _lastSignature = signature;
    _recompute();
  }

  /// Forces a recomputation using the most recent cached dataset. This is
  /// surfaced as a pull-to-refresh action in the dashboard UI so users can
  /// refresh charts after editing runtimes or toggling watched flags elsewhere.
  void forceRefresh() {
    _recompute();
  }

  void _recompute() {
    _snapshot = StatisticsSnapshot.fromItems(_currentItems);
    _hasComputed = true;
    notifyListeners();
  }

  List<SavedMediaItem> _mergeSources(
    List<SavedMediaItem> favorites,
    List<SavedMediaItem> watchlist,
  ) {
    final map = <String, SavedMediaItem>{};
    for (final item in favorites) {
      map[item.storageId] = item;
    }
    for (final item in watchlist) {
      final existing = map[item.storageId];
      if (existing == null) {
        map[item.storageId] = item;
      } else {
        map[item.storageId] = _mergeItem(existing, item);
      }
    }

    final merged = map.values.toList(growable: false);
    merged.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    return merged;
  }

  SavedMediaItem _mergeItem(SavedMediaItem a, SavedMediaItem b) {
    final newer = a.updatedAt.isAfter(b.updatedAt) ? a : b;
    final older = identical(newer, a) ? b : a;

    return newer.copyWith(
      watched: a.watched || b.watched,
      watchedAt: a.watchedAt ?? b.watchedAt,
      runtimeMinutes: newer.runtimeMinutes ?? older.runtimeMinutes,
      episodeRuntimeMinutes:
          newer.episodeRuntimeMinutes ?? older.episodeRuntimeMinutes,
      episodeCount: newer.episodeCount ?? older.episodeCount,
      seasonCount: newer.seasonCount ?? older.seasonCount,
      voteAverage: newer.voteAverage ?? older.voteAverage,
      voteCount: newer.voteCount ?? older.voteCount,
      overview: newer.overview ?? older.overview,
      releaseDate: newer.releaseDate ?? older.releaseDate,
      posterPath: newer.posterPath ?? older.posterPath,
      backdropPath: newer.backdropPath ?? older.backdropPath,
      genreIds: newer.genreIds.isNotEmpty ? newer.genreIds : older.genreIds,
      addedAt: a.addedAt.isBefore(b.addedAt) ? a.addedAt : b.addedAt,
    );
  }

  int _signatureFor(List<SavedMediaItem> items) {
    final elements = items
        .map(
          (item) => Object.hash(
            item.storageId,
            item.updatedAt.millisecondsSinceEpoch,
            item.watched,
            item.voteAverage,
            item.voteCount,
            item.runtimeMinutes,
            item.episodeRuntimeMinutes,
            item.episodeCount,
            item.seasonCount,
            Object.hashAll(item.genreIds),
          ),
        )
        .toList(growable: false);
    return Object.hashAll(elements);
  }
}

@immutable
class StatisticsSnapshot {
  const StatisticsSnapshot({
    required this.generatedAt,
    required this.totalTitles,
    required this.watchTime,
    required this.ratingBuckets,
    required this.actorTimeline,
    required this.releaseTimeline,
    required this.genreBreakdown,
    required this.boxOfficeTrend,
    required this.budgetVsRevenue,
    required this.episodeRatings,
    required this.seasonComparisons,
  });

  factory StatisticsSnapshot.empty() => StatisticsSnapshot(
        generatedAt: DateTime.fromMillisecondsSinceEpoch(0),
        totalTitles: 0,
        watchTime: WatchTimeStatistics.empty(),
        ratingBuckets: <ChartBucket>[],
        actorTimeline: <TimelineEntry>[],
        releaseTimeline: <TimelineEntry>[],
        genreBreakdown: <ChartBucket>[],
        boxOfficeTrend: <TimelineEntry>[],
        budgetVsRevenue: <ScatterPoint>[],
        episodeRatings: <EpisodeRatingPoint>[],
        seasonComparisons: <SeasonComparison>[],
      );

  factory StatisticsSnapshot.fromItems(List<SavedMediaItem> items) {
    return StatisticsSnapshot(
      generatedAt: DateTime.now(),
      totalTitles: items.length,
      watchTime: WatchTimeStatistics.fromItems(items),
      ratingBuckets: _ChartBuilders.ratingDistribution(items),
      actorTimeline: _ChartBuilders.actorTimeline(items),
      releaseTimeline: _ChartBuilders.releaseTimeline(items),
      genreBreakdown: _ChartBuilders.genrePopularity(items),
      boxOfficeTrend: _ChartBuilders.boxOfficeTrend(items),
      budgetVsRevenue: _ChartBuilders.budgetVsRevenue(items),
      episodeRatings: _ChartBuilders.episodeRatings(items),
      seasonComparisons: _ChartBuilders.seasonComparisons(items),
    );
  }

  final DateTime generatedAt;
  final int totalTitles;
  final WatchTimeStatistics watchTime;
  final List<ChartBucket> ratingBuckets;
  final List<TimelineEntry> actorTimeline;
  final List<TimelineEntry> releaseTimeline;
  final List<ChartBucket> genreBreakdown;
  final List<TimelineEntry> boxOfficeTrend;
  final List<ScatterPoint> budgetVsRevenue;
  final List<EpisodeRatingPoint> episodeRatings;
  final List<SeasonComparison> seasonComparisons;

  bool get hasContent => totalTitles > 0;
}

@immutable
class WatchTimeStatistics {
  const WatchTimeStatistics({
    required this.totalMinutes,
    required this.watchedMinutes,
    required this.movieCount,
    required this.tvCount,
    required this.watchedCount,
    required this.unwatchedCount,
  });

  const WatchTimeStatistics.empty()
      : totalMinutes = 0,
        watchedMinutes = 0,
        movieCount = 0,
        tvCount = 0,
        watchedCount = 0,
        unwatchedCount = 0;

  factory WatchTimeStatistics.fromItems(List<SavedMediaItem> items) {
    final totalMinutes = items.fold<int>(
      0,
      (sum, item) => sum + (item.totalRuntimeEstimate ?? 0),
    );
    final watchedMinutes = items.fold<int>(
      0,
      (sum, item) =>
          sum + ((item.watched ? item.totalRuntimeEstimate : null) ?? 0),
    );
    final movieCount =
        items.where((item) => item.type == SavedMediaType.movie).length;
    final tvCount =
        items.where((item) => item.type == SavedMediaType.tv).length;
    final watchedCount = items.where((item) => item.watched).length;
    final unwatchedCount = items.length - watchedCount;

    return WatchTimeStatistics(
      totalMinutes: totalMinutes,
      watchedMinutes: watchedMinutes,
      movieCount: movieCount,
      tvCount: tvCount,
      watchedCount: watchedCount,
      unwatchedCount: unwatchedCount,
    );
  }

  final int totalMinutes;
  final int watchedMinutes;
  final int movieCount;
  final int tvCount;
  final int watchedCount;
  final int unwatchedCount;

  int get plannedMinutes => math.max(0, totalMinutes - watchedMinutes);
  double get completionRate =>
      totalMinutes == 0 ? 0 : watchedMinutes / totalMinutes;
  double get totalHours => totalMinutes / 60.0;
  double get watchedHours => watchedMinutes / 60.0;
  double get plannedHours => plannedMinutes / 60.0;
}

@immutable
class ChartBucket {
  const ChartBucket({required this.label, required this.value});

  final String label;
  final double value;
}

@immutable
class TimelineEntry {
  const TimelineEntry({required this.label, required this.value});

  final String label;
  final double value;
}

@immutable
class ScatterPoint {
  const ScatterPoint({
    required this.x,
    required this.y,
    required this.label,
  });

  final double x;
  final double y;
  final String label;
}

@immutable
class EpisodeRatingPoint {
  const EpisodeRatingPoint({
    required this.x,
    required this.y,
    required this.seriesTitle,
  });

  final double x;
  final double y;
  final String seriesTitle;
}

@immutable
class SeasonComparison {
  const SeasonComparison({
    required this.title,
    required this.seasonCount,
    required this.episodeCount,
    required this.averageEpisodesPerSeason,
  });

  final String title;
  final int seasonCount;
  final int episodeCount;
  final double averageEpisodesPerSeason;
}

class _ChartBuilders {
  static List<ChartBucket> ratingDistribution(List<SavedMediaItem> items) {
    final counts = List<double>.filled(10, 0);
    for (final item in items) {
      final rating = item.voteAverage;
      if (rating == null || rating <= 0) continue;
      final bucketIndex = rating >= 10 ? 9 : rating.floor();
      counts[bucketIndex] += 1;
    }

    final buckets = <ChartBucket>[];
    for (var i = 0; i < counts.length; i++) {
      if (counts[i] <= 0) continue;
      buckets.add(ChartBucket(label: '$i-${i + 1}', value: counts[i]));
    }

    return List.unmodifiable(buckets);
  }

  static List<TimelineEntry> releaseTimeline(List<SavedMediaItem> items) {
    final map = <int, double>{};
    for (final item in items) {
      final year = _parseYear(item.releaseDate);
      if (year == null) continue;
      map.update(year, (value) => value + 1, ifAbsent: () => 1);
    }

    final sortedYears = map.keys.toList(growable: false)..sort();
    final entries = sortedYears
        .map(
          (year) => TimelineEntry(
            label: year.toString(),
            value: map[year] ?? 0,
          ),
        )
        .toList(growable: false);

    return List.unmodifiable(entries);
  }

  static List<TimelineEntry> actorTimeline(List<SavedMediaItem> items) {
    final watchedYearCounts = <int, double>{};
    for (final item in items) {
      final watchedAt = item.watchedAt;
      if (watchedAt == null) continue;
      watchedYearCounts.update(
        watchedAt.year,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }

    if (watchedYearCounts.isEmpty) {
      return releaseTimeline(items);
    }

    final sortedYears = watchedYearCounts.keys.toList(growable: false)..sort();
    return List.unmodifiable(
      sortedYears.map(
        (year) => TimelineEntry(
          label: year.toString(),
          value: watchedYearCounts[year] ?? 0,
        ),
      ),
    );
  }

  static List<ChartBucket> genrePopularity(List<SavedMediaItem> items) {
    final counts = <String, double>{};
    for (final item in items) {
      for (final id in item.genreIds) {
        final name = GenreCatalog.nameForId(id) ?? 'Genre $id';
        counts.update(name, (value) => value + 1, ifAbsent: () => 1);
      }
    }

    final sorted = counts.entries.toList(growable: false)
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(8);
    return List.unmodifiable(
      top.map((entry) => ChartBucket(label: entry.key, value: entry.value)),
    );
  }

  static List<TimelineEntry> boxOfficeTrend(List<SavedMediaItem> items) {
    final map = <int, double>{};
    for (final item in items) {
      final year = _parseYear(item.releaseDate);
      final voteCount = item.voteCount;
      if (year == null || voteCount == null || voteCount <= 0) continue;
      map.update(year, (value) => value + voteCount, ifAbsent: () => voteCount.toDouble());
    }

    final sortedYears = map.keys.toList(growable: false)..sort();
    return List.unmodifiable(
      sortedYears.map(
        (year) => TimelineEntry(
          label: year.toString(),
          value: map[year] ?? 0,
        ),
      ),
    );
  }

  static List<ScatterPoint> budgetVsRevenue(List<SavedMediaItem> items) {
    final points = <ScatterPoint>[];
    for (final item in items) {
      final runtime = _runtimeProxy(item);
      final voteCount = item.voteCount;
      if (runtime == null || runtime <= 0 || voteCount == null || voteCount <= 0) {
        continue;
      }
      points.add(
        ScatterPoint(
          x: runtime.toDouble(),
          y: voteCount.toDouble(),
          label: item.title,
        ),
      );
    }

    return List.unmodifiable(points.take(30));
  }

  static List<EpisodeRatingPoint> episodeRatings(List<SavedMediaItem> items) {
    final tvItems = items
        .where((item) => item.type == SavedMediaType.tv)
        .toList(growable: false)
      ..sort(
        (a, b) => (a.releaseDate ?? '').compareTo(b.releaseDate ?? ''),
      );

    final points = <EpisodeRatingPoint>[];
    double cursor = 0;
    for (final item in tvItems) {
      final episodes = item.episodeCount ?? 0;
      final rating = item.voteAverage ?? 0;
      if (episodes <= 0 || rating <= 0) continue;
      final start = cursor;
      cursor += episodes.toDouble();
      final x = (start + cursor) / 2;
      points.add(
        EpisodeRatingPoint(
          x: x,
          y: rating,
          seriesTitle: item.title,
        ),
      );
      cursor += 1; // gap between series
    }

    return List.unmodifiable(points);
  }

  static List<SeasonComparison> seasonComparisons(List<SavedMediaItem> items) {
    final comparisons = <SeasonComparison>[];
    final tvItems = items.where((item) => item.type == SavedMediaType.tv);
    for (final item in tvItems) {
      final seasons = item.seasonCount ?? 0;
      final episodes = item.episodeCount ?? 0;
      if (seasons <= 0 || episodes <= 0) continue;
      comparisons.add(
        SeasonComparison(
          title: item.title,
          seasonCount: seasons,
          episodeCount: episodes,
          averageEpisodesPerSeason: episodes / seasons,
        ),
      );
    }

    comparisons.sort((a, b) => b.episodeCount.compareTo(a.episodeCount));
    return List.unmodifiable(comparisons.take(10));
  }

  static int? _parseYear(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final parts = value.split('-');
    if (parts.isEmpty) {
      return null;
    }
    return int.tryParse(parts.first);
  }

  static int? _runtimeProxy(SavedMediaItem item) {
    if (item.type == SavedMediaType.movie) {
      return item.runtimeMinutes ?? item.totalRuntimeEstimate;
    }
    if (item.episodeRuntimeMinutes != null) {
      return item.episodeRuntimeMinutes;
    }
    if (item.episodeCount != null && item.totalRuntimeEstimate != null) {
      if (item.episodeCount! > 0) {
        return (item.totalRuntimeEstimate! / item.episodeCount!).round();
      }
    }
    return null;
  }
}
