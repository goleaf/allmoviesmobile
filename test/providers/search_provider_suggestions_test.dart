import 'dart:async';

import 'package:allmovies_mobile/data/models/company_model.dart';
import 'package:allmovies_mobile/data/models/paginated_response.dart';
import 'package:allmovies_mobile/data/models/search_result_model.dart';
import 'package:allmovies_mobile/data/services/local_storage_service.dart';
import 'package:allmovies_mobile/data/tmdb_repository.dart';
import 'package:allmovies_mobile/providers/search_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeRepo extends TmdbRepository {
  @override
  Future<SearchResponse> searchMulti(
    String query, {
    int page = 1,
    bool forceRefresh = false,
  }) async {
    return SearchResponse(
      page: 1,
      totalPages: 1,
      totalResults: 2,
      results: [
        SearchResult(id: 1, mediaType: MediaType.movie, title: query),
        SearchResult(id: 2, mediaType: MediaType.person, name: 'Keanu Reeves'),
      ],
    );
  }

  @override
  Future<PaginatedResponse<Company>> fetchCompanies({
    required String query,
    int page = 1,
    bool forceRefresh = false,
  }) async {
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

  test('updateInputQuery debounces and populates suggestions', () async {
    final prefs = await SharedPreferences.getInstance();
    final storage = LocalStorageService(prefs);
    final provider = SearchProvider(_FakeRepo(), storage);

    provider.updateInputQuery('Matrix');

    // Wait past the debounce window (350ms) and for async fetch to complete
    await Future<void>.delayed(const Duration(milliseconds: 450));

    expect(provider.suggestions, isNotEmpty);
    expect(provider.suggestions.first, 'Matrix');

    provider.dispose();
  });
}
