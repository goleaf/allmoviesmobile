import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:allmovies_mobile/core/constants/preferences_keys.dart';
import 'package:allmovies_mobile/data/tmdb_repository.dart';
import 'package:allmovies_mobile/presentation/screens/series/series_filters_screen.dart';
import 'package:allmovies_mobile/providers/preferences_provider.dart';
import 'package:allmovies_mobile/providers/series_provider.dart';

import '../test_utils/pump_app.dart';

class _StubRepo extends TmdbRepository {
  _StubRepo() : super(apiKey: 'test');
}

class _CapturingSeriesProvider extends SeriesProvider {
  _CapturingSeriesProvider()
      : lastAppliedFilters = null,
        super(_StubRepo(), autoInitialize: false);

  Map<String, String>? lastAppliedFilters;

  @override
  Future<void> applyTvFilters(Map<String, String> filters) async {
    lastAppliedFilters = Map<String, String>.from(filters);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('SeriesFiltersScreen returns Map<String,String> on apply', (
    tester,
  ) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    final prefs = await SharedPreferences.getInstance();

    await pumpApp(
      tester,
      const Scaffold(body: SizedBox.shrink()),
      providers: [
        ChangeNotifierProvider(create: (_) => PreferencesProvider(prefs)),
        ChangeNotifierProvider(create: (_) => _CapturingSeriesProvider()),
      ],
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

    await tester.tap(find.byKey(const ValueKey('seriesApplyFilters')));
    await tester.pumpAndSettle();

    final result = await future;
    expect(result, isA<Map<String, String>>());
  });

  testWidgets('loads saved presets and applies them via provider', (
    tester,
  ) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    final prefs = await SharedPreferences.getInstance();
    final presets = {
      'Drama Night': {
        'with_genres': '18',
        'vote_average.gte': '7.5',
        'vote_average.lte': '9.0',
      },
    };
    await prefs.setString(
      PreferenceKeys.tvFilterPresets,
      jsonEncode(presets),
    );

    final preferencesProvider = PreferencesProvider(prefs);
    final seriesProvider = _CapturingSeriesProvider();

    await pumpApp(
      tester,
      const Scaffold(body: SizedBox.shrink()),
      providers: [
        ChangeNotifierProvider(create: (_) => preferencesProvider),
        ChangeNotifierProvider(create: (_) => seriesProvider),
      ],
      navigatorKey: navigatorKey,
      onGenerateRoute: (settings) {
        if (settings.name == SeriesFiltersScreen.routeName) {
          return MaterialPageRoute(builder: (_) => const SeriesFiltersScreen());
        }
        return null;
      },
    );

    navigatorKey.currentState!.pushNamed(SeriesFiltersScreen.routeName);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('tvPresetPicker')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Drama Night').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('applyPresetButton')));
    await tester.pumpAndSettle();

    expect(seriesProvider.lastAppliedFilters, isNotNull);
    expect(seriesProvider.lastAppliedFilters, containsPair('with_genres', '18'));
  });

  testWidgets('saving preset persists filters via PreferencesProvider', (
    tester,
  ) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    final prefs = await SharedPreferences.getInstance();
    final preferencesProvider = PreferencesProvider(prefs);

    await pumpApp(
      tester,
      const Scaffold(body: SizedBox.shrink()),
      providers: [
        ChangeNotifierProvider(create: (_) => preferencesProvider),
        ChangeNotifierProvider(create: (_) => _CapturingSeriesProvider()),
      ],
      navigatorKey: navigatorKey,
      onGenerateRoute: (settings) {
        if (settings.name == SeriesFiltersScreen.routeName) {
          return MaterialPageRoute(builder: (_) => const SeriesFiltersScreen());
        }
        return null;
      },
    );

    navigatorKey.currentState!.pushNamed(SeriesFiltersScreen.routeName);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Drama'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('savePresetButton')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('presetNameField')),
      'My Preset',
    );
    await tester.pump();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final saved = await preferencesProvider.getTvFilterPreset('My Preset');
    expect(saved, isNotNull);
    expect(saved, containsPair('with_genres', '18'));
  });
}
