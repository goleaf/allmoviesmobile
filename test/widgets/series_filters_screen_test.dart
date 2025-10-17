import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:allmovies_mobile/core/constants/preferences_keys.dart';
import 'package:allmovies_mobile/presentation/screens/series/series_filters_screen.dart';
import 'package:allmovies_mobile/providers/preferences_provider.dart';
import 'package:allmovies_mobile/providers/series_provider.dart';
import 'package:allmovies_mobile/data/tmdb_repository.dart';
import '../test_utils/pump_app.dart';

void main() {
  testWidgets('SeriesFiltersScreen returns Map<String,String> on apply', (
    tester,
  ) async {
    final navigatorKey = GlobalKey<NavigatorState>();

    await pumpApp(
      tester,
      const Scaffold(body: SizedBox.shrink()),
      navigatorKey: navigatorKey,
      onGenerateRoute: (settings) {
        if (settings.name == SeriesFiltersScreen.routeName) {
          return MaterialPageRoute(builder: (_) => const SeriesFiltersScreen());
        }
        return null;
      },
    );

    final future = navigatorKey.currentState!.pushNamed(
      SeriesFiltersScreen.routeName,
    );
    await tester.pumpAndSettle();

    // Apply
    await tester.tap(find.byKey(const ValueKey('seriesApplyFilters')));
    await tester.pumpAndSettle();

    final result = await future;
    expect(result, isA<Map<String, String>>());
  });

  testWidgets('SeriesFiltersScreen restores saved filters into controls', (
    tester,
  ) async {
    final savedFilters = {
      'with_original_language': 'ja',
      'first_air_date.gte': '2020-01-01',
      'first_air_date.lte': '2021-12-31',
      'include_null_first_air_dates': 'true',
      'screened_theatrically': 'true',
      'with_watch_monetization_types': 'rent|buy',
      'with_watch_providers': '8,9',
      'timezone': 'America/Los_Angeles',
      'with_genres': '18,35',
      'with_networks': '213',
      'with_status': 'Returning Series',
      'with_type': 'Scripted',
      'vote_average.gte': '6.5',
      'vote_average.lte': '8.5',
      'with_runtime.gte': '30',
      'with_runtime.lte': '120',
      'vote_count.gte': '500',
      'first_air_date_year': '2020',
    };

    SharedPreferences.setMockInitialValues({
      PreferenceKeys.seriesFilters: jsonEncode(savedFilters),
    });

    final prefs = await SharedPreferences.getInstance();
    final seriesProvider = SeriesProvider(
      _StubRepo(),
      preferencesProvider: PreferencesProvider(prefs),
      autoInitialize: false,
    );

    await pumpApp(
      tester,
      const SeriesFiltersScreen(),
      providers: [
        ChangeNotifierProvider<SeriesProvider>.value(value: seriesProvider),
      ],
    );

    await tester.pumpAndSettle();

    expect(find.text('Restored saved series filters'), findsOneWidget);

    final languageChip =
        tester.widget<FilterChip>(find.widgetWithText(FilterChip, 'JA'));
    expect(languageChip.selected, isTrue);

    final includeNullSwitch = tester.widget<SwitchListTile>(
      find.widgetWithText(SwitchListTile, 'Include Null First Air Dates'),
    );
    expect(includeNullSwitch.value, isTrue);

    final screenedSwitch = tester.widget<SwitchListTile>(
      find.widgetWithText(SwitchListTile, 'Screened Theatrically'),
    );
    expect(screenedSwitch.value, isTrue);

    final timezoneField = tester.widget<TextField>(
      find.byKey(const ValueKey('seriesFiltersTimezoneField')),
    );
    expect(timezoneField.controller?.text, 'America/Los_Angeles');

    final watchProvidersField = tester.widget<TextField>(
      find.byKey(const ValueKey('seriesFiltersWatchProvidersField')),
    );
    expect(watchProvidersField.controller?.text, '8,9');

    final rentChip =
        tester.widget<FilterChip>(find.widgetWithText(FilterChip, 'rent'));
    expect(rentChip.selected, isTrue);

    final voteSlider =
        tester.widget<RangeSlider>(find.byType(RangeSlider).first);
    expect(voteSlider.values.start, closeTo(6.5, 0.01));
    expect(voteSlider.values.end, closeTo(8.5, 0.01));

    final runtimeSlider =
        tester.widget<RangeSlider>(find.byType(RangeSlider).at(1));
    expect(runtimeSlider.values.start, closeTo(30, 0.01));
    expect(runtimeSlider.values.end, closeTo(120, 0.01));

    final voteCountSlider = tester.widget<Slider>(find.byType(Slider));
    expect(voteCountSlider.value, 500);

    final statusChip = tester.widget<FilterChip>(
      find.widgetWithText(FilterChip, 'Returning Series'),
    );
    expect(statusChip.selected, isTrue);

    final typeChip =
        tester.widget<FilterChip>(find.widgetWithText(FilterChip, 'Scripted'));
    expect(typeChip.selected, isTrue);
  });
}

class _StubRepo extends TmdbRepository {}
