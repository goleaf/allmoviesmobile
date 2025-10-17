import 'package:allmovies_mobile/data/models/company_model.dart';
import 'package:allmovies_mobile/data/models/paginated_response.dart';
import 'package:allmovies_mobile/data/tmdb_repository.dart';
import 'package:allmovies_mobile/providers/companies_provider.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeRepo extends TmdbRepository {
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

  test('CompaniesProvider searchCompanies updates state', () async {
    final provider = CompaniesProvider(FakeRepo());
    await provider.searchCompanies('acme');
    expect(provider.isSearching, isFalse);
    expect(provider.searchResults, isNotEmpty);
    provider.clear();
    expect(provider.searchResults, isEmpty);
  });
}
