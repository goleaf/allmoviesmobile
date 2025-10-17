import 'package:allmovies_mobile/data/services/local_storage_service.dart';
import 'package:allmovies_mobile/data/tmdb_repository.dart';
import 'package:allmovies_mobile/data/services/static_catalog_service.dart';
import 'package:allmovies_mobile/main.dart';
import 'package:allmovies_mobile/presentation/screens/movies/movies_screen.dart';
import 'package:allmovies_mobile/presentation/screens/splash_preload/splash_preload_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:isar/isar.dart';

class _FakeRepo extends TmdbRepository {}

class _FakeCatalogServiceFirstRun extends StaticCatalogService {
  _FakeCatalogServiceFirstRun(TmdbRepository repo) : super(repo);
  @override
  Future<bool> isFirstRun(Isar isar) async => true;
  @override
  Future<bool> needsRefresh(Isar isar, List<Locale> locales) async => true;
  @override
  Future<void> preloadAll({required List<Locale> locales, required void Function(PreloadProgress p) onProgress}) async {}
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('First run shows SplashPreload then navigates to MoviesScreen', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    final repo = _FakeRepo();
    final app = AllMoviesApp(
      storageService: LocalStorageService(prefs),
      prefs: prefs,
      tmdbRepository: repo,
      catalogService: _FakeCatalogServiceFirstRun(repo),
    );

    await tester.pumpWidget(app);

    // Should navigate into splash
    await _pumpUntilFound(tester, find.byType(SplashPreloadScreen));
    expect(find.byType(SplashPreloadScreen), findsOneWidget);

    // After preload completes, should navigate to MoviesScreen
    await _pumpUntilFound(tester, find.byType(MoviesScreen), timeout: const Duration(seconds: 5));
    expect(find.byType(MoviesScreen), findsOneWidget);
  });
}

Future<void> _pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 3),
  Duration interval = const Duration(milliseconds: 50),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    if (finder.evaluate().isNotEmpty) return;
    await tester.pump(interval);
  }
  await tester.pump();
  if (finder.evaluate().isNotEmpty) return;
  throw TestFailure('Widget not found within ${timeout.inMilliseconds}ms: $finder');
}


