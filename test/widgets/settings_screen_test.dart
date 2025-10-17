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

    // Open theme dialog
    await tester.tap(find.textContaining('Theme'));
    await tester.pumpAndSettle();
    // Choose a different theme mode if available
    final radio = find.byType(RadioListTile<AppThemeMode>).first;
    await tester.tap(radio);
    await tester.pumpAndSettle();

    // Open language dialog
    await tester.tap(find.textContaining('Language'));
    await tester.pumpAndSettle();
    final languageRadio = find.byType(RadioListTile<Locale>).first;
    await tester.tap(languageRadio);
    await tester.pumpAndSettle();

    // Open region dialog (ensure visible)
    final listFinder = find.byType(ListView);
    if (listFinder.evaluate().isNotEmpty) {
      await tester.drag(listFinder.first, const Offset(0, -300));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.textContaining('Region'));
    await tester.pumpAndSettle();
    final regionRadio = find.byType(RadioListTile<String>).first;
    await tester.tap(regionRadio);
    await tester.pumpAndSettle();

    // If reached here without exceptions, interactions worked
    expect(find.byType(SettingsScreen), findsOneWidget);
  });
}


