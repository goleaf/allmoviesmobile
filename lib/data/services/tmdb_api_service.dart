import 'dart:convert';

import 'package:http/http.dart' as http;

class TmdbApiService {
  TmdbApiService({
    http.Client? client,
    required this.apiKey,
  })  : _client = client ?? http.Client();

  static const _baseHost = 'api.themoviedb.org';
  static const _apiVersion = '4';

  final http.Client _client;
  final String apiKey;

  Map<String, String> get _headers => {
        'Authorization': 'Bearer $apiKey',
        'Accept': 'application/json',
        'Content-Type': 'application/json;charset=utf-8',
      };

  Future<Map<String, dynamic>> fetchTrending({
    String mediaType = 'all',
    String timeWindow = 'day',
    int page = 1,
    Map<String, String>? queryParameters,
  }) {
    return _getJson(
      '/$_apiVersion/trending/$mediaType/$timeWindow',
      queryParameters: {
        'page': '$page',
        if (queryParameters != null) ...queryParameters,
      },
    );
  }

  Future<Map<String, dynamic>> fetchMovieCategory(
    String category, {
    int page = 1,
    Map<String, String>? queryParameters,
  }) {
    return _getJson(
      '/$_apiVersion/movie/$category',
      queryParameters: {
        'page': '$page',
        if (queryParameters != null) ...queryParameters,
      },
    );
  }

  Future<Map<String, dynamic>> fetchTvCategory(
    String category, {
    int page = 1,
    Map<String, String>? queryParameters,
  }) {
    return _getJson(
      '/$_apiVersion/tv/$category',
      queryParameters: {
        'page': '$page',
        if (queryParameters != null) ...queryParameters,
      },
    );
  }

  Future<Map<String, dynamic>> discoverMovie({
    Map<String, String>? queryParameters,
    int page = 1,
  }) {
    return _getJson(
      '/$_apiVersion/discover/movie',
      queryParameters: {
        'page': '$page',
        if (queryParameters != null) ...queryParameters,
      },
    );
  }

  Future<Map<String, dynamic>> discoverTv({
    Map<String, String>? queryParameters,
    int page = 1,
  }) {
    return _getJson(
      '/$_apiVersion/discover/tv',
      queryParameters: {
        'page': '$page',
        if (queryParameters != null) ...queryParameters,
      },
    );
  }

  Future<Map<String, dynamic>> search(
    String type,
    String query, {
    int page = 1,
    Map<String, String>? queryParameters,
  }) {
    return _getJson(
      '/$_apiVersion/search/$type',
      queryParameters: {
        'query': query,
        'page': '$page',
        if (queryParameters != null) ...queryParameters,
      },
    );
  }

  Future<Map<String, dynamic>> fetchMovieDetails(
    int movieId, {
    Map<String, String>? queryParameters,
  }) {
    return _getJson(
      '/$_apiVersion/movie/$movieId',
      queryParameters: queryParameters,
    );
  }

  Future<Map<String, dynamic>> fetchTvDetails(
    int tvId, {
    Map<String, String>? queryParameters,
  }) {
    return _getJson(
      '/$_apiVersion/tv/$tvId',
      queryParameters: queryParameters,
    );
  }

  Future<Map<String, dynamic>> fetchPersonDetails(
    int personId, {
    Map<String, String>? queryParameters,
  }) {
    return _getJson(
      '/$_apiVersion/person/$personId',
      queryParameters: queryParameters,
    );
  }

  Future<Map<String, dynamic>> fetchPersonCategory(
    String category, {
    int page = 1,
    Map<String, String>? queryParameters,
  }) {
    return _getJson(
      '/$_apiVersion/person/$category',
      queryParameters: {
        'page': '$page',
        if (queryParameters != null) ...queryParameters,
      },
    );
  }

  Future<Map<String, dynamic>> fetchCompanyDetails(
    int companyId, {
    Map<String, String>? queryParameters,
  }) {
    return _getJson(
      '/$_apiVersion/company/$companyId',
      queryParameters: queryParameters,
    );
  }

  Future<Map<String, dynamic>> fetchList(
    String listId, {
    int page = 1,
    Map<String, String>? queryParameters,
  }) {
    return _getJson(
      '/$_apiVersion/list/$listId',
      queryParameters: {
        'page': '$page',
        if (queryParameters != null) ...queryParameters,
      },
    );
  }

  Future<Map<String, dynamic>> fetchAccount(
    String accountId, {
    Map<String, String>? queryParameters,
  }) {
    return _getJson(
      '/$_apiVersion/account/$accountId',
      queryParameters: queryParameters,
    );
  }

  Future<Map<String, dynamic>> fetchAccountLists(
    String accountId, {
    int page = 1,
    Map<String, String>? queryParameters,
  }) {
    return _getJson(
      '/$_apiVersion/account/$accountId/lists',
      queryParameters: {
        'page': '$page',
        if (queryParameters != null) ...queryParameters,
      },
    );
  }

  Future<Map<String, dynamic>> fetchAccountFavorites(
    String accountId, {
    String mediaType = 'movie',
    int page = 1,
    Map<String, String>? queryParameters,
  }) {
    return _getJson(
      '/$_apiVersion/account/$accountId/$mediaType/favorites',
      queryParameters: {
        'page': '$page',
        if (queryParameters != null) ...queryParameters,
      },
    );
  }

  Future<Map<String, dynamic>> fetchAccountWatchlist(
    String accountId, {
    String mediaType = 'movie',
    int page = 1,
    Map<String, String>? queryParameters,
  }) {
    return _getJson(
      '/$_apiVersion/account/$accountId/$mediaType/watchlist',
      queryParameters: {
        'page': '$page',
        if (queryParameters != null) ...queryParameters,
      },
    );
  }

  Future<Map<String, dynamic>> _getJson(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    final uri = Uri.https(
      _baseHost,
      path,
      {
        'language': 'en-US',
        if (queryParameters != null) ...queryParameters,
      },
    );

    final response = await _client.get(uri, headers: _headers);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw TmdbHttpException(
        'Request failed with status: ${response.statusCode}',
        statusCode: response.statusCode,
        body: response.body,
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const TmdbHttpException('Malformed TMDB response.');
    }

    return decoded;
  }
}

class TmdbHttpException implements Exception {
  const TmdbHttpException(this.message, {this.statusCode, this.body});

  final String message;
  final int? statusCode;
  final String? body;

  @override
  String toString() => 'TmdbHttpException: $message';
}
