import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:allmovies_mobile/data/models/company_model.dart';
import 'package:allmovies_mobile/data/models/paginated_response.dart';
import 'package:allmovies_mobile/data/models/search_result_model.dart';
import 'package:allmovies_mobile/data/services/local_storage_service.dart';
import 'package:allmovies_mobile/data/tmdb_repository.dart';
import 'package:allmovies_mobile/providers/search_provider.dart';
import 'package:allmovies_mobile/presentation/screens/search/search_screen.dart';

class _FakeRepo extends TmdbRepository {
  _FakeRepo();

  @override
  Future<SearchResponse> searchMulti(String query, {int page = 1, bool forceRefresh = false}) async {
    return SearchResponse(
      page: 1,
      totalPages: 1,
      totalResults: 1,
      results: [SearchResult(id: 1, mediaType: MediaType.movie, title: 'X')],
    );
  }

  @override
  Future<PaginatedResponse<Company>> fetchCompanies({String? query, int page = 1, bool forceRefresh = false}) async {
    return PaginatedResponse<Company>(page: 1, totalPages: 1, totalResults: 1, results: [Company(id: 1, name: 'C')]);
  }
}

void main() {
  testWidgets('SearchScreen with initialQuery triggers search and renders', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storage = LocalStorageService(prefs);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SearchProvider(_FakeRepo(), storage)),
        ],
        child: const MaterialApp(
          home: SearchScreen(initialQuery: 'test'),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(SearchScreen), findsOneWidget);
  });
}


