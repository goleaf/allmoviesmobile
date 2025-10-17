import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:allmovies_mobile/data/models/movie.dart';
import 'package:allmovies_mobile/data/models/paginated_response.dart';
import 'package:allmovies_mobile/data/tmdb_repository.dart';
import 'package:allmovies_mobile/providers/series_provider.dart';
import 'package:allmovies_mobile/presentation/screens/series/series_screen.dart';

class _FakeRepo extends TmdbRepository {
  PaginatedResponse<Movie> _buildResponse(String prefix, int page) {
    return PaginatedResponse<Movie>(
      page: page,
      totalPages: 4,
      totalResults: 4,
      results: [Movie(id: page, title: '$prefix Page $page')],
    );
  }

  @override
  Future<PaginatedResponse<Movie>> fetchTrendingTvPaginated({
    String timeWindow = 'day',
    int page = 1,
    bool forceRefresh = false,
  }) async {
    return _buildResponse('Trending', page);
  }

  @override
  Future<PaginatedResponse<Movie>> fetchPopularTvPaginated({
    int page = 1,
  }) async {
    return _buildResponse('Popular', page);
  }

  @override
  Future<PaginatedResponse<Movie>> fetchTopRatedTvPaginated({
    int page = 1,
  }) async {
    return _buildResponse('Top Rated', page);
  }

  @override
  Future<PaginatedResponse<Movie>> fetchAiringTodayTvPaginated({
    int page = 1,
  }) async {
    return _buildResponse('Airing Today', page);
  }

  @override
  Future<PaginatedResponse<Movie>> fetchOnTheAirTvPaginated({
    int page = 1,
  }) async {
    return _buildResponse('On The Air', page);
  }
}

void main() {
  testWidgets('SeriesScreen shows pager controls that load requested pages',
      (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SeriesProvider(_FakeRepo())),
        ],
        child: const MaterialApp(home: SeriesScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SeriesScreen), findsOneWidget);
    expect(find.text('Trending Page 1'), findsOneWidget);

    final nextButton =
        find.byKey(const ValueKey('series_trending_pager_next'));
    expect(nextButton, findsOneWidget);

    await tester.tap(nextButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    expect(find.text('Trending Page 2'), findsOneWidget);
  });
}
