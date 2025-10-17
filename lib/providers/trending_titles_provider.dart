import 'package:flutter/foundation.dart';

import '../data/models/movie.dart';
import '../data/tmdb_repository.dart';

class TrendingTitlesProvider extends ChangeNotifier {
  TrendingTitlesProvider(this._repository) {
    loadTrendingTitles();
  }

  final TmdbRepository _repository;

  List<Movie> _titles = const [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Movie> get titles => _titles;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadTrendingTitles() async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetched = await _repository.fetchTrendingMovies();
      _titles = fetched;
    } on TmdbException catch (error) {
      _errorMessage = error.message;
      _titles = const [];
    } catch (error) {
      _errorMessage = 'Failed to load titles: $error';
      _titles = const [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
