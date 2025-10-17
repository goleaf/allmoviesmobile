import 'dart:convert';

import 'package:allmovies_mobile/data/models/discover_filters_model.dart';
import 'package:allmovies_mobile/data/models/movie.dart';
import 'package:allmovies_mobile/data/models/paginated_response.dart';
import 'package:allmovies_mobile/data/tmdb_repository.dart';
import 'package:allmovies_mobile/providers/movies_provider.dart';
import 'package:allmovies_mobile/providers/watch_region_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeRepo extends TmdbRepository {
  FakeRepo();

  List<Movie> _one(String title) => [Movie(id: 1, title: title, mediaType: 'movie')];

  @override
  Future<List<Movie>> fetchTrendingMovies({String timeWindow = 'day', bool forceRefresh = false}) async => _one('trend');
  @override
  Future<List<Movie>> fetchNowPlayingMovies({int page = 1, bool forceRefresh = false}) async => _one('now');
  @override
  Future<List<Movie>> fetchPopularMovies({int page = 1, bool forceRefresh = false}) async => _one('popular');
  @override
  Future<List<Movie>> fetchTopRatedMovies({int page = 1, bool forceRefresh = false}) async => _one('top');
  @override
  Future<List<Movie>> fetchUpcomingMovies({int page = 1}) async => _one('upcoming');
  @override
  Future<PaginatedResponse<Movie>> discoverMovies({int page = 1, DiscoverFilters? discoverFilters, Map<String, String>? filters, bool forceRefresh = false}) async =>
      PaginatedResponse<Movie>(page: 1, totalPages: 1, totalResults: 1, results: _one('discover'));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('MoviesProvider loads sections and reacts to region + window', () async {
    final repo = FakeRepo();
    final provider = MoviesProvider(repo);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(provider.isInitialized, isTrue);
    expect(provider.sectionState(MovieSection.trending).items, isNotEmpty);
    provider.setTrendingWindow('week');
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(provider.sectionState(MovieSection.trending).items, isNotEmpty);
    final prefsProvider = WatchRegionProvider(await SharedPreferencesWithDefault.get());
    provider.bindRegionProvider(prefsProvider);
    await provider.refresh(force: true);
    expect(provider.sectionState(MovieSection.discover).items, isNotEmpty);
  });
}

// Minimal shim for tests
class SharedPreferencesWithDefault {
  static Future<SharedPreferences> get() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    return SharedPreferences.getInstance();
  }
}


