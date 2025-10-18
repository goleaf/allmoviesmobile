import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:allmovies_mobile/data/models/notification_item.dart';
import 'package:allmovies_mobile/data/services/local_storage_service.dart';
import 'package:allmovies_mobile/providers/notifications_provider.dart';
import 'package:allmovies_mobile/providers/preferences_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('filters notifications when recommendation alerts are disabled', () async {
    final prefs = await SharedPreferences.getInstance();
    final storage = LocalStorageService(prefs);
    final notification = AppNotification(
      id: 'rec1',
      title: 'Fresh picks',
      message: 'A new recommendation awaits.',
      category: NotificationCategory.recommendation,
      isRead: false,
    );
    await storage.saveNotifications([notification]);

    final preferences = PreferencesProvider(prefs);
    await preferences.setNotificationsRecommendations(false);

    final provider = NotificationsProvider(
      storage: storage,
      preferences: preferences,
    );

    expect(provider.notifications, isEmpty);

    await preferences.setNotificationsRecommendations(true);
    provider.refresh();

    expect(provider.notifications, isNotEmpty);
    expect(provider.notifications.first.id, 'rec1');
  });
}
