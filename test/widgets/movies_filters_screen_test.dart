import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:allmovies_mobile/data/models/discover_filters_model.dart';
import 'package:allmovies_mobile/presentation/screens/movies/movies_filters_screen.dart';
import 'package:allmovies_mobile/providers/watch_region_provider.dart';
import 'package:allmovies_mobile/core/localization/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../test_utils/pump_app.dart';

void main() {
  testWidgets('MoviesFiltersScreen renders and is interactable', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final navigatorKey = GlobalKey<NavigatorState>();

    await pumpApp(
      tester,
      const Scaffold(body: SizedBox.shrink()),
      providers: [
        ChangeNotifierProvider(create: (_) => WatchRegionProvider(prefs)),
      ],
      navigatorKey: navigatorKey,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      onGenerateRoute: (settings) {
        if (settings.name == MoviesFiltersScreen.routeName) {
          return MaterialPageRoute(builder: (_) => const MoviesFiltersScreen());
        }
        return null;
      },
    );
    await tester.pumpAndSettle();

    final future = navigatorKey.currentState!.pushNamed(MoviesFiltersScreen.routeName);
    await tester.pumpAndSettle();

    // Tap a decade button e.g., 1990s
    await tester.tap(find.text('1990s'));
    await tester.pump();

    // Apply
    await tester.tap(find.byKey(const ValueKey('moviesApplyFilters')));
    await tester.pumpAndSettle();

    final result = await future;
    expect(result, isA<DiscoverFilters>());
    final filters = result as DiscoverFilters;
    expect(filters.releaseDateGte, isNotNull);
    expect(filters.releaseDateLte, isNotNull);
  });
}


