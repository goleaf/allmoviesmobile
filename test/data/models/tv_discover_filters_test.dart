import 'package:flutter_test/flutter_test.dart';

import 'package:allmovies_mobile/data/models/tv_discover_filters.dart';

void main() {
  group('TvDiscoverFilters', () {
    test('parses legacy query parameters', () {
      final filters = TvDiscoverFilters.fromQueryParameters({
        'with_status': 'Returning Series|Ended',
        'with_type': 'Scripted|Reality',
        'with_watch_monetization_types': 'flatrate|rent',
        'with_networks': '213|49',
        'include_null_first_air_dates': 'true',
      });

      expect(filters.statuses, containsAll({TvStatus.returningSeries, TvStatus.ended}));
      expect(filters.types, containsAll({TvShowType.scripted, TvShowType.reality}));
      expect(
        filters.monetizationTypes,
        containsAll({MonetizationType.flatrate, MonetizationType.rent}),
      );
      expect(filters.withNetworks, equals([213, 49]));
      expect(filters.includeNullFirstAirDates, isTrue);
    });

    test('toJson/fromJson round trips values', () {
      final original = TvDiscoverFilters(
        sortBy: TvSortOption.voteAverageDesc,
        firstAirDateYear: 2024,
        withGenres: const [18, 80],
        withRuntimeGte: 45,
        withRuntimeLte: 90,
        voteAverageGte: 7.5,
        voteAverageLte: 9.5,
        monetizationTypes: const {MonetizationType.buy, MonetizationType.free},
        statuses: const {TvStatus.inProduction},
        types: const {TvShowType.documentary},
      );

      final encoded = original.toJson();
      final decoded = TvDiscoverFilters.fromJson(encoded);

      expect(decoded.sortBy, TvSortOption.voteAverageDesc);
      expect(decoded.firstAirDateYear, 2024);
      expect(decoded.withGenres, equals([18, 80]));
      expect(decoded.withRuntimeGte, 45);
      expect(decoded.withRuntimeLte, 90);
      expect(decoded.voteAverageGte, closeTo(7.5, 0.001));
      expect(decoded.voteAverageLte, closeTo(9.5, 0.001));
      expect(decoded.monetizationTypes, containsAll({MonetizationType.buy, MonetizationType.free}));
      expect(decoded.statuses, contains(TvStatus.inProduction));
      expect(decoded.types, contains(TvShowType.documentary));
    });
  });

  group('TvDiscoverFilterPreset', () {
    test('serializes to and from JSON string', () {
      final preset = TvDiscoverFilterPreset(
        name: 'Sci-Fi Heists',
        filters: TvDiscoverFilters(
          withKeywords: const [123, 456],
          withOriginalLanguage: 'en',
        ),
      );

      final encoded = preset.toJsonString();
      final decoded = TvDiscoverFilterPreset.fromJsonString(encoded);

      expect(decoded, isNotNull);
      expect(decoded!.name, 'Sci-Fi Heists');
      expect(decoded.filters.withKeywords, equals([123, 456]));
      expect(decoded.filters.withOriginalLanguage, 'en');
    });
  });
}
