import 'package:allmovies_mobile/data/models/person_detail_model.dart';
import 'package:allmovies_mobile/data/tmdb_repository.dart';
import 'package:allmovies_mobile/providers/person_detail_provider.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePersonRepository extends TmdbRepository {
  _FakePersonRepository(this.detail) : super(apiKey: 'test');

  final PersonDetail detail;
  int calls = 0;

  @override
  Future<PersonDetail> fetchPersonDetails(
    int personId, {
    bool forceRefresh = false,
  }) async {
    calls += 1;
    return detail;
  }
}

void main() {
  group('PersonDetailProvider combined credits sorting', () {
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

    test('exposes sorted lists for year, popularity, and rating', () async {
      final provider = PersonDetailProvider(_FakePersonRepository(detail), 7);

      await provider.load();

      expect(provider.hasCombinedCredits, isTrue);
      expect(
        provider.combinedCreditsSortedByYear.map((c) => c.id),
        orderedEquals([2, 1, 3]),
      );
      expect(
        provider.combinedCreditsSortedByPopularity.map((c) => c.id),
        orderedEquals([3, 1, 2]),
      );
      expect(
        provider.combinedCreditsSortedByRating.map((c) => c.id),
        orderedEquals([2, 1, 3]),
      );
    });

    test('updates listeners when changing the selected sort option', () async {
      final provider = PersonDetailProvider(_FakePersonRepository(detail), 7);
      await provider.load();

      expect(provider.combinedCreditsSortOption, PersonCreditsSortOption.year);
      expect(provider.combinedCreditsSorted.first.id, 2);

      provider.setCombinedCreditsSortOption(PersonCreditsSortOption.popularity);
      expect(provider.combinedCreditsSortOption, PersonCreditsSortOption.popularity);
      expect(provider.combinedCreditsSorted.first.id, 3);

      provider.setCombinedCreditsSortOption(PersonCreditsSortOption.rating);
      expect(provider.combinedCreditsSortOption, PersonCreditsSortOption.rating);
      expect(provider.combinedCreditsSorted.first.id, 2);
    });
  });
}
