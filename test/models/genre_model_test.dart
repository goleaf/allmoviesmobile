import 'package:flutter_test/flutter_test.dart';

import 'package:allmovies_mobile/data/models/genre_model.dart';

import '../test_support/fixture_reader.dart';

void main() {
  group('Genre', () {
    test('parses from movie fixture', () async {
      final json = await loadJsonFixture('movie_full.json');
      final genres = (json['genres'] as List).cast<Map<String, dynamic>>();
      final genre = Genre.fromJson(genres.first);
      expect(genre.id, genres.first['id']);
      expect(genre.toJson(), equals(genres.first));
      expect(genre, equals(Genre.fromJson(genres.first)));
      expect(genre.copyWith(name: 'Action').name, 'Action');
    });
  });
}
