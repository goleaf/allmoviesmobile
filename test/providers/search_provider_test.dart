import 'package:allmovies_mobile/data/models/company_model.dart';
import 'package:allmovies_mobile/data/models/paginated_response.dart';
import 'package:allmovies_mobile/data/models/search_result_model.dart';
import 'package:allmovies_mobile/data/services/local_storage_service.dart';
import 'package:allmovies_mobile/data/tmdb_repository.dart';
import 'package:allmovies_mobile/providers/search_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeRepo extends TmdbRepository {
  @override
  Future<SearchResponse> searchMulti(String query, {int page = 1, bool forceRefresh = false}) async {
    return SearchResponse(
      page: 1,
      totalPages: 1,
      totalResults: 1,
      results: [
        SearchResult(id: 1, mediaType: MediaType.movie, title: 'Hello', name: 'Hello')
      ],
    );
  }

  @override
  Future<PaginatedResponse<Company>> fetchCompanies({required String query, int page = 1, bool forceRefresh = false}) async {
    return PaginatedResponse<Company>(
      page: 1,
      totalPages: 1,
      totalResults: 1,
      results: [Company(id: 1, name: 'Acme')],
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('SearchProvider search populates results and history', () async {
    final prefs = await SharedPreferences.getInstance();
    final storage = LocalStorageService(prefs);
    final provider = SearchProvider(FakeRepo(), storage);
    await provider.search('hello');
    expect(provider.hasResults, isTrue);
    expect(provider.searchHistory, contains('hello'));
    await provider.loadMore();
    expect(provider.results, isNotEmpty);
  });
}


