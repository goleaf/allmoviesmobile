import 'package:flutter_test/flutter_test.dart';

import 'package:allmovies_mobile/data/models/movie.dart';
import 'package:allmovies_mobile/data/models/movie_detailed_model.dart';
import 'package:allmovies_mobile/data/models/movie_mappers.dart';
import 'package:allmovies_mobile/data/models/tv_detailed_model.dart';

void main() {
  group('MovieDetailedMapper', () {
    test('converts MovieDetailed to Movie summary', () {
      final detailed = MovieDetailed(
        id: 1,
        title: 'Sample',
        overview: 'Overview',
        posterPath: '/poster.jpg',
        backdropPath: '/backdrop.jpg',
        runtime: 120,
        status: 'Released',
        voteAverage: 8.0,
        voteCount: 100,
        popularity: 50,
        releaseDate: '2024-01-01',
        genres: const [],
        credits: const [],
        reviews: const [],
        images: const [],
        videos: const [],
        recommendations: const [],
        similar: const [],
      );
      final movie = detailed.toMovieSummary();
      expect(movie.mediaType, 'movie');
      expect(movie.runtime, 120);
    });
  });

  group('TVDetailedMapper', () {
    test('converts TVDetailed to Movie summary', () {
      final detailed = TVDetailed(
        id: 2,
        name: 'TV Show',
        overview: 'Overview',
        posterPath: '/poster.jpg',
        backdropPath: '/backdrop.jpg',
        firstAirDate: '2020-01-01',
        voteAverage: 7.5,
        voteCount: 50,
        popularity: 40,
        originalName: 'TV Show',
        status: 'Returning Series',
        episodeRunTime: const [45],
        genres: const [],
        credits: const [],
        reviews: const [],
        images: const [],
        videos: const [],
        recommendations: const [],
        similar: const [],
        networks: const [],
        seasons: const [],
        externalIds: null,
      );
      final movie = detailed.toMovieSummaryFromTv();
      expect(movie.mediaType, 'tv');
      expect(movie.runtime, 45);
    });
  });
}
