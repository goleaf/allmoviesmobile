import 'package:flutter_test/flutter_test.dart';
import 'package:allmovies_mobile/providers/season_detail_provider.dart';
import 'package:allmovies_mobile/data/models/season_model.dart';
import 'package:allmovies_mobile/data/tmdb_repository.dart';

class _FakeRepo extends TmdbRepository {
  Season? toReturn;
  int calls = 0;
  _FakeRepo(this.toReturn);

  @override
  Future<Season> fetchTvSeason(
    int tvId,
    int seasonNumber, {
    bool forceRefresh = false,
  }) async {
    calls++;
    return toReturn!;
  }
}

void main() {
  test('loads season and caches result', () async {
    final season = Season(id: 1, name: 'S1', seasonNumber: 1, episodeCount: 10);
    final repo = _FakeRepo(season);
    final provider = SeasonDetailProvider(repo, tvId: 100, seasonNumber: 1);

    expect(provider.season, isNull);
    await provider.load();
    expect(provider.season, isNotNull);
    expect(repo.calls, 1);

    await provider.load();
    expect(repo.calls, 1, reason: 'should use cache without forceRefresh');

    await provider.load(forceRefresh: true);
    expect(repo.calls, 2, reason: 'forceRefresh should refetch');
  });
}
