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

  Future<List<Movie>> fetchTrendingMovies({String timeWindow = 'day'}) async {
    if (_apiKey.isEmpty) {
      throw const TmdbException('TMDB API key is not configured.');
    }

    final uri = Uri.https(_host, '$_basePath/trending/all/$timeWindow', {
      'language': 'en-US',
      'api_key': _apiKey,
    });

    final response = await _client.get(uri, headers: {
      'Accept': 'application/json',
    });

    if (response.statusCode != 200) {
      throw TmdbException(
        'Failed to fetch trending titles (status ${response.statusCode}).',
      );
    }

    final payload = jsonDecode(response.body) as Map<String, dynamic>;
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
}

class TmdbException implements Exception {
  const TmdbException(this.message);

  final String message;

  @override
  String toString() => 'TmdbException: $message';
}
