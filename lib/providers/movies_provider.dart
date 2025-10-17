import 'package:flutter/material.dart';
import 'dart:async';

import '../data/models/movie.dart';
import '../data/tmdb_repository.dart';
import '../data/models/discover_filters_model.dart';
import 'watch_region_provider.dart';
import '../data/models/paginated_response.dart';
import '../data/services/local_storage_service.dart';
import 'preferences_provider.dart';

enum MovieSection {
  trending,
  nowPlaying,
  popular,
  topRated,
  upcoming,
  discover,
}

class MovieSectionState {
  const MovieSectionState({
    this.items = const <Movie>[],
    this.isLoading = false,
    this.errorMessage,
    this.currentPage = 1,
    this.totalPages = 1,
    this.isLoadingMore = false,
  });

  static const _sentinel = Object();

  final List<Movie> items;
  final bool isLoading;
  final String? errorMessage;
  final int currentPage;
  final int totalPages;
  final bool isLoadingMore;

  MovieSectionState copyWith({
    List<Movie>? items,
    bool? isLoading,
    Object? errorMessage = _sentinel,
    int? currentPage,
    int? totalPages,
    bool? isLoadingMore,
  }) {
    return MovieSectionState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class MoviesProvider extends ChangeNotifier {
  MoviesProvider(
    this._repository, {
    WatchRegionProvider? regionProvider,
    PreferencesProvider? preferencesProvider,
    LocalStorageService? storageService,
    bool autoInitialize = true,
  }) {
    _regionProvider = regionProvider;
    _preferences = preferencesProvider;
    _storage = storageService;
    if (autoInitialize) {
      _init();
    }
  }

  final TmdbRepository _repository;
  WatchRegionProvider? _regionProvider;
  PreferencesProvider? _preferences;
  LocalStorageService? _storage;

  // Trending window: 'day' or 'week'
  String _trendingWindow = 'day';
  String get trendingWindow => _trendingWindow;
  void setTrendingWindow(String window) {
    if (window != 'day' && window != 'week') return;
    if (_trendingWindow == window) return;
    _trendingWindow = window;
    _storage?.setTrendingWindow(window);
    refresh(force: true);
  }

  void bindRegionProvider(WatchRegionProvider provider) {
    _regionProvider = provider;
    notifyListeners();
  }

  void bindPreferencesProvider(PreferencesProvider provider) {
    _preferences = provider;
    notifyListeners();
  }

  final Map<MovieSection, MovieSectionState> _sections = {
    for (final section in MovieSection.values)
      section: const MovieSectionState(),
  };

  bool _isInitialized = false;
  bool _isRefreshing = false;
  String? _globalError;
  DiscoverFilters? _discoverFilters;

  final Completer<void> _initializedCompleter = Completer<void>();

  Map<MovieSection, MovieSectionState> get sections => _sections;
  bool get isInitialized => _isInitialized;
  bool get isRefreshing => _isRefreshing;
  String? get globalError => _globalError;

  Future<void> get initialized => _initializedCompleter.future;

  MovieSectionState sectionState(MovieSection section) => _sections[section]!;

  Future<void> _init() async {
    final savedWindow = _storage?.getTrendingWindow();
    if (savedWindow == 'day' || savedWindow == 'week') {
      _trendingWindow = savedWindow!;
    }
      _discoverFilters = _storage?.getDiscoverFilters();
    await refresh(force: true);
  }

  Future<void> refresh({bool force = false}) async {
    if (_isRefreshing) {
      return;
    }

    if (_isInitialized && !force) {
      return;
    }

    _isRefreshing = true;
    _globalError = null;
    for (final section in MovieSection.values) {
      _sections[section] = _sections[section]!.copyWith(
        isLoading: true,
        errorMessage: null,
        currentPage: 1,
        totalPages: 1,
      );
    }
    notifyListeners();

    try {
      final region = _regionProvider?.region;
      final includeAdultPref = _preferences?.includeAdult ?? false;
      final defaultSortRaw = _preferences?.defaultDiscoverSortRaw ?? 'popularity.desc';
      final defaultSort = () {
        switch (defaultSortRaw) {
          case 'vote_average.desc':
            return SortBy.ratingDesc;
          case 'release_date.desc':
            return SortBy.releaseDateDesc;
          case 'title.asc':
            return SortBy.titleAsc;
          case 'popularity.desc':
          default:
            return SortBy.popularityDesc;
        }
      }();
      _discoverFilters =
          (_discoverFilters ??
                  DiscoverFilters(
                    sortBy: defaultSort,
                    watchRegion: region,
                    withWatchMonetizationTypes: 'flatrate|rent|buy|ads|free',
                    includeAdult: includeAdultPref,
                  ))
              .copyWith(watchRegion: region, includeAdult: includeAdultPref);

      final responses = await Future.wait<PaginatedResponse<Movie>>([
        _repository.fetchTrendingMoviesPaginated(
          timeWindow: _trendingWindow,
          page: 1,
        ),
        _repository.fetchNowPlayingMoviesPaginated(page: 1),
        _repository.fetchPopularMoviesPaginated(page: 1),
        _repository.fetchTopRatedMoviesPaginated(page: 1),
        _repository.fetchUpcomingMoviesPaginated(page: 1),
        _repository.discoverMovies(page: 1, discoverFilters: _discoverFilters),
      ]);

      final sectionsList = MovieSection.values;
      for (var index = 0; index < sectionsList.length; index++) {
        final section = sectionsList[index];
        final resp = responses[index];
        _sections[section] = MovieSectionState(
          items: resp.results,
          currentPage: resp.page,
          totalPages: resp.totalPages,
        );
      }

      _globalError = null;
      _isInitialized = true;
    } on TmdbException catch (error) {
      _globalError = error.message;
      _setErrorForAll(error.message);
    } catch (error) {
      _globalError = 'Failed to load movies: $error';
      _setErrorForAll(_globalError);
    } finally {
      _isRefreshing = false;
      notifyListeners();
      if (!_initializedCompleter.isCompleted) {
        _initializedCompleter.complete();
      }
    }
  }

  void _setErrorForAll(String? message) {
    for (final section in MovieSection.values) {
      _sections[section] = _sections[section]!.copyWith(
        isLoading: false,
        errorMessage: message,
        items: const <Movie>[],
      );
    }
  }

  Future<List<Movie>> search(String query) async {
    try {
      final res = await _repository.searchMovies(query);
      return res.results;
    } catch (error) {
      _globalError = 'Search failed: $error';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> applyDecadeFilter(int startYear) async {
    // Example: startYear=1990 => 1990-01-01 to 1999-12-31
    final endYear = startYear + 9;
    final filters = DiscoverFilters(
      sortBy: SortBy.popularityDesc,
      releaseDateGte: '$startYear-01-01',
      releaseDateLte: '$endYear-12-31',
      watchRegion: _regionProvider?.region,
    );

    _sections[MovieSection.discover] = _sections[MovieSection.discover]!
        .copyWith(isLoading: true, errorMessage: null, items: const <Movie>[]);
    notifyListeners();

    try {
      final response = await _repository.discoverMovies(
        discoverFilters: filters,
      );
      _discoverFilters = filters;
      _storage?.saveDiscoverFilters(filters);
      _sections[MovieSection.discover] = MovieSectionState(
        items: response.results,
        currentPage: response.page,
        totalPages: response.totalPages,
      );
    } catch (error) {
      _sections[MovieSection.discover] = _sections[MovieSection.discover]!
          .copyWith(
            isLoading: false,
            errorMessage: '$error',
            items: const <Movie>[],
          );
    } finally {
      notifyListeners();
    }
  }

  Future<void> applyFilters(DiscoverFilters filters) async {
    final enriched = filters.copyWith(
      watchRegion: filters.watchRegion ?? _regionProvider?.region,
      withWatchMonetizationTypes:
          filters.withWatchMonetizationTypes ?? 'flatrate|rent|buy|ads|free',
    );

    _sections[MovieSection.discover] = _sections[MovieSection.discover]!
        .copyWith(isLoading: true, errorMessage: null, items: const <Movie>[]);
    notifyListeners();

    try {
      final response = await _repository.discoverMovies(
        discoverFilters: enriched,
      );
      _discoverFilters = enriched;
      _storage?.saveDiscoverFilters(enriched);
      _sections[MovieSection.discover] = MovieSectionState(
        items: response.results,
        currentPage: response.page,
        totalPages: response.totalPages,
      );
    } catch (error) {
      _sections[MovieSection.discover] = _sections[MovieSection.discover]!
          .copyWith(
            isLoading: false,
            errorMessage: '$error',
            items: const <Movie>[],
          );
    } finally {
      notifyListeners();
    }
  }

  // Public getters
  DiscoverFilters? get discoverFilters => _discoverFilters;

  // Pagination controls
  Future<void> loadPage(MovieSection section, int page) async {
    if (page < 1) return;
    final state = _sections[section]!;
    if (state.isLoading) return;
    _sections[section] = state.copyWith(isLoading: true, errorMessage: null);
    notifyListeners();

    try {
      PaginatedResponse<Movie> response;
      switch (section) {
        case MovieSection.trending:
          response = await _repository.fetchTrendingMoviesPaginated(
            timeWindow: _trendingWindow,
            page: page,
          );
          break;
        case MovieSection.nowPlaying:
          response = await _repository.fetchNowPlayingMoviesPaginated(
            page: page,
          );
          break;
        case MovieSection.popular:
          response = await _repository.fetchPopularMoviesPaginated(page: page);
          break;
        case MovieSection.topRated:
          response = await _repository.fetchTopRatedMoviesPaginated(page: page);
          break;
        case MovieSection.upcoming:
          response = await _repository.fetchUpcomingMoviesPaginated(page: page);
          break;
        case MovieSection.discover:
          response = await _repository.discoverMovies(
            page: page,
            discoverFilters: _discoverFilters,
          );
          break;
      }

      _sections[section] = state.copyWith(
        isLoading: false,
        items: response.results,
        currentPage: response.page,
        totalPages: response.totalPages,
        errorMessage: null,
      );
    } catch (error) {
      _sections[section] = state.copyWith(
        isLoading: false,
        errorMessage: '$error',
      );
    } finally {
      notifyListeners();
    }
  }

  Future<void> jumpToPage(MovieSection section, int page) =>
      loadPage(section, page);

  Future<void> loadNextPage(MovieSection section) async {
    final state = _sections[section]!;
    if (state.currentPage >= state.totalPages) return;
    await loadPage(section, state.currentPage + 1);
  }

  void clearError() {
    _globalError = null;
    notifyListeners();
  }
}
