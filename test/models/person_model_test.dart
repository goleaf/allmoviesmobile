import 'package:flutter_test/flutter_test.dart';

import 'package:allmovies_mobile/data/models/person_model.dart';

import '../test_support/fixture_reader.dart';

void main() {
  group('Person', () {
    test('parses TMDB person fixture', () async {
      final json = await loadJsonFixture('person.json');
      final person = Person.fromJson(json);
      expect(person.name, 'Keanu Reeves');
      expect(person.alsoKnownAs, isNotEmpty);
      expect(person.profileUrl, contains('/w500'));
      expect(person.toJson(), equals({
        'id': 6384,
        'name': 'Keanu Reeves',
        'profile_path': '/keanu.jpg',
        'biography': 'Keanu Charles Reeves is a Canadian actor.',
        'known_for_department': 'Acting',
        'birthday': '1964-09-02',
        'place_of_birth': 'Beirut, Lebanon',
        'also_known_as': ['Киану Ривз'],
        'popularity': null,
      }));
      expect(person, equals(Person.fromJson(json)));
      expect(person.copyWith(name: 'Neo').name, 'Neo');
    });
  });
}
