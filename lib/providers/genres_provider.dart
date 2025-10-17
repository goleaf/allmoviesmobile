import 'package:flutter/material.dart';
import '../data/models/genre_model.dart';
import '../data/tmdb_repository.dart';
import '../data/utils/genre_catalog.dart';

class GenresProvider with ChangeNotifier {
  GenresProvider(this._repository);

  final TmdbRepository _repository;

  List<Genre> _movieGenres = const [];
  List<Genre> _tvGenres = const [];
  Map<int, Genre> _movieGenreMap = const {};
  Map<int, Genre> _tvGenreMap = const {};
  bool _isLoadingMovies = false;
  bool _isLoadingTv = false;
  String? _errorMovies;
  String? _errorTv;

  List<Genre> get movieGenres => _movieGenres;
  List<Genre> get tvGenres => _tvGenres;
  Map<int, Genre> get movieGenreMap => _movieGenreMap;
  Map<int, Genre> get tvGenreMap => _tvGenreMap;
  bool get isLoadingMovies => _isLoadingMovies;
  bool get isLoadingTv => _isLoadingTv;
  String? get movieError => _errorMovies;
  String? get tvError => _errorTv;
  bool get hasMovieGenres => _movieGenres.isNotEmpty;
  bool get hasTvGenres => _tvGenres.isNotEmpty;

  Future<void> fetchMovieGenres({bool forceRefresh = false}) async {
    if (_movieGenres.isNotEmpty && !forceRefresh) {
      return;
    }

    _isLoadingMovies = true;
    _errorMovies = null;
    notifyListeners();

    try {
      final genres = await _repository.fetchMovieGenres();
      if (genres.isEmpty) {
        _applyMovieFallback();
      } else {
        _applyMovieGenres(genres);
      }
    } on TmdbException catch (error) {
      _errorMovies = error.message;
      _applyMovieFallback();
    } catch (error) {
      _errorMovies = 'Failed to load movie genres: $error';
      _applyMovieFallback();
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
      final genres = await _repository.fetchTVGenres();
      if (genres.isEmpty) {
        _applyTvFallback();
      } else {
        _applyTvGenres(genres);
      }
    } on TmdbException catch (error) {
      _errorTv = error.message;
      _applyTvFallback();
    } catch (error) {
      _errorTv = 'Failed to load TV genres: $error';
      _applyTvFallback();
    } finally {
      _isLoadingTv = false;
      notifyListeners();
    }
  }

  Genre? getGenreById(int id, {bool isTv = false}) {
    final map = isTv ? _tvGenreMap : _movieGenreMap;
    final genre = map[id];
    if (genre != null) {
      return genre;
    }

    final fallback = GenreCatalog.fallbackGenres(isTv: isTv);
    try {
      return fallback.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  String getGenreNames(List<int> genreIds, {bool isTv = false}) {
    final names = getGenreNameList(genreIds, isTv: isTv);
    return names.join(', ');
  }

  List<String> getGenreNameList(List<int> genreIds, {bool isTv = false}) {
    if (genreIds.isEmpty) {
      return const [];
    }

    final map = isTv ? _tvGenreMap : _movieGenreMap;
    final names = <String>[];
    for (final id in genreIds) {
      final match = map[id]?.name ?? GenreCatalog.nameForId(id);
      if (match != null && match.isNotEmpty) {
        names.add(match);
      }
    }

    return names;
  }

  String? getGenreName(int id, {bool isTv = false}) {
    final genre = (isTv ? _tvGenreMap : _movieGenreMap)[id];
    return genre?.name ?? GenreCatalog.nameForId(id);
  }

  void _applyMovieGenres(List<Genre> genres) {
    _movieGenres = genres;
    _movieGenreMap = {for (final genre in genres) genre.id: genre};
  }

  void _applyTvGenres(List<Genre> genres) {
    _tvGenres = genres;
    _tvGenreMap = {for (final genre in genres) genre.id: genre};
  }

  void _applyMovieFallback() {
    _applyMovieGenres(GenreCatalog.movieGenres);
  }

  void _applyTvFallback() {
    _applyTvGenres(GenreCatalog.tvGenres);
  }
}
