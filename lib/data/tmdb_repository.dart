import 'dart:convert';
import 'package:http/http.dart' as http;

import 'models/movie.dart';

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
  Future<List<Movie>> fetchTrendingMovies({String timeWindow = 'day'}) async {
    final payload = await _get('/trending/all/$timeWindow');
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

  // Popular
  Future<List<Movie>> fetchPopularMovies({int page = 1}) async {
    final payload = await _get('/movie/popular', {
      'page': page.toString(),
    });
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

  // Similar Movies
  Future<List<Movie>> fetchSimilarMovies(int movieId, {int page = 1}) async {
    final payload = await _get('/movie/$movieId/similar', {
      'page': page.toString(),
    });
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

  // Discover Movies with filters
  Future<List<Movie>> discoverMovies({
    List<int>? genreIds,
    int? year,
    String sortBy = 'popularity.desc',
    int page = 1,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'sort_by': sortBy,
    };

    if (genreIds != null && genreIds.isNotEmpty) {
      queryParams['with_genres'] = genreIds.join(',');
    }

    if (year != null) {
      queryParams['year'] = year.toString();
    }

    final payload = await _get('/discover/movie', queryParams);
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

  // Search Multi (movies, TV, people)
  Future<List<Movie>> searchMulti(String query, {int page = 1}) async {
    final payload = await _get('/search/multi', {
      'query': query,
      'page': page.toString(),
    });
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
  }) async {
    final queryParams = <String, String>{
      'page': '$page',
      if (sortBy != null) 'sort_by': sortBy,
      if (withGenres != null && withGenres.isNotEmpty) 
        'with_genres': withGenres.join(','),
      if (year != null) 'year': '$year',
      if (voteAverageGte != null) 'vote_average.gte': '$voteAverageGte',
    };

    final payload = await _get('/discover/movie', queryParams);
    final results = payload['results'] as List?;

    if (results == null) return [];

    return results
        .whereType<Map<String, dynamic>>()
        .map(Movie.fromJson)
        .where((movie) => movie.title.isNotEmpty)
        .toList(growable: false);
  }

  // Genres
  Future<List<Map<String, dynamic>>> fetchMovieGenres() async {
    final payload = await _get('/genre/movie/list');
    final genres = payload['genres'] as List?;

    if (genres == null) return [];

    return genres.whereType<Map<String, dynamic>>().toList(growable: false);
  }

  Future<List<Map<String, dynamic>>> fetchTVGenres() async {
    final payload = await _get('/genre/tv/list');
    final genres = payload['genres'] as List?;

    if (genres == null) return [];

    return genres.whereType<Map<String, dynamic>>().toList(growable: false);
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
}

class TmdbException implements Exception {
  const TmdbException(this.message);

  final String message;

  @override
  String toString() => 'TmdbException: $message';
}
