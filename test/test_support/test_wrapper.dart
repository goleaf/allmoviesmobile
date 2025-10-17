import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:allmovies_mobile/core/localization/app_localizations.dart' as core_l10n;
import 'package:allmovies_mobile/providers/locale_provider.dart';
import 'package:allmovies_mobile/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A minimal reusable app wrapper for widget tests that provides
/// localization delegates and Provider tree commonly used in the app.
class TestApp extends StatelessWidget {
  final Widget child;
  final Locale? locale;
  final SharedPreferences prefs;
  final List<Override> overrides;

  const TestApp({
    super.key,
    required this.child,
    required this.prefs,
    this.locale,
    this.overrides = const [],
  });

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: overrides,
      child: MultiProvider(
      providers: [
        // Minimal providers needed for localization/theme dependent widgets.
        ChangeNotifierProvider<LocaleProvider>(
          create: (_) => LocaleProvider(prefs),
        ),
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(prefs),
        ),
      ],
        child: Builder(
          builder: (context) {
            final effectiveLocale = locale ?? const Locale('en');
            return MaterialApp(
              locale: effectiveLocale,
              supportedLocales: core_l10n.AppLocalizations.supportedLocales,
              localizationsDelegates: const [
                core_l10n.AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: child,
            );
          },
        ),
      ),
    );
  }
}

/// Pumps [TestApp] with the provided [child] wrapped inside, ensuring
/// localization and providers are available for widget tests.
Future<void> pumpTestApp(
  WidgetTester tester,
  Widget child, {
  Locale locale = const Locale('en'),
  Map<String, Object> initialPrefs = const {},
  List<Override> overrides = const [],
}) async {
  SharedPreferences.setMockInitialValues(initialPrefs);
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    TestApp(
      child: child,
      locale: locale,
      prefs: prefs,
      overrides: overrides,
    ),
  );
  // Let localization delegates load if any async microtasks occur.
  await tester.pumpAndSettle();
}


