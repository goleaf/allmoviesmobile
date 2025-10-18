import 'dart:async';

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
import 'package:allmovies_mobile/presentation/widgets/loading_indicator.dart';
import 'package:allmovies_mobile/data/models/search_filters.dart';

import '../test_utils/pump_app.dart';

class _FakeRepo extends TmdbRepository {
  _FakeRepo({this.searchCompleter});

  final Completer<PaginatedResponse<Movie>>? searchCompleter;

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

  @override
  Future<PaginatedResponse<Movie>> searchMovies(
    String query, {
    int page = 1,
    MovieSearchFilters? filters,
    bool forceRefresh = false,
  }) async {
    if (searchCompleter != null && !searchCompleter!.isCompleted) {
      return searchCompleter!.future;
    }
    return PaginatedResponse<Movie>(
      page: 1,
      totalPages: 1,
      totalResults: 1,
      results: [Movie(id: 7, title: 'Search Movie')],
    );
  }
}

class _ManualMoviesProvider extends MoviesProvider {
  _ManualMoviesProvider(
    TmdbRepository repo, {
    required WatchRegionProvider regionProvider,
  }) : super(
          repo,
          regionProvider: regionProvider,
          autoInitialize: false,
        );

  @override
  Future<void> refresh({bool force = false}) async {}
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

  testWidgets('Movies list shows shimmer skeleton while loading', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final provider = _ManualMoviesProvider(
      _FakeRepo(),
      regionProvider: WatchRegionProvider(prefs),
    );

    provider.sections[MovieSection.trending] =
        provider.sectionState(MovieSection.trending)
            .copyWith(isLoading: true, items: const <Movie>[]);
    provider.notifyListeners();

    await pumpApp(
      tester,
      const MoviesScreen(),
      providers: [ChangeNotifierProvider.value(value: provider)],
      localizationsDelegates: delegates,
    );

    await tester.pump();

    expect(find.byType(ShimmerLoading), findsWidgets);
    expect(find.byIcon(Icons.movie_filter_outlined), findsNothing);
  });

  testWidgets('Search mode fades from skeleton to results', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final searchCompleter = Completer<PaginatedResponse<Movie>>();
    final provider = _ManualMoviesProvider(
      _FakeRepo(searchCompleter: searchCompleter),
      regionProvider: WatchRegionProvider(prefs),
    );

    provider.sections[MovieSection.trending] = const MovieSectionState(
      items: [Movie(id: 1, title: 'Trending Movie')],
    );
    provider.notifyListeners();

    await pumpApp(
      tester,
      const MoviesScreen(),
      providers: [ChangeNotifierProvider.value(value: provider)],
      localizationsDelegates: delegates,
    );

    await tester.pump();

    await tester.enterText(find.byType(TextField), 'query');
    await tester.pump();

    expect(find.byType(ShimmerLoading), findsWidgets);

    searchCompleter.complete(
      PaginatedResponse<Movie>(
        page: 1,
        totalPages: 1,
        totalResults: 1,
        results: [Movie(id: 9, title: 'Search Result')],
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('Search Result'), findsOneWidget);
    expect(find.byType(ShimmerLoading), findsNothing);
  });
}
