import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:allmovies_mobile/data/models/person_model.dart';
import 'package:allmovies_mobile/data/tmdb_repository.dart';
import 'package:allmovies_mobile/providers/people_provider.dart';
import 'package:allmovies_mobile/presentation/screens/people/people_screen.dart';

class _FakeRepo extends TmdbRepository {
  @override
  Future<List<Person>> fetchPopularPeople({int page = 1, bool forceRefresh = false}) async => [Person(id: 1, name: 'P')];
  @override
  Future<List<Person>> fetchTrendingPeople({String timeWindow = 'day', bool forceRefresh = false}) async => [Person(id: 2, name: 'T')];
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
}


