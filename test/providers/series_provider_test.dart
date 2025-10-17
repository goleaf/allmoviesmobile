import 'package:flutter_test/flutter_test.dart';

import 'package:allmovies_mobile/data/models/movie.dart';
import 'package:allmovies_mobile/data/models/paginated_response.dart';
import 'package:allmovies_mobile/data/tmdb_repository.dart';
import 'package:allmovies_mobile/providers/series_provider.dart';

class _FakeRepo extends TmdbRepository {
  _FakeRepo();

  @override
  Future<List<Movie>> fetchTrendingTv({
    String timeWindow = 'day',
    bool forceRefresh = false,
  }) async {
    return [Movie(id: 10, title: 'TV-T')];
  }

  @override
  Future<List<Movie>> fetchPopularTv({int page = 1}) async {
    return [Movie(id: 11, title: 'TV-P')];
  }

  @override
  Future<List<Movie>> fetchTopRatedTv({int page = 1}) async {
    return [Movie(id: 12, title: 'TV-TR')];
  }

  @override
  Future<List<Movie>> fetchAiringTodayTv({int page = 1}) async {
    return [Movie(id: 13, title: 'TV-AT')];
  }

  @override
  Future<List<Movie>> fetchOnTheAirTv({int page = 1}) async {
    return [Movie(id: 14, title: 'TV-OTA')];
  }

  @override
  Future<PaginatedResponse<Movie>> fetchNetworkTvShows({
    required int networkId,
    int page = 1,
    String sortBy = 'popularity.desc',
    double? minVoteAverage,
    String? originalLanguage,
    bool forceRefresh = false,
  }) async {
    return PaginatedResponse<Movie>(
      page: 1,
      totalPages: 1,
      totalResults: 1,
      results: [Movie(id: 99, title: 'By Network')],
    );
  }
}

void main() {
  group('SeriesProvider', () {
    test('initial refresh populates series sections', () async {
      final provider = SeriesProvider(_FakeRepo());
      await provider.initialized;

      expect(provider.isInitialized, isTrue);
      for (final section in SeriesSection.values) {
        expect(provider.sectionState(section).items, isNotEmpty);
      }
    });

    test(
      'applyNetworkFilter loads network shows into popular section',
      () async {
        final provider = SeriesProvider(_FakeRepo());
        await provider.initialized;

        await provider.applyNetworkFilter(213); // Netflix
        expect(
          provider.sectionState(SeriesSection.popular).items.first.title,
          'By Network',
        );
      },
    );
  });
}
