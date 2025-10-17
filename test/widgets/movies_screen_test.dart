import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:allmovies_mobile/data/models/movie.dart';
import 'package:allmovies_mobile/data/models/paginated_response.dart';
import 'package:allmovies_mobile/data/tmdb_repository.dart';
import 'package:allmovies_mobile/providers/movies_provider.dart';
import 'package:allmovies_mobile/providers/watch_region_provider.dart';
import 'package:allmovies_mobile/presentation/screens/movies/movies_screen.dart';
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

void main() {
  const delegates = <LocalizationsDelegate<dynamic>>[
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  testWidgets('MoviesScreen builds with providers and localized tabs', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await pumpApp(
      tester,
      const MoviesScreen(),
      providers: [
        ChangeNotifierProvider(
          create: (_) => MoviesProvider(
            _FakeRepo(),
            regionProvider: WatchRegionProvider(prefs),
          ),
        ),
      ],
      localizationsDelegates: delegates,
    );

    expect(find.byType(MoviesScreen), findsOneWidget);
    expect(find.byType(TabBar), findsOneWidget);
    expect(find.text('Trending'), findsWidgets);
  });
}
