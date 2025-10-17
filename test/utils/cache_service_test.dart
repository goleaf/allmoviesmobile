import 'dart:async';

import 'package:allmovies_mobile/data/services/cache_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CacheService (in-memory)', () {
    test('set/get within TTL returns value', () async {
      final cache = CacheService();
      cache.set<String>('k', 'v', ttlSeconds: 2);
      expect(cache.get<String>('k'), 'v');
    });

    test('expired entry is evicted on access', () async {
      final cache = CacheService();
      cache.set<String>('k', 'v', ttlSeconds: 1);
      await Future<void>.delayed(const Duration(seconds: 2));
      expect(cache.get<String>('k'), isNull);
    });

    test('remove and removePattern work', () async {
      final cache = CacheService();
      cache.set('a:1', 1);
      cache.set('a:2', 2);
      cache.set('b:1', 3);
      cache.remove('a:1');
      expect(cache.get('a:1'), isNull);
      cache.removePattern(r'^a:');
      expect(cache.get('a:2'), isNull);
      expect(cache.get('b:1'), 3);
    });
  });

  group('CacheService (persistent)', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
    });

    test('setPersistent/getPersistent roundtrip', () async {
      final prefs = await SharedPreferences.getInstance();
      final cache = CacheService(prefs: prefs);
      await cache.setPersistent('key', <String, dynamic>{'a': 1}, ttlSeconds: 2);
      final v = await cache.getPersistent<Map<String, dynamic>>('key');
      expect(v, isA<Map<String, dynamic>>());
      expect(v!['a'], 1);
    });

    test('expired persistent entry returns null and removes', () async {
      final prefs = await SharedPreferences.getInstance();
      final cache = CacheService(prefs: prefs);
      await cache.setPersistent('key', 'value', ttlSeconds: 1);
      await Future<void>.delayed(const Duration(seconds: 2));
      final v = await cache.getPersistent<String>('key');
      expect(v, isNull);
    });

    test('cleanPersistentExpired removes expired keys', () async {
      final prefs = await SharedPreferences.getInstance();
      final cache = CacheService(prefs: prefs);
      await cache.setPersistent('x', 'v', ttlSeconds: 1);
      await Future<void>.delayed(const Duration(seconds: 2));
      final removed = await cache.cleanPersistentExpired();
      expect(removed, greaterThanOrEqualTo(1));
    });
  });
}


