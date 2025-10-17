import 'package:flutter_test/flutter_test.dart';

import 'package:allmovies_mobile/data/models/country_model.dart';

import '../test_support/fixture_reader.dart';

void main() {
  group('Country', () {
    test('round-trips json', () async {
      final list = await loadJsonListFixture('configuration_countries.json');
      final country = Country.fromJson(list.first as Map<String, dynamic>);
      expect(country.iso31661, 'US');
      expect(country.toJson(), equals(list.first));
      expect(country, equals(Country.fromJson(country.toJson())));
      expect(country.copyWith(name: 'USA').name, 'USA');
    });
  });
}
