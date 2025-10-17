import 'package:allmovies_mobile/data/models/paginated_response.dart';
import 'package:allmovies_mobile/data/models/person_model.dart';
import 'package:allmovies_mobile/data/tmdb_repository.dart';
import 'package:allmovies_mobile/providers/people_provider.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeRepo extends TmdbRepository {
  FakeRepo({
    this.trending = const [
      Person(id: 1, name: 'P', knownForDepartment: 'Acting'),
    ],
    this.popular = const [
      Person(id: 2, name: 'Q', knownForDepartment: 'Directing'),
    ],
  });

  final List<Person> trending;
  final List<Person> popular;

  @override
  Future<List<Person>> fetchTrendingPeople({
    String timeWindow = 'day',
    bool forceRefresh = false,
  }) async => trending;
  @override
  Future<PaginatedResponse<Person>> fetchPopularPeople({
    int page = 1,
    bool forceRefresh = false,
  }) async => PaginatedResponse<Person>(
    page: 1,
    totalPages: 1,
    totalResults: popular.length,
    results: popular,
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

  test('PeopleProvider filters by selected department', () async {
    final provider = PeopleProvider(
      FakeRepo(
        trending: const [
          Person(id: 1, name: 'Actor', knownForDepartment: 'Acting'),
          Person(id: 2, name: 'Director', knownForDepartment: 'Directing'),
        ],
        popular: const [
          Person(id: 3, name: 'Producer', knownForDepartment: 'Production'),
        ],
      ),
    );

    await provider.initialized;

    expect(provider.availableDepartments,
        equals(['Acting', 'Directing', 'Production']));
    expect(
      provider.sectionState(PeopleSection.trending).items.map((e) => e.name),
      ['Actor', 'Director'],
    );
    expect(
      provider.sectionState(PeopleSection.popular).items.map((e) => e.name),
      ['Producer'],
    );

    provider.selectDepartment('Directing');

    expect(
      provider.sectionState(PeopleSection.trending).items.map((e) => e.name),
      ['Director'],
    );
    expect(
      provider.sectionState(PeopleSection.popular).items,
      isEmpty,
    );

    provider.selectDepartment(null);

    expect(
      provider.sectionState(PeopleSection.trending).items.map((e) => e.name),
      ['Actor', 'Director'],
    );
    expect(
      provider.sectionState(PeopleSection.popular).items.map((e) => e.name),
      ['Producer'],
    );
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
