import 'package:flutter/material.dart';
import 'dart:async';

import '../data/models/movie.dart';
import '../data/tmdb_repository.dart';
import '../data/models/discover_filters_model.dart';
import 'watch_region_provider.dart';
import '../data/models/paginated_response.dart';
import '../data/services/local_storage_service.dart';
import '../data/services/offline_service.dart';
import '../core/constants/app_strings.dart';
import 'preferences_provider.dart';
import '../core/utils/performance_monitor.dart';

enum MovieSection {
  trending,
  nowPlaying,
  popular,
  topRated,
  upcoming,
  discover,
}

/// Maps each movie section to the TMDB JSON endpoint that powers its content.
///
/// Keeping the association in a single place makes it trivial to emit
/// diagnostics, documentation comments, and telemetry that explains which
/// remote payload (e.g. `GET /3/trending/movie/{time_window}`) backed a given
/// UI update.
const Map<MovieSection, String> _sectionEndpointByType = {
  MovieSection.trending: '/3/trending/movie/{time_window}',
  MovieSection.nowPlaying: '/3/movie/now_playing',
  MovieSection.popular: '/3/movie/popular',
  MovieSection.topRated: '/3/movie/top_rated',
  MovieSection.upcoming: '/3/movie/upcoming',
  MovieSection.discover: '/3/discover/movie',
};

class MovieSectionState {
  const MovieSectionState({
    this.items = const <Movie>[],
    this.isLoading = false,
    this.errorMessage,
    this.currentPage = 1,
    this.totalPages = 1,
    this.isLoadingMore = false,
    this.pages = const <int, List<Movie>>{},
    this.inflightPages = const <int>{},
  });

  static const _sentinel = Object();

  final List<Movie> items;
  final bool isLoading;
  final String? errorMessage;
  final int currentPage;
  final int totalPages;
  final bool isLoadingMore;
  final Map<int, List<Movie>> pages;
  final Set<int> inflightPages;

  MovieSectionState copyWith({
    List<Movie>? items,
    bool? isLoading,
    Object? errorMessage = _sentinel,
    int? currentPage,
    int? totalPages,
    bool? isLoadingMore,
    Map<int, List<Movie>>? pages,
    Set<int>? inflightPages,
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
      pages: pages ?? this.pages,
      inflightPages: inflightPages ?? this.inflightPages,
    );
  }
}

