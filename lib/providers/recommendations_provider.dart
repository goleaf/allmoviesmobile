import 'package:flutter/material.dart';

import '../data/models/movie.dart';
import '../data/services/local_storage_service.dart';
import '../data/tmdb_repository.dart';

/// Provides movie recommendations based on user's favorites and viewing history
/// without requiring user accounts - all local
class RecommendationsProvider with ChangeNotifier {
  final TmdbRepository _repository;
  final LocalStorageService _storage;

  RecommendationsProvider(this._repository, this._storage);

  List<Movie> _recommendedMovies = [];
  List<Movie> _popularMovies = [];
  List<Movie> _similarMovies = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Movie> get recommendedMovies => _recommendedMovies;
  List<Movie> get popularMovies => _popularMovies;
  List<Movie> get similarMovies => _similarMovies;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasRecommendations => _recommendedMovies.isNotEmpty;

  /// Get recommendations based on user's favorites
  Future<void> fetchPersonalizedRecommendations() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get user's favorite movies
      final favoriteIds = _storage.getFavorites();
      
      if (favoriteIds.isEmpty) {
        // No favorites yet, return popular movies
        _recommendedMovies = await _repository.fetchPopularMovies();
      } else {
        // Get trending movies as base recommendations
        // In a real app, you would fetch similar movies based on favorites
        _recommendedMovies = await _repository.fetchTrendingMovies();
        
        // Filter out already favorited movies
        _recommendedMovies = _recommendedMovies
            .where((movie) => !favoriteIds.contains(movie.id))
            .take(20)
            .toList();
      }
    } catch (error) {
      _errorMessage = 'Failed to fetch recommendations: $error';
      _recommendedMovies = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get popular movies
  Future<void> fetchPopularMovies() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _popularMovies = await _repository.fetchPopularMovies();
    } catch (error) {
      _errorMessage = 'Failed to fetch popular movies: $error';
      _popularMovies = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get movies similar to a given movie
  Future<void> fetchSimilarMovies(int movieId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _similarMovies = await _repository.fetchSimilarMovies(movieId);
      
      // Filter out the current movie
      _similarMovies = _similarMovies
          .where((movie) => movie.id != movieId)
          .take(10)
          .toList();
    } catch (error) {
      _errorMessage = 'Failed to fetch similar movies: $error';
      _similarMovies = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get movies by genre
  Future<void> fetchMoviesByGenre(int genreId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.discoverMovies(
        filters: {'with_genres': '$genreId'},
      );
      _recommendedMovies = response.results;
    } catch (error) {
      _errorMessage = 'Failed to fetch movies by genre: $error';
      _recommendedMovies = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get recommendations based on recently viewed movies
  Future<void> fetchRecommendationsFromHistory() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final recentlyViewed = _storage.getRecentlyViewed(limit: 5);
      
      if (recentlyViewed.isEmpty) {
        // No history, return popular movies
        _recommendedMovies = await _repository.fetchPopularMovies();
      } else {
        // Get trending movies and filter based on recent views
        _recommendedMovies = await _repository.fetchTrendingMovies();
        
        // Filter out recently viewed movies
        _recommendedMovies = _recommendedMovies
            .where((movie) => !recentlyViewed.contains(movie.id))
            .take(20)
            .toList();
      }
    } catch (error) {
      _errorMessage = 'Failed to fetch recommendations: $error';
      _recommendedMovies = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear all recommendations
  void clearRecommendations() {
    _recommendedMovies = [];
    _popularMovies = [];
    _similarMovies = [];
    _errorMessage = null;
    notifyListeners();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Analyze user preferences based on favorites and history
  Map<int, int> analyzePreferences() {
    final favoriteIds = _storage.getFavorites();
    final recentlyViewed = _storage.getRecentlyViewed(limit: 20);
    
    // This would ideally fetch actual movie data and count genre frequencies
    // For now, return empty map - can be enhanced when API is connected
    final genreFrequency = <int, int>{};
    
    return genreFrequency;
  }

  /// Get top genres from user preferences
  List<int> getTopGenres({int limit = 3}) {
    final preferences = analyzePreferences();
    
    if (preferences.isEmpty) {
      return [];
    }
    
    final sortedGenres = preferences.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedGenres.take(limit).map((e) => e.key).toList();
  }
}

