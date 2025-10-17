import 'package:flutter/foundation.dart';

import '../data/models/collection_model.dart';
import '../data/models/movie.dart';
import '../data/models/person_model.dart';
import '../data/tmdb_repository.dart';

/// Describes the different home screen highlight sections that
/// need to fetch remote content.
enum HomeHighlightsSection {
  ofMomentMovies,
  ofMomentTv,
  popularPeople,
  featuredCollections,
  newReleases,
  recommendations,
}

/// Lightweight state holder used to expose the current loading status,
/// items and error message for each highlight section.
class HomeSectionState<T> {
  const HomeSectionState({
    this.items = const <T>[],
    this.isLoading = false,
    this.errorMessage,
  });

  static const Object _errorSentinel = Object();

  /// Items fetched for the section.
  final List<T> items;

  /// Whether the section is currently loading content.
  final bool isLoading;

  /// Optional error message when the section fails to load.
  final String? errorMessage;

  /// Creates an updated copy of the current state.
  HomeSectionState<T> copyWith({
    List<T>? items,
    bool? isLoading,
    Object? errorMessage = _errorSentinel,
  }) {
    return HomeSectionState<T>(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: identical(errorMessage, _errorSentinel)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

/// Provider responsible for loading and caching the data displayed in the
/// dedicated home screen.
class HomeHighlightsProvider extends ChangeNotifier {
  HomeHighlightsProvider(this._repository);

  final TmdbRepository _repository;

  bool _initialized = false;
  bool _isRefreshing = false;

  HomeSectionState<Movie> _moviesOfMoment = const HomeSectionState<Movie>();
  HomeSectionState<Movie> _tvOfMoment = const HomeSectionState<Movie>();
  HomeSectionState<Person> _popularPeople = const HomeSectionState<Person>();
  HomeSectionState<CollectionDetails> _featuredCollections =
      const HomeSectionState<CollectionDetails>();
  HomeSectionState<Movie> _newReleases = const HomeSectionState<Movie>();
  HomeSectionState<Movie> _recommendations = const HomeSectionState<Movie>();

  /// Static list of curated collection identifiers that serves as the
  /// "featured collections" carousel on the home screen.
  static const List<int> _featuredCollectionIds = <int>{
    10,
    1241,
    86311,
    328,
    87118,
  }.toList(growable: false);

  /// Exposes the loading state for the movies carousel.
  HomeSectionState<Movie> get moviesOfMoment => _moviesOfMoment;

  /// Exposes the loading state for the TV carousel.
  HomeSectionState<Movie> get tvOfMoment => _tvOfMoment;

  /// Exposes the loading state for the popular people carousel.
  HomeSectionState<Person> get popularPeople => _popularPeople;

  /// Exposes the loading state for the featured collections carousel.
  HomeSectionState<CollectionDetails> get featuredCollections =>
      _featuredCollections;

  /// Exposes the loading state for the new releases carousel.
  HomeSectionState<Movie> get newReleases => _newReleases;

  /// Exposes the loading state for personalized recommendations.
  HomeSectionState<Movie> get recommendations => _recommendations;

  /// Whether a manual refresh is currently running.
  bool get isRefreshing => _isRefreshing;

  /// Loads all home screen sections the first time the widget tree requests
  /// data. Subsequent calls are ignored to prevent redundant API usage.
  Future<void> ensureInitialized() async {
    if (_initialized) {
      return;
    }
    _initialized = true;
    await refreshAll();
  }

  /// Forces a refresh of every highlight section.
  Future<void> refreshAll() async {
    if (_isRefreshing) {
      return;
    }
    _isRefreshing = true;
    notifyListeners();

    try {
      await Future.wait<void>(<Future<void>>[
        loadMoviesOfMoment(forceRefresh: true),
        loadTvOfMoment(forceRefresh: true),
        loadPopularPeople(forceRefresh: true),
        loadFeaturedCollections(forceRefresh: true),
        loadNewReleases(forceRefresh: true),
        loadRecommendations(forceRefresh: true),
      ]);
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  /// Loads the "of the moment" movie carousel.
  Future<void> loadMoviesOfMoment({bool forceRefresh = false}) async {
    _moviesOfMoment = _moviesOfMoment.copyWith(
      isLoading: true,
      errorMessage: null,
    );
    notifyListeners();

    try {
      final List<Movie> movies = await _repository.fetchTrendingMovies(
        timeWindow: 'day',
        forceRefresh: forceRefresh,
      );
      _moviesOfMoment = HomeSectionState<Movie>(
        items: movies.take(20).toList(growable: false),
      );
    } on TmdbException catch (error) {
      _moviesOfMoment = HomeSectionState<Movie>(
        errorMessage: error.message,
      );
    } catch (error) {
      _moviesOfMoment = HomeSectionState<Movie>(
        errorMessage: 'Failed to load trending movies: $error',
      );
    } finally {
      notifyListeners();
    }
  }

  /// Loads the "of the moment" TV carousel.
  Future<void> loadTvOfMoment({bool forceRefresh = false}) async {
    _tvOfMoment = _tvOfMoment.copyWith(isLoading: true, errorMessage: null);
    notifyListeners();

    try {
      final List<Movie> shows = await _repository.fetchTrendingTv(
        timeWindow: 'day',
        forceRefresh: forceRefresh,
      );
      _tvOfMoment = HomeSectionState<Movie>(
        items: shows.take(20).toList(growable: false),
      );
    } on TmdbException catch (error) {
      _tvOfMoment = HomeSectionState<Movie>(
        errorMessage: error.message,
      );
    } catch (error) {
      _tvOfMoment = HomeSectionState<Movie>(
        errorMessage: 'Failed to load trending TV: $error',
      );
    } finally {
      notifyListeners();
    }
  }

  /// Loads the popular people carousel.
  Future<void> loadPopularPeople({bool forceRefresh = false}) async {
    _popularPeople =
        _popularPeople.copyWith(isLoading: true, errorMessage: null);
    notifyListeners();

    try {
      final response = await _repository.fetchPopularPeople(
        forceRefresh: forceRefresh,
      );
      _popularPeople = HomeSectionState<Person>(
        items: response.results.take(20).toList(growable: false),
      );
    } on TmdbException catch (error) {
      _popularPeople = HomeSectionState<Person>(
        errorMessage: error.message,
      );
    } catch (error) {
      _popularPeople = HomeSectionState<Person>(
        errorMessage: 'Failed to load popular people: $error',
      );
    } finally {
      notifyListeners();
    }
  }

  /// Loads the curated featured collections carousel.
  Future<void> loadFeaturedCollections({bool forceRefresh = false}) async {
    _featuredCollections =
        _featuredCollections.copyWith(isLoading: true, errorMessage: null);
    notifyListeners();

    try {
      final results = await Future.wait<CollectionDetails?>(
        _featuredCollectionIds.map((int id) async {
          try {
            return await _repository.fetchCollectionDetails(
              id,
              forceRefresh: forceRefresh,
            );
          } catch (error) {
            debugPrint('Failed to load collection $id: $error');
            return null;
          }
        }),
      );
      final filtered =
          results.whereType<CollectionDetails>().toList(growable: false);
      _featuredCollections = HomeSectionState<CollectionDetails>(
        items: filtered,
        errorMessage: filtered.isEmpty ? 'Collections unavailable' : null,
      );
    } on TmdbException catch (error) {
      _featuredCollections = HomeSectionState<CollectionDetails>(
        errorMessage: error.message,
      );
    } catch (error) {
      _featuredCollections = HomeSectionState<CollectionDetails>(
        errorMessage: 'Failed to load collections: $error',
      );
    } finally {
      notifyListeners();
    }
  }

  /// Loads the "new releases" carousel combining recent movies and TV shows.
  Future<void> loadNewReleases({bool forceRefresh = false}) async {
    _newReleases = _newReleases.copyWith(isLoading: true, errorMessage: null);
    notifyListeners();

    try {
      final List<Movie> nowPlaying = await _repository.fetchNowPlayingMovies();
      final List<Movie> onTheAir = await _repository.fetchOnTheAirTv();
      final combined = <Movie>[...nowPlaying, ...onTheAir];
      combined.sort((Movie a, Movie b) {
        DateTime? parseDate(Movie movie) {
          final String? date = movie.releaseDate;
          if (date == null || date.isEmpty) {
            return null;
          }
          return DateTime.tryParse(date);
        }

        final DateTime? dateA = parseDate(a);
        final DateTime? dateB = parseDate(b);
        if (dateA == null && dateB == null) {
          return 0;
        }
        if (dateA == null) {
          return 1;
        }
        if (dateB == null) {
          return -1;
        }
        return dateB.compareTo(dateA);
      });

      _newReleases = HomeSectionState<Movie>(
        items: combined.take(20).toList(growable: false),
      );
    } on TmdbException catch (error) {
      _newReleases = HomeSectionState<Movie>(
        errorMessage: error.message,
      );
    } catch (error) {
      _newReleases = HomeSectionState<Movie>(
        errorMessage: 'Failed to load new releases: $error',
      );
    } finally {
      notifyListeners();
    }
  }

  /// Loads the personalized recommendations carousel by combining popular
  /// and top rated titles while avoiding duplicates.
  Future<void> loadRecommendations({bool forceRefresh = false}) async {
    _recommendations =
        _recommendations.copyWith(isLoading: true, errorMessage: null);
    notifyListeners();

    try {
      final List<Movie> popularMovies = await _repository.fetchPopularMovies(
        forceRefresh: forceRefresh,
      );
      final List<Movie> topRatedMovies = await _repository.fetchTopRatedMovies(
        forceRefresh: forceRefresh,
      );
      final List<Movie> popularTv = await _repository.fetchPopularTv();

      final Map<int, Movie> deduped = <int, Movie>{};
      void addAll(Iterable<Movie> source) {
        for (final Movie movie in source) {
          deduped[movie.id] = movie;
        }
      }

      addAll(popularMovies);
      addAll(topRatedMovies);
      addAll(popularTv);

      _recommendations = HomeSectionState<Movie>(
        items: deduped.values.take(20).toList(growable: false),
      );
    } on TmdbException catch (error) {
      _recommendations = HomeSectionState<Movie>(
        errorMessage: error.message,
      );
    } catch (error) {
      _recommendations = HomeSectionState<Movie>(
        errorMessage: 'Failed to load recommendations: $error',
      );
    } finally {
      notifyListeners();
    }
  }

  /// Utility used exclusively from the widget tests to seed deterministic
  /// data without going through HTTP requests.
  @visibleForTesting
  void setTestSectionState<T>(
    HomeHighlightsSection section,
    HomeSectionState<T> state,
  ) {
    switch (section) {
      case HomeHighlightsSection.ofMomentMovies:
        _moviesOfMoment = state as HomeSectionState<Movie>;
        break;
      case HomeHighlightsSection.ofMomentTv:
        _tvOfMoment = state as HomeSectionState<Movie>;
        break;
      case HomeHighlightsSection.popularPeople:
        _popularPeople = state as HomeSectionState<Person>;
        break;
      case HomeHighlightsSection.featuredCollections:
        _featuredCollections = state as HomeSectionState<CollectionDetails>;
        break;
      case HomeHighlightsSection.newReleases:
        _newReleases = state as HomeSectionState<Movie>;
        break;
      case HomeHighlightsSection.recommendations:
        _recommendations = state as HomeSectionState<Movie>;
        break;
    }
    _initialized = true;
    notifyListeners();
  }
}
