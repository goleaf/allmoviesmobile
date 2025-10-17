import 'package:allmovies_mobile/data/models/person_detail_model.dart';
import 'package:allmovies_mobile/data/tmdb_repository.dart';
import 'package:allmovies_mobile/presentation/screens/person_detail/person_detail_screen.dart';
import 'package:allmovies_mobile/providers/people_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('PersonDetailScreen renders and reacts to timeline controls', (tester) async {
    final repo = _PersonDetailRepo();
    final peopleProvider = PeopleProvider(repo, autoInitialize: false);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<TmdbRepository>.value(value: repo),
          ChangeNotifierProvider<PeopleProvider>.value(value: peopleProvider),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: PersonDetailScreen(personId: 1),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Career timeline'), findsOneWidget);
    expect(find.text('Project Modern'), findsOneWidget);
    expect(find.text('Project Early'), findsOneWidget);

    peopleProvider.setCreditSortOrder(CreditSortOrder.oldestFirst);
    await tester.pumpAndSettle();

    final earlyOffset = tester.getTopLeft(find.text('Project Early'));
    final modernOffset = tester.getTopLeft(find.text('Project Modern'));
    expect(earlyOffset.dy, lessThan(modernOffset.dy));

    peopleProvider.setDepartmentFilter('Production');
    await tester.pumpAndSettle();

    expect(find.text('Project Modern'), findsNothing);
    expect(find.text('Series Role'), findsNothing);
    expect(find.text('Project Early'), findsOneWidget);
  });
}

class _PersonDetailRepo extends TmdbRepository {
  @override
  Future<PersonDetail> fetchPersonDetails(
    int personId, {
    bool forceRefresh = false,
  }) async {
    return PersonDetail(
      id: personId,
      name: 'Test Person',
      combinedCredits: PersonCredits(
        cast: const [
          PersonCredit(
            id: 20,
            mediaType: 'tv',
            name: 'Series Role',
            character: 'Lead',
            department: 'Acting',
            firstAirDate: '2015-07-01',
          ),
        ],
        crew: const [
          PersonCredit(
            id: 10,
            mediaType: 'movie',
            title: 'Project Modern',
            job: 'Director',
            department: 'Directing',
            releaseDate: '2020-01-01',
          ),
          PersonCredit(
            id: 11,
            mediaType: 'movie',
            title: 'Project Early',
            job: 'Producer',
            department: 'Production',
            releaseDate: '2010-05-02',
          ),
        ],
      ),
      movieCredits: const PersonCredits(),
      tvCredits: const PersonCredits(),
    );
  }
}
