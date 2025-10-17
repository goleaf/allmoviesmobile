import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart' as legacy_provider;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:allmovies_mobile/core/localization/app_localizations.dart';
import 'package:allmovies_mobile/providers/locale_provider.dart';
import 'package:allmovies_mobile/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A minimal reusable app wrapper for widget tests that provides
/// localization delegates and Provider tree commonly used in the app.
class TestApp extends StatefulWidget {
  final Widget child;
  final Locale? locale;
  final SharedPreferences? prefs;
  final List<Override> overrides;

  const TestApp({
    super.key,
    required this.child,
    this.prefs,
    this.locale,
    this.overrides = const [],
  });

  @override
  State<TestApp> createState() => _TestAppState();
}

class _TestAppState extends State<TestApp> {
  SharedPreferences? _effectivePrefs;

  @override
  void initState() {
    super.initState();
    if (widget.prefs != null) {
      _effectivePrefs = widget.prefs;
    } else {
      // Resolve prefs asynchronously if not provided by the test
      SharedPreferences.getInstance().then((p) {
        if (!mounted) return;
        setState(() {
          _effectivePrefs = p;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show a lightweight placeholder until prefs are ready
    if (_effectivePrefs == null) {
      return const SizedBox.shrink();
    }

    return ProviderScope(
      overrides: widget.overrides,
      child: legacy_provider.MultiProvider(
        providers: [
          legacy_provider.ChangeNotifierProvider<LocaleProvider>(
            create: (_) => LocaleProvider(_effectivePrefs!),
          ),
          legacy_provider.ChangeNotifierProvider<ThemeProvider>(
            create: (_) => ThemeProvider(_effectivePrefs!),
          ),
        ],
        child: Builder(
          builder: (context) {
            final effectiveLocale = widget.locale ?? const Locale('en');
            return MaterialApp(
              locale: effectiveLocale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: widget.child,
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
  bool settle = true,
}) async {
  SharedPreferences.setMockInitialValues(initialPrefs);
  final prefs = await SharedPreferences.getInstance();
  await tester.pumpWidget(
    TestApp(child: child, locale: locale, prefs: prefs, overrides: overrides),
  );
  // Let localization delegates load if any async microtasks occur.
  if (settle) {
    await tester.pumpAndSettle();
  }
}
