import 'package:allmovies_mobile/data/services/local_storage_service.dart';
import 'package:allmovies_mobile/data/tmdb_repository.dart';
import 'package:allmovies_mobile/data/services/static_catalog_service.dart';
import 'package:allmovies_mobile/main.dart';
import 'package:allmovies_mobile/presentation/screens/movies/movies_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeRepo extends TmdbRepository {}

class FakeCatalogService extends StaticCatalogService {
  FakeCatalogService(TmdbRepository repo) : super(repo);
  @override
  Future<bool> isFirstRun(Isar isar) async => false;
  @override
  Future<bool> needsRefresh(Isar isar, List<Locale> locales) async => false;
  @override
  Future<void> preloadAll({required List<Locale> locales, required void Function(PreloadProgress p) onProgress}) async {}
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Boot navigates to MoviesScreen when not first run', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    final app = AllMoviesApp(
      storageService: LocalStorageService(prefs),
      prefs: prefs,
      tmdbRepository: FakeRepo(),
      catalogService: FakeCatalogService(FakeRepo()),
    );
    await tester.pumpWidget(app);
    await tester.pumpAndSettle(const Duration(seconds: 1));
    // We expect to eventually land on MoviesScreen route
    // Note: SplashPreload may push replace, so settle
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(MoviesScreen), findsOneWidget);
  });
}


