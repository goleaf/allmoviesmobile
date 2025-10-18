import 'package:allmovies_mobile/data/models/movie_detailed_model.dart';
import 'package:allmovies_mobile/data/models/tv_detailed_model.dart';
import 'package:allmovies_mobile/data/tmdb_repository.dart';

class FakeTmdbRepository extends TmdbRepository {
  FakeTmdbRepository({
    Map<int, MovieDetailed>? movies,
    Map<int, TVDetailed>? shows,
  })  : _movies = Map<int, MovieDetailed>.from(movies ?? const {}),
        _shows = Map<int, TVDetailed>.from(shows ?? const {}),
        super(apiKey: 'fake');

  Map<int, MovieDetailed> _movies;
  Map<int, TVDetailed> _shows;

  set movies(Map<int, MovieDetailed> value) {
    _movies = Map<int, MovieDetailed>.from(value);
  }

  set shows(Map<int, TVDetailed> value) {
    _shows = Map<int, TVDetailed>.from(value);
  }

  @override
  Future<MovieDetailed> fetchMovieDetails(
    int movieId, {
    bool forceRefresh = false,
  }) async {
    final movie = _movies[movieId];
    if (movie == null) {
      throw Exception('Missing movie $movieId');
    }
    return movie;
  }

  @override
  Future<TVDetailed> fetchTvDetails(
    int tvId, {
    bool forceRefresh = false,
  }) async {
    final show = _shows[tvId];
    if (show == null) {
      throw Exception('Missing tv $tvId');
    }
    return show;
  }
}
