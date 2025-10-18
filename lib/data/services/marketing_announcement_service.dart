import '../models/notification_item.dart';
import 'local_storage_service.dart';
import 'notification_preferences_service.dart';
import '../local/marketing_announcements.dart';

class MarketingAnnouncementService {
  MarketingAnnouncementService({
    required LocalStorageService storage,
    required NotificationPreferences preferences,
  })  : _storage = storage,
        _preferences = preferences;

  final LocalStorageService _storage;
  final NotificationPreferences _preferences;

  Future<void> publishAvailableAnnouncements({DateTime? now}) async {
    if (!_preferences.marketingEnabled) {
      return;
    }

    final today = _normalizeDate(now ?? DateTime.now());
    for (final announcement in marketingAnnouncements) {
      if (!announcement.isActiveOn(today)) {
        continue;
      }

      final notification = AppNotification(
        id: 'marketing_${announcement.id}',
        title: announcement.title,
        message: announcement.message,
        category: NotificationCategory.marketing,
        actionRoute: announcement.actionRoute,
        metadata: announcement.metadata,
      );
      await _storage.upsertNotification(notification);
    }
  }

  DateTime _normalizeDate(DateTime value) =>
      DateTime.utc(value.year, value.month, value.day);
}
