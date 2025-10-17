import 'package:flutter_test/flutter_test.dart';

import 'package:allmovies_mobile/data/models/movie.dart';
import 'package:allmovies_mobile/data/models/paginated_response.dart';
import 'package:allmovies_mobile/data/tmdb_repository.dart';
import 'package:allmovies_mobile/providers/preferences_provider.dart';
import 'package:allmovies_mobile/providers/series_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  Future<PaginatedResponse<Movie>> discoverTvSeries({
    int page = 1,
    Map<String, String>? filters,
    bool forceRefresh = false,
  }) async {
    final label = filters?['with_original_language'] ?? 'default';
    return PaginatedResponse<Movie>(
      page: 1,
      totalPages: 1,
      totalResults: 1,
      results: [Movie(id: 102, title: 'Discover $label')],
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

    test('saved filters persist across provider reloads', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final preferencesProvider = PreferencesProvider(prefs);
      final repo = _FakeRepo();

      final provider = SeriesProvider(
        repo,
        preferencesProvider: preferencesProvider,
        autoInitialize: false,
      );

      await provider.loadSavedFilters();
      await provider.refresh(force: true);

      final filters = {
        'with_original_language': 'ja',
        'vote_average.gte': '6.5',
      };

      await provider.applyTvFilters(filters);

      expect(provider.savedFilters['with_original_language'], 'ja');
      expect(
        provider.sectionState(SeriesSection.popular).items.first.title,
        'Discover ja',
      );

      final reloadedProvider = SeriesProvider(
        repo,
        preferencesProvider: preferencesProvider,
        autoInitialize: false,
      );

      await reloadedProvider.loadSavedFilters();
      await reloadedProvider.refresh(force: true);

      expect(reloadedProvider.savedFilters['with_original_language'], 'ja');
      expect(
        reloadedProvider.sectionState(SeriesSection.popular).items.first.title,
        'Discover ja',
      );
    });
  });
}
