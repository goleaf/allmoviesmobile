import 'package:flutter_test/flutter_test.dart';

import 'package:allmovies_mobile/data/models/tv_ref_model.dart';

import '../test_support/fixture_reader.dart';

void main() {
  group('TVRef', () {
    test('parses from tv fixture', () async {
      final json = await loadJsonFixture('tv_full.json');
      final ref = TVRef.fromJson({
        'id': json['id'],
        'name': json['name'],
        'poster_path': json['poster_path'],
        'backdrop_path': json['backdrop_path'],
        'vote_average': json['vote_average'],
        'first_air_date': json['first_air_date'],
      });
      expect(ref.name, 'Game of Thrones');
      expect(ref.copyWith(name: 'GOT').name, 'GOT');
      expect(ref.toJson(), equals({
        'id': 1399,
        'name': 'Game of Thrones',
        'poster_path': '/got-poster.jpg',
        'backdrop_path': '/got-backdrop.jpg',
        'vote_average': 8.4,
        'first_air_date': '2011-04-17',
      }));
    });
  });
}
