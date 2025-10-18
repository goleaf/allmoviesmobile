import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:allmovies_mobile/core/constants/preferences_keys.dart';
import 'package:allmovies_mobile/data/models/notification_item.dart';
import 'package:allmovies_mobile/data/services/local_storage_service.dart';
import 'package:allmovies_mobile/data/services/marketing_announcement_service.dart';
import 'package:allmovies_mobile/data/services/notification_preferences_service.dart';

void main() {
  group('MarketingAnnouncementService', () {
    late SharedPreferences prefs;
    late LocalStorageService storage;
    late NotificationPreferences preferences;
    late MarketingAnnouncementService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        PreferenceKeys.notificationsMarketing: true,
      });
      prefs = await SharedPreferences.getInstance();
      storage = LocalStorageService(prefs);
      preferences = NotificationPreferences(prefs);
      service = MarketingAnnouncementService(
        storage: storage,
        preferences: preferences,
      );
    });

    test('publishes marketing notifications within active window', () async {
      await service.publishAvailableAnnouncements(
        now: DateTime.utc(2024, 6, 15),
      );

      final notifications = storage.getNotifications();
      expect(notifications, isNotEmpty);
      expect(notifications.first.category, NotificationCategory.marketing);
    });

    test('respects marketing preference toggle', () async {
      await prefs.setBool(PreferenceKeys.notificationsMarketing, false);

      await service.publishAvailableAnnouncements(
        now: DateTime.utc(2024, 6, 15),
      );

      expect(storage.getNotifications(), isEmpty);
    });
  });
}
