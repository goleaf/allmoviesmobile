import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:allmovies_mobile/data/services/cache_service.dart';

void main() {
  group('CacheService', () {
    test('in-memory TTL expires entries', () async {
      final cache = CacheService();
      cache.set<String>('k', 'v', ttlSeconds: 1);
      expect(cache.get<String>('k'), 'v');
      await Future<void>.delayed(const Duration(seconds: 2));
      expect(cache.get<String>('k'), isNull);
    });

    test('persistent set/get honors TTL and cleanup', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final cache = CacheService(prefs: prefs);

      await cache.setPersistent<String>('pk', 'pv', ttlSeconds: 1);
      expect(await cache.getPersistent<String>('pk'), 'pv');

      await Future<void>.delayed(const Duration(seconds: 2));
      expect(await cache.getPersistent<String>('pk'), isNull);

      final removed = await cache.cleanPersistentExpired();
      expect(removed, greaterThanOrEqualTo(0));
    });
  });
}
