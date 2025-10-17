import 'package:flutter/material.dart';
import '../data/models/genre_model.dart';
import '../data/tmdb_repository.dart';

class GenresProvider with ChangeNotifier {
  GenresProvider(this._repository);

  final TmdbRepository _repository;

  List<Genre> _movieGenres = const [];
  List<Genre> _tvGenres = const [];
  bool _isLoadingMovies = false;
  bool _isLoadingTv = false;
  String? _errorMovies;
  String? _errorTv;

  List<Genre> get movieGenres => _movieGenres;
  List<Genre> get tvGenres => _tvGenres;
  bool get isLoadingMovies => _isLoadingMovies;
  bool get isLoadingTv => _isLoadingTv;
  String? get movieError => _errorMovies;
  String? get tvError => _errorTv;

  Future<void> fetchMovieGenres({bool forceRefresh = false}) async {
    if (_movieGenres.isNotEmpty && !forceRefresh) {
      return;
    }

    _isLoadingMovies = true;
    _errorMovies = null;
    notifyListeners();

    try {
      _movieGenres = await _repository.fetchMovieGenres();
    } on TmdbException catch (error) {
      _errorMovies = error.message;
      _movieGenres = const [];
    } catch (error) {
      _errorMovies = 'Failed to load movie genres: $error';
      _movieGenres = const [];
    } finally {
      _isLoadingMovies = false;
      notifyListeners();
    }
  }

  Future<void> fetchTvGenres({bool forceRefresh = false}) async {
    if (_tvGenres.isNotEmpty && !forceRefresh) {
      return;
    }

    _isLoadingTv = true;
    _errorTv = null;
    notifyListeners();

    try {
      _tvGenres = await _repository.fetchTVGenres();
    } on TmdbException catch (error) {
      _errorTv = error.message;
      _tvGenres = const [];
    } catch (error) {
      _errorTv = 'Failed to load TV genres: $error';
      _tvGenres = const [];
    } finally {
      _isLoadingTv = false;
      notifyListeners();
    }
  }

  Genre? getGenreById(int id, {bool isTv = false}) {
    final genres = isTv ? _tvGenres : _movieGenres;
    try {
      return genres.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  String getGenreNames(List<int> genreIds, {bool isTv = false}) {
    if (genreIds.isEmpty) {
      return '';
    }

    final genres = isTv ? _tvGenres : _movieGenres;
    final names = <String>[];
    for (final id in genreIds) {
      final match = genres.cast<Genre?>().firstWhere(
            (genre) => genre?.id == id,
            orElse: () => null,
          );
      if (match != null && match.name.isNotEmpty) {
        names.add(match.name);
      }
    }

    return names.join(', ');
  }
}

