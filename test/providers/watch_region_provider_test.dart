import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:allmovies_mobile/providers/watch_region_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WatchRegionProvider', () {
    test('defaults to US when no pref stored or invalid', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final provider = WatchRegionProvider(prefs);
      expect(provider.region, 'US');

      await provider.setRegion('XX');
      expect(provider.region, 'US');
    });

    test('sets and persists valid region', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final provider = WatchRegionProvider(prefs);

      await provider.setRegion('GB');
      expect(provider.region, 'GB');

      final prefs2 = await SharedPreferences.getInstance();
      final provider2 = WatchRegionProvider(prefs2);
      expect(provider2.region, 'GB');
    });

    test('initializes from existing pref and normalizes codes', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'watch_region_code': 'gb',
      });
      final prefs = await SharedPreferences.getInstance();
      final provider = WatchRegionProvider(prefs);
      expect(provider.region.toUpperCase(), 'GB');

      await provider.setRegion('de');
      expect(provider.region, 'DE');
    });

    test('rejects unknown codes and falls back to US', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'watch_region_code': 'xx',
      });
      final prefs = await SharedPreferences.getInstance();
      final provider = WatchRegionProvider(prefs);
      expect(provider.region, 'US');
      await provider.setRegion('  xx  ');
      expect(provider.region, 'US');
    });
  });
}
