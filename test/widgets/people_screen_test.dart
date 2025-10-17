import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:allmovies_mobile/data/models/person_model.dart';
import 'package:allmovies_mobile/data/models/paginated_response.dart';
import 'package:allmovies_mobile/data/tmdb_repository.dart';
import 'package:allmovies_mobile/providers/people_provider.dart';
import 'package:allmovies_mobile/presentation/screens/people/people_screen.dart';

class _FakeRepo extends TmdbRepository {
  @override
  Future<PaginatedResponse<Person>> fetchPopularPeople({
    int page = 1,
    bool forceRefresh = false,
  }) async {
    return PaginatedResponse<Person>(
      page: 1,
      totalPages: 1,
      totalResults: 1,
      results: [
        const Person(id: 1, name: 'Popular Actor', knownForDepartment: 'Acting'),
        const Person(id: 2, name: 'Popular Producer', knownForDepartment: 'Production'),
      ],
    );
  }

  @override
  Future<List<Person>> fetchTrendingPeople({
    String timeWindow = 'day',
    bool forceRefresh = false,
  }) async => const [
        Person(id: 3, name: 'Trending Actor', knownForDepartment: 'Acting'),
        Person(id: 4, name: 'Trending Director', knownForDepartment: 'Directing'),
      ];
}

void main() {
  testWidgets('PeopleScreen builds with tabs', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => PeopleProvider(_FakeRepo())),
        ],
        child: const MaterialApp(home: PeopleScreen()),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(PeopleScreen), findsOneWidget);
    expect(find.byType(TabBar), findsOneWidget);
  });

  testWidgets('PeopleScreen filter bar updates provider state', (tester) async {
    final provider = PeopleProvider(_FakeRepo());

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<PeopleProvider>.value(value: provider),
        ],
        child: const MaterialApp(home: PeopleScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Trending Actor'), findsOneWidget);
    expect(find.text('Trending Director'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('people_department_filter')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Acting').last);
    await tester.pumpAndSettle();

    expect(provider.departmentFilter, equals('Acting'));
    expect(find.text('Trending Director'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('people_credit_sort')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Oldest first').last);
    await tester.pumpAndSettle();

    expect(provider.creditSortOrder, CreditSortOrder.oldestFirst);
  });
}
