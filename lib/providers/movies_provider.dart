import '../data/models/movie.dart';
import '../data/models/paginated_response.dart';
import '../data/tmdb_repository.dart';
import 'paginated_resource_provider.dart';

class MoviesProvider extends PaginatedResourceProvider<Movie> {
  MoviesProvider(this._repository, {this.category = 'popular'}) {
    loadInitial();
  }

  final TmdbRepository _repository;
  final String category;

  List<Movie> get movies => items;
  bool get isLoading => isInitialLoading;
  bool get isLoadingMore => super.isLoadingMore;
  bool get canLoadMore => hasMore;

  Future<void> refreshMovies() => refresh();
  Future<void> loadMoreMovies() => loadMore();

  @override
  Future<PaginatedResponse<Movie>> loadPage(int page, {bool forceRefresh = false}) {
    return _repository.fetchMovieCategory(
      category: category,
      page: page,
      forceRefresh: forceRefresh,
    );
  }
}
