import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:allmovies_mobile/data/models/movie.dart';
import 'package:allmovies_mobile/data/models/paginated_response.dart';
import 'package:allmovies_mobile/data/tv_filter_presets_repository.dart';
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

class _CountingRepo extends _FakeRepo {
  int popularCalls = 0;

  @override
  Future<PaginatedResponse<Movie>> fetchPopularTv({int page = 1}) async {
    popularCalls++;
    return super.fetchPopularTv(page: page);
  }
}

void main() {
  group('SeriesProvider', () {
    late TvFilterPresetsRepository presetsRepository;

    setUp(() async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final prefs = await SharedPreferences.getInstance();
      presetsRepository = TvFilterPresetsRepository(prefs);
    });

    test('initial refresh populates series sections with pagination metadata',
        () async {
      final provider = SeriesProvider(
        _FakeRepo(),
        filterPresetsRepository: presetsRepository,
      );
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
        final provider = SeriesProvider(
          _FakeRepo(),
          filterPresetsRepository: presetsRepository,
        );
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
      final provider = SeriesProvider(
        _FakeRepo(),
        filterPresetsRepository: presetsRepository,
      );
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
      final provider = SeriesProvider(
        _FakeRepo(),
        filterPresetsRepository: presetsRepository,
      );
      await provider.initialized;

      await provider.loadSectionPage(SeriesSection.popular, 99);

      final state = provider.sectionState(SeriesSection.popular);
      expect(state.currentPage, 1);
      expect(state.errorMessage, contains('out of range'));
    });

    test('loadSectionPage surfaces repository errors', () async {
      final provider = SeriesProvider(
        _ErroringRepo(2),
        filterPresetsRepository: presetsRepository,
      );
      await provider.initialized;

      await provider.loadSectionPage(SeriesSection.popular, 2);

      final state = provider.sectionState(SeriesSection.popular);
      expect(state.currentPage, 1);
      expect(state.errorMessage, 'Boom');
    });

    test('jumpToPage loads the requested page when within bounds', () async {
      final provider = SeriesProvider(
        _FakeRepo(),
        filterPresetsRepository: presetsRepository,
      );
      await provider.initialized;

      final success = await provider.jumpToPage(SeriesSection.popular, 3);

      expect(success, isTrue);
      final state = provider.sectionState(SeriesSection.popular);
      expect(state.currentPage, 3);
      expect(state.items.first.title, 'P3');
    });

    test('jumpToPage rejects page numbers outside the available range',
        () async {
      final provider = SeriesProvider(
        _FakeRepo(),
        filterPresetsRepository: presetsRepository,
      );
      await provider.initialized;

      final success = await provider.jumpToPage(SeriesSection.popular, 0);

      expect(success, isFalse);
      final state = provider.sectionState(SeriesSection.popular);
      expect(state.currentPage, 1);
      expect(state.errorMessage, contains('out of range'));
    });

    test('applyTvFilters resets to first page and supports pagination',
        () async {
      final provider = SeriesProvider(
        _FakeRepo(),
        filterPresetsRepository: presetsRepository,
      );
      await provider.initialized;

      await provider.applyTvFilters({'sort_by': 'vote_average.desc'});

      final state = provider.sectionState(SeriesSection.popular);
      expect(state.currentPage, 1);
      expect(state.items.first.title, 'Filtered 1');

      await provider.loadNextPage(SeriesSection.popular);
      expect(provider.sectionState(SeriesSection.popular).items.first.title,
          'Filtered 2');
    });

    test('applyTvFilters persists the active preset selection', () async {
      final provider = SeriesProvider(
        _FakeRepo(),
        filterPresetsRepository: presetsRepository,
      );
      await provider.initialized;

      await provider.applyTvFilters(
        {'sort_by': 'vote_average.desc'},
        presetName: 'Critics',
      );

      final selection = await presetsRepository.loadActiveSelection();
      expect(selection.presetName, 'Critics');
      expect(selection.filters, {'sort_by': 'vote_average.desc'});
      expect(provider.activePresetName, 'Critics');
      expect(provider.activeFilters, {'sort_by': 'vote_average.desc'});

      await provider.clearTvFilters();
      final cleared = await presetsRepository.loadActiveSelection();
      expect(cleared.filters, isNull);
      expect(cleared.presetName, isNull);
      expect(provider.activeFilters, isNull);
      expect(provider.activePresetName, isNull);
    });

    test('loadSectionPage reuses cached data for previously fetched pages',
        () async {
      final repo = _CountingRepo();
      final provider = SeriesProvider(
        repo,
        filterPresetsRepository: presetsRepository,
      );
      await provider.initialized;

      expect(repo.popularCalls, 1);

      await provider.loadNextPage(SeriesSection.popular);
      expect(provider.sectionState(SeriesSection.popular).currentPage, 2);
      expect(repo.popularCalls, 2);

      await provider.loadSectionPage(SeriesSection.popular, 1);
      final state = provider.sectionState(SeriesSection.popular);
      expect(state.currentPage, 1);
      expect(state.items.first.title, 'P1');
      expect(repo.popularCalls, 2);
    });

    test('refreshSection reloads the current page while preserving caches',
        () async {
      final repo = _CountingRepo();
      final provider = SeriesProvider(
        repo,
        filterPresetsRepository: presetsRepository,
      );
      await provider.initialized;

      await provider.loadNextPage(SeriesSection.popular);
      final cachedState = provider.sectionState(SeriesSection.popular);
      expect(cachedState.pageResults.containsKey(1), isTrue);
      expect(cachedState.pageResults.containsKey(2), isTrue);

      final previousCalls = repo.popularCalls;
      await provider.refreshSection(SeriesSection.popular);
      expect(repo.popularCalls, previousCalls + 1);

      final refreshedState = provider.sectionState(SeriesSection.popular);
      expect(refreshedState.currentPage, cachedState.currentPage);
      expect(refreshedState.pageResults.length, cachedState.pageResults.length);
      expect(
        refreshedState.pageResults[refreshedState.currentPage]?.first.title,
        startsWith('P'),
      );
    });
  });
}
