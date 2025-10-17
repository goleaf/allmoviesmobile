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
  testWidgets('MoviesFiltersScreen renders and is interactable', (tester) async {
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
          home: const MoviesFiltersScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Validate the title exists and interact with decade button
    expect(find.text('Filters'), findsOneWidget);
    await tester.tap(find.text('1990s'));
    await tester.pumpAndSettle();
    // Tap Apply
    await tester.tap(find.byKey(const ValueKey('moviesApplyFilters')));
    await tester.pumpAndSettle();
  });
}

// Duplicate block removed (defined above in this file)


