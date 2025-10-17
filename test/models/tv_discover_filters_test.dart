import 'package:flutter_test/flutter_test.dart';

import 'package:allmovies_mobile/data/models/tv_discover_filters.dart';

void main() {
  group('TvDiscoverFilters', () {
    test('generates query parameters with deduped values', () {
      final filters = TvDiscoverFilters(
        page: 3,
        withGenres: const [10765, 18, 18],
        withNetworks: const [49, 49],
        withWatchProviders: const [8, 9],
        watchRegion: 'US',
        monetizationTypes: const {MonetizationType.flatRate, MonetizationType.rent},
        includeNullFirstAirDates: true,
        screenedTheatrically: false,
        timezone: 'America/New_York',
      );
      final params = filters.toQueryParameters(includePage: true);
      expect(params['page'], '3');
      expect(params['with_genres'], '10765,18');
      expect(params['with_watch_monetization_types'], contains('flatrate'));
      expect(params['screened_theatrically'], 'false');
      expect(params['timezone'], 'America/New_York');
    });

    test('copyWith toggles runtime filters and resets optional values', () {
      final filters = TvDiscoverFilters(
        withRuntimeGte: 30,
        withRuntimeLte: 60,
        voteAverageGte: 7.5,
      );
      final updated = filters.copyWith(
        withRuntimeLte: 55,
        voteAverageGte: 8.0,
        screenedTheatrically: true,
      );
      expect(updated.withRuntimeGte, 30);
      expect(updated.withRuntimeLte, 55);
      expect(updated.voteAverageGte, 8.0);
      expect(updated.screenedTheatrically, isTrue);
    });
  });
}
