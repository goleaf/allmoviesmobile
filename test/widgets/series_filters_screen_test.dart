import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:allmovies_mobile/data/models/tv_discover_filters.dart';
import 'package:allmovies_mobile/presentation/screens/series/series_filters_screen.dart';
import 'package:allmovies_mobile/providers/preferences_provider.dart';
import '../test_utils/pump_app.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object?>{});
  });

  testWidgets('SeriesFiltersScreen returns SeriesFilterResult on apply', (
    tester,
  ) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    final prefs = await SharedPreferences.getInstance();

    await pumpApp(
      tester,
      const Scaffold(body: SizedBox.shrink()),
      navigatorKey: navigatorKey,
      onGenerateRoute: (settings) {
        if (settings.name == SeriesFiltersScreen.routeName) {
          return MaterialPageRoute(
            builder: (_) => const SeriesFiltersScreen(),
          );
        }
        return null;
      },
      providers: [
        ChangeNotifierProvider<PreferencesProvider>(
          create: (_) => PreferencesProvider(prefs),
        ),
      ],
    );

    final future = navigatorKey.currentState!.pushNamed(
      SeriesFiltersScreen.routeName,
    );
    await tester.pumpAndSettle();

    // Apply
    await tester.tap(find.byKey(const ValueKey('seriesApplyFilters')));
    await tester.pumpAndSettle();

    final result = await future;
    expect(result, isA<SeriesFilterResult>());
    final typed = result as SeriesFilterResult;
    expect(typed.filters, isA<TvDiscoverFilters>());
  });

  testWidgets('SeriesFiltersScreen can save and apply presets', (tester) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    final prefs = await SharedPreferences.getInstance();

    await pumpApp(
      tester,
      const Scaffold(body: SizedBox.shrink()),
      navigatorKey: navigatorKey,
      onGenerateRoute: (settings) {
        if (settings.name == SeriesFiltersScreen.routeName) {
          return MaterialPageRoute(
            builder: (_) => const SeriesFiltersScreen(),
          );
        }
        return null;
      },
      providers: [
        ChangeNotifierProvider<PreferencesProvider>(
          create: (_) => PreferencesProvider(prefs),
        ),
      ],
    );

    final future = navigatorKey.currentState!.pushNamed(
      SeriesFiltersScreen.routeName,
    );
    await tester.pumpAndSettle();

    // Select a network to enable saving.
    await tester.tap(find.text('Netflix'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save preset'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      ),
      'Weekend Binge',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final element = tester.element(find.byType(SeriesFiltersScreen));
    final prefsProvider =
        Provider.of<PreferencesProvider>(element, listen: false);
    expect(prefsProvider.tvFilterPresets, hasLength(1));
    expect(prefsProvider.tvFilterPresets.first.name, 'Weekend Binge');

    await tester.tap(find.byTooltip('Saved presets'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Weekend Binge'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('seriesApplyFilters')));
    await tester.pumpAndSettle();

    final result = await future;
    expect(result, isA<SeriesFilterResult>());
    final typed = result as SeriesFilterResult;
    expect(typed.presetName, 'Weekend Binge');
    expect(
      typed.filters.toQueryParameters()['with_networks'],
      contains('213'),
    );
  });
}
