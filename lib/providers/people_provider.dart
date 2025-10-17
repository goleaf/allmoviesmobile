import '../data/models/paginated_response.dart';
import '../data/models/person_model.dart';
import '../data/tmdb_repository.dart';
import 'paginated_resource_provider.dart';

class PeopleProvider extends PaginatedResourceProvider<Person> {
  PeopleProvider(this._repository) {
    loadInitial();
  }

  final TmdbRepository _repository;

  List<Person> get people => items;
  bool get isLoading => isInitialLoading;
  bool get isLoadingMore => super.isLoadingMore;
  bool get canLoadMore => hasMore;

  Future<void> refreshPeople() => refresh();
  Future<void> loadMorePeople() => loadMore();

  @override
  Future<PaginatedResponse<Person>> loadPage(int page, {bool forceRefresh = false}) {
    return _repository.fetchPopularPeople(
      page: page,
      forceRefresh: forceRefresh,
    );
  }
}
