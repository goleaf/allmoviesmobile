import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:allmovies_mobile/data/services/cache_service.dart';
import 'package:allmovies_mobile/data/services/local_storage_service.dart';
import 'package:allmovies_mobile/data/tmdb_repository.dart';
import 'package:allmovies_mobile/data/models/movie.dart';
import 'package:allmovies_mobile/data/models/movie_detailed_model.dart';
import 'package:allmovies_mobile/data/models/image_model.dart';
import 'package:allmovies_mobile/data/models/media_images.dart';
import 'package:allmovies_mobile/data/models/paginated_response.dart';

class FakeHttpClient extends http.BaseClient {
  FakeHttpClient({this.onSend});

  final Future<http.StreamedResponse> Function(http.BaseRequest request)? onSend;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (onSend != null) {
      return onSend!(request);
    }
    return http.StreamedResponse(Stream<List<int>>.value(<int>[]), 200);
  }
}

class FakeTmdbRepository extends TmdbRepository {
  FakeTmdbRepository({http.Client? client, CacheService? cache})
      : super(client: client, cacheService: cache, apiKey: 'test');

  static const String _fixturesDir = 'test/test_support/fixtures';

  Future<Map<String, dynamic>> _readJsonFixture(String filename) async {
    final file = File('$_fixturesDir/$filename');
    final contents = await file.readAsString();
    return jsonDecode(contents) as Map<String, dynamic>;
  }

  List<T> _mapList<T>(List<dynamic> list, T Function(Map<String, dynamic>) mapper) {
    return list
        .whereType<Map<String, dynamic>>()
        .map<T>(mapper)
        .toList(growable: false);
  }

  @override
  Future<PaginatedResponse<Movie>> fetchTrendingTitles({
    String mediaType = 'all',
    String timeWindow = 'day',
    int page = 1,
    bool forceRefresh = false,
  }) async {
    // Use movie trending fixture for simplicity; adequate for UI tests
    final json = await _readJsonFixture('trending_movie_${timeWindow}_page$page.json');
    final results = (json['results'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map((raw) => Movie.fromJson(
              raw,
              mediaType: mediaType == 'tv'
                  ? 'tv'
                  : (mediaType == 'person' ? 'person' : 'movie'),
            ))
        .toList(growable: false);

    return PaginatedResponse<Movie>(
      page: json['page'] is int ? json['page'] as int : int.tryParse('${json['page']}') ?? 1,
      totalPages: json['total_pages'] is int
          ? json['total_pages'] as int
          : int.tryParse('${json['total_pages']}') ?? 1,
      totalResults: json['total_results'] is int
          ? json['total_results'] as int
          : int.tryParse('${json['total_results']}') ?? results.length,
      results: results,
    );
  }

  @override
  Future<List<Movie>> fetchTrendingMovies({String timeWindow = 'day', bool forceRefresh = false}) async {
    final page1 = await fetchTrendingTitles(mediaType: 'movie', timeWindow: timeWindow, page: 1);
    return page1.results;
  }

  @override
  Future<MovieDetailed> fetchMovieDetails(int movieId, {bool forceRefresh = false}) async {
    final json = await _readJsonFixture('movie_${movieId}_details.json');
    return MovieDetailed.fromJson(json);
  }

  @override
  Future<MediaImages> fetchMovieImages(int movieId, {bool forceRefresh = false}) async {
    final json = await _readJsonFixture('movie_${movieId}_images.json');
    List<ImageModel> mapImages(String key) {
      final list = json[key];
      if (list is! List) return const [];
      return _mapList<ImageModel>(list, ImageModel.fromJson);
    }

    return MediaImages(
      posters: mapImages('posters'),
      backdrops: mapImages('backdrops'),
      stills: mapImages('profiles'),
    );
  }
}

class InMemoryPrefs implements SharedPreferences {
  final Map<String, Object> _data = {};

  @override
  Set<String> getKeys() => _data.keys.toSet();

  @override
  Object? get(String key) => _data[key];

  @override
  bool containsKey(String key) => _data.containsKey(key);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

LocalStorageService makeLocalStorageWithMockPrefs() {
  SharedPreferences.setMockInitialValues({});
  // ignore: invalid_use_of_visible_for_testing_member
  // ignore: invalid_use_of_internal_member
  final prefs = SharedPreferences.getInstance();
  throw UnimplementedError('Use SharedPreferences.setMockInitialValues in tests');
}


