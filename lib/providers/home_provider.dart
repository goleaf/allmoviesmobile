import 'package:flutter/foundation.dart';

import '../data/models/movie.dart';
import '../data/models/person_model.dart';
import '../data/tmdb_repository.dart';
import '../data/tmdb_repository.dart' show TmdbException;

/// Aggregates the remote sections displayed on the Home screen.
///
/// Each helper below documents the exact TMDB REST endpoint that is queried
/// together with the core shape of the JSON payload so that future maintainers
/// can quickly map UI requirements to the upstream API surface.
class HomeProvider extends ChangeNotifier {
  HomeProvider(this._repository);

  final TmdbRepository _repository;

  bool _isLoading = false;
  bool _hasLoaded = false;

  List<Movie> _ofTheMomentMovies = const <Movie>[];
  List<Movie> _ofTheMomentTvShows = const <Movie>[];
  List<Person> _popularPeople = const <Person>[];
  List<Movie> _newReleases = const <Movie>[];

  String? _ofTheMomentMoviesError;
  String? _ofTheMomentTvError;
  String? _popularPeopleError;
  String? _newReleasesError;

  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasLoaded;

  List<Movie> get ofTheMomentMovies => _ofTheMomentMovies;
  List<Movie> get ofTheMomentTvShows => _ofTheMomentTvShows;
  List<Person> get popularPeople => _popularPeople;
  List<Movie> get newReleases => _newReleases;

  String? get ofTheMomentMoviesError => _ofTheMomentMoviesError;
  String? get ofTheMomentTvError => _ofTheMomentTvError;
  String? get popularPeopleError => _popularPeopleError;
  String? get newReleasesError => _newReleasesError;

  /// Loads every section required by the Home screen in parallel.
  ///
  /// API surface involved:
  /// * `GET /3/trending/movie/day` – JSON payload: `{ "results": [Movie...] }`
  /// * `GET /3/trending/tv/day` – JSON payload: `{ "results": [TV...] }`
  /// * `GET /3/person/popular` – JSON payload: `{ "results": [Person...] }`
  /// * `GET /3/movie/now_playing` – JSON payload: `{ "results": [Movie...] }`
  Future<void> load({bool forceRefresh = false}) async {
    if (_isLoading) {
      return;
    }

    if (!forceRefresh && _hasLoaded) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    await Future.wait<void>(<Future<void>>[
      _loadOfTheMomentMovies(forceRefresh: forceRefresh),
      _loadOfTheMomentTvShows(forceRefresh: forceRefresh),
      _loadPopularPeople(forceRefresh: forceRefresh),
      _loadNewReleases(forceRefresh: forceRefresh),
    ]);

    _isLoading = false;
    _hasLoaded = true;
    notifyListeners();
  }

  /// Forces a refresh of every section shown on the Home screen.
  Future<void> refresh() => load(forceRefresh: true);

  /// Fetches "of the moment" movies using `GET /3/trending/movie/day` which
  /// returns `{ "results": [ { id, title, poster_path, release_date, ... } ] }`.
  Future<void> _loadOfTheMomentMovies({bool forceRefresh = false}) async {
    try {
      final List<Movie> movies = await _repository.fetchTrendingMovies(
        timeWindow: 'day',
        forceRefresh: forceRefresh,
      );
      _ofTheMomentMovies = movies.take(20).toList(growable: false);
      _ofTheMomentMoviesError = null;
    } on TmdbException catch (error) {
      _ofTheMomentMovies = const <Movie>[];
      _ofTheMomentMoviesError = error.message;
    } catch (error) {
      _ofTheMomentMovies = const <Movie>[];
      _ofTheMomentMoviesError = 'Failed to load trending movies: $error';
    }
  }

  /// Fetches "of the moment" TV shows using `GET /3/trending/tv/day` with the
  /// response payload `{ "results": [ { id, name, poster_path, ... } ] }`.
  Future<void> _loadOfTheMomentTvShows({bool forceRefresh = false}) async {
    try {
      final response = await _repository.fetchTrendingTv(
        timeWindow: 'day',
        page: 1,
        forceRefresh: forceRefresh,
      );
      _ofTheMomentTvShows = response.results.take(20).toList(growable: false);
      _ofTheMomentTvError = null;
    } on TmdbException catch (error) {
      _ofTheMomentTvShows = const <Movie>[];
      _ofTheMomentTvError = error.message;
    } catch (error) {
      _ofTheMomentTvShows = const <Movie>[];
      _ofTheMomentTvError = 'Failed to load trending TV shows: $error';
    }
  }

  /// Fetches popular people using `GET /3/person/popular` which yields
  /// `{ "results": [ { id, name, profile_path, ... } ] }`.
  Future<void> _loadPopularPeople({bool forceRefresh = false}) async {
    try {
      final response = await _repository.fetchPopularPeople(
        page: 1,
        forceRefresh: forceRefresh,
      );
      _popularPeople = response.results.take(20).toList(growable: false);
      _popularPeopleError = null;
    } on TmdbException catch (error) {
      _popularPeople = const <Person>[];
      _popularPeopleError = error.message;
    } catch (error) {
      _popularPeople = const <Person>[];
      _popularPeopleError = 'Failed to load people: $error';
    }
  }

  /// Fetches new theatrical releases using `GET /3/movie/now_playing` which
  /// returns `{ "results": [ { id, title, release_date, ... } ] }`.
  Future<void> _loadNewReleases({bool forceRefresh = false}) async {
    try {
      final response = await _repository.fetchNowPlayingMoviesPaginated(
        page: 1,
        forceRefresh: forceRefresh,
      );
      _newReleases = response.results.take(20).toList(growable: false);
      _newReleasesError = null;
    } on TmdbException catch (error) {
      _newReleases = const <Movie>[];
      _newReleasesError = error.message;
    } catch (error) {
      _newReleases = const <Movie>[];
      _newReleasesError = 'Failed to load new releases: $error';
    }
  }
}
