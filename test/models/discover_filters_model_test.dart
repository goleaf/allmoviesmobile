import 'package:flutter_test/flutter_test.dart';

import 'package:allmovies_mobile/data/models/discover_filters_model.dart';

import '../test_support/fixture_reader.dart';

void main() {
  group('DiscoverFilters', () {
    test('parses json and builds query parameters', () async {
      final json = await loadJsonFixture('discover_filters.json');
      final filters = DiscoverFilters.fromJson(json);
      expect(filters.sortBy, SortBy.ratingDesc);
      final query = filters.toQueryParameters();
      expect(query, isNot(contains('page')));
      expect(query['sort_by'], 'vote_average.desc');
      expect(filters.toJson(), equals(json));
      expect(filters, equals(DiscoverFilters.fromJson(json)));
      expect(filters.copyWith(includeAdult: false).includeAdult, isFalse);
    });
  });
}
