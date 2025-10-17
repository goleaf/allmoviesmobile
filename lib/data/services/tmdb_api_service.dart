import 'dart:convert';

import 'package:http/http.dart' as http;

class TmdbApiService {
  TmdbApiService({
    http.Client? client,
    required this.apiKey,
  }) : _client = client ?? http.Client();

  static const _baseHost = 'api.themoviedb.org';
  static const _apiVersion = '3';

  final http.Client _client;
  final String apiKey;

  Future<List<Map<String, dynamic>>> fetchTrendingMovies({int page = 1}) async {
    return _getJsonList(
      '/$_apiVersion/trending/movie/week',
      queryParameters: {
        'language': 'en-US',
        'page': '$page',
      },
    );
  }

  Future<List<Map<String, dynamic>>> fetchPopularMovies({int page = 1}) async {
    return _getJsonList(
      '/$_apiVersion/movie/popular',
      queryParameters: {
        'language': 'en-US',
        'page': '$page',
      },
    );
  }

  Future<List<Map<String, dynamic>>> _getJsonList(
    String path, {
    Map<String, String>? queryParameters,
  }) async {
    final uri = Uri.https(
      _baseHost,
      path,
      {
        'api_key': apiKey,
        if (queryParameters != null) ...queryParameters,
      },
    );

    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw TmdbHttpException(
        'Request failed with status: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final results = decoded['results'];
    if (results is! List) {
      return const [];
    }

    return results
        .whereType<Map<String, dynamic>>()
        .toList(growable: false);
  }
}

class TmdbHttpException implements Exception {
  TmdbHttpException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'TmdbHttpException: $message';
}
