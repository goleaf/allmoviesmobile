import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:allmovies_mobile/core/localization/app_localizations.dart';
import 'package:allmovies_mobile/data/models/notification_item.dart';
import 'package:allmovies_mobile/data/services/local_storage_service.dart';
import 'package:allmovies_mobile/providers/notifications_provider.dart';
import 'package:allmovies_mobile/providers/preferences_provider.dart';
import 'package:allmovies_mobile/presentation/screens/notifications/notifications_screen.dart';

import '../test_utils/pump_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const delegates = <LocalizationsDelegate<dynamic>>[
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('marks notifications as read from the notifications screen', (
    tester,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final storage = LocalStorageService(prefs);
    final unreadNotification = AppNotification(
      id: 'notif_unread',
      title: 'List updated',
      message: 'A title you follow was updated.',
      category: NotificationCategory.list,
      isRead: false,
    );
    final readNotification = AppNotification(
      id: 'notif_read',
      title: 'Welcome',
      message: 'Thanks for using AllMovies.',
      category: NotificationCategory.system,
      isRead: true,
    );

    await storage.saveNotifications([unreadNotification, readNotification]);

    final preferencesProvider = PreferencesProvider(prefs);
    final notificationsProvider = NotificationsProvider(
      storage: storage,
      preferences: preferencesProvider,
    );

    await pumpApp(
      tester,
      const NotificationsScreen(),
      providers: [
        ChangeNotifierProvider<PreferencesProvider>.value(
          value: preferencesProvider,
        ),
        ChangeNotifierProvider<NotificationsProvider>.value(
          value: notificationsProvider,
        ),
      ],
      localizationsDelegates: delegates,
    );

    expect(find.byIcon(Icons.mark_chat_unread), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Mark read').first);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.mark_chat_unread), findsNothing);
    expect(notificationsProvider.unreadCount, 0);
    expect(
      notificationsProvider.notifications.every((n) => n.isRead),
      isTrue,
    );
  });
}
