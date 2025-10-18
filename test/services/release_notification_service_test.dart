import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:allmovies_mobile/core/constants/preferences_keys.dart';
import 'package:allmovies_mobile/data/models/notification_item.dart';
import 'package:allmovies_mobile/data/models/saved_media_item.dart';
import 'package:allmovies_mobile/data/services/local_storage_service.dart';
import 'package:allmovies_mobile/data/services/notification_preferences_service.dart';
import 'package:allmovies_mobile/data/services/release_notification_service.dart';

void main() {
  group('ReleaseNotificationService', () {
    late SharedPreferences prefs;
    late LocalStorageService storage;
    late NotificationPreferences preferences;
    late ReleaseNotificationService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        PreferenceKeys.notificationsNewReleases: true,
      });
      prefs = await SharedPreferences.getInstance();
      storage = LocalStorageService(prefs);
      preferences = NotificationPreferences(prefs);
      service = ReleaseNotificationService(
        storage: storage,
        preferences: preferences,
      );
    });

    test('emits system notification when release date matches today', () async {
      const releaseDate = '2024-02-01';
      await storage.addToWatchlist(
        7,
        item: SavedMediaItem(
          id: 7,
          type: SavedMediaType.movie,
          title: 'Test Movie',
          releaseDate: releaseDate,
        ),
      );

      await service.runDailyCheck(now: DateTime.utc(2024, 2, 1));

      final notifications = storage.getNotifications();
      expect(notifications, hasLength(1));
      expect(notifications.first.category, NotificationCategory.system);
      expect(notifications.first.metadata['releaseDate'], releaseDate);
    });

    test('skips when preference disabled', () async {
      await prefs.setBool(PreferenceKeys.notificationsNewReleases, false);
      await storage.addToWatchlist(
        8,
        item: SavedMediaItem(
          id: 8,
          type: SavedMediaType.tv,
          title: 'Future Show',
          releaseDate: '2024-05-01',
        ),
      );

      await service.runDailyCheck(now: DateTime.utc(2024, 5, 1));

      expect(storage.getNotifications(), isEmpty);
    });
  });
}
