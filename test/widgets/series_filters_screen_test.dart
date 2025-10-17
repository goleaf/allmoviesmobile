import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  });
}
