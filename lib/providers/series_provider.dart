import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import '../data/models/movie.dart';
import '../data/tmdb_repository.dart';
import 'preferences_provider.dart';

enum SeriesSection { trending, popular, topRated, airingToday, onTheAir }

class SeriesSectionState {
  const SeriesSectionState({
    this.items = const <Movie>[],
    this.isLoading = false,
    this.errorMessage,
  });

  static const _sentinel = Object();

  final List<Movie> items;
  final bool isLoading;
  final String? errorMessage;

  SeriesSectionState copyWith({
    List<Movie>? items,
    bool? isLoading,
    Object? errorMessage = _sentinel,
  }) {
    return SeriesSectionState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
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
  Map<String, String> _savedFilters = const {};

  final Map<SeriesSection, SeriesSectionState> _sections = {
    for (final section in SeriesSection.values)
      section: const SeriesSectionState(),
  };

  bool _isInitialized = false;
  bool _isRefreshing = false;
  String? _globalError;
  int? _activeNetworkId;

  final Completer<void> _initializedCompleter = Completer<void>();

  Map<SeriesSection, SeriesSectionState> get sections => _sections;
  bool get isInitialized => _isInitialized;
  bool get isRefreshing => _isRefreshing;
  String? get globalError => _globalError;
  int? get activeNetworkId => _activeNetworkId;
  Map<String, String> get savedFilters => Map.unmodifiable(_savedFilters);

  Future<void> get initialized => _initializedCompleter.future;

  SeriesSectionState sectionState(SeriesSection section) => _sections[section]!;

  Future<void> _init() async {
    await loadSavedFilters();
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
      final includeAdult = _preferences?.includeAdult ?? false;
      final results = await Future.wait<List<Movie>>([
        _repository.fetchTrendingTv(forceRefresh: false),
        _loadPopularSeries(),
        _repository.fetchTopRatedTv(),
        _repository.fetchAiringTodayTv(),
        _repository.fetchOnTheAirTv(),
      ]);

      final sectionsList = SeriesSection.values;
      for (var index = 0; index < sectionsList.length; index++) {
        final section = sectionsList[index];
        final sectionItems = results[index];
        _sections[section] = SeriesSectionState(items: sectionItems);
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

  Future<List<Movie>> _loadPopularSeries() async {
    if (_activeNetworkId != null) {
      final response = await _repository.fetchNetworkTvShows(
        networkId: _activeNetworkId!,
      );
      return response.results;
    }
    if (_savedFilters.isNotEmpty) {
      final response = await _repository.discoverTvSeries(
        filters: _savedFilters,
      );
      return response.results;
    }
    return _repository.fetchPopularTv();
  }

  void _setErrorForAll(String? message) {
    for (final section in SeriesSection.values) {
      _sections[section] = _sections[section]!.copyWith(
        isLoading: false,
        errorMessage: message,
        items: const <Movie>[],
      );
    }
  }

  Future<void> applyNetworkFilter(int networkId) async {
    _activeNetworkId = networkId;
    _sections[SeriesSection.popular] = _sections[SeriesSection.popular]!
        .copyWith(isLoading: true, errorMessage: null, items: const <Movie>[]);
    notifyListeners();

    try {
      final response = await _repository.fetchNetworkTvShows(
        networkId: networkId,
      );
      _sections[SeriesSection.popular] = SeriesSectionState(
        items: response.results,
      );
    } catch (error) {
      _sections[SeriesSection.popular] = _sections[SeriesSection.popular]!
          .copyWith(
            isLoading: false,
            errorMessage: '$error',
            items: const <Movie>[],
          );
    } finally {
      notifyListeners();
    }
  }

  Future<void> applyTvFilters(Map<String, String> filters) async {
    _activeNetworkId = null;
    _sections[SeriesSection.popular] = _sections[SeriesSection.popular]!
        .copyWith(isLoading: true, errorMessage: null, items: const <Movie>[]);
    notifyListeners();
    try {
      final response = await _repository.discoverTvSeries(filters: filters);
      _sections[SeriesSection.popular] = SeriesSectionState(
        items: response.results,
      );
      await saveFilters(filters, notify: false);
    } catch (error) {
      _sections[SeriesSection.popular] = _sections[SeriesSection.popular]!
          .copyWith(
            isLoading: false,
            errorMessage: '$error',
            items: const <Movie>[],
          );
    } finally {
      notifyListeners();
    }
  }

  Future<Map<String, String>> loadSavedFilters() async {
    final prefs = _preferences;
    if (prefs == null) {
      _savedFilters = const <String, String>{};
      return savedFilters;
    }

    final stored = prefs.seriesFiltersJson;
    if (stored == null || stored.isEmpty) {
      _savedFilters = const <String, String>{};
      return savedFilters;
    }

    try {
      final decoded = jsonDecode(stored);
      if (decoded is Map) {
        final normalized = <String, String>{};
        decoded.forEach((key, value) {
          if (key == null || value == null) return;
          normalized[key.toString()] = value.toString();
        });
        _savedFilters = normalized;
      } else {
        _savedFilters = const <String, String>{};
      }
    } catch (_) {
      _savedFilters = const <String, String>{};
    }

    return savedFilters;
  }

  Future<void> saveFilters(
    Map<String, String> filters, {
    bool notify = true,
  }) async {
    final normalized = Map<String, String>.from(filters);
    final changed = !mapEquals(_savedFilters, normalized);
    _savedFilters = normalized;

    final prefs = _preferences;
    if (prefs != null) {
      if (_savedFilters.isEmpty) {
        await prefs.setSeriesFiltersJson(null);
      } else {
        await prefs.setSeriesFiltersJson(jsonEncode(_savedFilters));
      }
    }

    if (changed && notify) {
      notifyListeners();
    }
  }

  Future<void> clearSavedFilters({bool notify = true}) async {
    if (_savedFilters.isEmpty) {
      final prefs = _preferences;
      if (prefs != null && prefs.seriesFiltersJson != null) {
        await prefs.setSeriesFiltersJson(null);
        if (notify) {
          notifyListeners();
        }
      }
      return;
    }

    await saveFilters(const <String, String>{}, notify: notify);
  }

  Future<void> clearNetworkFilter() async {
    if (_activeNetworkId == null) return;
    _activeNetworkId = null;
    await refresh(force: true);
  }
}
