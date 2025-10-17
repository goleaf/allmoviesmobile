import 'package:flutter_test/flutter_test.dart';

import 'package:allmovies_mobile/data/models/search_filters.dart';

void main() {
  group('MovieSearchFilters', () {
    test('produces query map with trimmed values', () {
      final filters = MovieSearchFilters(
        includeAdult: true,
        primaryReleaseYear: ' 1999 ',
        language: ' en ',
        region: ' US ',
      );
      final params = filters.toQueryParameters();
      expect(params['include_adult'], 'true');
      expect(params['primary_release_year'], '1999');
      expect(filters.hasActiveFilters, isTrue);
      final updated = filters.copyWith(includeAdult: false);
      expect(updated.includeAdult, isFalse);
    });
  });

  group('TvSearchFilters', () {
    test('produces query map with optional fields', () {
      final filters = TvSearchFilters(
        includeAdult: false,
        firstAirDateYear: '2011',
        language: 'en',
      );
      final params = filters.toQueryParameters();
      expect(params['include_adult'], 'false');
      expect(params['first_air_date_year'], '2011');
      expect(filters.hasActiveFilters, isTrue);
      expect(filters.copyWith(language: 'es').language, 'es');
    });
  });
}
