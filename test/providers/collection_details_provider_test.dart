import 'package:flutter_test/flutter_test.dart';
import 'package:allmovies_mobile/providers/collection_details_provider.dart';
import 'package:allmovies_mobile/data/services/tmdb_comprehensive_service.dart';

class _FakeService extends TmdbComprehensiveService {
  _FakeService();

  @override
  Future<Map<String, dynamic>> getCollectionDetails(int collectionId) async {
    return {
      'id': collectionId,
      'name': 'Test Collection',
      'overview': 'Overview',
      'poster_path': '/p.jpg',
      'backdrop_path': '/b.jpg',
      'parts': [
        {
          'id': 1,
          'title': 'Part 1',
          'release_date': '2001-01-01',
          'vote_average': 7.0,
        },
        {
          'id': 2,
          'title': 'Part 2',
          'release_date': '2003-01-01',
          'vote_average': 8.0,
        },
      ],
    };
  }

  @override
  Future<Map<String, dynamic>> getCollectionImages(int collectionId) async {
    return {
      'posters': [
        {
          'file_path': '/p1.jpg',
          'width': 500,
          'height': 750,
          'vote_average': 5.0,
          'vote_count': 10,
        },
      ],
      'backdrops': [
        {
          'file_path': '/b1.jpg',
          'width': 1280,
          'height': 720,
          'vote_average': 5.0,
          'vote_count': 10,
        },
      ],
    };
  }

  @override
  Future<Map<String, dynamic>> getCollectionTranslations(
    int collectionId,
  ) async {
    return {
      'translations': [
        {
          'iso_639_1': 'en',
          'iso_3166_1': 'US',
          'name': 'English',
          'english_name': 'English',
          'data': {'title': 'Test Collection', 'overview': 'Overview'},
        },
      ],
    };
  }

  @override
  Future<Map<String, dynamic>> getMovieDetails(
    int movieId, {
    String? appendToResponse,
  }) async {
    // Return distinct revenue for each id
    final revenue = movieId == 1 ? 100 : 300;
    return {'id': movieId, 'title': 'Movie $movieId', 'revenue': revenue};
  }
}

void main() {
  test(
    'CollectionDetailsProvider aggregates part revenues and enriches parts',
    () async {
      final provider = CollectionDetailsProvider(
        comprehensiveService: _FakeService(),
      );
      await provider.loadCollection(42);

      expect(provider.errorMessage, isNull);
      final data = provider.collection!;
      expect(data.name, 'Test Collection');
      // 100 + 300
      expect(data.totalRevenue, 400);
      expect(data.parts.length, 2);
      expect(data.parts[0].revenue, isNotNull);
      expect(data.parts[1].revenue, isNotNull);
    },
  );
}
