import '../data/models/movie.dart';
import '../data/models/paginated_response.dart';
import '../data/tmdb_repository.dart';
import 'paginated_resource_provider.dart';

class SeriesProvider extends PaginatedResourceProvider<Movie> {
  SeriesProvider(this._repository, {this.category = 'popular'}) {
    loadInitial();
  }

  final TmdbRepository _repository;
  final String category;

  List<Movie> get series => items;
  bool get isLoading => isInitialLoading;
  bool get isLoadingMore => super.isLoadingMore;
  bool get canLoadMore => hasMore;

  Future<void> refreshSeries() => refresh();
  Future<void> loadMoreSeries() => loadMore();

  @override
  Future<PaginatedResponse<Movie>> loadPage(int page, {bool forceRefresh = false}) {
    return _repository.fetchTvCategory(
      category: category,
      page: page,
      forceRefresh: forceRefresh,
    );
  }
}
