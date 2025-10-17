import 'package:flutter/material.dart';

import '../data/models/movie.dart';
import '../data/models/movie_detailed_model.dart';
import '../data/tmdb_repository.dart';

class MovieDetailProvider with ChangeNotifier {
  MovieDetailProvider(this._repository, this.movie);

  final TmdbRepository _repository;
  final Movie movie;

  MovieDetailed? _details;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isOverviewExpanded = false;

  MovieDetailed? get details => _details;
  Movie get initialMovie => movie;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  bool get isOverviewExpanded => _isOverviewExpanded;

  Future<void> load({bool forceRefresh = false}) async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _details = await _repository.fetchMovieDetails(
        movie.id,
        forceRefresh: forceRefresh,
      );
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleOverview() {
    _isOverviewExpanded = !_isOverviewExpanded;
    notifyListeners();
  }
}
