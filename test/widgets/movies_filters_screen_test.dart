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
          home: Builder(
            builder: (context) => Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () async {
                    final filters = await Navigator.of(context).push<DiscoverFilters>(
                      MaterialPageRoute(builder: (_) => const MoviesFiltersScreen()),
                    );
                    result = filters;
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    // Set some filters (toggle Include Adult and pick a decade)
    await tester.tap(find.byType(SwitchListTile));
    await tester.pump();

    // Tap a decade button e.g., 1990s
    await tester.tap(find.text('1990s'));
    await tester.pump();

    // Apply
    await tester.tap(find.widgetWithText(FilledButton, 'Apply'));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    // Include adult true and release date range set
    expect(result!.includeAdult, isTrue);
    expect(result!.releaseDateGte, isNotNull);
    expect(result!.releaseDateLte, isNotNull);
  });
}

// Duplicate block removed (defined above in this file)


