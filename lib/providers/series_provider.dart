import 'package:flutter/material.dart';
import 'dart:async';

import '../data/models/movie.dart';
import '../data/models/paginated_response.dart';
import '../data/tmdb_repository.dart';
import 'preferences_provider.dart';

enum SeriesSection { trending, popular, topRated, airingToday, onTheAir }

class SeriesSectionState {
  const SeriesSectionState({
    this.items = const <Movie>[],
    this.isLoading = false,
    this.errorMessage,
    this.currentPage = 0,
    this.totalPages = 0,
  });

  static const _sentinel = Object();

  final List<Movie> items;
  final bool isLoading;
  final String? errorMessage;
  final int currentPage;
  final int totalPages;

  SeriesSectionState copyWith({
    List<Movie>? items,
    bool? isLoading,
    Object? errorMessage = _sentinel,
    int? currentPage,
    int? totalPages,
  }) {
    return SeriesSectionState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}

class SeriesProvider extends ChangeNotifier {
  SeriesProvider(
    this._repository, {
    PreferencesProvider? preferencesProvider,
    bool autoInitialize = true,
  }) {
    _preferences = preferencesProvider;
    if (autoInitialize) {
      _init();
    }
  }

  final TmdbRepository _repository;
  PreferencesProvider? _preferences;

  final Map<SeriesSection, SeriesSectionState> _sections = {
    for (final section in SeriesSection.values)
      section: const SeriesSectionState(),
  };

  bool _isInitialized = false;
  bool _isRefreshing = false;
  String? _globalError;
  int? _activeNetworkId;
  Map<String, String>? _activeTvFilters;

  final Completer<void> _initializedCompleter = Completer<void>();

  Map<SeriesSection, SeriesSectionState> get sections => _sections;
  bool get isInitialized => _isInitialized;
  bool get isRefreshing => _isRefreshing;
  String? get globalError => _globalError;
  int? get activeNetworkId => _activeNetworkId;
  Map<String, String>? get activeTvFilters => _activeTvFilters;

  Future<void> get initialized => _initializedCompleter.future;

  SeriesSectionState sectionState(SeriesSection section) => _sections[section]!;

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
    for (final section in SeriesSection.values) {
      _sections[section] = _sections[section]!.copyWith(
        isLoading: true,
        errorMessage: null,
      );
    }
    notifyListeners();

    try {
      final targetPages = {
        for (final section in SeriesSection.values)
          section: _sections[section]!.currentPage <= 0
              ? 1
              : _sections[section]!.currentPage,
      };

      final responses = await Future.wait<PaginatedResponse<Movie>>([
        _repository.fetchTrendingTvPaginated(
          page: targetPages[SeriesSection.trending]!,
        ),
        _loadPopularSeries(page: targetPages[SeriesSection.popular]!),
        _repository.fetchTopRatedTvPaginated(
          page: targetPages[SeriesSection.topRated]!,
        ),
        _repository.fetchAiringTodayTvPaginated(
          page: targetPages[SeriesSection.airingToday]!,
        ),
        _repository.fetchOnTheAirTvPaginated(
          page: targetPages[SeriesSection.onTheAir]!,
        ),
      ]);

      final sectionsList = SeriesSection.values;
      for (var index = 0; index < sectionsList.length; index++) {
        final section = sectionsList[index];
        final response = responses[index];
        _sections[section] = SeriesSectionState(
          items: response.results,
          currentPage: response.page,
          totalPages: response.totalPages,
        );
      }

      _globalError = null;
      _isInitialized = true;
    } on TmdbException catch (error) {
      _globalError = error.message;
      _setErrorForAll(error.message);
    } catch (error) {
      _globalError = 'Failed to load series: $error';
      _setErrorForAll(_globalError);
    } finally {
      _isRefreshing = false;
      notifyListeners();
      if (!_initializedCompleter.isCompleted) {
        _initializedCompleter.complete();
      }
    }
  }

  Future<PaginatedResponse<Movie>> _loadPopularSeries({required int page}) {
    if (_activeNetworkId != null) {
      return _repository.fetchNetworkTvShows(
        networkId: _activeNetworkId!,
        page: page,
      );
    }

    if (_activeTvFilters != null) {
      return _repository.discoverTvSeries(
        page: page,
        filters: _activeTvFilters,
      );
    }

    return _repository.fetchPopularTvPaginated(page: page);
  }

  void _setErrorForAll(String? message) {
    for (final section in SeriesSection.values) {
      _sections[section] = _sections[section]!.copyWith(
        isLoading: false,
        errorMessage: message,
        items: const <Movie>[],
        currentPage: 0,
        totalPages: 0,
      );
    }
  }

  Future<void> applyNetworkFilter(int networkId) async {
    _activeNetworkId = networkId;
    _activeTvFilters = null;
    await loadPage(SeriesSection.popular, 1);
  }

  Future<void> applyTvFilters(Map<String, String> filters) async {
    _activeNetworkId = null;
    _activeTvFilters = Map<String, String>.from(filters);
    await loadPage(SeriesSection.popular, 1);
  }

  Future<void> clearNetworkFilter() async {
    if (_activeNetworkId == null) return;
    _activeNetworkId = null;
    _activeTvFilters = null;
    await refresh(force: true);
  }

  Future<void> loadPage(SeriesSection section, int page) async {
    if (page < 1) return;
    final state = _sections[section]!;
    if (state.isLoading) return;
    if (state.currentPage == page && state.items.isNotEmpty) return;

    _sections[section] = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );
    notifyListeners();

    try {
      PaginatedResponse<Movie> response;
      switch (section) {
        case SeriesSection.trending:
          response = await _repository.fetchTrendingTvPaginated(page: page);
          break;
        case SeriesSection.popular:
          response = await _loadPopularSeries(page: page);
          break;
        case SeriesSection.topRated:
          response = await _repository.fetchTopRatedTvPaginated(page: page);
          break;
        case SeriesSection.airingToday:
          response = await _repository.fetchAiringTodayTvPaginated(page: page);
          break;
        case SeriesSection.onTheAir:
          response = await _repository.fetchOnTheAirTvPaginated(page: page);
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

  Future<void> jumpToPage(SeriesSection section, int page) =>
      loadPage(section, page);

  Future<void> loadNextPage(SeriesSection section) async {
    final state = _sections[section]!;
    if (state.currentPage >= state.totalPages) return;
    await loadPage(section, state.currentPage + 1);
  }
}
