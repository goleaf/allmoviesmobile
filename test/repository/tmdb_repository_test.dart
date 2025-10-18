// removed duplicate test suite; see unified tests below

import 'dart:convert';

import 'package:allmovies_mobile/data/models/movie.dart';
import 'package:allmovies_mobile/data/services/cache_service.dart';
import 'package:allmovies_mobile/data/services/network_quality_service.dart';
import 'package:allmovies_mobile/data/tmdb_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class _MockNetworkQualityNotifier extends ChangeNotifier
    implements NetworkQualityNotifier {
  _MockNetworkQualityNotifier([this._quality = NetworkQuality.excellent]);

  NetworkQuality _quality;

  @override
  NetworkQuality get quality => _quality;

  @override
  Duration? get lastLatency => null;

  void setQuality(NetworkQuality quality) {
    if (_quality != quality) {
      _quality = quality;
      notifyListeners();
    }
  }

  @override
  Future<void> initialize() async {}

  @override
  Future<void> refreshQuality({Duration timeout = const Duration(seconds: 3)}) async {}

  @override
  void dispose() {
    super.dispose();
  }
}

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
        return http.Response(
          jsonEncode(routes[match]),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
    }

    test('fetchTrendingMovies maps results', () async {
      final payload = {
        'page': 1,
        'total_pages': 1,
        'total_results': 1,
        'results': [
          {'id': 1, 'title': 'A', 'media_type': 'movie'},
        ],
      };
      final client = buildClient({'/3/trending/movie/day?': payload});
      final repo = TmdbRepository(
        client: client,
        cacheService: CacheService(),
        apiKey: 'k',
        language: 'en-US',
      );
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
          {'id': 1, 'title': 'A'},
        ],
      };
      final client = MockClient((request) async {
        count++;
        return http.Response(
          jsonEncode(data),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final repo = TmdbRepository(
        client: client,
        cacheService: CacheService(),
        apiKey: 'k',
        language: 'en-US',
      );
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
      final repo = TmdbRepository(
        client: client,
        cacheService: CacheService(),
        apiKey: 'k',
        language: 'en-US',
      );
      expect(
        () => repo.fetchTrendingTitles(mediaType: 'movie', timeWindow: 'day'),
        throwsA(isA<TmdbException>()),
      );
    });

    test('network quality notifier seeds and updates throttling delay', () {
      final notifier = _MockNetworkQualityNotifier(NetworkQuality.balanced);
      final repo = TmdbRepository(
        client: MockClient((request) async => http.Response('{}', 200)),
        networkQualityNotifier: notifier,
        apiKey: 'k',
        language: 'en-US',
      );

      expect(
        repo.networkAwareDelayForTesting,
        const Duration(milliseconds: 300),
      );

      notifier.setQuality(NetworkQuality.constrained);
      expect(
        repo.networkAwareDelayForTesting,
        const Duration(milliseconds: 600),
      );

      notifier.setQuality(NetworkQuality.excellent);
      expect(repo.networkAwareDelayForTesting, Duration.zero);

      repo.dispose();
    });

    test('dispose detaches network quality listener', () {
      final notifier = _MockNetworkQualityNotifier(NetworkQuality.constrained);
      final repo = TmdbRepository(
        client: MockClient((request) async => http.Response('{}', 200)),
        networkQualityNotifier: notifier,
        apiKey: 'k',
        language: 'en-US',
      );

      expect(
        repo.networkAwareDelayForTesting,
        const Duration(milliseconds: 600),
      );

      repo.dispose();

      notifier.setQuality(NetworkQuality.excellent);
      expect(
        repo.networkAwareDelayForTesting,
        const Duration(milliseconds: 600),
      );
    });

    test('_delayForQuality returns expected durations', () {
      final repo = TmdbRepository(
        client: MockClient((request) async => http.Response('{}', 200)),
        apiKey: 'k',
        language: 'en-US',
      );

      expect(
        repo.delayForQualityForTesting(NetworkQuality.offline),
        Duration.zero,
      );
      expect(
        repo.delayForQualityForTesting(NetworkQuality.constrained),
        const Duration(milliseconds: 500),
      );
      expect(
        repo.delayForQualityForTesting(NetworkQuality.balanced),
        const Duration(milliseconds: 100),
      );
      expect(
        repo.delayForQualityForTesting(NetworkQuality.excellent),
        Duration.zero,
      );
      expect(repo.delayForQualityForTesting(null), Duration.zero);

      repo.dispose();
    });
  });
}