class MoviesProvider extends ChangeNotifier {
  MoviesProvider(
    this._repository, {
    WatchRegionProvider? regionProvider,
    PreferencesProvider? preferencesProvider,
    LocalStorageService? storageService,
    OfflineService? offlineService,
    bool autoInitialize = true,
  }) : _offlineService = offlineService {
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
  final OfflineService? _offlineService;

  static const int _pageSize = 20;
  static const int _maxCachedPages = 6;

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
  final Map<MovieSection, Set<int>> _pendingPageLoads = {
    for (final section in MovieSection.values) section: <int>{},
  };
  final Map<MovieSection, int> _lastFetchDurationsMs = {
    for (final section in MovieSection.values) section: 0,
  };

  bool _isInitialized = false;
  bool _isRefreshing = false;
  String? _globalError;
  DiscoverFilters? _discoverFilters;

  Timer? _backgroundPrefetchTimer;

  final Completer<void> _initializedCompleter = Completer<void>();

  Map<MovieSection, MovieSectionState> get sections => _sections;
  bool get isInitialized => _isInitialized;
  bool get isRefreshing => _isRefreshing;
  String? get globalError => _globalError;

  Future<void> get initialized => _initializedCompleter.future;

  MovieSectionState sectionState(MovieSection section) => _sections[section]!;

  /// Exposes the most recent network duration per section in milliseconds.
  ///
  /// Each entry corresponds to a TMDB endpoint described in
  /// [_sectionEndpointByType] so that UX or QA teams can cross-reference the
  /// captured timings with the originating JSON payload (for example, a spike
  /// on `MovieSection.trending` points to `GET /3/trending/movie/{time_window}`).
  Map<MovieSection, int> get lastFetchDurationsMs =>
      Map.unmodifiable(_lastFetchDurationsMs);

  /// Aggregates the latest refresh timings to provide a quick snapshot of how
  /// long the entire home experience took to hydrate from TMDB.
  int get lastTotalFetchDurationMs => _lastFetchDurationsMs.values.fold<int>(
        0,
        (running, value) => running + value,
      );

  Map<int, List<Movie>> _trimPages(
    Map<int, List<Movie>> pages,
    int anchorPage,
  ) {
    if (pages.length <= _maxCachedPages) {
      return pages;
    }
    final sorted = pages.keys.toList()..sort();
    final anchorIndex = sorted.indexOf(anchorPage).clamp(0, sorted.length - 1);
    final windowHalf = _maxCachedPages ~/ 2;
    var start = anchorIndex - windowHalf;
    if (start < 0) {
      start = 0;
    }
    if (start + _maxCachedPages > sorted.length) {
      start = sorted.length - _maxCachedPages;
    }
    final trimmed = <int, List<Movie>>{};
    for (var i = start; i < start + _maxCachedPages && i < sorted.length; i++) {
      final page = sorted[i];
      trimmed[page] = List<Movie>.from(pages[page]!);
    }
    return trimmed;
  }

  List<Movie> _flattenPages(Map<int, List<Movie>> pages) {
    final sorted = pages.keys.toList()..sort();
    return [
      for (final page in sorted) ...pages[page]!,
    ];
  }

  bool _isPageInflight(MovieSection section, int page) {
    return _pendingPageLoads[section]!.contains(page);
  }

  void _setPageInflight(MovieSection section, int page, bool value) {
    final set = _pendingPageLoads[section]!;
    if (value) {
      set.add(page);
    } else {
      set.remove(page);
    }
  }

  Future<void> _init() async {
    final savedWindow = _storage?.getTrendingWindow();
    if (savedWindow == 'day' || savedWindow == 'week') {
      _trendingWindow = savedWindow!;
    }
    _discoverFilters = _storage?.getDiscoverFilters();
    final savedPages = {
      for (final section in MovieSection.values)
        section: _storage?.getPageIndex('movies', section.name) ?? 1,
    };
    await refresh(force: true);
    for (final entry in savedPages.entries) {
      if (entry.value > 1) {
        unawaited(loadPage(entry.key, entry.value));
      }
    }
    _scheduleBackgroundPrefetch();
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
      final servedFromOffline = await _tryServeOffline();
      if (servedFromOffline && (_offlineService?.isOffline ?? false)) {
        _isRefreshing = false;
        if (!_initializedCompleter.isCompleted) {
          _initializedCompleter.complete();
        }
        notifyListeners();
        return;
      }

      final region = _regionProvider?.region;
      final includeAdultPref = _preferences?.includeAdult ?? false;
      final defaultSortRaw =
          _preferences?.defaultDiscoverSortRaw ?? 'popularity.desc';
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
      final minVotes = _preferences?.defaultMinVoteCount ?? 0;
      final minScore = _preferences?.defaultMinUserScore ?? 0.0;
      final certCountry = _preferences?.certificationCountry;
      final certValue = _preferences?.certificationValue;
      _discoverFilters =
          (_discoverFilters ??
                  DiscoverFilters(
                    sortBy: defaultSort,
                    watchRegion: region,
                    withWatchMonetizationTypes: 'flatrate|rent|buy|ads|free',
                    includeAdult: includeAdultPref,
                    voteCountGte: minVotes > 0 ? minVotes : null,
                    voteAverageGte: minScore > 0 ? minScore : null,
                    certificationCountry: certCountry,
                    certification: certValue,
                  ))
              .copyWith(
                watchRegion: region,
                includeAdult: includeAdultPref,
                voteCountGte: minVotes > 0 ? minVotes : null,
                voteAverageGte: minScore > 0 ? minScore : null,
                certificationCountry: certCountry,
                certification: certValue,
              );

      _resetSectionDurations();
      final responses = await Future.wait<PaginatedResponse<Movie>>([
        _measureSectionFetch(
          section: MovieSection.trending,
          endpoint: _sectionEndpointByType[MovieSection.trending]!,
          request: () => _repository.fetchTrendingMoviesPaginated(
            timeWindow: _trendingWindow,
            page: 1,
          ),
        ),
        _measureSectionFetch(
          section: MovieSection.nowPlaying,
          endpoint: _sectionEndpointByType[MovieSection.nowPlaying]!,
          request: () =>
              _repository.fetchNowPlayingMoviesPaginated(page: 1),
        ),
        _measureSectionFetch(
          section: MovieSection.popular,
          endpoint: _sectionEndpointByType[MovieSection.popular]!,
          request: () => _repository.fetchPopularMoviesPaginated(page: 1),
        ),
        _measureSectionFetch(
          section: MovieSection.topRated,
          endpoint: _sectionEndpointByType[MovieSection.topRated]!,
          request: () => _repository.fetchTopRatedMoviesPaginated(page: 1),
        ),
        _measureSectionFetch(
          section: MovieSection.upcoming,
          endpoint: _sectionEndpointByType[MovieSection.upcoming]!,
          request: () => _repository.fetchUpcomingMoviesPaginated(page: 1),
        ),
        _measureSectionFetch(
          section: MovieSection.discover,
          endpoint: _sectionEndpointByType[MovieSection.discover]!,
          request: () => _repository.discoverMovies(
            page: 1,
            discoverFilters: _discoverFilters,
          ),
        ),
      ]);

      final sectionsList = MovieSection.values;
      for (var index = 0; index < sectionsList.length; index++) {
        final section = sectionsList[index];
        final resp = responses[index];
        final firstPage = <int, List<Movie>>{resp.page: resp.results};
        _sections[section] = MovieSectionState(
          items: _flattenPages(firstPage),
          currentPage: resp.page,
          totalPages: resp.totalPages,
          pages: firstPage,
          inflightPages: const <int>{},
        );
        await _offlineService?.cacheMoviesSection(
          _offlineKeyFor(section),
          resp.results,
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
      _scheduleBackgroundPrefetch();
      notifyListeners();
      if (!_initializedCompleter.isCompleted) {
        _initializedCompleter.complete();
      }
    }
  }

  /// Resets the stored metrics before a new refresh cycle begins so that stale
  /// values never bleed into reporting dashboards or QA screenshots.
  void _resetSectionDurations() {
    for (final section in MovieSection.values) {
      _lastFetchDurationsMs[section] = 0;
    }
  }

  /// Wraps a TMDB request with stopwatch-based telemetry.
  ///
  /// The `endpoint` string must match the documented REST path (for example,
  /// `/3/movie/now_playing`). Captured metrics are logged through
  /// [PerformanceMonitor] and stored locally so that UI layers can expose the
  /// most recent millisecond duration for each section without needing to
  /// listen to debug logs.
  Future<PaginatedResponse<Movie>> _measureSectionFetch({
    required MovieSection section,
    required String endpoint,
    required Future<PaginatedResponse<Movie>> Function() request,
  }) async {
    final operationName = 'movies.${section.name} $endpoint';
    final stopwatch = Stopwatch()..start();
    PerformanceMonitor.startTimer(operationName);
    try {
      final response = await request();
      final elapsed = stopwatch.elapsedMilliseconds;
      _lastFetchDurationsMs[section] = elapsed;
      PerformanceMonitor.logMetric(
        '$operationName.count',
        response.results.length,
      );
      return response;
    } finally {
      stopwatch.stop();
      PerformanceMonitor.stopTimer(operationName, logResult: false);
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

  Future<bool> _tryServeOffline() async {
    final service = _offlineService;
    if (service == null || !(service.isOffline)) {
      return false;
    }

    var hasData = false;
    for (final section in MovieSection.values) {
      final cached = await service.loadMoviesSection(_offlineKeyFor(section));
      if (cached != null && cached.items.isNotEmpty) {
        hasData = true;
        _sections[section] = MovieSectionState(
          items: cached.items,
          currentPage: 1,
          totalPages: 1,
          isLoading: false,
          errorMessage: null,
        );
      } else {
        _sections[section] = _sections[section]!.copyWith(
          isLoading: false,
          errorMessage: AppStrings.offlineCacheUnavailable,
          items: const <Movie>[],
        );
      }
    }

    if (!hasData) {
      _globalError = AppStrings.offlineCacheUnavailable;
      return true;
    }

    _globalError = null;
    _isInitialized = true;
    return true;
  }

  String _offlineKeyFor(MovieSection section) {
    switch (section) {
      case MovieSection.trending:
        return 'trending_${_trendingWindow}';
      case MovieSection.nowPlaying:
        return 'now_playing';
      case MovieSection.popular:
        return 'popular';
      case MovieSection.topRated:
        return 'top_rated';
      case MovieSection.upcoming:
        return 'upcoming';
      case MovieSection.discover:
        return 'discover';
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

  Future<PaginatedResponse<Movie>> _fetchSectionPage(
    MovieSection section,
    int page,
  ) {
    switch (section) {
      case MovieSection.trending:
        return _repository.fetchTrendingMoviesPaginated(
          timeWindow: _trendingWindow,
          page: page,
        );
      case MovieSection.nowPlaying:
        return _repository.fetchNowPlayingMoviesPaginated(page: page);
      case MovieSection.popular:
        return _repository.fetchPopularMoviesPaginated(page: page);
      case MovieSection.topRated:
        return _repository.fetchTopRatedMoviesPaginated(page: page);
      case MovieSection.upcoming:
        return _repository.fetchUpcomingMoviesPaginated(page: page);
      case MovieSection.discover:
        return _repository.discoverMovies(
          page: page,
          discoverFilters: _discoverFilters,
        );
    }
  }

  // Pagination controls
  Future<void> loadPage(MovieSection section, int page) async {
    await _loadSectionPage(
      section,
      page,
      isForeground: true,
      persist: true,
    );
  }

  Future<void> jumpToPage(MovieSection section, int page) =>
      loadPage(section, page);

  Future<void> loadNextPage(MovieSection section) async {
    final state = _sections[section]!;
    if (state.currentPage >= state.totalPages) return;
    await _loadSectionPage(
      section,
      state.currentPage + 1,
      isForeground: false,
      anchorPage: state.currentPage + 1,
      persist: true,
    );
  }

  void clearError() {
    _globalError = null;
    notifyListeners();
  }

  Future<void> prefetchAroundIndex(MovieSection section, int index) async {
    final page = (index ~/ _pageSize) + 1;
    final state = _sections[section]!;
    if (page <= 0 || page > state.totalPages) {
      return;
    }
    await _loadSectionPage(
      section,
      page,
      isForeground: false,
      anchorPage: page,
      persist: false,
    );
  }

  Future<void> _loadSectionPage(
    MovieSection section,
    int page, {
    required bool isForeground,
    int? anchorPage,
    bool persist = false,
  }) async {
    if (page < 1) return;
    final state = _sections[section]!;
    if (_isPageInflight(section, page)) {
      return;
    }

    if (!isForeground && state.pages.containsKey(page)) {
      return;
    }

    _setPageInflight(section, page, true);
    final inflight = {...state.inflightPages, page};

    if (isForeground) {
      _sections[section] = state.copyWith(
        isLoading: true,
        errorMessage: null,
        inflightPages: inflight,
      );
    } else {
      _sections[section] = state.copyWith(
        isLoadingMore: true,
        inflightPages: inflight,
      );
    }
    notifyListeners();

    try {
      final response = await _fetchSectionPage(section, page);
      final mergedPages = Map<int, List<Movie>>.from(state.pages);
      mergedPages[page] = response.results;
      final trimmed = _trimPages(mergedPages, anchorPage ?? page);
      final flattened = _flattenPages(trimmed);
      final updatedInflight = {...inflight}..remove(page);

      _sections[section] = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        items: flattened,
        currentPage: isForeground ? page : state.currentPage,
        totalPages: response.totalPages,
        errorMessage: null,
        pages: trimmed,
        inflightPages: updatedInflight,
      );

      if (persist && isForeground) {
        _storage?.setPageIndex('movies', section.name, page);
      }
    } catch (error) {
      final updatedInflight = {...inflight}..remove(page);
      _sections[section] = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        errorMessage: '$error',
        inflightPages: updatedInflight,
      );
    } finally {
      _setPageInflight(section, page, false);
      notifyListeners();
    }
  }

  void _scheduleBackgroundPrefetch() {
    _backgroundPrefetchTimer?.cancel();
    _backgroundPrefetchTimer = Timer.periodic(
      const Duration(minutes: 10),
      (_) => _runBackgroundPrefetch(),
    );
  }

  Future<void> _runBackgroundPrefetch() async {
    for (final section in MovieSection.values) {
      final state = _sections[section]!;
      if (state.currentPage < state.totalPages) {
        await _loadSectionPage(
          section,
          state.currentPage + 1,
          isForeground: false,
          anchorPage: state.currentPage + 1,
          persist: false,
        );
      }
    }
  }

  @override
  void dispose() {
    _backgroundPrefetchTimer?.cancel();
    super.dispose();
  }
}
