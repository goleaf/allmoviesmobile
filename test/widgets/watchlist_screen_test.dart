import 'package:allmovies_mobile/core/localization/app_localizations.dart';
import 'package:allmovies_mobile/data/models/movie_detailed_model.dart';
import 'package:allmovies_mobile/data/models/saved_media_item.dart';
import 'package:allmovies_mobile/data/services/local_storage_service.dart';
import 'package:allmovies_mobile/data/tmdb_repository.dart';
import 'package:allmovies_mobile/presentation/screens/watchlist/watchlist_screen.dart';
import 'package:allmovies_mobile/providers/watchlist_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test_support/fake_tmdb_repository.dart';
import '../test_utils/pump_app.dart';

class _TestWatchlistProvider extends WatchlistProvider {
  _TestWatchlistProvider(LocalStorageService storage) : super(storage);

  int refreshCount = 0;

  @override
  Future<void> refresh() async {
    refreshCount++;
    return super.refresh();
  }
}

Future<void> _pumpWatchlistScreen(
  WidgetTester tester, {
  required WatchlistProvider provider,
  required TmdbRepository repository,
}) {
  return pumpApp(
    tester,
    const WatchlistScreen(),
    providers: [
      ChangeNotifierProvider<WatchlistProvider>.value(value: provider),
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
    voteAverage: 7.5,
    voteCount: 500,
    releaseDate: '2022-01-01',
    runtime: 130,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WatchlistScreen', () {
    testWidgets('dismissible removes watchlist item', (tester) async {
      final savedItem = SavedMediaItem(
        id: 303,
        type: SavedMediaType.movie,
        title: 'Sample Watchlist',
        addedAt: DateTime(2023, 1, 1),
      );

      SharedPreferences.setMockInitialValues({
        'allmovies_watchlist': SavedMediaItem.encodeList([savedItem]),
      });
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs);
      final provider = WatchlistProvider(storage);
      final repository = FakeTmdbRepository(movies: {303: _movie(303, 'Sample Watchlist')});

      await _pumpWatchlistScreen(
        tester,
        provider: provider,
        repository: repository,
      );
      await tester.pumpAndSettle();

      expect(find.text('Sample Watchlist'), findsOneWidget);

      await tester.drag(find.byType(Dismissible).first, const Offset(-500, 0));
      await tester.pumpAndSettle();

      expect(provider.watchlistItems, isEmpty);
    });

    testWidgets('pull to refresh invokes provider refresh', (tester) async {
      final savedItem = SavedMediaItem(
        id: 404,
        type: SavedMediaType.movie,
        title: 'Another Watchlist',
        addedAt: DateTime(2023, 1, 1),
      );

      SharedPreferences.setMockInitialValues({
        'allmovies_watchlist': SavedMediaItem.encodeList([savedItem]),
      });
      final prefs = await SharedPreferences.getInstance();
      final storage = LocalStorageService(prefs);
      final provider = _TestWatchlistProvider(storage);
      final repository = FakeTmdbRepository(movies: {404: _movie(404, 'Another Watchlist')});

      await _pumpWatchlistScreen(
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
