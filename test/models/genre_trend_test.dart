import 'package:flutter_test/flutter_test.dart';

import 'package:allmovies_mobile/data/models/genre_trend.dart';
import 'package:allmovies_mobile/data/models/movie.dart';

void main() {
  group('GenreTrend', () {
    test('derives top titles from movies', () {
      const movieA = Movie(id: 1, title: 'Matrix', mediaType: 'movie');
      const movieB = Movie(id: 2, title: 'Speed', mediaType: 'movie');
      final trend = GenreTrend(
        genreId: 28,
        totalTitles: 2,
        averageRating: 8.5,
        averagePopularity: 200,
        topMovies: const [movieA, movieB],
      );
      expect(trend.topTitles, equals(['Matrix', 'Speed']));
      expect(() => trend.topMovies.add(const Movie(id: 3, title: 'John Wick')), throwsUnsupportedError);
    });
  });
}
