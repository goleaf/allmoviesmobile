import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:allmovies_mobile/core/constants/preferences_keys.dart';
import 'package:allmovies_mobile/core/localization/app_localizations.dart';
import 'package:allmovies_mobile/providers/locale_provider.dart';
import 'package:allmovies_mobile/providers/theme_provider.dart';
import 'package:allmovies_mobile/providers/watch_region_provider.dart';
import 'package:allmovies_mobile/presentation/screens/settings/settings_screen.dart';
import 'package:allmovies_mobile/providers/preferences_provider.dart';

void main() {
  testWidgets('SettingsScreen toggles theme, locale, and region', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider(prefs)),
          ChangeNotifierProvider(create: (_) => LocaleProvider(prefs)),
          ChangeNotifierProvider(create: (_) => WatchRegionProvider(prefs)),
          ChangeNotifierProvider(create: (_) => PreferencesProvider(prefs)),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SettingsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final context = tester.element(find.byType(SettingsScreen));
    final l = AppLocalizations.of(context);

    // Theme
    await tester.tap(find.textContaining('Theme'));
    await tester.pumpAndSettle();
    final themeTile = find.byType(RadioListTile<AppThemeMode>).first;
    if (themeTile.evaluate().isNotEmpty) {
      await tester.tap(themeTile);
      await tester.pumpAndSettle();
    }

    // Language
    await tester.tap(find.textContaining('Language'));
    await tester.pumpAndSettle();
    final langTile = find.byType(RadioListTile<Locale>).first;
    if (langTile.evaluate().isNotEmpty) {
      await tester.tap(langTile);
      await tester.pumpAndSettle();
    }

    // Region: find tile by icon and tap
    final regionTileFinder = find.widgetWithIcon(ListTile, Icons.public);
    expect(regionTileFinder, findsOneWidget);
    await tester.ensureVisible(regionTileFinder);
    await tester.tap(regionTileFinder);
    await tester.pumpAndSettle();
    final dialogFinder = find.byType(AlertDialog);
    if (dialogFinder.evaluate().isNotEmpty) {
      final regionTiles = find.byType(RadioListTile<String>);
      if (regionTiles.evaluate().isNotEmpty) {
        await tester.tap(regionTiles.first, warnIfMissed: false);
        await tester.pumpAndSettle();
      }
    }

    // Notifications
    final notificationsHeader = find.text(l.t('settings.notifications'));
    await tester.ensureVisible(notificationsHeader);
    expect(notificationsHeader, findsOneWidget);

    Future<void> toggleNotification(String labelKey, String prefKey) async {
      final label = l.t(labelKey);
      final tileFinder = find.widgetWithText(SwitchListTile, label);
      expect(tileFinder, findsOneWidget);
      await tester.tap(tileFinder);
      await tester.pumpAndSettle();
      expect(prefs.getBool(prefKey), isTrue);
    }

    await toggleNotification(
      'settings.notifications_new_releases',
      PreferenceKeys.notificationsNewReleases,
    );
    await toggleNotification(
      'settings.notifications_watchlist_alerts',
      PreferenceKeys.notificationsWatchlistAlerts,
    );
    await toggleNotification(
      'settings.notifications_recommendations',
      PreferenceKeys.notificationsRecommendations,
    );
    await toggleNotification(
      'settings.notifications_marketing',
      PreferenceKeys.notificationsMarketing,
    );

    expect(find.byType(SettingsScreen), findsOneWidget);
  });
}
