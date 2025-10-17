import 'package:flutter/foundation.dart';

import '../data/models/keyword_model.dart';
import '../data/models/movie_detailed_model.dart';
import '../data/models/genre_model.dart';
import '../data/tmdb_repository.dart';

class MovieDetailProvider with ChangeNotifier {
  MovieDetailProvider(this._repository, this.movieId) {
    _fetch();
  }

  final TmdbRepository _repository;
  final int movieId;

  MovieDetailed? _movie;
  bool _isLoading = false;
  String? _errorMessage;

  MovieDetailed? get movie => _movie;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Keyword> get keywords => _movie?.keywords ?? const [];
  List<Genre> get genres => _movie?.genres ?? const [];

  bool get hasKeywords => keywords.isNotEmpty;
  bool get hasGenres => genres.isNotEmpty;

  Future<void> refresh() => _fetch(forceRefresh: true);

  Future<void> _fetch({bool forceRefresh = false}) async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final detailedMovie =
          await _repository.fetchMovieDetails(movieId, forceRefresh: forceRefresh);
      _movie = detailedMovie;
      _errorMessage = null;
    } catch (error, stackTrace) {
      _errorMessage = 'Failed to load movie details: $error';
      debugPrintStack(label: _errorMessage, stackTrace: stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

