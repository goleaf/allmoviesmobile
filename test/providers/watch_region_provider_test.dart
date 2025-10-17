import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:allmovies_mobile/providers/watch_region_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('WatchRegionProvider initializes from prefs and updates', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{'watch_region_code': 'gb'});
    final prefs = await SharedPreferences.getInstance();
    final provider = WatchRegionProvider(prefs);
    expect(provider.region.toUpperCase(), 'GB');
    await provider.setRegion('de');
    expect(provider.region, 'DE');
  });
}


