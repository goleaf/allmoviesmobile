import 'package:flutter/material.dart';

import '../data/models/movie.dart';
import '../data/tmdb_repository.dart';
import '../data/models/discover_filters_model.dart';
import 'watch_region_provider.dart';

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
  });

  static const _sentinel = Object();

  final List<Movie> items;
  final bool isLoading;
  final String? errorMessage;

  MovieSectionState copyWith({
    List<Movie>? items,
    bool? isLoading,
    Object? errorMessage = _sentinel,
  }) {
    return MovieSectionState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

class MoviesProvider extends ChangeNotifier {
  MoviesProvider(this._repository, {WatchRegionProvider? regionProvider}) {
    _regionProvider = regionProvider;
    _init();
  }

  final TmdbRepository _repository;
  WatchRegionProvider? _regionProvider;

  // Trending window: 'day' or 'week'
  String _trendingWindow = 'day';
  String get trendingWindow => _trendingWindow;
  void setTrendingWindow(String window) {
    if (window != 'day' && window != 'week') return;
    if (_trendingWindow == window) return;
    _trendingWindow = window;
    refresh(force: true);
  }

  void bindRegionProvider(WatchRegionProvider provider) {
    _regionProvider = provider;
    notifyListeners();
  }

  final Map<MovieSection, MovieSectionState> _sections = {
    for (final section in MovieSection.values) section: const MovieSectionState(),
  };

  bool _isInitialized = false;
  bool _isRefreshing = false;
  String? _globalError;

  Map<MovieSection, MovieSectionState> get sections => _sections;
  bool get isInitialized => _isInitialized;
  bool get isRefreshing => _isRefreshing;
  String? get globalError => _globalError;

  MovieSectionState sectionState(MovieSection section) => _sections[section]!;

  Future<void> _init() async {
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
      _sections[section] = _sections[section]!.copyWith(isLoading: true, errorMessage: null);
    }
    notifyListeners();

    try {
      final region = _regionProvider?.region;
      final discoverFilters = DiscoverFilters(
        sortBy: SortBy.popularityDesc,
        watchRegion: region,
        withWatchMonetizationTypes: 'flatrate|rent|buy|ads|free',
      );

      final results = await Future.wait<List<Movie>>([
        _repository.fetchTrendingMovies(timeWindow: _trendingWindow),
        _repository.fetchNowPlayingMovies(),
        _repository.fetchPopularMovies(),
        _repository.fetchTopRatedMovies(),
        _repository.fetchUpcomingMovies(),
        _repository
            .discoverMovies(discoverFilters: discoverFilters)
            .then((r) => r.results),
      ]);

      final sectionsList = MovieSection.values;
      for (var index = 0; index < sectionsList.length; index++) {
        final section = sectionsList[index];
        final sectionItems = results[index];
        _sections[section] = MovieSectionState(items: sectionItems);
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
      final response = await _repository.discoverMovies(discoverFilters: filters);
      _sections[MovieSection.discover] = MovieSectionState(items: response.results);
    } catch (error) {
      _sections[MovieSection.discover] = _sections[MovieSection.discover]!
          .copyWith(isLoading: false, errorMessage: '$error', items: const <Movie>[]);
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
      final response = await _repository.discoverMovies(discoverFilters: enriched);
      _sections[MovieSection.discover] = MovieSectionState(items: response.results);
    } catch (error) {
      _sections[MovieSection.discover] = _sections[MovieSection.discover]!
          .copyWith(isLoading: false, errorMessage: '$error', items: const <Movie>[]);
    } finally {
      notifyListeners();
    }
  }

  void clearError() {
    _globalError = null;
    notifyListeners();
  }
}
