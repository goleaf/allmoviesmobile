import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'package:allmovies_mobile/core/localization/app_localizations.dart' as core_l10n;
import 'package:allmovies_mobile/providers/locale_provider.dart';
import 'package:allmovies_mobile/providers/theme_provider.dart';

/// A minimal reusable app wrapper for widget tests that provides
/// localization delegates and Provider tree commonly used in the app.
class TestApp extends StatelessWidget {
  final Widget child;
  final Locale? locale;

  const TestApp({super.key, required this.child, this.locale});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Minimal providers needed for localization/theme dependent widgets.
        ChangeNotifierProvider<LocaleProvider>(
          create: (_) => LocaleProvider(null /* SharedPreferences not needed in tests */),
        ),
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(null /* SharedPreferences not needed in tests */),
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
    );
  }
}

/// Pumps [TestApp] with the provided [child] wrapped inside, ensuring
/// localization and providers are available for widget tests.
Future<void> pumpTestApp(
  WidgetTester tester,
  Widget child, {
  Locale locale = const Locale('en'),
}) async {
  await tester.pumpWidget(TestApp(child: child, locale: locale));
  // Let localization delegates load if any async microtasks occur.
  await tester.pumpAndSettle();
}


