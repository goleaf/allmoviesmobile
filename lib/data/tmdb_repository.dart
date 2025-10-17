import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config/app_config.dart';
import 'models/collection_model.dart';
import 'models/company_model.dart';
import 'models/genre_model.dart';
import 'models/image_model.dart';
import 'models/keyword_model.dart';
import 'models/media_images.dart';
import 'models/movie.dart';
import 'models/movie_detailed_model.dart';
import 'models/network_detailed_model.dart';
import 'models/network_model.dart';
import 'models/paginated_response.dart';
import 'models/person_detail_model.dart';
import 'models/person_model.dart';
import 'models/search_result_model.dart';
import 'models/season_model.dart';
import 'models/tmdb_list_model.dart';
import 'models/tv_detailed_model.dart';
import 'models/watch_provider_model.dart';
import 'services/cache_service.dart';

class TmdbRepository {
  TmdbRepository({http.Client? client, String? apiKey})
      : _client = client ?? http.Client(),
        _apiKey = apiKey ?? const String.fromEnvironment('TMDB_API_KEY', defaultValue: '');

  static const _host = 'api.themoviedb.org';
  static const _basePath = '/3';

  final http.Client _client;
  final String _apiKey;

  void _checkApiKey() {
    if (_apiKey.isEmpty) {
      throw const TmdbException('TMDB API key is not configured.');
    }
  }

