import 'package:flutter/material.dart';
import '../data/models/genre_model.dart';
import '../data/tmdb_repository.dart';

class GenresProvider with ChangeNotifier {
  final TmdbRepository _repository;
  
  List<Genre> _movieGenres = [];
  List<Genre> _tvGenres = [];
  bool _isLoading = false;
  String? _error;

  GenresProvider(this._repository);

  List<Genre> get movieGenres => _movieGenres;
  List<Genre> get tvGenres => _tvGenres;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchMovieGenres() async {
    if (_movieGenres.isNotEmpty) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Implement in repository
      // _movieGenres = await _repository.fetchMovieGenres();
      _movieGenres = _getMockMovieGenres();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTVGenres() async {
    if (_tvGenres.isNotEmpty) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Implement in repository
      // _tvGenres = await _repository.fetchTVGenres();
      _tvGenres = _getMockTVGenres();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Genre? getGenreById(int id, {bool isTv = false}) {
    final genres = isTv ? _tvGenres : _movieGenres;
    try {
      return genres.firstWhere((g) => g.id == id);
    } catch (e) {
      return null;
    }
  }

  String getGenreNames(List<int> genreIds, {bool isTv = false}) {
    final genres = isTv ? _tvGenres : _movieGenres;
    final names = genreIds
        .map((id) => genres.firstWhere((g) => g.id == id, orElse: () => const Genre(id: 0, name: '')))
        .where((g) => g.name.isNotEmpty)
        .map((g) => g.name)
        .toList();
    
    return names.join(', ');
  }

  // Mock data until API is implemented
  List<Genre> _getMockMovieGenres() {
    return const [
      Genre(id: 28, name: 'Action'),
      Genre(id: 12, name: 'Adventure'),
      Genre(id: 16, name: 'Animation'),
      Genre(id: 35, name: 'Comedy'),
      Genre(id: 80, name: 'Crime'),
      Genre(id: 99, name: 'Documentary'),
      Genre(id: 18, name: 'Drama'),
      Genre(id: 10751, name: 'Family'),
      Genre(id: 14, name: 'Fantasy'),
      Genre(id: 36, name: 'History'),
      Genre(id: 27, name: 'Horror'),
      Genre(id: 10402, name: 'Music'),
      Genre(id: 9648, name: 'Mystery'),
      Genre(id: 10749, name: 'Romance'),
      Genre(id: 878, name: 'Science Fiction'),
      Genre(id: 10770, name: 'TV Movie'),
      Genre(id: 53, name: 'Thriller'),
      Genre(id: 10752, name: 'War'),
      Genre(id: 37, name: 'Western'),
    ];
  }

  List<Genre> _getMockTVGenres() {
    return const [
      Genre(id: 10759, name: 'Action & Adventure'),
      Genre(id: 16, name: 'Animation'),
      Genre(id: 35, name: 'Comedy'),
      Genre(id: 80, name: 'Crime'),
      Genre(id: 99, name: 'Documentary'),
      Genre(id: 18, name: 'Drama'),
      Genre(id: 10751, name: 'Family'),
      Genre(id: 10762, name: 'Kids'),
      Genre(id: 9648, name: 'Mystery'),
      Genre(id: 10763, name: 'News'),
      Genre(id: 10764, name: 'Reality'),
      Genre(id: 10765, name: 'Sci-Fi & Fantasy'),
      Genre(id: 10766, name: 'Soap'),
      Genre(id: 10767, name: 'Talk'),
      Genre(id: 10768, name: 'War & Politics'),
      Genre(id: 37, name: 'Western'),
    ];
  }
}

