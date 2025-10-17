import 'package:allmovies_mobile/data/models/genre_model.dart';
import 'package:allmovies_mobile/data/tmdb_repository.dart';
import 'package:allmovies_mobile/providers/genres_provider.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeRepo extends TmdbRepository {
  @override
  Future<List<Genre>> fetchMovieGenres({bool forceRefresh = false}) async => [const Genre(id: 1, name: 'Action')];
  @override
  Future<List<Genre>> fetchTVGenres({bool forceRefresh = false}) async => [const Genre(id: 2, name: 'Drama')];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('GenresProvider loads and maps names', () async {
    final provider = GenresProvider(FakeRepo());
    await provider.fetchMovieGenres(forceRefresh: true);
    await provider.fetchTvGenres(forceRefresh: true);
    expect(provider.movieGenres, isNotEmpty);
    expect(provider.tvGenres, isNotEmpty);
    expect(provider.getGenreName(1), 'Action');
    expect(provider.getGenreName(2, isTv: true), 'Drama');
  });
}


