import 'package:flutter_test/flutter_test.dart';

import 'package:allmovies_mobile/data/models/genre_statistics.dart';
import 'package:allmovies_mobile/data/models/movie.dart';

import '../test_support/fixture_reader.dart';

void main() {
  group('GenreStatistics', () {
    test('builds aggregates from movies', () async {
      final json = await loadJsonFixture('trending_movie_day_page1.json');
      final results = (json['results'] as List).cast<Map<String, dynamic>>();
      final movies = results
          .map(
            (raw) => Movie.fromJson(
              raw,
              mediaType: raw['media_type'] as String?,
            ),
          )
          .toList();
      final stats = GenreStatistics.fromMovies({28}, movies);
      expect(stats.hasData, isTrue);
      expect(stats.sampleSize, movies.length);
      expect(stats.topTitles, isNotEmpty);
      expect(stats.genreIds, equals({28}));
      expect(stats.releaseYearRange, isNotEmpty);
    });

    test('empty factory returns zeroed stats', () {
      final stats = GenreStatistics.empty({12, 14});
      expect(stats.hasData, isFalse);
      expect(stats.averageRating, 0);
      expect(() => stats.genreIds.add(1), throwsUnsupportedError);
    });
  });
}
