import '../data/models/movie.dart';
import '../data/models/paginated_response.dart';
import '../data/tmdb_repository.dart';
import 'paginated_resource_provider.dart';

class TrendingTitlesProvider extends PaginatedResourceProvider<Movie> {
  TrendingTitlesProvider(this._repository) {
    loadInitial();
  }

  final TmdbRepository _repository;

  List<Movie> get titles => items;
  bool get isLoading => isInitialLoading;
  bool get isLoadingMore => super.isLoadingMore;
  bool get canLoadMore => hasMore;

  Future<void> loadTrendingTitles({bool forceRefresh = false}) =>
      loadInitial(forceRefresh: forceRefresh);

  Future<void> loadMoreTrendingTitles() => loadMore();

  @override
  Future<PaginatedResponse<Movie>> loadPage(int page, {bool forceRefresh = false}) {
    return _repository.fetchTrendingTitles(
      page: page,
      forceRefresh: forceRefresh,
    );
  }
}
