import 'package:flutter_test/flutter_test.dart';

import 'package:allmovies_mobile/data/models/movie.dart';
import 'package:allmovies_mobile/data/models/paginated_response.dart';
import 'package:allmovies_mobile/data/tmdb_repository.dart';
import 'package:allmovies_mobile/providers/trending_titles_provider.dart';

class _FakeRepo extends TmdbRepository {
  @override
  Future<PaginatedResponse<Movie>> fetchTrendingTitles({
    String mediaType = 'all',
    String timeWindow = 'day',
    int page = 1,
    bool forceRefresh = false,
  }) async {
    return PaginatedResponse<Movie>(
      page: 1,
      totalPages: 1,
      totalResults: 1,
      results: [const Movie(id: 1, title: 'A', mediaType: 'movie')],
    );
  }
}

class _CountingRepo extends TmdbRepository {
  int callCount = 0;

  @override
  Future<PaginatedResponse<Movie>> fetchTrendingTitles({
    String mediaType = 'all',
    String timeWindow = 'day',
    int page = 1,
    bool forceRefresh = false,
  }) async {
    callCount++;
    return PaginatedResponse<Movie>(
      page: page,
      totalPages: 2,
      totalResults: 2,
      results: [
        Movie(id: page, title: 'Movie #$page', mediaType: mediaType),
      ],
    );
  }
}

class _ErrorRepo extends TmdbRepository {
  @override
  Future<PaginatedResponse<Movie>> fetchTrendingTitles({
    String mediaType = 'all',
    String timeWindow = 'day',
    int page = 1,
    bool forceRefresh = false,
  }) async {
    throw const TmdbException('kaput');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('TrendingTitlesProvider loads and refreshes', () async {
    final provider = TrendingTitlesProvider(_FakeRepo());
    await provider.load();
    expect(
      provider.stateFor(TrendingMediaType.all, TrendingWindow.day).items,
      isNotEmpty,
    );
    await provider.refreshAll();
    expect(
      provider.stateFor(TrendingMediaType.all, TrendingWindow.week).items,
      isNotEmpty,
    );
  });

  test('ensureLoaded avoids duplicate fetches without force refresh', () async {
    final repo = _CountingRepo();
    final provider = TrendingTitlesProvider(repo);

    // First ensureLoaded should perform a fetch for the default bucket.
    await provider.ensureLoaded();
    expect(repo.callCount, 1);

    // Subsequent ensureLoaded for same bucket should use cached data.
    await provider.ensureLoaded();
    expect(repo.callCount, 1);

    // Forcing a refresh should issue another repository call.
    await provider.load(forceRefresh: true);
    expect(repo.callCount, 2);
  });

  test('load surfaces repository error as user-facing message', () async {
    final provider = TrendingTitlesProvider(_ErrorRepo());

    // Trigger the failing load path and verify error message is captured.
    await provider.load(mediaType: TrendingMediaType.movie);
    final state = provider.stateFor(TrendingMediaType.movie, TrendingWindow.day);
    expect(state.items, isEmpty);
    expect(state.errorMessage, contains('kaput'));
  });
}
