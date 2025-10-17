import 'package:flutter_test/flutter_test.dart';

import 'package:allmovies_mobile/data/models/movie.dart';
import 'package:allmovies_mobile/data/models/paginated_response.dart';
import 'package:allmovies_mobile/data/tmdb_repository.dart';
import 'package:allmovies_mobile/providers/trending_titles_provider.dart';

class FakeRepo extends TmdbRepository {
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('TrendingTitlesProvider loads and refreshes', () async {
    final provider = TrendingTitlesProvider(FakeRepo());
    await provider.load();
    expect(provider.stateFor(TrendingMediaType.all, TrendingWindow.day).items, isNotEmpty);
    await provider.refreshAll();
    expect(provider.stateFor(TrendingMediaType.all, TrendingWindow.week).items, isNotEmpty);
  });
}


