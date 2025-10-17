import 'package:allmovies_mobile/data/models/paginated_response.dart';
import 'package:allmovies_mobile/data/models/person_model.dart';
import 'package:allmovies_mobile/data/tmdb_repository.dart';
import 'package:allmovies_mobile/providers/people_provider.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeRepo extends TmdbRepository {
  @override
  Future<List<Person>> fetchTrendingPeople({String timeWindow = 'day', bool forceRefresh = false}) async =>
      [const Person(id: 1, name: 'P')];
  @override
  Future<PaginatedResponse<Person>> fetchPopularPeople({int page = 1, bool forceRefresh = false}) async =>
      PaginatedResponse<Person>(page: 1, totalPages: 1, totalResults: 1, results: [const Person(id: 2, name: 'Q')]);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('PeopleProvider loads sections', () async {
    final provider = PeopleProvider(FakeRepo());
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(provider.isInitialized, isTrue);
    expect(provider.sectionState(PeopleSection.trending).items, isNotEmpty);
    expect(provider.sectionState(PeopleSection.popular).items, isNotEmpty);
  });
}


