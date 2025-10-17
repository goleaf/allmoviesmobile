import 'package:flutter_test/flutter_test.dart';

import 'package:allmovies_mobile/data/models/credit_model.dart';

import '../test_support/fixture_reader.dart';

void main() {
  group('Credits', () {
    test('parses cast and crew arrays', () async {
      final json = await loadJsonFixture('credits_full.json');
      final credits = Credits.fromJson(json);
      expect(credits.cast.single.character, 'Neo');
      expect(credits.crew.single.job, 'Director');
      expect(credits.toJson(), equals(json));
      expect(credits, equals(Credits.fromJson(json)));
      expect(credits.copyWith(cast: []).cast, isEmpty);
    });
  });

  group('Cast', () {
    test('round-trips json', () async {
      final json = await loadJsonFixture('credits_full.json');
      final castJson = (json['cast'] as List).first as Map<String, dynamic>;
      final cast = Cast.fromJson(castJson);
      expect(cast.toJson(), equals(castJson));
      expect(cast.copyWith(order: 2).order, 2);
    });
  });

  group('Crew', () {
    test('round-trips json', () async {
      final json = await loadJsonFixture('credits_full.json');
      final crewJson = (json['crew'] as List).first as Map<String, dynamic>;
      final crew = Crew.fromJson(crewJson);
      expect(crew.toJson(), equals(crewJson));
      expect(crew, equals(Crew.fromJson(crewJson)));
      expect(crew.copyWith(job: 'Writer').job, 'Writer');
    });
  });
}
