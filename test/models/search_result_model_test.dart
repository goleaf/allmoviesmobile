import 'package:flutter_test/flutter_test.dart';

import 'package:allmovies_mobile/data/models/search_result_model.dart';

import '../test_support/fixture_reader.dart';

void main() {
  group('SearchResult & SearchResponse', () {
    test('parses multi-search fixture', () async {
      final json = await loadJsonFixture('search_multi_page1.json');
      final response = SearchResponse.fromJson(json);
      expect(response.results, isNotEmpty);
      final first = response.results.first;
      expect(first.mediaType, isNotNull);
      expect(first.toJson(), contains('media_type'));
      expect(response.toJson(), containsPair('page', json['page']));
      expect(response, equals(SearchResponse.fromJson(json)));
      expect(
        first.copyWith(voteAverage: 9.0).voteAverage,
        anyOf(isNull, equals(9.0)),
      );
    });
  });
}
