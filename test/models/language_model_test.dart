import 'package:flutter_test/flutter_test.dart';

import 'package:allmovies_mobile/data/models/language_model.dart';

import '../test_support/fixture_reader.dart';

void main() {
  group('Language', () {
    test('round-trips json', () async {
      final list = await loadJsonListFixture('configuration_languages.json');
      final language = Language.fromJson(list.first as Map<String, dynamic>);
      expect(language.iso6391, 'en');
      expect(language.toJson(), equals(list.first));
      expect(language, equals(Language.fromJson(language.toJson())));
      expect(language.copyWith(name: 'English').name, 'English');
    });
  });
}
