import 'package:flutter_test/flutter_test.dart';

import 'package:allmovies_mobile/data/models/watch_provider_model.dart';

import '../test_support/fixture_reader.dart';

void main() {
  group('WatchProvider', () {
    test('round-trips json', () async {
      final json = await loadJsonFixture('watch_providers_us.json');
      final flatrate = (json['flatrate'] as List).cast<Map<String, dynamic>>();
      final provider = WatchProvider.fromJson(flatrate.first);
      expect(provider.toJson(), equals(flatrate.first));
      expect(provider.copyWith(providerName: 'NF').providerName, 'NF');
    });
  });

  group('WatchProviderResults', () {
    test('handles null lists as empty', () async {
      final json = await loadJsonFixture('watch_providers_us.json');
      final results = WatchProviderResults.fromJson(json);
      expect(results.flatrate, hasLength(1));
      expect(results.ads, isEmpty);
      expect(results.free, isEmpty);
      expect(results.toJson(), containsPair('flatrate', isNotEmpty));
    });
  });

  group('WatchProviderRegion', () {
    test('parses from list fixture', () async {
      final list = await loadJsonListFixture('watch_provider_regions.json');
      final regions = list
          .whereType<Map<String, dynamic>>()
          .map(WatchProviderRegion.fromJson)
          .toList();
      expect(regions.first.countryCode, 'US');
      expect(regions.first, equals(WatchProviderRegion.fromJson(list.first as Map<String, dynamic>)));
      expect(regions.first.toJson(), equals(list.first));
    });
  });
}
