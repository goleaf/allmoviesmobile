import 'package:flutter_test/flutter_test.dart';

import 'package:allmovies_mobile/data/models/movie.dart';
import 'package:allmovies_mobile/data/models/paginated_response.dart';
import 'package:allmovies_mobile/data/tmdb_repository.dart';
import 'package:allmovies_mobile/providers/series_provider.dart';

class _FakeRepo extends TmdbRepository {
  final Map<SeriesSection, List<int>> requestedPages = {
    for (final section in SeriesSection.values) section: <int>[],
  };

  final List<int> networkPages = <int>[];

  PaginatedResponse<Movie> _buildResponse(String prefix, int page) {
    return PaginatedResponse<Movie>(
      page: page,
      totalPages: 5,
      totalResults: 5,
      results: [Movie(id: page, title: '$prefix Page $page')],
    );
  }

  @override
  Future<PaginatedResponse<Movie>> fetchTrendingTvPaginated({
    String timeWindow = 'day',
    int page = 1,
    bool forceRefresh = false,
  }) async {
    requestedPages[SeriesSection.trending]!.add(page);
    return _buildResponse('Trending', page);
  }

  @override
  Future<PaginatedResponse<Movie>> fetchPopularTvPaginated({
    int page = 1,
  }) async {
    requestedPages[SeriesSection.popular]!.add(page);
    return _buildResponse('Popular', page);
  }

  @override
  Future<PaginatedResponse<Movie>> fetchTopRatedTvPaginated({
    int page = 1,
  }) async {
    requestedPages[SeriesSection.topRated]!.add(page);
    return _buildResponse('Top Rated', page);
  }

  @override
  Future<PaginatedResponse<Movie>> fetchAiringTodayTvPaginated({
    int page = 1,
  }) async {
    requestedPages[SeriesSection.airingToday]!.add(page);
    return _buildResponse('Airing Today', page);
  }

  @override
  Future<PaginatedResponse<Movie>> fetchOnTheAirTvPaginated({
    int page = 1,
  }) async {
    requestedPages[SeriesSection.onTheAir]!.add(page);
    return _buildResponse('On The Air', page);
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
    networkPages.add(page);
    return PaginatedResponse<Movie>(
      page: page,
      totalPages: 3,
      totalResults: 3,
      results: [Movie(id: networkId, title: 'Network $networkId - Page $page')],
    );
  }
}

void main() {
  group('SeriesProvider', () {
    test('initial refresh populates series sections with pagination state',
        () async {
      final repo = _FakeRepo();
      final provider = SeriesProvider(repo);
      await provider.initialized;

      expect(provider.isInitialized, isTrue);
      for (final section in SeriesSection.values) {
        final state = provider.sectionState(section);
        expect(state.items, isNotEmpty);
        expect(state.currentPage, 1);
        expect(state.totalPages, greaterThanOrEqualTo(1));
      }
    });

    test(
      'applyNetworkFilter loads network shows into popular section',
      () async {
        final repo = _FakeRepo();
        final provider = SeriesProvider(repo);
        await provider.initialized;

        await provider.applyNetworkFilter(213); // Netflix
        expect(
          provider.sectionState(SeriesSection.popular).items.first.title,
          'Network 213 - Page 1',
        );
        expect(provider.sectionState(SeriesSection.popular).currentPage, 1);
        expect(repo.networkPages.last, 1);
      },
    );

    test('loadPage updates provider state and refresh respects selected page',
        () async {
      final repo = _FakeRepo();
      final provider = SeriesProvider(repo);
      await provider.initialized;

      await provider.loadPage(SeriesSection.topRated, 3);
      final state = provider.sectionState(SeriesSection.topRated);
      expect(state.currentPage, 3);
      expect(state.items.single.title, 'Top Rated Page 3');
      expect(repo.requestedPages[SeriesSection.topRated], contains(3));

      await provider.refresh(force: true);
      final refreshed = provider.sectionState(SeriesSection.topRated);
      expect(refreshed.currentPage, 3);
      expect(repo.requestedPages[SeriesSection.topRated]!.last, 3);
    });
  });
}
