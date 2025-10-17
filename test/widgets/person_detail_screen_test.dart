import 'package:allmovies_mobile/core/localization/app_localizations.dart';
import 'package:allmovies_mobile/data/models/person_detail_model.dart';
import 'package:allmovies_mobile/data/models/person_model.dart';
import 'package:allmovies_mobile/data/tmdb_repository.dart';
import 'package:allmovies_mobile/presentation/screens/person_detail/person_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../test_utils/pump_app.dart';

class _FakePersonRepository extends TmdbRepository {
  _FakePersonRepository(this.detail) : super(apiKey: 'test');

  final PersonDetail detail;

  @override
  Future<PersonDetail> fetchPersonDetails(
    int personId, {
    bool forceRefresh = false,
  }) async => detail;
}

void main() {
  const delegates = <LocalizationsDelegate<dynamic>>[
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  String titleForRow(WidgetTester tester, int index) {
    final finder = find.byKey(ValueKey('combinedCreditTitle_$index'));
    final text = tester.widget<Text>(finder);
    return text.data ?? '';
  }

  testWidgets('Combined credits reorder when selecting different sorts', (
    tester,
  ) async {
    final creditA = PersonCredit(
      id: 1,
      title: 'Alpha',
      releaseDate: '2020-05-01',
      popularity: 12,
      voteAverage: 7.5,
      voteCount: 200,
    );
    final creditB = PersonCredit(
      id: 2,
      title: 'Bravo',
      releaseDate: '2022-08-15',
      popularity: 8,
      voteAverage: 8.9,
      voteCount: 50,
    );
    final creditC = PersonCredit(
      id: 3,
      title: 'Charlie',
      releaseDate: '2018-11-20',
      popularity: 20,
      voteAverage: 6.2,
      voteCount: 500,
    );

    final detail = PersonDetail(
      id: 7,
      name: 'Test Person',
      combinedCredits: PersonCredits(
        cast: [creditA, creditB],
        crew: [creditC],
      ),
    );

    await pumpApp(
      tester,
      PersonDetailScreen(
        personId: 7,
        initialPerson: const Person(id: 7, name: 'Test Person'),
      ),
      providers: [
        Provider<TmdbRepository>.value(value: _FakePersonRepository(detail)),
      ],
      localizationsDelegates: delegates,
      supportedLocales: const [Locale('en')],
    );

    expect(find.text('Combined Credits'), findsOneWidget);
    expect(titleForRow(tester, 0), equals('Bravo'));

    await tester.tap(
      find.byKey(const ValueKey('personCombinedCreditsSortDropdown')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('personCombinedCreditsSortOption_popularity')),
    );
    await tester.pumpAndSettle();
    expect(titleForRow(tester, 0), equals('Charlie'));

    await tester.tap(
      find.byKey(const ValueKey('personCombinedCreditsSortDropdown')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('personCombinedCreditsSortOption_rating')),
    );
    await tester.pumpAndSettle();
    expect(titleForRow(tester, 0), equals('Bravo'));
  });
}
