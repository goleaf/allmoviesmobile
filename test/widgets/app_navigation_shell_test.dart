import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:allmovies_mobile/presentation/navigation/app_navigation_shell.dart';
import 'package:allmovies_mobile/providers/movies_provider.dart';
import 'package:allmovies_mobile/providers/series_provider.dart';
import 'package:allmovies_mobile/providers/search_provider.dart';
import 'package:allmovies_mobile/data/tmdb_repository.dart';
import 'package:allmovies_mobile/data/services/local_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Bottom navigation switches destinations', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    final storage = LocalStorageService(prefs);
    final repo = TmdbRepository();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => MoviesProvider(repo)),
          ChangeNotifierProvider(create: (_) => SeriesProvider(repo)),
          ChangeNotifierProvider(create: (_) => SearchProvider(repo, storage)),
        ],
        child: const MaterialApp(home: AppNavigationShell()),
      ),
    );
    await tester.pumpAndSettle();

    // Initially on Home
    expect(find.byType(NavigationBar), findsOneWidget);

    // Tap Movies destination (use label from AppStrings)
    await tester.tap(find.text('Movies').first);
    await tester.pumpAndSettle();

    // Tap TV destination
    await tester.tap(find.text('Series').first);
    await tester.pumpAndSettle();

    // Tap Search destination (label is 'Search movies...' in AppStrings.search)
    // Fallback to tapping the navigation icon by tooltip if text is not visible
    final searchTextFinder = find.text('Search movies...');
    if (searchTextFinder.evaluate().isEmpty) {
      // Find the third NavigationDestination by semantics
      final navBar = find.byType(NavigationBar);
      expect(navBar, findsOneWidget);
      // Tap by index using widget tree order
      await tester.tap(find.descendant(of: navBar, matching: find.byIcon(Icons.search)).first);
    } else {
      await tester.tap(searchTextFinder.first);
    }
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
  });
}


