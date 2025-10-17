import 'package:flutter_test/flutter_test.dart';

import 'package:allmovies_mobile/data/models/collection_model.dart';
import 'package:allmovies_mobile/data/models/movie_ref_model.dart';

import '../test_support/fixture_reader.dart';

void main() {
  group('Collection models', () {
    test('CollectionDetails parses parts', () async {
      final json = await loadJsonFixture('collection.json');
      final details = CollectionDetails.fromJson(json);
      expect(details.parts, hasLength(2));
      expect(details.toJson(), equals(json));
      expect(details, equals(CollectionDetails.fromJson(json)));
      expect(details.copyWith(name: 'Matrix Saga').name, 'Matrix Saga');
    });

    test('Collection base model round-trips', () {
      const collection = Collection(
        id: 2344,
        name: 'The Matrix Collection',
        posterPath: '/matrix-collection.jpg',
      );
      expect(Collection.fromJson(collection.toJson()), equals(collection));
    });
  });

  group('MovieRef', () {
    test('derives poster url', () async {
      final json = await loadJsonFixture('collection.json');
      final movie = MovieRef.fromJson(
        (json['parts'] as List).first as Map<String, dynamic>,
      );
      expect(movie.posterUrl, contains('/w342'));
      expect(movie.toJson(), equals({
        'id': 603,
        'title': 'The Matrix',
        'poster_path': '/matrix.jpg',
        'backdrop_path': null,
        'vote_average': null,
        'release_date': null,
        'media_type': null,
      }));
      expect(movie.copyWith(title: 'Matrix').title, 'Matrix');
    });
  });
}
