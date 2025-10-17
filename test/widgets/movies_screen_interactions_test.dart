import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:allmovies_mobile/data/models/movie.dart';
import 'package:allmovies_mobile/data/models/paginated_response.dart';
import 'package:allmovies_mobile/data/tmdb_repository.dart';
import 'package:allmovies_mobile/presentation/screens/movies/movies_filters_screen.dart';
import 'package:allmovies_mobile/presentation/screens/movies/movies_screen.dart';
import 'package:allmovies_mobile/providers/movies_provider.dart';
import 'package:allmovies_mobile/providers/watch_region_provider.dart';
import 'package:allmovies_mobile/core/localization/app_localizations.dart';

import '../test_utils/pump_app.dart';

class _FakeRepo extends TmdbRepository {
  @override
  Future<List<Movie>> fetchTrendingMovies({
    String timeWindow = 'day',
    bool forceRefresh = false,
  }) async => [Movie(id: 1, title: 'Trending Movie')];

  @override
  Future<List<Movie>> fetchNowPlayingMovies({int page = 1}) async => [
        Movie(id: 2, title: 'Now Playing Movie'),
      ];

  @override
  Future<List<Movie>> fetchPopularMovies({
    int page = 1,
    bool forceRefresh = false,
  }) async => [Movie(id: 3, title: 'Popular Movie')];

  @override
  Future<List<Movie>> fetchTopRatedMovies({
    int page = 1,
    bool forceRefresh = false,
  }) async => [Movie(id: 4, title: 'Top Rated Movie')];

  @override
  Future<List<Movie>> fetchUpcomingMovies({int page = 1}) async => [
        Movie(id: 5, title: 'Upcoming Movie'),
      ];

  @override
  Future<PaginatedResponse<Movie>> discoverMovies({
    int page = 1,
    discoverFilters,
    Map<String, String>? filters,
    bool forceRefresh = false,
  }) async => PaginatedResponse<Movie>(
        page: 1,
        totalPages: 1,
        totalResults: 1,
        results: [Movie(id: 6, title: 'Discover Movie')],
      );
}

Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
  if (settings.name == MoviesFiltersScreen.routeName) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => const MoviesFiltersScreen(),
      fullscreenDialog: true,
    );
  }
  return null;
}

void main() {
  const delegates = <LocalizationsDelegate<dynamic>>[
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  Future<void> _pumpMoviesScreen(
    WidgetTester tester,
    MoviesProvider provider,
  ) {
    return pumpApp(
      tester,
      const MoviesScreen(),
      providers: [ChangeNotifierProvider.value(value: provider)],
      localizationsDelegates: delegates,
      onGenerateRoute: _onGenerateRoute,
    );
  }

  testWidgets(
    'MoviesScreen filter button opens filters and applying selects Discover',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final moviesProvider = MoviesProvider(
        _FakeRepo(),
        regionProvider: WatchRegionProvider(prefs),
      );

      await _pumpMoviesScreen(tester, moviesProvider);
      expect(find.byType(MoviesScreen), findsOneWidget);
      expect(find.text('Trending Movie'), findsOneWidget);

      await tester.tap(find.byTooltip('Filters'));
      await tester.pumpAndSettle();
      expect(find.byType(MoviesFiltersScreen), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('moviesApplyFilters')));
      await tester.pumpAndSettle();

      expect(find.byType(MoviesFiltersScreen), findsNothing);
      expect(find.text('Discover Movie'), findsOneWidget);
    },
  );

  testWidgets('MoviesScreen trending menu changes provider window', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final moviesProvider = MoviesProvider(
      _FakeRepo(),
      regionProvider: WatchRegionProvider(prefs),
    );

    await _pumpMoviesScreen(tester, moviesProvider);
    expect(moviesProvider.trendingWindow, 'day');

    await tester.tap(find.byIcon(Icons.schedule));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Trending: Week'));
    await tester.pumpAndSettle();

    expect(moviesProvider.trendingWindow, 'week');
  });

  testWidgets('Pager controls render and jump opens dialog', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final provider = MoviesProvider(
      _FakeRepo(),
      regionProvider: WatchRegionProvider(prefs),
    );

    await _pumpMoviesScreen(tester, provider);
    expect(find.textContaining('Page'), findsWidgets);

    await tester.tap(find.widgetWithText(OutlinedButton, 'Jump'));
    await tester.pumpAndSettle();
    expect(find.text('Jump to page'), findsOneWidget);
  });

  testWidgets('Switching tabs reveals the matching movie lists', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final provider = MoviesProvider(
      _FakeRepo(),
      regionProvider: WatchRegionProvider(prefs),
    );

    await _pumpMoviesScreen(tester, provider);
    expect(find.text('Trending Movie'), findsOneWidget);

    await tester.tap(find.text('New Releases'));
    await tester.pumpAndSettle();
    expect(find.text('Now Playing Movie'), findsOneWidget);

    await tester.tap(find.text('Popular'));
    await tester.pumpAndSettle();
    expect(find.text('Popular Movie'), findsOneWidget);
  });
}
