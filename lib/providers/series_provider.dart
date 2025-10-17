import 'package:flutter/material.dart';

import '../data/models/movie.dart';
import '../data/tmdb_repository.dart';

enum SeriesSection {
  trending,
  popular,
  topRated,
  airingToday,
  onTheAir,
}

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
      errorMessage:
          errorMessage == _sentinel ? this.errorMessage : errorMessage as String?,
    );
  }
}

class SeriesProvider extends ChangeNotifier {
  SeriesProvider(this._repository) {
    _init();
  }

  final TmdbRepository _repository;

  final Map<SeriesSection, SeriesSectionState> _sections = {
    for (final section in SeriesSection.values) section: const SeriesSectionState(),
  };

  bool _isInitialized = false;
  bool _isRefreshing = false;
  String? _globalError;
  int? _activeNetworkId;

  Map<SeriesSection, SeriesSectionState> get sections => _sections;
  bool get isInitialized => _isInitialized;
  bool get isRefreshing => _isRefreshing;
  String? get globalError => _globalError;
  int? get activeNetworkId => _activeNetworkId;

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
      _sections[section] =
          _sections[section]!.copyWith(isLoading: true, errorMessage: null);
    }
    notifyListeners();

    try {
      final results = await Future.wait<List<Movie>>([
        _repository.fetchTrendingTv(),
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
    }
  }

  Future<List<Movie>> _loadPopularSeries() async {
    if (_activeNetworkId != null) {
      final response = await _repository.fetchNetworkTvShows(
        networkId: _activeNetworkId!,
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
      final response = await _repository.fetchNetworkTvShows(networkId: networkId);
      _sections[SeriesSection.popular] = SeriesSectionState(items: response.results);
    } catch (error) {
      _sections[SeriesSection.popular] = _sections[SeriesSection.popular]!
          .copyWith(isLoading: false, errorMessage: '$error', items: const <Movie>[]);
    } finally {
      notifyListeners();
    }
  }

  Future<void> applyTvFilters(Map<String, String> filters) async {
    _sections[SeriesSection.popular] = _sections[SeriesSection.popular]!
        .copyWith(isLoading: true, errorMessage: null, items: const <Movie>[]);
    notifyListeners();
    try {
      final response = await _repository.discoverTvSeries(filters: filters);
      _sections[SeriesSection.popular] = SeriesSectionState(items: response.results);
    } catch (error) {
      _sections[SeriesSection.popular] = _sections[SeriesSection.popular]!
          .copyWith(isLoading: false, errorMessage: '$error', items: const <Movie>[]);
    } finally {
      notifyListeners();
    }
  }

  Future<void> clearNetworkFilter() async {
    if (_activeNetworkId == null) return;
    _activeNetworkId = null;
    await refresh(force: true);
  }
}
