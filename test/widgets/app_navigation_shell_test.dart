import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'package:allmovies_mobile/core/localization/app_localizations.dart';
import 'package:allmovies_mobile/core/navigation/deep_link_handler.dart';
import 'package:allmovies_mobile/data/models/company_model.dart';
import 'package:allmovies_mobile/data/models/movie.dart';
import 'package:allmovies_mobile/data/models/paginated_response.dart';
import 'package:allmovies_mobile/data/models/person_model.dart';
import 'package:allmovies_mobile/data/models/search_result_model.dart';
import 'package:allmovies_mobile/data/tmdb_repository.dart';
import 'package:allmovies_mobile/data/services/local_storage_service.dart';
import 'package:allmovies_mobile/presentation/navigation/app_navigation_shell.dart';
import 'package:allmovies_mobile/providers/app_state_provider.dart';
import 'package:allmovies_mobile/providers/movies_provider.dart';
import 'package:allmovies_mobile/providers/search_provider.dart';
import 'package:allmovies_mobile/providers/series_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Bottom navigation switches destinations', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    final storage = LocalStorageService(prefs);
    final repo = _FakeTmdbRepository();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<TmdbRepository>.value(value: repo),
          ChangeNotifierProvider(create: (_) => AppStateProvider(prefs)),
          ChangeNotifierProvider(
            create: (_) => DeepLinkHandler(
              uriStream: const Stream<Uri?>.empty(),
              initialUriGetter: () async => null,
            ),
          ),
          ChangeNotifierProvider(
            create: (_) => MoviesProvider(
              repo,
              autoInitialize: false,
            ),
          ),
          ChangeNotifierProvider(
            create: (_) => SeriesProvider(
              repo,
              autoInitialize: false,
            ),
          ),
          ChangeNotifierProvider(
            create: (_) => SearchProvider(repo, storage),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: const AppNavigationShell(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Initially on Home
    expect(find.byType(NavigationBar), findsOneWidget);

    // Tap Movies destination (use label from AppStrings)
    await tester.tap(find.text('Movies').first);
    await tester.pumpAndSettle();

    // Tap TV destination
    await tester.tap(find.text('Series').first);
    await tester.pumpAndSettle();

    // Tap Search destination (label is 'Search movies...' in AppStrings.search)
    // Fallback to tapping the navigation icon by tooltip if text is not visible
    final searchTextFinder = find.text('Search movies...');
    if (searchTextFinder.evaluate().isEmpty) {
      // Find the third NavigationDestination by semantics
      final navBar = find.byType(NavigationBar);
      expect(navBar, findsOneWidget);
      // Tap by index using widget tree order
      await tester.tap(
        find.descendant(of: navBar, matching: find.byIcon(Icons.search)).first,
      );
    } else {
      await tester.tap(searchTextFinder.first);
    }
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
  });
}

class _FakeTmdbRepository extends TmdbRepository {
  _FakeTmdbRepository() : super(apiKey: 'test');

  PaginatedResponse<T> _emptyResponse<T>() {
    return const PaginatedResponse<T>(
      page: 1,
      totalPages: 1,
      totalResults: 0,
      results: <T>[],
    );
  }

  @override
  Future<PaginatedResponse<Movie>> fetchTrendingTitles({
    String mediaType = 'all',
    String timeWindow = 'day',
    int page = 1,
    bool forceRefresh = false,
  }) async {
    return _emptyResponse<Movie>();
  }

  @override
  Future<SearchResponse> searchMulti(
    String query, {
    int page = 1,
    bool forceRefresh = false,
  }) async {
    return const SearchResponse();
  }

  @override
  Future<PaginatedResponse<Movie>> searchMovies(
    String query, {
    int page = 1,
    bool includeAdult = false,
    String? region,
    String? year,
    String? primaryReleaseYear,
    bool forceRefresh = false,
  }) async {
    return _emptyResponse<Movie>();
  }

  @override
  Future<PaginatedResponse<Movie>> searchTvSeries(
    String query, {
    int page = 1,
    String? language,
    String? firstAirDateYear,
    bool forceRefresh = false,
  }) async {
    return _emptyResponse<Movie>();
  }

  @override
  Future<PaginatedResponse<Person>> searchPeople(
    String query, {
    int page = 1,
    bool includeAdult = false,
    String? region,
    bool forceRefresh = false,
  }) async {
    return _emptyResponse<Person>();
  }

  @override
  Future<PaginatedResponse<Company>> fetchCompanies({
    String? query,
    int page = 1,
    bool forceRefresh = false,
  }) async {
    return _emptyResponse<Company>();
  }
}
