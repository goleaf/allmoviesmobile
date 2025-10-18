import 'package:flutter/material.dart';
import 'dart:async';

import '../data/models/movie.dart';
import '../data/models/paginated_response.dart';
import '../data/models/tv_discover_filters.dart';
import '../data/models/tv_ref_model.dart';
import '../data/services/offline_service.dart';
import '../data/tmdb_repository.dart';
import '../core/constants/app_strings.dart';
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
    OfflineService? offlineService,
    bool autoInitialize = true,
  }) : _offlineService = offlineService {
    _preferences = preferencesProvider;
    if (autoInitialize) {
      _init();
    }
  }

  final TmdbRepository _repository;
  PreferencesProvider? _preferences;
  final OfflineService? _offlineService;

  final Map<SeriesSection, SeriesSectionState> _sections = {
    for (final section in SeriesSection.values)
      section: const SeriesSectionState(),
  };

  bool _isInitialized = false;
  bool _isRefreshing = false;
  String? _globalError;
  int? _activeNetworkId;
  TvDiscoverFilters? _activeFilters;
  String? _activePresetName;

  final Completer<void> _initializedCompleter = Completer<void>();

  Map<SeriesSection, SeriesSectionState> get sections => _sections;
  bool get isInitialized => _isInitialized;
  bool get isRefreshing => _isRefreshing;
  String? get globalError => _globalError;
  int? get activeNetworkId => _activeNetworkId;
  TvDiscoverFilters? get activeFilters => _activeFilters;
  String? get activePresetName => _activePresetName;

  /// Allows late binding of [PreferencesProvider] after the provider is
  /// constructed so we can restore persisted discover filters immediately.
  void bindPreferencesProvider(PreferencesProvider? provider) {
    _preferences = provider;
    if (provider != null) {
      _restorePersistedFilters();
    }
  }

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

  /// Load any discover filters stored in preferences so pagination restarts
  /// from the same `/3/discover/tv` query the user last applied.
  void _restorePersistedFilters() {
    final saved = _preferences?.tvDiscoverFilterPreset;
    if (saved != null) {
      _activeFilters = saved.filters;
      final name = saved.name.trim();
      _activePresetName = name.isEmpty ? null : name;
      _activeNetworkId = null;
    } else {
      _activeFilters = null;
      _activePresetName = null;
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
      final servedOffline = await _tryServeOffline();
      if (servedOffline && (_offlineService?.isOffline ?? false)) {
        _isRefreshing = false;
        if (!_initializedCompleter.isCompleted) {
          _initializedCompleter.complete();
        }
        notifyListeners();
        return;
      }

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
        await _offlineService?.cacheTvSection(
          _offlineKeyFor(section),
          response.results
              .map((item) => TVRef(
                    id: item.id,
                    name: item.title,
                    posterPath: item.posterPath,
                    backdropPath: item.backdropPath,
                    voteAverage: item.voteAverage,
                    firstAirDate: item.releaseDate,
                  ))
              .toList(growable: false),
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
            filters: _activeFilters!.toQueryParameters(),
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

  Future<bool> _tryServeOffline() async {
    final service = _offlineService;
    if (service == null || !(service.isOffline)) {
      return false;
    }

    var hasData = false;
    for (final section in SeriesSection.values) {
      final cached = await service.loadTvSection(_offlineKeyFor(section));
      if (cached != null && cached.items.isNotEmpty) {
        hasData = true;
        final movies = cached.items
            .map(
              (show) => Movie(
                id: show.id,
                title: show.name,
                posterPath: show.posterPath,
                backdropPath: show.backdropPath,
                voteAverage: show.voteAverage,
                releaseDate: show.firstAirDate,
                mediaType: 'tv',
              ),
            )
            .toList(growable: false);
        _sections[section] = SeriesSectionState(
          items: movies,
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

  String _offlineKeyFor(SeriesSection section) {
    switch (section) {
      case SeriesSection.trending:
        return 'trending';
      case SeriesSection.popular:
        return 'popular_${_activeNetworkId ?? 'all'}';
      case SeriesSection.topRated:
        return 'top_rated';
      case SeriesSection.airingToday:
        return 'airing_today';
      case SeriesSection.onTheAir:
        return 'on_the_air';
    }
  }

  /// Focus the popular tab on a single network by leveraging
  /// `/3/discover/tv?with_networks=` underneath.
  Future<void> applyNetworkFilter(int networkId) async {
    _activeNetworkId = networkId;
    _activeFilters = null;
    _activePresetName = null;
    await _preferences?.setTvDiscoverFilterPreset(null);
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

  /// Apply a custom set of TMDB `/3/discover/tv` parameters and optionally tag
  /// them with the preset the user selected from the sheet.
  Future<void> applyTvFilters(
    TvDiscoverFilters filters, {
    String? presetName,
  }) async {
    _activeFilters = filters;
    _activeNetworkId = null;
    _activePresetName = presetName;
    _sections[SeriesSection.popular] = _sections[SeriesSection.popular]!.copyWith(
      isLoading: true,
      errorMessage: null,
      items: const <Movie>[],
      pageResults: const <int, List<Movie>>{},
    );
    notifyListeners();
    try {
      final response = await _repository.discoverTvSeries(
        filters: filters.toQueryParameters(),
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
      final prefs = _preferences;
      if (prefs != null) {
        final name = presetName ?? '';
        await prefs.setTvDiscoverFilterPreset(
          TvDiscoverFilterPreset(name: name, filters: filters),
        );
      }
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

  /// Reset back to `/3/tv/popular` by clearing any discover filters and the
  /// stored preset reference.
  Future<void> clearTvFilters() async {
    _activeFilters = null;
    _activeNetworkId = null;
    _activePresetName = null;
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

  /// Remove the focused network and return to the vanilla `/3/tv/popular`
  /// results.
  Future<void> clearNetworkFilter() async {
    if (_activeNetworkId == null) return;
    _activeNetworkId = null;
    _activeFilters = null;
    _activePresetName = null;
    await _preferences?.setTvDiscoverFilterPreset(null);
    await refresh(force: true);
  }
}
