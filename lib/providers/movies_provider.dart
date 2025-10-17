import 'package:flutter/material.dart';

import '../data/models/movie.dart';
import '../data/tmdb_repository.dart';

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
  MoviesProvider(this._repository) {
    _init();
  }

  final TmdbRepository _repository;

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
      final results = await Future.wait<List<Movie>>([
        _repository.fetchTrendingMovies(),
        _repository.fetchNowPlayingMovies(),
        _repository.fetchPopularMovies(),
        _repository.fetchTopRatedMovies(),
        _repository.fetchUpcomingMovies(),
        _repository.discoverMovies(sortBy: 'popularity.desc'),
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
      return await _repository.searchMovies(query);
    } catch (error) {
      _globalError = 'Search failed: $error';
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _globalError = null;
    notifyListeners();
  }
}
