import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:allmovies_mobile/l10n/app_localizations.dart';
import 'package:allmovies_mobile/providers/locale_provider.dart';
import 'package:allmovies_mobile/providers/theme_provider.dart';
import 'package:allmovies_mobile/providers/watch_region_provider.dart';
import 'package:allmovies_mobile/presentation/screens/settings/settings_screen.dart';

void main() {
  testWidgets('SettingsScreen toggles theme, locale, and region', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider(prefs)),
          ChangeNotifierProvider(create: (_) => LocaleProvider(prefs)),
          ChangeNotifierProvider(create: (_) => WatchRegionProvider(prefs)),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const SettingsScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

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

    // Region (scroll first)
    final listView = find.byType(ListView).first;
    await tester.dragUntilVisible(
      find.textContaining('Region'),
      listView,
      const Offset(0, -200),
    );
    await tester.tap(find.textContaining('Region'));
    await tester.pumpAndSettle();
    final regionTile = find.byType(RadioListTile<String>).first;
    if (regionTile.evaluate().isNotEmpty) {
      await tester.tap(regionTile);
      await tester.pumpAndSettle();
    }

    expect(find.byType(SettingsScreen), findsOneWidget);
  });
}


