import 'package:flutter_test/flutter_test.dart';

import 'package:allmovies_mobile/data/models/certification_model.dart';

import '../test_support/fixture_reader.dart';

void main() {
  group('Certification models', () {
    test('ReleaseDatesResult round-trips and defaults', () async {
      final json = await loadJsonFixture('certifications_us.json');
      final result = ReleaseDatesResult.fromJson(json);
      expect(result.countryCode, 'US');
      expect(result.releaseDates, hasLength(2));
      expect(result.toJson(), equals(json));
      expect(result, equals(ReleaseDatesResult.fromJson(json)));
    });

    test('ReleaseDates handles nullable fields', () async {
      final json = await loadJsonFixture('certifications_us.json');
      final entry = ReleaseDates.fromJson(
        (json['release_dates'] as List).last as Map<String, dynamic>,
      );
      expect(entry.language, isNull);
      expect(entry.toJson(), equals((json['release_dates'] as List).last));
      expect(entry.copyWith(certification: 'NR').certification, 'NR');
    });

    test('Certification serializes to json', () {
      const certification = Certification(
        certification: 'PG-13',
        meaning: 'Parents strongly cautioned',
        order: 2,
      );
      expect(
        Certification.fromJson(certification.toJson()),
        equals(certification),
      );
    });
  });
}
