import 'package:flutter/material.dart';
import 'dart:async';

import '../data/models/movie.dart';
import '../data/models/paginated_response.dart';
import '../data/tmdb_repository.dart';
import 'preferences_provider.dart';

enum SeriesSection { trending, popular, topRated, airingToday, onTheAir }

enum TvFilterPersistenceAction { keep, save, clear }

class SeriesSectionState {
  const SeriesSectionState({
    this.items = const <Movie>[],
    this.isLoading = false,
    this.errorMessage,
    this.currentPage = 1,
    this.totalPages = 1,
    this.pageResults = const <int, List<Movie>>{},
  });

  static const _sentinel = Object();

  final List<Movie> items;
  final bool isLoading;
  final String? errorMessage;
  final int currentPage;
  final int totalPages;
  final Map<int, List<Movie>> pageResults;

  SeriesSectionState copyWith({
    List<Movie>? items,
    bool? isLoading,
    Object? errorMessage = _sentinel,
    int? currentPage,
    int? totalPages,
    Map<int, List<Movie>>? pageResults,
  }) {
    return SeriesSectionState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      pageResults: pageResults ?? this.pageResults,
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
  Map<String, String>? _activeFilters;
  String? _activePresetName;

  final Completer<void> _initializedCompleter = Completer<void>();

  Map<SeriesSection, SeriesSectionState> get sections => _sections;
  bool get isInitialized => _isInitialized;
  bool get isRefreshing => _isRefreshing;
  String? get globalError => _globalError;
  int? get activeNetworkId => _activeNetworkId;
  Map<String, String>? get activeFilters => _activeFilters;
  String? get activePresetName => _activePresetName;

  Future<void> get initialized => _initializedCompleter.future;

  SeriesSectionState sectionState(SeriesSection section) => _sections[section]!;

  bool canGoNext(SeriesSection section) {
    final state = sectionState(section);
    return !state.isLoading && state.currentPage < state.totalPages;
  }

  bool canGoPrev(SeriesSection section) {
    final state = sectionState(section);
    return !state.isLoading && state.currentPage > 1;
  }

  Future<void> _init() async {
    _restorePersistedFilters();
    await refresh(force: true);
  }

  void _restorePersistedFilters() {
    final saved = _preferences?.tvDiscoverFilterPreset;
    if (saved != null && saved.isNotEmpty) {
      _activeFilters = Map<String, String>.from(saved);
      _activeNetworkId = null;
    }
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
      final sectionsList = SeriesSection.values;
      final futures = <Future<PaginatedResponse<Movie>>>[];
      final previousStates = <SeriesSection, SeriesSectionState>{};
      for (final section in sectionsList) {
        final state = _sections[section]!;
        previousStates[section] = state;
        final desiredPage = force ? 1 : state.currentPage;
        futures.add(_fetchSection(section, page: desiredPage));
      }

      final results = await Future.wait(futures);

      for (var index = 0; index < sectionsList.length; index++) {
        final section = sectionsList[index];
        final response = results[index];
        final pageItems = List<Movie>.unmodifiable(response.results);
        final previousState = previousStates[section]!;
        final updatedPages = force
            ? <int, List<Movie>>{}
            : Map<int, List<Movie>>.from(previousState.pageResults);
        updatedPages[response.page] = pageItems;
        _sections[section] = SeriesSectionState(
          items: pageItems,
          currentPage: response.page,
          totalPages: response.totalPages,
          pageResults: Map<int, List<Movie>>.unmodifiable(updatedPages),
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

  Future<PaginatedResponse<Movie>> _fetchSection(
    SeriesSection section, {
    int page = 1,
  }) {
    switch (section) {
      case SeriesSection.trending:
        return _repository.fetchTrendingTv(page: page);
      case SeriesSection.popular:
        if (_activeNetworkId != null) {
          return _repository.fetchNetworkTvShows(
            networkId: _activeNetworkId!,
            page: page,
          );
        }
        if (_activeFilters != null) {
          return _repository.discoverTvSeries(
            page: page,
            filters: _activeFilters,
          );
        }
        return _repository.fetchPopularTv(page: page);
      case SeriesSection.topRated:
        return _repository.fetchTopRatedTv(page: page);
      case SeriesSection.airingToday:
        return _repository.fetchAiringTodayTv(page: page);
      case SeriesSection.onTheAir:
        return _repository.fetchOnTheAirTv(page: page);
    }
  }

  Future<void> loadNextPage(SeriesSection section) {
    final nextPage = sectionState(section).currentPage + 1;
    return loadSectionPage(section, nextPage);
  }

  Future<void> loadPreviousPage(SeriesSection section) {
    final previousPage = sectionState(section).currentPage - 1;
    return loadSectionPage(section, previousPage);
  }

  Future<void> refreshSection(SeriesSection section) {
    final currentPage = sectionState(section).currentPage;
    return loadSectionPage(section, currentPage, forceReload: true);
  }

  Future<void> loadSectionPage(
    SeriesSection section,
    int page, {
    bool forceReload = false,
  }) async {
    final currentState = sectionState(section);
    if (!forceReload && page == currentState.currentPage) {
      return;
    }
    if (page < 1 || page > currentState.totalPages) {
      _sections[section] = currentState.copyWith(
        errorMessage: 'Requested page $page is out of range.',
      );
      notifyListeners();
      return;
    }

    if (!forceReload && currentState.pageResults.containsKey(page)) {
      _sections[section] = currentState.copyWith(
        currentPage: page,
        items: currentState.pageResults[page],
        errorMessage: null,
      );
      notifyListeners();
      return;
    }

    _sections[section] = currentState.copyWith(
      isLoading: true,
      errorMessage: null,
    );
    notifyListeners();

    try {
      final response = await _fetchSection(section, page: page);
      final nextPageItems = List<Movie>.unmodifiable(response.results);
      final updatedPages = Map<int, List<Movie>>.from(currentState.pageResults)
        ..[response.page] = nextPageItems;
      _sections[section] = SeriesSectionState(
        items: nextPageItems,
        currentPage: response.page,
        totalPages: response.totalPages,
        pageResults: Map<int, List<Movie>>.unmodifiable(updatedPages),
      );
    } on TmdbException catch (error) {
      _sections[section] = currentState.copyWith(
        isLoading: false,
        errorMessage: error.message,
      );
    } catch (error) {
      _sections[section] = currentState.copyWith(
        isLoading: false,
        errorMessage: '$error',
      );
    } finally {
      notifyListeners();
    }
  }

  void _setErrorForAll(String? message) {
    for (final section in SeriesSection.values) {
      _sections[section] = _sections[section]!.copyWith(
        isLoading: false,
        errorMessage: message,
        items: const <Movie>[],
        currentPage: 1,
        totalPages: 1,
        pageResults: const <int, List<Movie>>{},
      );
    }
  }

  Future<void> applyNetworkFilter(int networkId) async {
    _activeNetworkId = networkId;
    _activeFilters = null;
    _sections[SeriesSection.popular] = _sections[SeriesSection.popular]!.copyWith(
      isLoading: true,
      errorMessage: null,
      items: const <Movie>[],
      pageResults: const <int, List<Movie>>{},
    );
    notifyListeners();

    try {
      final response = await _repository.fetchNetworkTvShows(
        networkId: networkId,
      );
      final pageItems = List<Movie>.unmodifiable(response.results);
      _sections[SeriesSection.popular] = SeriesSectionState(
        items: pageItems,
        currentPage: response.page,
        totalPages: response.totalPages,
        pageResults: Map<int, List<Movie>>.unmodifiable({
          response.page: pageItems,
        }),
      );
    } catch (error) {
      _sections[SeriesSection.popular] = _sections[SeriesSection.popular]!
          .copyWith(
            isLoading: false,
            errorMessage: '$error',
            items: const <Movie>[],
            currentPage: 1,
            totalPages: 1,
            pageResults: const <int, List<Movie>>{},
          );
    } finally {
      notifyListeners();
    }
  }

  Future<void> applyTvFilters(
    Map<String, String> filters, {
    String? presetName,
  }) async {
    _activeFilters = Map<String, String>.from(filters);
    _activeNetworkId = null;
    _sections[SeriesSection.popular] = _sections[SeriesSection.popular]!.copyWith(
      isLoading: true,
      errorMessage: null,
      items: const <Movie>[],
      pageResults: const <int, List<Movie>>{},
    );
    notifyListeners();
    try {
      final response = await _repository.discoverTvSeries(filters: filters);
      final pageItems = List<Movie>.unmodifiable(response.results);
      _sections[SeriesSection.popular] = SeriesSectionState(
        items: pageItems,
        currentPage: response.page,
        totalPages: response.totalPages,
        pageResults: Map<int, List<Movie>>.unmodifiable({
          response.page: pageItems,
        }),
      );
    } catch (error) {
      _sections[SeriesSection.popular] = _sections[SeriesSection.popular]!
          .copyWith(
            isLoading: false,
            errorMessage: '$error',
            items: const <Movie>[],
            currentPage: 1,
            totalPages: 1,
            pageResults: const <int, List<Movie>>{},
          );
    } finally {
      notifyListeners();
    }
  }

  Future<void> clearTvFilters() async {
    _activeFilters = null;
    _activeNetworkId = null;
    final prefs = _preferences;
    if (prefs != null) {
      await prefs.setTvDiscoverFilterPreset(null);
    }
    final currentState = _sections[SeriesSection.popular]!;
    _sections[SeriesSection.popular] = currentState.copyWith(
      isLoading: true,
      errorMessage: null,
      items: const <Movie>[],
      currentPage: 1,
      totalPages: 1,
    );
    notifyListeners();

    try {
      final response = await _repository.fetchPopularTv(page: 1);
      _sections[SeriesSection.popular] = SeriesSectionState(
        items: response.results,
        currentPage: response.page,
        totalPages: response.totalPages,
      );
    } catch (error) {
      _sections[SeriesSection.popular] = currentState.copyWith(
        isLoading: false,
        errorMessage: '$error',
        items: const <Movie>[],
        currentPage: 1,
        totalPages: 1,
      );
    } finally {
      notifyListeners();
    }
  }

  Future<void> clearNetworkFilter() async {
    if (_activeNetworkId == null) return;
    _activeNetworkId = null;
    _activeFilters = null;
    _activePresetName = null;
    await refresh(force: true);
  }
}