  Future<Map<String, dynamic>> _get(String endpoint, [Map<String, String>? queryParams]) async {
    _checkApiKey();

    final uri = Uri.https(_host, '$_basePath$endpoint', {
      'api_key': _apiKey,
      'language': 'en-US',
      if (queryParams != null) ...queryParams,
    });

    final response = await _client.get(uri, headers: {
      'Accept': 'application/json',
    });

    if (response.statusCode != 200) {
      throw TmdbException(
        'Request failed with status ${response.statusCode}',
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // Trending
  Future<PaginatedResponse<Movie>> fetchTrendingTitles({
    String mediaType = 'all',
    String timeWindow = 'day',
    int page = 1,
    bool forceRefresh = false,
  }) async {
    if (forceRefresh) {
      // No caching layer wired yet; parameter reserved for future use.
    }

    final payload = await _get(
      '/trending/$mediaType/$timeWindow',
      {
        'page': '$page',
      },
    );

    final response = PaginatedResponse<Movie>.fromJson(
      payload,
      (json) => Movie.fromJson(json),
    );

    return PaginatedResponse<Movie>(
      page: response.page,
      totalPages: response.totalPages,
      totalResults: response.totalResults,
      results: response.results
          .where((movie) => movie.title.isNotEmpty)
          .toList(growable: false),
    );
  }

  Future<List<Movie>> fetchTrendingMovies({
    String timeWindow = 'day',
    int page = 1,
  }) async {
    final payload = await _get('/trending/movie/$timeWindow', {'page': '$page'});
    final results = payload['results'];

    if (results is! List) {
      throw const TmdbException('Malformed TMDB response: missing results list.');
    }

    return results
        .whereType<Map<String, dynamic>>()
        .map(Movie.fromJson)
        .where((movie) => movie.title.isNotEmpty)
        .toList(growable: false);
  }

  // Movie Details
  Future<Map<String, dynamic>> fetchMovieDetails(int movieId) async {
    return await _get('/movie/$movieId', {'append_to_response': 'videos,images,credits,recommendations,similar'});
  }

  // Popular Movies
  Future<List<Movie>> fetchPopularMovies({int page = 1}) async {
    final payload = await _get('/movie/popular', {'page': '$page'});
    final results = payload['results'] as List?;

    if (results == null) return [];

    return results
        .whereType<Map<String, dynamic>>()
        .map(Movie.fromJson)
        .where((movie) => movie.title.isNotEmpty)
        .toList(growable: false);
  }

  // Top Rated Movies
  Future<List<Movie>> fetchTopRatedMovies({int page = 1}) async {
    final payload = await _get('/movie/top_rated', {'page': '$page'});
    final results = payload['results'] as List?;

    if (results == null) return [];

    return results
        .whereType<Map<String, dynamic>>()
        .map(Movie.fromJson)
        .where((movie) => movie.title.isNotEmpty)
        .toList(growable: false);
  }

  // Now Playing Movies
  Future<List<Movie>> fetchNowPlayingMovies({int page = 1}) async {
    final payload = await _get('/movie/now_playing', {'page': '$page'});
    final results = payload['results'] as List?;

    if (results == null) return [];

    return results
        .whereType<Map<String, dynamic>>()
        .map(Movie.fromJson)
        .where((movie) => movie.title.isNotEmpty)
        .toList(growable: false);
  }

  // Upcoming Movies
  Future<List<Movie>> fetchUpcomingMovies({int page = 1}) async {
    final payload = await _get('/movie/upcoming', {'page': '$page'});
    final results = payload['results'] as List?;

    if (results == null) return [];

    return results
        .whereType<Map<String, dynamic>>()
        .map(Movie.fromJson)
        .where((movie) => movie.title.isNotEmpty)
        .toList(growable: false);
  }

  // Search Movies
  Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    if (query.trim().isEmpty) return [];

    final payload = await _get('/search/movie', {
      'query': query,
      'page': '$page',
    });
    final results = payload['results'] as List?;

    if (results == null) return [];

    return results
        .whereType<Map<String, dynamic>>()
        .map(Movie.fromJson)
        .where((movie) => movie.title.isNotEmpty)
        .toList(growable: false);
  }

  // Search Multi (movies, TV, people)
  Future<List<Movie>> searchMulti(String query, {int page = 1}) async {
    if (query.trim().isEmpty) return [];

    final payload = await _get('/search/multi', {
      'query': query,
      'page': '$page',
    });
    final results = payload['results'] as List?;

    if (results == null) return [];

    return results
        .whereType<Map<String, dynamic>>()
        .map(Movie.fromJson)
        .where((movie) => movie.title.isNotEmpty)
        .toList(growable: false);
  }

  // Discover Movies with Filters
  Future<List<Movie>> discoverMovies({
    int page = 1,
    String? sortBy,
    List<int>? withGenres,
    int? year,
    double? voteAverageGte,
    double? voteAverageLte,
  }) async {
    final response = await discoverMoviesPaginated(
      page: page,
      sortBy: sortBy,
      withGenres: withGenres,
      year: year,
      voteAverageGte: voteAverageGte,
      voteAverageLte: voteAverageLte,
    );
    return response.results;
  }

  Future<PaginatedResponse<Movie>> discoverMoviesPaginated({
    int page = 1,
    String? sortBy,
    List<int>? withGenres,
    int? year,
    double? voteAverageGte,
    double? voteAverageLte,
  }) async {
    final queryParams = <String, String>{
      'page': '$page',
      if (sortBy != null) 'sort_by': sortBy,
      if (withGenres != null && withGenres.isNotEmpty)
        'with_genres': withGenres.join(','),
      if (year != null) 'year': '$year',
      if (voteAverageGte != null) 'vote_average.gte': '$voteAverageGte',
      if (voteAverageLte != null) 'vote_average.lte': '$voteAverageLte',
    };

    final payload = await _get('/discover/movie', queryParams);
    final response = PaginatedResponse<Movie>.fromJson(
      payload,
      (json) => Movie.fromJson(json),
    );

    return PaginatedResponse<Movie>(
      page: response.page,
      totalPages: response.totalPages,
      totalResults: response.totalResults,
      results: response.results
          .where((movie) => movie.title.isNotEmpty)
          .toList(growable: false),
    );
  }

  // Genres
  Future<List<Genre>> fetchMovieGenres() async {
    final payload = await _get('/genre/movie/list');
    final genres = payload['genres'] as List?;

    if (genres == null) return [];

    return genres
        .whereType<Map<String, dynamic>>()
        .map(Genre.fromJson)
        .toList(growable: false);
  }

  Future<List<Genre>> fetchTVGenres() async {
    final payload = await _get('/genre/tv/list');
    final genres = payload['genres'] as List?;

    if (genres == null) return [];

    return genres
        .whereType<Map<String, dynamic>>()
        .map(Genre.fromJson)
        .toList(growable: false);
  }

  // TV
  Future<List<Movie>> fetchTrendingTv({
    String timeWindow = 'day',
    int page = 1,
  }) async {
    final payload = await _get('/trending/tv/$timeWindow', {'page': '$page'});
    final results = payload['results'] as List?;

    if (results == null) return [];

    return results
        .whereType<Map<String, dynamic>>()
        .map(Movie.fromJson)
        .where((show) => show.title.isNotEmpty)
        .toList(growable: false);
  }

  Future<List<Movie>> fetchPopularTv({int page = 1}) async {
    final payload = await _get('/tv/popular', {'page': '$page'});
    final results = payload['results'] as List?;

    if (results == null) return [];

    return results
        .whereType<Map<String, dynamic>>()
        .map(Movie.fromJson)
        .where((show) => show.title.isNotEmpty)
        .toList(growable: false);
  }

  Future<List<Movie>> fetchTopRatedTv({int page = 1}) async {
    final payload = await _get('/tv/top_rated', {'page': '$page'});
    final results = payload['results'] as List?;

    if (results == null) return [];

    return results
        .whereType<Map<String, dynamic>>()
        .map(Movie.fromJson)
        .where((show) => show.title.isNotEmpty)
        .toList(growable: false);
  }

  Future<List<Movie>> fetchAiringTodayTv({int page = 1}) async {
    final payload = await _get('/tv/airing_today', {'page': '$page'});
    final results = payload['results'] as List?;

    if (results == null) return [];

    return results
        .whereType<Map<String, dynamic>>()
        .map(Movie.fromJson)
        .where((show) => show.title.isNotEmpty)
        .toList(growable: false);
  }

  Future<List<Movie>> fetchOnTheAirTv({int page = 1}) async {
    final payload = await _get('/tv/on_the_air', {'page': '$page'});
    final results = payload['results'] as List?;

    if (results == null) return [];

    return results
        .whereType<Map<String, dynamic>>()
        .map(Movie.fromJson)
        .where((show) => show.title.isNotEmpty)
        .toList(growable: false);
  }

  Future<PaginatedResponse<Movie>> discoverTvPaginated({
    int page = 1,
    String? sortBy,
    List<int>? withGenres,
    double? voteAverageGte,
    double? voteAverageLte,
    String? firstAirDateGte,
    String? firstAirDateLte,
  }) async {
    final queryParams = <String, String>{
      'page': '$page',
      if (sortBy != null) 'sort_by': sortBy,
      if (withGenres != null && withGenres.isNotEmpty)
        'with_genres': withGenres.join(','),
      if (voteAverageGte != null) 'vote_average.gte': '$voteAverageGte',
      if (voteAverageLte != null) 'vote_average.lte': '$voteAverageLte',
      if (firstAirDateGte != null) 'first_air_date.gte': firstAirDateGte,
      if (firstAirDateLte != null) 'first_air_date.lte': firstAirDateLte,
    };

    final payload = await _get('/discover/tv', queryParams);
    final response = PaginatedResponse<Movie>.fromJson(
      payload,
      (json) => Movie.fromJson(json),
    );

    return PaginatedResponse<Movie>(
      page: response.page,
      totalPages: response.totalPages,
      totalResults: response.totalResults,
      results: response.results
          .where((show) => show.title.isNotEmpty)
          .toList(growable: false),
    );
  }

  Future<List<Movie>> discoverTvShows({
    int page = 1,
    String? sortBy,
    List<int>? withGenres,
    double? voteAverageGte,
    double? voteAverageLte,
  }) async {
    final response = await discoverTvPaginated(
      page: page,
      sortBy: sortBy,
      withGenres: withGenres,
      voteAverageGte: voteAverageGte,
      voteAverageLte: voteAverageLte,
    );
    return response.results;
  }

  // People
  Future<List<Person>> fetchTrendingPeople({String timeWindow = 'day'}) async {
    final payload = await _get('/trending/person/$timeWindow');
    final results = payload['results'] as List?;

    if (results == null) return [];

    return results
        .whereType<Map<String, dynamic>>()
        .map(Person.fromJson)
        .toList(growable: false);
  }

  Future<List<Person>> fetchPopularPeople({int page = 1}) async {
    final payload = await _get('/person/popular', {'page': '$page'});
    final results = payload['results'] as List?;

    if (results == null) return [];

    return results
        .whereType<Map<String, dynamic>>()
        .map(Person.fromJson)
        .toList(growable: false);
  }

  Future<Person> fetchPersonDetails(int personId) async {
    final payload = await _get('/person/$personId', {
      'append_to_response': 'combined_credits,external_ids,images,tagged_images',
    });
    return Person.fromJson(payload);
  }

  // Companies
  Future<List<Company>> searchCompanies(
    String query, {
    int page = 1,
  }) async {
    if (query.trim().isEmpty) {
      return const <Company>[];
    }

    final payload = await _get('/search/company', {
      'query': query,
      'page': '$page',
    });
    final results = payload['results'] as List?;

    if (results == null) return [];

    return results
        .whereType<Map<String, dynamic>>()
        .map(Company.fromJson)
        .toList(growable: false);
  }

  Future<Company> fetchCompanyDetails(int companyId) async {
    final payload = await _get('/company/$companyId');
    return Company.fromJson(payload);
  }

  // Similar Movies
  Future<List<Movie>> fetchSimilarMovies(int movieId, {int page = 1}) async {
    final payload = await _get('/movie/$movieId/similar', {'page': '$page'});
    final results = payload['results'] as List?;

    if (results == null) return [];

    return results
        .whereType<Map<String, dynamic>>()
        .map(Movie.fromJson)
        .where((movie) => movie.title.isNotEmpty)
        .toList(growable: false);
  }

  // Recommended Movies
  Future<List<Movie>> fetchRecommendedMovies(int movieId, {int page = 1}) async {
    final payload = await _get('/movie/$movieId/recommendations', {'page': '$page'});
    final results = payload['results'] as List?;

    if (results == null) return [];

    return results
        .whereType<Map<String, dynamic>>()
        .map(Movie.fromJson)
        .where((movie) => movie.title.isNotEmpty)
        .toList(growable: false);
  }

  // Watch Providers
  Future<List<WatchProviderRegion>> fetchWatchProviderRegions() async {
    final payload = await _get('/watch/providers/regions');
    final results = payload['results'];

    if (results is! List) {
      return const <WatchProviderRegion>[];
    }

    return results
        .whereType<Map<String, dynamic>>()
        .map(WatchProviderRegion.fromJson)
        .toList(growable: false);
  }

  Future<Map<String, WatchProviderResults>> fetchMovieWatchProviders(int movieId) async {
    final payload = await _get('/movie/$movieId/watch/providers');
    final results = payload['results'];

    if (results is! Map) {
      return const {};
    }

    return results.map(
      (key, value) {
        if (value is Map<String, dynamic>) {
          return MapEntry(
            '$key',
            WatchProviderResults.fromJson(value),
          );
        }
        return MapEntry('$key', const WatchProviderResults());
      },
    );
  }

  Future<Map<String, WatchProviderResults>> fetchTvWatchProviders(int tvId) async {
    final payload = await _get('/tv/$tvId/watch/providers');
    final results = payload['results'];

    if (results is! Map) {
      return const {};
    }

    return results.map(
      (key, value) {
        if (value is Map<String, dynamic>) {
          return MapEntry(
            '$key',
            WatchProviderResults.fromJson(value),
          );
        }
        return MapEntry('$key', const WatchProviderResults());
      },
    );
  }
}

class TmdbException implements Exception {
  const TmdbException(this.message);

  final String message;

  @override
  String toString() => 'TmdbException: $message';
}
