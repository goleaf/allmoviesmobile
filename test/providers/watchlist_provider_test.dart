import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:allmovies_mobile/core/constants/preferences_keys.dart';
import 'package:allmovies_mobile/data/models/notification_item.dart';
import 'package:allmovies_mobile/data/services/local_storage_service.dart';
import 'package:allmovies_mobile/data/services/notification_preferences_service.dart';
import 'package:allmovies_mobile/providers/watchlist_provider.dart';

void main() {
  group('WatchlistProvider import/export & watched', () {
    late WatchlistProvider provider;
    late LocalStorageService storage;

    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        PreferenceKeys.notificationsWatchlistAlerts: true,
      });
      final prefs = await SharedPreferences.getInstance();
      storage = LocalStorageService(prefs);
      provider = WatchlistProvider(
        storage,
        notificationPreferences: NotificationPreferences(prefs),
      );
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

      final prefs = await SharedPreferences.getInstance();
      final p = WatchlistProvider(
        storage,
        notificationPreferences: NotificationPreferences(prefs),
        httpClient: client,
      );
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

    test('emits list notification on add/remove', () async {
      await provider.addToWatchlist(444);
      var notifications = storage.getNotifications();
      expect(notifications.length, 1);
      expect(notifications.first.category, NotificationCategory.list);
      expect(notifications.first.metadata['action'], 'added');

      await provider.removeFromWatchlist(444);
      notifications = storage.getNotifications();
      expect(notifications.first.category, NotificationCategory.list);
      expect(notifications.first.metadata['action'], 'removed');
    });
  });
}
