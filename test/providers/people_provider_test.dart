import 'package:allmovies_mobile/data/models/paginated_response.dart';
import 'package:allmovies_mobile/data/models/person_model.dart';
import 'package:allmovies_mobile/data/models/person_detail_model.dart';
import 'package:allmovies_mobile/data/tmdb_repository.dart';
import 'package:allmovies_mobile/providers/people_provider.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeRepo extends TmdbRepository {
  @override
  Future<List<Person>> fetchTrendingPeople({
    String timeWindow = 'day',
    bool forceRefresh = false,
  }) async => const [
        Person(id: 1, name: 'P', knownForDepartment: 'Acting'),
        Person(id: 2, name: 'Q', knownForDepartment: 'Directing'),
      ];
  @override
  Future<PaginatedResponse<Person>> fetchPopularPeople({
    int page = 1,
    bool forceRefresh = false,
  }) async => PaginatedResponse<Person>(
    page: 1,
    totalPages: 1,
    totalResults: 1,
    results: const [
      Person(id: 3, name: 'R', knownForDepartment: 'Production'),
      Person(id: 4, name: 'S', knownForDepartment: 'Acting'),
    ],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('PeopleProvider loads sections', () async {
    final provider = PeopleProvider(FakeRepo());
    await provider.initialized;
    expect(provider.isInitialized, isTrue);
    expect(provider.sectionState(PeopleSection.trending).items, isNotEmpty);
    expect(provider.sectionState(PeopleSection.popular).items, isNotEmpty);
  });

  test(
    'PeopleProvider sets globalError and section errors on TmdbException',
    () async {
      final failingRepo = _FailingRepo();
      final provider = PeopleProvider(failingRepo);
      await provider.initialized;
      expect(provider.isInitialized, isFalse);
      expect(provider.globalError, contains('boom'));
      for (final section in PeopleSection.values) {
        final state = provider.sectionState(section);
        expect(state.isLoading, isFalse);
        expect(state.items, isEmpty);
        expect(state.errorMessage, isNotNull);
      }
    },
  );

  test('PeopleProvider filters people by selected department', () async {
    final provider = PeopleProvider(FakeRepo());
    await provider.initialized;

    expect(provider.availableDepartments, containsAll(['Acting', 'Directing', 'Production']));

    provider.setDepartmentFilter('Acting');
    final trending = provider.sectionState(PeopleSection.trending).items;
    final popular = provider.sectionState(PeopleSection.popular).items;

    expect(trending, hasLength(1));
    expect(popular, hasLength(1));
    expect(trending.every((person) => person.knownForDepartment == 'Acting'), isTrue);
    expect(popular.every((person) => person.knownForDepartment == 'Acting'), isTrue);

    provider.setDepartmentFilter(null);
    expect(provider.sectionState(PeopleSection.trending).items, hasLength(2));
  });

  test('PeopleProvider sorts credits using configured order', () {
    final provider = PeopleProvider(FakeRepo(), autoInitialize: false);
    final credits = [
      const PersonCredit(
        id: 1,
        mediaType: 'movie',
        job: 'Director',
        department: 'Directing',
        releaseDate: '2022-05-01',
      ),
      const PersonCredit(
        id: 2,
        mediaType: 'movie',
        character: 'Hero',
        department: 'Acting',
        releaseDate: '2018-01-01',
      ),
      const PersonCredit(
        id: 3,
        mediaType: 'tv',
        job: 'Producer',
        department: 'Production',
        firstAirDate: '2010-09-10',
      ),
    ];

    final newestFirst = provider.sortCredits(credits);
    expect(newestFirst.first.id, 1);

    provider.setCreditSortOrder(CreditSortOrder.oldestFirst);
    final oldestFirst = provider.sortCredits(credits);
    expect(oldestFirst.first.id, 3);

    provider.setDepartmentFilter('Directing');
    final filtered = provider.transformCredits(credits);
    expect(filtered, hasLength(1));
    expect(filtered.first.department, equals('Directing'));
  });
}

class _FailingRepo extends TmdbRepository {
  @override
  Future<List<Person>> fetchTrendingPeople({
    String timeWindow = 'day',
    bool forceRefresh = false,
  }) async {
    throw TmdbException('boom');
  }

  @override
  Future<PaginatedResponse<Person>> fetchPopularPeople({
    int page = 1,
    bool forceRefresh = false,
  }) async {
    throw TmdbException('boom');
  }
}
