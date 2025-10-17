import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:allmovies_mobile/data/models/movie.dart';
import 'package:allmovies_mobile/data/tmdb_repository.dart';
import 'package:allmovies_mobile/providers/series_provider.dart';
import 'package:allmovies_mobile/presentation/screens/series/series_screen.dart';

class _FakeRepo extends TmdbRepository {
  @override
  Future<List<Movie>> fetchTrendingTv({
    String timeWindow = 'day',
    bool forceRefresh = false,
  }) async => [Movie(id: 10, title: 'TV-T')];
  @override
  Future<List<Movie>> fetchPopularTv({int page = 1}) async => [
    Movie(id: 11, title: 'TV-P'),
  ];
  @override
  Future<List<Movie>> fetchTopRatedTv({int page = 1}) async => [
    Movie(id: 12, title: 'TV-TR'),
  ];
  @override
  Future<List<Movie>> fetchAiringTodayTv({int page = 1}) async => [
    Movie(id: 13, title: 'TV-AT'),
  ];
  @override
  Future<List<Movie>> fetchOnTheAirTv({int page = 1}) async => [
    Movie(id: 14, title: 'TV-OTA'),
  ];
}

void main() {
  testWidgets('SeriesScreen builds with tabs', (tester) async {
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
  });
}
