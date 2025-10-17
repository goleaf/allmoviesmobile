import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../data/models/movie.dart';
import '../data/repositories/movie_repository.dart';
import '../data/services/tmdb_api_service.dart';

enum MovieFilterOption { all, trending, popular }

enum MovieSortOption { popularity, rating, releaseDate, title }

class MoviesProvider extends ChangeNotifier {
  MoviesProvider({required this.repository});

  final MovieRepository repository;

  bool _isLoading = false;
  String? _errorMessage;
  MovieFilterOption _selectedFilter = MovieFilterOption.all;
  MovieSortOption _selectedSort = MovieSortOption.popularity;
  String _searchQuery = '';

  final Map<MovieCollection, List<Movie>> _movieCollections = {
    MovieCollection.trending: const [],
    MovieCollection.popular: const [],
  };

  final List<Movie> _visibleMovies = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  MovieFilterOption get selectedFilter => _selectedFilter;
  MovieSortOption get selectedSort => _selectedSort;
  String get searchQuery => _searchQuery;
  UnmodifiableListView<Movie> get visibleMovies => UnmodifiableListView(_visibleMovies);

  Future<void> loadMovies() async {
    if (_isLoading) return;

    if (!repository.hasApiKey) {
      _errorMessage =
          'TMDB API key missing. Pass --dart-define=TMDB_API_KEY=<your_key> when running the app.';
      _visibleMovies
        ..clear()
        ..addAll(const []);
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final collections = await repository.fetchMovies();
      _movieCollections
        ..[MovieCollection.trending] = collections[MovieCollection.trending] ?? const []
        ..[MovieCollection.popular] = collections[MovieCollection.popular] ?? const [];
      _applyFilters();
    } catch (error) {
      if (error is TmdbHttpException && error.statusCode == 401) {
        _errorMessage =
            'Invalid TMDB API key. Verify the key passed via --dart-define=TMDB_API_KEY=<your_key>.';
      } else {
        _errorMessage = error.toString();
      }
      _visibleMovies
        ..clear()
        ..addAll(const []);
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateFilter(MovieFilterOption filter) {
    if (_selectedFilter == filter) return;
    _selectedFilter = filter;
    _applyFilters();
  }

  void updateSort(MovieSortOption sortOption) {
    if (_selectedSort == sortOption) return;
    _selectedSort = sortOption;
    _applyFilters();
  }

  void updateSearchQuery(String query) {
    _searchQuery = query.trim().toLowerCase();
    _applyFilters();
  }

  void retry() {
    loadMovies();
  }

  void _applyFilters() {
    final movies = switch (_selectedFilter) {
      MovieFilterOption.trending => _movieCollections[MovieCollection.trending] ?? const [],
      MovieFilterOption.popular => _movieCollections[MovieCollection.popular] ?? const [],
      MovieFilterOption.all => [
          ...?_movieCollections[MovieCollection.trending],
          ...?_movieCollections[MovieCollection.popular],
        ],
    };

    final filtered = movies.where((movie) {
      if (_searchQuery.isEmpty) return true;
      return movie.title.toLowerCase().contains(_searchQuery);
    }).toList(growable: false);

    filtered.sort((a, b) {
      switch (_selectedSort) {
        case MovieSortOption.popularity:
          return b.popularity.compareTo(a.popularity);
        case MovieSortOption.rating:
          return b.voteAverage.compareTo(a.voteAverage);
        case MovieSortOption.releaseDate:
          final aDate = a.releaseDateTime;
          final bDate = b.releaseDateTime;
          if (aDate == null && bDate == null) return 0;
          if (aDate == null) return 1;
          if (bDate == null) return -1;
          return bDate.compareTo(aDate);
        case MovieSortOption.title:
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      }
    });

    _visibleMovies
      ..clear()
      ..addAll(filtered);
    notifyListeners();
  }
}
