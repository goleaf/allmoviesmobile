import 'package:allmovies_mobile/presentation/screens/settings/settings_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:allmovies_mobile/l10n/app_localizations.dart' as l10n;
import 'package:allmovies_mobile/providers/locale_provider.dart';
import 'package:allmovies_mobile/providers/theme_provider.dart';
import 'package:allmovies_mobile/providers/watch_region_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget makeApp() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snap) {
        if (!snap.hasData) return const SizedBox.shrink();
        final prefs = snap.data!;
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => LocaleProvider(prefs)),
            ChangeNotifierProvider(create: (_) => ThemeProvider(prefs)),
            ChangeNotifierProvider(create: (_) => WatchRegionProvider(prefs)),
          ],
          child: MaterialApp(
            localizationsDelegates: const [
              l10n.AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: l10n.AppLocalizations.supportedLocales,
            home: const SettingsScreen(),
          ),
        );
      },
    );
  }

  testWidgets('SettingsScreen renders', (tester) async {
    await tester.pumpWidget(makeApp());
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);
  });
}


