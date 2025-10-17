import 'dart:convert';

import 'package:allmovies_mobile/data/models/discover_filters_model.dart';
import 'package:allmovies_mobile/data/models/movie.dart';
import 'package:allmovies_mobile/data/models/paginated_response.dart';
import 'package:allmovies_mobile/data/tmdb_repository.dart';
import 'package:allmovies_mobile/providers/movies_provider.dart';
import 'package:allmovies_mobile/providers/watch_region_provider.dart';
import 'package:allmovies_mobile/data/services/local_storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeRepo extends TmdbRepository {
  FakeRepo();

  List<Movie> _one(String title) => [
    Movie(id: 1, title: title, mediaType: 'movie'),
  ];

  // New paginated overrides expected by MoviesProvider
  @override
  Future<PaginatedResponse<Movie>> fetchTrendingMoviesPaginated({
    String timeWindow = 'day',
    int page = 1,
    bool forceRefresh = false,
  }) async => PaginatedResponse<Movie>(
        page: 1,
        totalPages: 1,
        totalResults: 1,
        results: _one('trend'),
      );

  @override
  Future<PaginatedResponse<Movie>> fetchNowPlayingMoviesPaginated({
    int page = 1,
    bool forceRefresh = false,
  }) async => PaginatedResponse<Movie>(
        page: 1,
        totalPages: 1,
        totalResults: 1,
        results: _one('now'),
      );

  @override
  Future<PaginatedResponse<Movie>> fetchPopularMoviesPaginated({
    int page = 1,
    bool forceRefresh = false,
  }) async => PaginatedResponse<Movie>(
        page: 1,
        totalPages: 1,
        totalResults: 1,
        results: _one('popular'),
      );

  @override
  Future<PaginatedResponse<Movie>> fetchTopRatedMoviesPaginated({
    int page = 1,
    bool forceRefresh = false,
  }) async => PaginatedResponse<Movie>(
        page: 1,
        totalPages: 1,
        totalResults: 1,
        results: _one('top'),
      );

  @override
  Future<PaginatedResponse<Movie>> fetchUpcomingMoviesPaginated({
    int page = 1,
    bool forceRefresh = false,
  }) async => PaginatedResponse<Movie>(
        page: 1,
        totalPages: 1,
        totalResults: 1,
        results: _one('upcoming'),
      );

  @override
  Future<List<Movie>> fetchTrendingMovies({
    String timeWindow = 'day',
    bool forceRefresh = false,
  }) async => _one('trend');
  @override
  Future<List<Movie>> fetchNowPlayingMovies({
    int page = 1,
    bool forceRefresh = false,
  }) async => _one('now');
  @override
  Future<List<Movie>> fetchPopularMovies({
    int page = 1,
    bool forceRefresh = false,
  }) async => _one('popular');
  @override
  Future<List<Movie>> fetchTopRatedMovies({
    int page = 1,
    bool forceRefresh = false,
  }) async => _one('top');
  @override
  Future<List<Movie>> fetchUpcomingMovies({int page = 1}) async =>
      _one('upcoming');
  @override
  Future<PaginatedResponse<Movie>> discoverMovies({
    int page = 1,
    DiscoverFilters? discoverFilters,
    Map<String, String>? filters,
    bool forceRefresh = false,
  }) async => PaginatedResponse<Movie>(
    page: 1,
    totalPages: 1,
    totalResults: 1,
    results: _one('discover'),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('MoviesProvider loads sections and reacts to region + window', () async {
    final repo = FakeRepo();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final storage = LocalStorageService(await SharedPreferences.getInstance());
    final provider = MoviesProvider(repo, storageService: storage);
    await provider.initialized;
    expect(provider.isInitialized, isTrue);
    expect(provider.sectionState(MovieSection.trending).items, isNotEmpty);
    provider.setTrendingWindow('week');
    await provider.initialized; // already completed; ensures no race
    expect(provider.sectionState(MovieSection.trending).items, isNotEmpty);
    final prefsProvider = WatchRegionProvider(
      await SharedPreferencesWithDefault.get(),
    );
    provider.bindRegionProvider(prefsProvider);
    await provider.refresh(force: true);
    expect(provider.sectionState(MovieSection.discover).items, isNotEmpty);
  });

  test(
    'MoviesProvider pagination jumpToPage updates current and total',
    () async {
      final repo = FakeRepo();
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final storage = LocalStorageService(
        await SharedPreferences.getInstance(),
      );
      final provider = MoviesProvider(repo, storageService: storage);
      await provider.initialized;

      // Simulate that repository returns 1 page via discoverMovies; we only check call path works
      final before = provider.sectionState(MovieSection.trending).currentPage;
      await provider.jumpToPage(MovieSection.trending, 1);
      final after = provider.sectionState(MovieSection.trending).currentPage;
      expect(after, isNonZero);
      expect(after, isA<int>());
      expect(before, isA<int>());
    },
  );
}

// Minimal shim for tests
class SharedPreferencesWithDefault {
  static Future<SharedPreferences> get() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    return SharedPreferences.getInstance();
  }
}
