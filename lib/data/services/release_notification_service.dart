import '../models/notification_item.dart';
import 'local_storage_service.dart';
import 'notification_preferences_service.dart';

class ReleaseNotificationService {
  ReleaseNotificationService({
    required LocalStorageService storage,
    required NotificationPreferences preferences,
  })  : _storage = storage,
        _preferences = preferences;

  final LocalStorageService _storage;
  final NotificationPreferences _preferences;

  Future<void> runDailyCheck({DateTime? now}) async {
    if (!_preferences.newReleasesEnabled) {
      return;
    }

    final today = _normalizeDate(now ?? DateTime.now());
    for (final item in _storage.getWatchlistItems()) {
      final releaseDate = _parseDate(item.releaseDate);
      if (releaseDate == null || releaseDate != today) {
        continue;
      }

      final notification = AppNotification(
        id: 'release_${item.type.storageKey}_${item.id}',
        title: '${item.title} releases today',
        message: '${item.title} is now available to watch.',
        category: NotificationCategory.system,
        metadata: <String, dynamic>{
          'mediaId': item.id,
          'mediaType': item.type.storageKey,
          'releaseDate': item.releaseDate,
        },
      );
      await _storage.upsertNotification(notification);
    }
  }

  DateTime _normalizeDate(DateTime value) =>
      DateTime.utc(value.year, value.month, value.day);

  DateTime? _parseDate(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    final parts = value.split('-');
    if (parts.length < 3) {
      return null;
    }
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year == null || month == null || day == null) {
      return null;
    }
    return DateTime.utc(year, month, day);
  }
}
