import 'package:flutter_test/flutter_test.dart';

import 'package:allmovies_mobile/data/models/keyword_model.dart';

import '../test_support/fixture_reader.dart';

void main() {
  group('Keyword', () {
    test('round-trips json', () async {
      final json = await loadJsonFixture('keywords.json');
      final keywordJson = (json['keywords'] as List).first as Map<String, dynamic>;
      final keyword = Keyword.fromJson(keywordJson);
      expect(keyword.toJson(), equals(keywordJson));
      expect(keyword, equals(Keyword.fromJson(keywordJson)));
      expect(keyword.copyWith(name: 'matrix').name, 'matrix');
    });
  });

  group('KeywordDetails', () {
    test('round-trips json', () {
      const details = KeywordDetails(id: 1, name: 'sci-fi');
      expect(KeywordDetails.fromJson(details.toJson()), equals(details));
    });
  });
}
