import 'package:allmovies_mobile/core/localization/app_localizations.dart';
import 'package:allmovies_mobile/data/models/movie_detailed_model.dart';
import 'package:allmovies_mobile/data/models/saved_media_item.dart';
import 'package:allmovies_mobile/data/services/local_storage_service.dart';
import 'package:allmovies_mobile/data/tmdb_repository.dart';
import 'package:allmovies_mobile/presentation/screens/favorites/favorites_screen.dart';
import 'package:allmovies_mobile/providers/favorites_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test_support/fake_tmdb_repository.dart';
import '../test_utils/pump_app.dart';

class _TestFavoritesProvider extends FavoritesProvider {
  _TestFavoritesProvider(LocalStorageService storage) : super(storage);

  int refreshCount = 0;

  @override
  Future<void> refresh() async {
    refreshCount++;
    return super.refresh();
  }
}

Future<void> _pumpFavoritesScreen(
  WidgetTester tester, {
  required FavoritesProvider provider,
  required TmdbRepository repository,
}) {
  return pumpApp(
    tester,
    const FavoritesScreen(),
    providers: [
      ChangeNotifierProvider<FavoritesProvider>.value(value: provider),
      Provider<TmdbRepository>.value(value: repository),
    ],
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
  );
}

MovieDetailed _movie(int id, String title) {
  return MovieDetailed(
    id: id,
    title: title,
    originalTitle: title,
    voteAverage: 8.5,
    voteCount: 1000,
    releaseDate: '2023-01-01',
    runtime: 120,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FavoritesScreen', () {
    testWidgets('dismissible removes favorite item', (tester) async {
      final savedItem = SavedMediaItem(
        id: 101,
        type: SavedMediaType.movie,
        title: 'Sample Favorite',
        addedAt: DateTime(2023, 1, 1),
      );

      SharedPreferences.setMockInitialValues({
        'allmovies_favorites': SavedMediaItem.encodeList([savedItem]),
      });
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs);
      final provider = FavoritesProvider(storage);
      final repository = FakeTmdbRepository(movies: {101: _movie(101, 'Sample Favorite')});

      await _pumpFavoritesScreen(
        tester,
        provider: provider,
        repository: repository,
      );
      await tester.pumpAndSettle();

      expect(find.text('Sample Favorite'), findsOneWidget);

      await tester.drag(find.byType(Dismissible).first, const Offset(-500, 0));
      await tester.pumpAndSettle();

      expect(provider.favoriteItems, isEmpty);
    });

    testWidgets('pull to refresh invokes provider refresh', (tester) async {
      final savedItem = SavedMediaItem(
        id: 202,
        type: SavedMediaType.movie,
        title: 'Another Favorite',
        addedAt: DateTime(2023, 1, 1),
      );

      SharedPreferences.setMockInitialValues({
        'allmovies_favorites': SavedMediaItem.encodeList([savedItem]),
      });
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs);
      final provider = _TestFavoritesProvider(storage);
      final repository = FakeTmdbRepository(movies: {202: _movie(202, 'Another Favorite')});

      await _pumpFavoritesScreen(
        tester,
        provider: provider,
        repository: repository,
      );
      await tester.pumpAndSettle();

      expect(provider.refreshCount, 0);

      await tester.drag(find.byType(ListView).first, const Offset(0, 300));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(provider.refreshCount, 1);
    });
  });
}
