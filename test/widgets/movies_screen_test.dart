import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:allmovies_mobile/data/models/movie.dart';
import 'package:allmovies_mobile/data/models/paginated_response.dart';
import 'package:allmovies_mobile/data/tmdb_repository.dart';
import 'package:allmovies_mobile/providers/movies_provider.dart';
import 'package:allmovies_mobile/providers/watch_region_provider.dart';
import 'package:allmovies_mobile/presentation/screens/movies/movies_screen.dart';

class _FakeRepo extends TmdbRepository {
  @override
  Future<List<Movie>> fetchTrendingMovies({
    String timeWindow = 'day',
    bool forceRefresh = false,
  }) async => [Movie(id: 1, title: 'A')];
  @override
  Future<List<Movie>> fetchNowPlayingMovies({int page = 1}) async => [
    Movie(id: 2, title: 'B'),
  ];
  @override
  Future<List<Movie>> fetchPopularMovies({
    int page = 1,
    bool forceRefresh = false,
  }) async => [Movie(id: 3, title: 'C')];
  @override
  Future<List<Movie>> fetchTopRatedMovies({
    int page = 1,
    bool forceRefresh = false,
  }) async => [Movie(id: 4, title: 'D')];
  @override
  Future<List<Movie>> fetchUpcomingMovies({int page = 1}) async => [
    Movie(id: 5, title: 'E'),
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
    results: [Movie(id: 6, title: 'F')],
  );
}

void main() {
  testWidgets('MoviesScreen builds with providers and tabs', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => MoviesProvider(
              _FakeRepo(),
              regionProvider: WatchRegionProvider(prefs),
            ),
          ),
        ],
        child: const MaterialApp(home: MoviesScreen()),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(MoviesScreen), findsOneWidget);
    expect(find.byType(TabBar), findsOneWidget);
  });
}
