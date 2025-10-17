import '../data/models/movie.dart';
import '../data/models/paginated_response.dart';
import '../data/tmdb_repository.dart';
import 'paginated_resource_provider.dart';

enum SeriesRequestType { category, discover }

class SeriesProvider extends PaginatedResourceProvider<Movie> {
  SeriesProvider(
    this._repository, {
    String? category,
    Map<String, String>? discoverFilters,
    SeriesRequestType requestType = SeriesRequestType.category,
  })  : category = category ?? 'popular',
        _requestType = requestType,
        _discoverFilters = Map.unmodifiable(discoverFilters ?? const {}),
        assert(
          requestType == SeriesRequestType.category ||
              (discoverFilters != null && discoverFilters.isNotEmpty),
          'Discover filters are required when using SeriesRequestType.discover',
        ) {
    loadInitial();
  }

  final TmdbRepository _repository;
  final SeriesRequestType _requestType;
  final Map<String, String> _discoverFilters;
  final String category;

  SeriesRequestType get requestType => _requestType;
  Map<String, String> get discoverFilters => _discoverFilters;

  List<Movie> get series => items;
  bool get isLoading => isInitialLoading;
  bool get isLoadingMore => super.isLoadingMore;
  bool get canLoadMore => hasMore;

  Future<void> refreshSeries() => refresh();
  Future<void> loadMoreSeries() => loadMore();

  @override
  Future<PaginatedResponse<Movie>> loadPage(int page, {bool forceRefresh = false}) {
    switch (_requestType) {
      case SeriesRequestType.category:
        return _repository.fetchTvCategory(
          category: category,
          page: page,
          forceRefresh: forceRefresh,
        );
      case SeriesRequestType.discover:
        return _repository.discoverTvSeries(
          filters: _discoverFilters,
          page: page,
          forceRefresh: forceRefresh,
        );
    }
  }
}
