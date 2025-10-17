import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:allmovies_mobile/presentation/screens/series/series_filters_screen.dart';
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
}
