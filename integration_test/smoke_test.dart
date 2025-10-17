import 'package:allmovies_mobile/main.dart';
import 'package:allmovies_mobile/presentation/screens/movies/movies_screen.dart';
import 'package:allmovies_mobile/presentation/screens/series/series_screen.dart';
import 'package:allmovies_mobile/presentation/screens/search/search_screen.dart';
import 'package:allmovies_mobile/presentation/screens/companies/companies_screen.dart';
import 'package:allmovies_mobile/presentation/screens/movies/movies_filters_screen.dart';
import 'package:allmovies_mobile/presentation/screens/series/series_filters_screen.dart';
import 'package:allmovies_mobile/presentation/widgets/media_image.dart';
import 'package:allmovies_mobile/data/tmdb_repository.dart';
import 'package:allmovies_mobile/data/services/local_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeRepo extends TmdbRepository {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Smoke: routes load, images render, modal opens', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();

    // Boot app
    await tester.pumpWidget(AllMoviesApp(
      storageService: LocalStorageService(prefs),
      prefs: prefs,
      tmdbRepository: _FakeRepo(),
    ));

    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Verify initial route (Movies)
    expect(find.byType(MoviesScreen), findsOneWidget);

    // Navigate to Series via Navigator to ensure route works
    await tester.runAsync(() async {
      Navigator.of(tester.element(find.byType(MoviesScreen))).pushNamed(SeriesScreen.routeName);
    });
    await tester.pumpAndSettle();
    expect(find.byType(SeriesScreen), findsOneWidget);

    // Navigate to Search
    await tester.runAsync(() async {
      Navigator.of(tester.element(find.byType(SeriesScreen))).pushNamed(SearchScreen.routeName);
    });
    await tester.pumpAndSettle();
    expect(find.byType(SearchScreen), findsOneWidget);

    // Navigate to Companies and open modal bottom sheet (if available via provider flow, open directly)
    await tester.runAsync(() async {
      Navigator.of(tester.element(find.byType(SearchScreen))).pushNamed(CompaniesScreen.routeName);
    });
    await tester.pumpAndSettle();
    expect(find.byType(CompaniesScreen), findsOneWidget);

    // Attempt to open a modal bottom sheet by calling showModalBottomSheet on the current context
    final ctx = tester.element(find.byType(CompaniesScreen));
    await tester.runAsync(() async {
      await showModalBottomSheet<void>(
        context: ctx,
        builder: (_) => const SizedBox(height: 120, child: Center(child: Text('Modal OK'))),
      );
    });
    await tester.pumpAndSettle();

    // Verify that a MediaImage can render (widget exists and builds). We inject it in a new route.
    await tester.runAsync(() async {
      Navigator.of(ctx).push(MaterialPageRoute(builder: (_) {
        return const Scaffold(
          body: Center(
            child: SizedBox(
              width: 100,
              height: 150,
              child: MediaImage(path: '/test.jpg'),
            ),
          ),
        );
      }));
    });
    await tester.pumpAndSettle();
    expect(find.byType(MediaImage), findsOneWidget);

    // Navigate to filters routes to ensure they are registered
    await tester.runAsync(() async {
      Navigator.of(tester.element(find.byType(Scaffold).first)).pushNamed(MoviesFiltersScreen.routeName);
    });
    await tester.pumpAndSettle();
    expect(find.byType(MoviesFiltersScreen), findsOneWidget);

    await tester.runAsync(() async {
      Navigator.of(tester.element(find.byType(MoviesFiltersScreen))).pushNamed(SeriesFiltersScreen.routeName);
    });
    await tester.pumpAndSettle();
    expect(find.byType(SeriesFiltersScreen), findsOneWidget);
  });
}


