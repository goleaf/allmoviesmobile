import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:allmovies_mobile/data/models/company_model.dart';
import 'package:allmovies_mobile/data/models/paginated_response.dart';
import 'package:allmovies_mobile/data/tmdb_repository.dart';
import 'package:allmovies_mobile/presentation/screens/companies/companies_screen.dart';
import 'package:allmovies_mobile/providers/companies_provider.dart';

class _FakeRepo extends TmdbRepository {
  @override
  Future<PaginatedResponse<Company>> fetchCompanies({String? query, int page = 1, bool forceRefresh = false}) async =>
      PaginatedResponse<Company>(page: 1, totalPages: 1, totalResults: 0, results: const []);
  @override
  Future<Company> fetchCompanyDetails(int companyId) async => const Company(id: 1, name: 'Comp');
}

void main() {
  testWidgets('CompaniesScreen builds with search field and empty state', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CompaniesProvider(_FakeRepo())),
        ],
        child: const MaterialApp(home: CompaniesScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(CompaniesScreen), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });
}


