import 'package:flutter_test/flutter_test.dart';

import 'package:allmovies_mobile/data/models/alternative_title_model.dart';

import '../test_support/fixture_reader.dart';

void main() {
  group('AlternativeTitle', () {
    test('parses list fixture and computes display label', () async {
      final json = await loadJsonFixture('alternative_titles.json');
      final titleJson = (json['titles'] as List).first as Map<String, dynamic>;
      final title = AlternativeTitle.fromJson(titleJson);
      expect(title.toJson(), equals(titleJson));
      expect(title.displayLabel, 'The Matrix • Working Title');
      expect(title.copyWith(type: null).displayLabel, 'The Matrix');
    });
  });
}
