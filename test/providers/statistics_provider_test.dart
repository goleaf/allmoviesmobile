import 'package:allmovies_mobile/data/models/saved_media_item.dart';
import 'package:allmovies_mobile/providers/statistics_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StatisticsProvider', () {
    test('aggregates watch time and chart data from favorites and watchlist', () {
      final provider = StatisticsProvider();
      final favoriteMovie = SavedMediaItem(
        id: 1,
        type: SavedMediaType.movie,
        title: 'Movie A',
        runtimeMinutes: 120,
        voteAverage: 8.2,
        voteCount: 1500,
        releaseDate: '2020-05-01',
        genreIds: const [28, 12],
        watched: true,
      );
      final watchlistShow = SavedMediaItem(
        id: 2,
        type: SavedMediaType.tv,
        title: 'Show B',
        episodeCount: 10,
        episodeRuntimeMinutes: 45,
        seasonCount: 2,
        voteAverage: 7.4,
        voteCount: 900,
        releaseDate: '2021-03-15',
        genreIds: const [18, 35],
        watched: false,
      );

      provider.updateSources(favorites: [favoriteMovie], watchlist: [watchlistShow]);

      final snapshot = provider.snapshot;
      expect(snapshot.totalTitles, 2);
      expect(snapshot.watchTime.totalMinutes, 120 + 10 * 45);
      expect(snapshot.watchTime.watchedMinutes, 120);
      expect(snapshot.ratingBuckets, isNotEmpty);
      expect(snapshot.actorTimeline, isNotEmpty);
      expect(snapshot.genreBreakdown.map((bucket) => bucket.label), contains('Action'));
      expect(snapshot.boxOfficeTrend, isNotEmpty);
      expect(snapshot.budgetVsRevenue, isNotEmpty);
      expect(snapshot.episodeRatings, isNotEmpty);
      expect(snapshot.seasonComparisons, isNotEmpty);
      expect(
        snapshot.seasonComparisons.first.averageEpisodesPerSeason,
        closeTo(5, 1e-9),
      );
    });

    test('forceRefresh recomputes snapshot timestamp', () async {
      final provider = StatisticsProvider();
      final movie = SavedMediaItem(
        id: 3,
        type: SavedMediaType.movie,
        title: 'Movie C',
        runtimeMinutes: 90,
        voteAverage: 6.5,
        voteCount: 100,
        releaseDate: '2019-01-01',
        genreIds: const [35],
      );

      provider.updateSources(favorites: [movie], watchlist: const []);
      final firstTimestamp = provider.snapshot.generatedAt;

      await Future<void>.delayed(const Duration(milliseconds: 1));
      provider.forceRefresh();
      final secondTimestamp = provider.snapshot.generatedAt;

      expect(secondTimestamp.isAtSameMomentAs(firstTimestamp), isFalse);
    });
  });
}
