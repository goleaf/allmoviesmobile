import 'package:allmovies_mobile/data/models/season_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Season model', () {
    test('creates from JSON with backdrop path', () {
      final json = {
        'id': 1,
        'name': 'Season 1',
        'season_number': 1,
        'overview': 'Overview',
        'air_date': '2024-01-01',
        'poster_path': '/poster.jpg',
        'backdrop_path': '/backdrop.jpg',
        'episode_count': 10,
        'episodes': const [],
      };

      final season = Season.fromJson(json);

      expect(season.posterUrl, 'https://image.tmdb.org/t/p/w500/poster.jpg');
      expect(season.backdropUrl, 'https://image.tmdb.org/t/p/w780/backdrop.jpg');
    });

    test('handles missing poster/backdrop paths', () {
      const season = Season(
        id: 2,
        name: 'Season 2',
        seasonNumber: 2,
        episodeCount: 8,
      );

      expect(season.posterUrl, isNull);
      expect(season.backdropUrl, isNull);
    });
  });
}
