import 'package:allmovies_mobile/main.dart';
import 'package:allmovies_mobile/presentation/screens/movies/movies_screen.dart';
import 'package:allmovies_mobile/presentation/screens/series/series_screen.dart';
import 'package:allmovies_mobile/presentation/screens/search/search_screen.dart';
import 'package:allmovies_mobile/presentation/screens/companies/companies_screen.dart';
import 'package:allmovies_mobile/presentation/screens/movies/movies_filters_screen.dart';
import 'package:allmovies_mobile/presentation/screens/series/series_filters_screen.dart';
import 'package:allmovies_mobile/presentation/widgets/media_image.dart';
import 'package:allmovies_mobile/data/tmdb_repository.dart';
import 'package:allmovies_mobile/data/services/static_catalog_service.dart';
import 'package:isar/isar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:allmovies_mobile/data/services/local_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeRepo extends TmdbRepository {}

class _FakeCatalogService extends StaticCatalogService {
  _FakeCatalogService(TmdbRepository repo) : super(repo);
  @override
  Future<bool> isFirstRun(Isar isar) async => false;
  @override
  Future<bool> needsRefresh(Isar isar, List<Locale> locales) async => false;
  @override
  Future<void> preloadAll({required List<Locale> locales, required void Function(PreloadProgress p) onProgress}) async {}
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Smoke: routes load, images render, modal opens', (tester) async {
    // Avoid IO in tests from google_fonts
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();

    // Boot app
    await tester.pumpWidget(AllMoviesApp(
      storageService: LocalStorageService(prefs),
      prefs: prefs,
      tmdbRepository: _FakeRepo(),
      catalogService: _FakeCatalogService(_FakeRepo()),
    ));

    // Wait for initial route (Movies)
    await _pumpUntilFound(tester, find.byType(MoviesScreen), timeout: const Duration(seconds: 8));
    expect(find.byType(MoviesScreen), findsOneWidget);

    // Navigate to Series via Navigator to ensure route works
    await tester.runAsync(() async {
      Navigator.of(tester.element(find.byType(MoviesScreen))).pushNamed(SeriesScreen.routeName);
    });
    await _pumpUntilFound(tester, find.byType(SeriesScreen), timeout: const Duration(seconds: 8));
    expect(find.byType(SeriesScreen), findsOneWidget);

    // Navigate to Search
    await tester.runAsync(() async {
      Navigator.of(tester.element(find.byType(SeriesScreen))).pushNamed(SearchScreen.routeName);
    });
    await _pumpUntilFound(tester, find.byType(SearchScreen), timeout: const Duration(seconds: 8));
    expect(find.byType(SearchScreen), findsOneWidget);

    // Navigate to Companies and open modal bottom sheet (if available via provider flow, open directly)
    await tester.runAsync(() async {
      Navigator.of(tester.element(find.byType(SearchScreen))).pushNamed(CompaniesScreen.routeName);
    });
    await _pumpUntilFound(tester, find.byType(CompaniesScreen), timeout: const Duration(seconds: 8));
    expect(find.byType(CompaniesScreen), findsOneWidget);

    // Attempt to open a modal bottom sheet by calling showModalBottomSheet on the current context
    final ctx = tester.element(find.byType(CompaniesScreen));
    await tester.runAsync(() async {
      await showModalBottomSheet<void>(
        context: ctx,
        builder: (_) => const SizedBox(height: 120, child: Center(child: Text('Modal OK'))),
      );
    });
    // Ensure the modal animates and closes
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
    await _pumpUntilFound(tester, find.byType(MediaImage), timeout: const Duration(seconds: 8));
    expect(find.byType(MediaImage), findsOneWidget);

    // Navigate to filters routes to ensure they are registered
    await tester.runAsync(() async {
      Navigator.of(tester.element(find.byType(Scaffold).first)).pushNamed(MoviesFiltersScreen.routeName);
    });
    await _pumpUntilFound(tester, find.byType(MoviesFiltersScreen), timeout: const Duration(seconds: 8));
    expect(find.byType(MoviesFiltersScreen), findsOneWidget);

    await tester.runAsync(() async {
      Navigator.of(tester.element(find.byType(MoviesFiltersScreen))).pushNamed(SeriesFiltersScreen.routeName);
    });
    await _pumpUntilFound(tester, find.byType(SeriesFiltersScreen), timeout: const Duration(seconds: 8));
    expect(find.byType(SeriesFiltersScreen), findsOneWidget);
  });
}


Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 5),
  Duration interval = const Duration(milliseconds: 50),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    if (finder.evaluate().isNotEmpty) return;
    await tester.pump(interval);
  }
  await tester.pump();
  if (finder.evaluate().isNotEmpty) return;
  throw TestFailure('Widget not found within \\${timeout.inMilliseconds}ms: $finder');
}
