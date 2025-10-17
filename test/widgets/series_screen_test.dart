import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:allmovies_mobile/data/models/movie.dart';
import 'package:allmovies_mobile/data/models/paginated_response.dart';
import 'package:allmovies_mobile/data/tmdb_repository.dart';
import 'package:allmovies_mobile/providers/series_provider.dart';
import 'package:allmovies_mobile/presentation/screens/series/series_screen.dart';
import 'package:allmovies_mobile/core/constants/app_strings.dart';

PaginatedResponse<Movie> _page(String prefix, int page, {int totalPages = 5}) {
  return PaginatedResponse<Movie>(
    page: page,
    totalPages: totalPages,
    totalResults: totalPages,
    results: [Movie(id: page, title: '$prefix$page')],
  );
}

class _FakeRepo extends TmdbRepository {
  @override
  Future<PaginatedResponse<Movie>> fetchTrendingTv({
    String timeWindow = 'day',
    int page = 1,
    bool forceRefresh = false,
  }) async => _page('TV-T', page);

  @override
  Future<PaginatedResponse<Movie>> fetchPopularTv({int page = 1}) async =>
      _page('TV-P', page);

  @override
  Future<PaginatedResponse<Movie>> fetchTopRatedTv({int page = 1}) async =>
      _page('TV-TR', page);

  @override
  Future<PaginatedResponse<Movie>> fetchAiringTodayTv({int page = 1}) async =>
      _page('TV-AT', page);

  @override
  Future<PaginatedResponse<Movie>> fetchOnTheAirTv({int page = 1}) async =>
      _page('TV-OTA', page);
}

void main() {
  testWidgets('SeriesScreen builds with tabs and pagination controls',
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
    expect(find.byType(TabBar), findsOneWidget);
    expect(find.textContaining('Page 1'), findsWidgets);

    await tester.tap(find.byTooltip('Next page'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.textContaining('Page 2'), findsWidgets);
  });

  testWidgets('SeriesScreen jump-to-page flow updates pagination state',
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

    expect(find.text('Page 1 of 5'), findsWidgets);

    await tester.tap(find.text(AppStrings.jump));
    await tester.pumpAndSettle();

    final sheet = find.byType(BottomSheet);
    expect(sheet, findsOneWidget);

    await tester.enterText(
      find.descendant(of: sheet, matching: find.byType(TextField)).first,
      '3',
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(AppStrings.go));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Page 3 of 5'), findsWidgets);

    await tester.tap(find.byTooltip('Next page'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Page 4 of 5'), findsWidgets);
  });
}
