import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:allmovies_mobile/data/models/movie.dart';
import 'package:allmovies_mobile/data/models/paginated_response.dart';
import 'package:allmovies_mobile/data/services/local_storage_service.dart';
import 'package:allmovies_mobile/data/tmdb_repository.dart';
import 'package:allmovies_mobile/providers/recommendations_provider.dart';

class _FakeRepo extends TmdbRepository {
  _FakeRepo();

  @override
  Future<List<Movie>> fetchTrendingMovies({String timeWindow = 'day', bool forceRefresh = false}) async {
    return [Movie(id: 101, title: 'Trend')];
  }

  @override
  Future<List<Movie>> fetchPopularMovies({int page = 1, bool forceRefresh = false}) async {
    return [Movie(id: 201, title: 'Popular')];
  }

  @override
  Future<List<Movie>> fetchSimilarMovies(int movieId, {int page = 1}) async {
    return [Movie(id: 301, title: 'Similar to $movieId')];
  }

  @override
  Future<List<Movie>> fetchRecommendedMovies(int movieId, {int page = 1}) async {
    return [Movie(id: 401, title: 'Recommended for $movieId')];
  }
}

void main() {
  group('RecommendationsProvider', () {
    late LocalStorageService storage;
    late RecommendationsProvider provider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      storage = LocalStorageService(prefs);
      provider = RecommendationsProvider(_FakeRepo(), storage);
    });

    test('when no favorites, returns popular deterministically (deduped/sorted/limited)', () async {
      await provider.fetchPersonalizedRecommendations();
      expect(provider.recommendedMovies, isNotEmpty);
      final ids = provider.recommendedMovies.map((m) => m.id).toList(growable: false);
      // Sorted ascending by id
      final sorted = [...ids]..sort();
      expect(ids, sorted);
      // No duplicates
      expect(ids.toSet().length, ids.length);
      // Limited to <= 20
      expect(ids.length <= 20, isTrue);
    });

    test('when favorites exist, filters favorites and returns deterministic list', () async {
      // Add a favorite
      await storage.addToFavorites(101);

      await provider.fetchPersonalizedRecommendations();
      // Should not include favorite id 101
      expect(provider.recommendedMovies.where((m) => m.id == 101), isEmpty);
      // Sorted ascending by id and unique
      final ids = provider.recommendedMovies.map((m) => m.id).toList(growable: false);
      final sorted = [...ids]..sort();
      expect(ids, sorted);
      expect(ids.toSet().length, ids.length);
      expect(ids.length <= 20, isTrue);
    });
  });
}


