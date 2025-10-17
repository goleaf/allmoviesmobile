import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:allmovies_mobile/data/models/discover_filters_model.dart';
import 'package:allmovies_mobile/presentation/screens/movies/movies_filters_screen.dart';
import 'package:allmovies_mobile/providers/watch_region_provider.dart';
import 'package:allmovies_mobile/core/localization/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  testWidgets('MoviesFiltersScreen apply returns DiscoverFilters with expected fields', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    DiscoverFilters? result;

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => WatchRegionProvider(prefs)),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: MoviesFiltersScreen(),
        ),
      ),
    );

    // Apply without changing values
    await tester.tap(find.byKey(const ValueKey('moviesApplyFilters')));
    await tester.pumpAndSettle();

    // Validate the page is rendered without errors
    expect(find.text('By Decade'), findsOneWidget);
    // Release date range set via decade quick buttons
    expect(result!.releaseDateGte, isNotNull);
    expect(result!.releaseDateLte, isNotNull);
  });
}

// Duplicate block removed (defined above in this file)


