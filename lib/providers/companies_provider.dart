import '../data/models/company_model.dart';
import '../data/models/paginated_response.dart';
import '../data/tmdb_repository.dart';
import 'paginated_resource_provider.dart';

class CompaniesProvider extends PaginatedResourceProvider<Company> {
  CompaniesProvider(this._repository, {String initialQuery = 'studio'})
      : _query = initialQuery.trim().isEmpty ? 'studio' : initialQuery.trim() {
    loadInitial();
  }

  final TmdbRepository _repository;
  String _query;

  String get query => _query;
  List<Company> get companies => items;
  bool get isLoading => isInitialLoading;
  bool get isLoadingMore => super.isLoadingMore;
  bool get canLoadMore => hasMore;

  Future<void> refreshCompanies() => refresh();
  Future<void> loadMoreCompanies() => loadMore();

  Future<void> searchCompanies(String newQuery) async {
    final sanitized = newQuery.trim();
    if (sanitized.isEmpty) {
      _query = 'studio';
      await loadInitial(forceRefresh: true);
      return;
    }

    if (sanitized.toLowerCase() == _query.toLowerCase() && items.isNotEmpty) {
      return;
    }

    _query = sanitized;
    await loadInitial(forceRefresh: true);
  }

  @override
  Future<PaginatedResponse<Company>> loadPage(int page, {bool forceRefresh = false}) {
    return _repository.fetchCompanies(
      query: _query,
      page: page,
      forceRefresh: forceRefresh,
    );
  }
}
