import 'package:flutter/foundation.dart';

import '../data/models/discover_filters_model.dart';
import '../data/models/genre_model.dart';
import '../data/models/genre_statistics.dart';
import '../data/models/movie.dart';
import '../data/models/paginated_response.dart';
import '../data/models/search_result_model.dart';
import '../data/tmdb_repository.dart';
import 'paginated_resource_provider.dart';

/// Provider responsible for discovering titles that belong to a single TMDB
/// genre by delegating to the Discover API family.
///
/// API contracts leveraged:
/// * `GET /3/discover/movie` – movie catalog filtered by genre.
/// * `GET /3/discover/tv` – TV catalog filtered by genre.
///
/// The TMDB API responds with a JSON envelope such as:
/// ```json
/// {
///   "page": 1,
///   "total_pages": 500,
///   "total_results": 10000,
///   "results": [
///     {
///       "id": 634649,
///       "title": "Spider-Man: No Way Home",
///       "genre_ids": [28, 12, 878],
///       "vote_average": 8.0,
///       "popularity": 7245.123
///     }
///   ]
/// }
/// ```
///
/// The provider normalizes those responses into [Movie] models and surfaces
/// lightweight statistics to keep the UI layer declarative.
class GenreBrowseProvider extends PaginatedResourceProvider<Movie> {
  GenreBrowseProvider({
    required TmdbRepository repository,
    required this.genre,
    required this.mediaType,
  }) : _repository = repository;

  final TmdbRepository _repository;

  /// Genre metadata selected by the user.
  final Genre genre;

  /// Indicates whether we should query the movie or TV discover endpoint.
  final MediaType mediaType;

  GenreStatistics? _statistics;
  List<Movie> _trending = const <Movie>[];

  /// Most recent statistics calculated from the fetched titles. When no data is
  /// available, returns an empty snapshot with zeroed aggregates.
  GenreStatistics get statistics =>
      _statistics ?? GenreStatistics.empty({genre.id});

  /// Trending titles derived from the Discover payload, sorted by popularity
  /// and limited to a short list for UI presentation.
  List<Movie> get trendingTitles => _trending;

  @override
  Future<PaginatedResponse<Movie>> loadPage(
    int page, {
    bool forceRefresh = false,
  }) async {
    switch (mediaType) {
      case MediaType.movie:
        // Delegates to GET /3/discover/movie with "with_genres" query.
        return _repository.discoverMovies(
          page: page,
          forceRefresh: forceRefresh,
          discoverFilters: DiscoverFilters(
            page: page,
            sortBy: SortBy.popularityDesc,
            withGenres: '${genre.id}',
          ),
        );
      case MediaType.tv:
        // Delegates to GET /3/discover/tv with "with_genres" query.
        return _repository.discoverTvSeries(
          page: page,
          forceRefresh: forceRefresh,
          filters: {
            'with_genres': '${genre.id}',
            'sort_by': 'popularity.desc',
          },
        );
      case MediaType.person:
        throw ArgumentError('Genre browsing is not supported for people.');
    }
  }

  @override
  void onItemsReplaced(List<Movie> items) {
    _recomputeInsights();
  }

  @override
  void onItemsAppended(List<Movie> items) {
    _recomputeInsights();
  }

  void _recomputeInsights() {
    final snapshot = List<Movie>.from(items);
    if (snapshot.isEmpty) {
      _statistics = GenreStatistics.empty({genre.id});
      _trending = const <Movie>[];
      return;
    }

    _statistics = GenreStatistics.fromMovies({genre.id}, snapshot);
    snapshot.sort(
      (a, b) => (b.popularity ?? 0).compareTo(a.popularity ?? 0),
    );
    const trendingLimit = 6;
    _trending = snapshot
        .where((movie) => (movie.popularity ?? 0) > 0)
        .take(trendingLimit)
        .toList(growable: false);
  }
}
