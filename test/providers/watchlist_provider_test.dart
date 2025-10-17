import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:allmovies_mobile/data/services/local_storage_service.dart';
import 'package:allmovies_mobile/providers/watchlist_provider.dart';

void main() {
  group('WatchlistProvider import/export & watched', () {
    late WatchlistProvider provider;
    late LocalStorageService storage;

    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final prefs = await SharedPreferences.getInstance();
      storage = LocalStorageService(prefs);
      provider = WatchlistProvider(storage);
    });

    test('exportToJson returns valid JSON array', () async {
      await provider.addToWatchlist(101);
      final json = provider.exportToJson();
      expect(json.trim().startsWith('['), true);
      expect(json.contains('"id"'), true);
    });

    test('importFromRemoteJson replaces items from URL', () async {
      final mockResponse = '[{"id":201,"type":"movie","title":"Movie #201"}]';
      final client = MockClient((request) async {
        return http.Response(mockResponse, 200);
      });

      final p = WatchlistProvider(storage, httpClient: client);
      await p.importFromRemoteJson(
        Uri.parse('https://example.com/watchlist.json'),
      );

      expect(p.watchlist, contains(201));
      expect(p.count, 1);
    });

    test('setWatched toggles watched flag', () async {
      await provider.addToWatchlist(303);
      expect(provider.isWatched(303), false);
      await provider.setWatched(303, watched: true);
      expect(provider.isWatched(303), true);
    });
  });
}
