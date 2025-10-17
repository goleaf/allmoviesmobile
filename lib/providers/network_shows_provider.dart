import '../data/models/movie.dart';
import '../data/models/paginated_response.dart';
import '../data/tmdb_repository.dart';
import 'paginated_resource_provider.dart';

class NetworkShowsProvider extends PaginatedResourceProvider<Movie> {
  NetworkShowsProvider(
    this._repository, {
    required this.networkId,
  }) {
    loadInitial();
  }

  final TmdbRepository _repository;
  final int networkId;

  String _sortBy = 'popularity.desc';
  double? _minVoteAverage;
  String? _originalLanguage;

  List<Movie> get shows => items;
  bool get isLoading => isInitialLoading;
  bool get isLoadingMore => super.isLoadingMore;
  bool get canLoadMore => hasMore;
  String? get errorMessage => super.errorMessage;
  String get sortBy => _sortBy;
  double? get minVoteAverage => _minVoteAverage;
  String? get originalLanguage => _originalLanguage;

  Future<void> refreshShows() => refresh();
  Future<void> loadMoreShows() => loadMore();

  void updateSortBy(String value) {
    if (_sortBy == value) {
      return;
    }

    _sortBy = value;
    loadInitial(forceRefresh: true);
  }

  void updateMinVoteAverage(double? value) {
    if (_minVoteAverage == value) {
      return;
    }

    _minVoteAverage = value;
    loadInitial(forceRefresh: true);
  }

  void updateOriginalLanguage(String? value) {
    if (_originalLanguage == value) {
      return;
    }

    _originalLanguage = value?.isEmpty == true ? null : value;
    loadInitial(forceRefresh: true);
  }

  @override
  Future<PaginatedResponse<Movie>> loadPage(int page, {bool forceRefresh = false}) {
    return _repository.fetchNetworkTvShows(
      networkId: networkId,
      page: page,
      forceRefresh: forceRefresh,
      sortBy: _sortBy,
      minVoteAverage: _minVoteAverage,
      originalLanguage: _originalLanguage,
    );
  }
}
