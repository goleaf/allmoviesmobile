import 'package:flutter_test/flutter_test.dart';

import 'package:allmovies_mobile/data/models/translation_model.dart';

import '../test_support/fixture_reader.dart';

void main() {
  group('Translation', () {
    test('parses translation fixture', () async {
      final json = await loadJsonFixture('collection_translations.json');
      final translationJson =
          (json['translations'] as List).first as Map<String, dynamic>;
      final translation = Translation.fromJson(translationJson);
      expect(translation.displayName, 'English (US)');
      expect(translation.data.overview, 'A trilogy following Neo.');
      expect(translation.toJson(), equals(translationJson));
      expect(translation, equals(Translation.fromJson(translationJson)));
      expect(translation.copyWith(name: 'EN-US').name, 'EN-US');
    });
  });
}
