import 'package:flutter_test/flutter_test.dart';

import 'package:allmovies_mobile/data/models/movie.dart';
import 'package:allmovies_mobile/data/models/paginated_response.dart';
import 'package:allmovies_mobile/data/tmdb_repository.dart';
import 'package:allmovies_mobile/providers/series_provider.dart';

PaginatedResponse<Movie> _page(String prefix, int page, {int totalPages = 3}) {
  return PaginatedResponse<Movie>(
    page: page,
    totalPages: totalPages,
    totalResults: totalPages,
    results: [Movie(id: page, title: '$prefix$page')],
  );
}

class _FakeRepo extends TmdbRepository {
  _FakeRepo();

  @override
  Future<PaginatedResponse<Movie>> fetchTrendingTv({
    String timeWindow = 'day',
    int page = 1,
    bool forceRefresh = false,
  }) async {
    return _page('T', page);
  }

  @override
  Future<PaginatedResponse<Movie>> fetchPopularTv({int page = 1}) async {
    return _page('P', page);
  }

  @override
  Future<PaginatedResponse<Movie>> fetchTopRatedTv({int page = 1}) async {
    return _page('TR', page);
  }

  @override
  Future<PaginatedResponse<Movie>> fetchAiringTodayTv({int page = 1}) async {
    return _page('AT', page);
  }

  @override
  Future<PaginatedResponse<Movie>> fetchOnTheAirTv({int page = 1}) async {
    return _page('OTA', page);
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
      page: page,
      totalPages: 2,
      totalResults: 2,
      results: [Movie(id: 99 + page, title: 'By Network $page')],
    );
  }

  @override
  Future<PaginatedResponse<Movie>> discoverTvSeries({
    int page = 1,
    Map<String, String>? filters,
    bool forceRefresh = false,
  }) async {
    return PaginatedResponse<Movie>(
      page: page,
      totalPages: 4,
      totalResults: 4,
      results: [Movie(id: 200 + page, title: 'Filtered $page')],
    );
  }
}

class _ErroringRepo extends _FakeRepo {
  _ErroringRepo(this.failOnPage);

  final int failOnPage;

  @override
  Future<PaginatedResponse<Movie>> fetchPopularTv({int page = 1}) async {
    if (page == failOnPage) {
      throw const TmdbException('Boom');
    }
    return super.fetchPopularTv(page: page);
  }
}

void main() {
  group('SeriesProvider', () {
    test('initial refresh populates series sections with pagination metadata',
        () async {
      final provider = SeriesProvider(_FakeRepo());
      await provider.initialized;

      expect(provider.isInitialized, isTrue);
      for (final section in SeriesSection.values) {
        expect(provider.sectionState(section).items, isNotEmpty);
        expect(provider.sectionState(section).currentPage, 1);
        expect(provider.sectionState(section).totalPages, greaterThan(1));
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
          'By Network 1',
        );
        expect(provider.sectionState(SeriesSection.popular).totalPages, 2);
      },
    );

    test('loadNextPage advances pagination state', () async {
      final provider = SeriesProvider(_FakeRepo());
      await provider.initialized;

      expect(provider.sectionState(SeriesSection.popular).currentPage, 1);

      await provider.loadNextPage(SeriesSection.popular);

      expect(provider.sectionState(SeriesSection.popular).currentPage, 2);
      expect(
        provider.sectionState(SeriesSection.popular).items.first.title,
        'P2',
      );
      expect(provider.canGoPrev(SeriesSection.popular), isTrue);
    });

    test('loadSectionPage handles out of range requests gracefully', () async {
      final provider = SeriesProvider(_FakeRepo());
      await provider.initialized;

      await provider.loadSectionPage(SeriesSection.popular, 99);

      final state = provider.sectionState(SeriesSection.popular);
      expect(state.currentPage, 1);
      expect(state.errorMessage, contains('out of range'));
    });

    test('loadSectionPage surfaces repository errors', () async {
      final provider = SeriesProvider(_ErroringRepo(2));
      await provider.initialized;

      await provider.loadSectionPage(SeriesSection.popular, 2);

      final state = provider.sectionState(SeriesSection.popular);
      expect(state.currentPage, 1);
      expect(state.errorMessage, 'Boom');
    });

    test('applyTvFilters resets to first page and supports pagination',
        () async {
      final provider = SeriesProvider(_FakeRepo());
      await provider.initialized;

      await provider.applyTvFilters({'sort_by': 'vote_average.desc'});

      final state = provider.sectionState(SeriesSection.popular);
      expect(state.currentPage, 1);
      expect(state.items.first.title, 'Filtered 1');

      await provider.loadNextPage(SeriesSection.popular);
      expect(provider.sectionState(SeriesSection.popular).items.first.title,
          'Filtered 2');
    });
  });
}
