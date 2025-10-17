import 'package:allmovies_mobile/data/services/local_storage_service.dart';
import 'package:allmovies_mobile/data/tmdb_repository.dart';
// Use a minimal fake defined locally to avoid external test support imports
// static_catalog_service removed from app; tests no longer inject it
import 'package:allmovies_mobile/main.dart';
import 'package:allmovies_mobile/presentation/screens/movies/movies_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:isar/isar.dart';

class FakeRepo extends TmdbRepository {}

class FakeCatalogService {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Boot navigates to MoviesScreen when not first run', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    final app = AllMoviesApp(
      storageService: LocalStorageService(prefs),
      prefs: prefs,
      tmdbRepository: FakeRepo(),
      // catalogService no longer accepted
    );
    await tester.pumpWidget(app);
    await _pumpUntilFound(
      tester,
      find.byType(MoviesScreen),
      timeout: const Duration(seconds: 8),
      interval: const Duration(milliseconds: 100),
    );
    expect(find.byType(MoviesScreen), findsOneWidget);
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
  // One final pump to flush pending microtasks, then check again
  await tester.pump();
  if (finder.evaluate().isNotEmpty) return;
  throw TestFailure(
    'Widget not found within ${timeout.inMilliseconds}ms: $finder',
  );
}
