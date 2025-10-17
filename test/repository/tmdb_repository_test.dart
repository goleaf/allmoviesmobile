// removed duplicate test suite; see unified tests below

import 'dart:convert';

import 'package:allmovies_mobile/data/models/movie.dart';
import 'package:allmovies_mobile/data/services/cache_service.dart';
import 'package:allmovies_mobile/data/tmdb_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TmdbRepository', () {
    http.Client buildClient(Map<String, Map<String, dynamic>> routes) {
      return MockClient((request) async {
        final key = '${request.url.path}?${request.url.query}';
        // match by path startsWith when query order differs
        final match = routes.keys.firstWhere(
          (k) => key.startsWith(k),
          orElse: () => '',
        );
        if (match.isEmpty) {
          return http.Response('Not Found', 404);
        }
        return http.Response(jsonEncode(routes[match]), 200, headers: {'content-type': 'application/json'});
      });
    }

    test('fetchTrendingMovies maps results', () async {
      final payload = {
        'page': 1,
        'total_pages': 1,
        'total_results': 1,
        'results': [
          {
            'id': 1,
            'title': 'A',
            'media_type': 'movie',
          }
        ]
      };
      final client = buildClient({
        '/3/trending/movie/day?': payload,
      });
      final repo = TmdbRepository(client: client, cacheService: CacheService(), apiKey: 'k', language: 'en-US');
      final list = await repo.fetchTrendingMovies();
      expect(list, isNotEmpty);
      expect(list.first.title, 'A');
    });

    test('caching returns same instance without forceRefresh', () async {
      var count = 0;
      final data = {
        'page': 1,
        'total_pages': 1,
        'total_results': 1,
        'results': [
          {'id': 1, 'title': 'A'}
        ]
      };
      final client = MockClient((request) async {
        count++;
        return http.Response(jsonEncode(data), 200, headers: {'content-type': 'application/json'});
      });
      final repo = TmdbRepository(client: client, cacheService: CacheService(), apiKey: 'k', language: 'en-US');
      final a = await repo.fetchPopularMovies();
      final b = await repo.fetchPopularMovies();
      expect(count, 1);
      expect(a.first.title, 'A');
      expect(b.first.title, 'A');
    });

    test('non-200 response throws TmdbException', () async {
      final client = MockClient((request) async {
        return http.Response('fail', 500);
      });
      final repo = TmdbRepository(client: client, cacheService: CacheService(), apiKey: 'k', language: 'en-US');
      expect(
        () => repo.fetchTrendingTitles(mediaType: 'movie', timeWindow: 'day'),
        throwsA(isA<TmdbException>()),
      );
    });
  });
}


