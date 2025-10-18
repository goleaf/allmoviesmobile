import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:allmovies_mobile/core/localization/app_localizations.dart';
import 'package:allmovies_mobile/data/models/collection_model.dart';
import 'package:allmovies_mobile/data/models/movie.dart';
import 'package:allmovies_mobile/data/models/movie_ref_model.dart';
import 'package:allmovies_mobile/data/models/paginated_response.dart';
import 'package:allmovies_mobile/data/models/person_model.dart';
import 'package:allmovies_mobile/data/models/saved_media_item.dart';
import 'package:allmovies_mobile/data/models/notification_item.dart';
import 'package:allmovies_mobile/data/services/local_storage_service.dart';
import 'package:allmovies_mobile/data/tmdb_repository.dart';
import 'package:allmovies_mobile/presentation/screens/home/home_screen.dart';
import 'package:allmovies_mobile/presentation/screens/movies/movies_screen.dart';
import 'package:allmovies_mobile/presentation/screens/notifications/notifications_screen.dart';
import 'package:allmovies_mobile/presentation/screens/search/search_screen.dart';
import 'package:allmovies_mobile/providers/collections_provider.dart';
import 'package:allmovies_mobile/providers/movies_provider.dart';
import 'package:allmovies_mobile/providers/notifications_provider.dart';
import 'package:allmovies_mobile/providers/people_provider.dart';
import 'package:allmovies_mobile/providers/preferences_provider.dart';
import 'package:allmovies_mobile/providers/recommendations_provider.dart';
import 'package:allmovies_mobile/providers/series_provider.dart';
import 'package:allmovies_mobile/providers/watch_region_provider.dart';
import 'package:allmovies_mobile/providers/watchlist_provider.dart';

import '../../../test_utils/pump_app.dart';

class _RejectingClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    throw StateError('Unexpected network call: ${request.url}');
  }
}

class _HomeScreenTestRepository extends TmdbRepository {
  _HomeScreenTestRepository()
      : super(apiKey: 'test', client: _RejectingClient());

  static const Movie _trendingMovie = Movie(
    id: 101,
    title: 'Trending Hit',
    mediaType: 'movie',
  );

  static const Movie _nowPlayingMovie = Movie(
    id: 102,
    title: 'Now Playing Blockbuster',
    mediaType: 'movie',
  );

  static const Movie _popularMovie = Movie(
    id: 103,
    title: 'Popular Favorite',
    mediaType: 'movie',
  );

  static const Movie _topRatedMovie = Movie(
    id: 104,
    title: 'Top Rated Gem',
    mediaType: 'movie',
  );

  static const Movie _upcomingMovie = Movie(
    id: 105,
    title: 'Upcoming Anticipation',
    mediaType: 'movie',
  );

  static const Movie _discoverMovie = Movie(
    id: 106,
    title: 'Discover Surprise',
    mediaType: 'movie',
  );

  static const Movie _trendingSeries = Movie(
    id: 201,
    title: 'Trending Series',
    mediaType: 'tv',
  );

  static const Movie _popularSeries = Movie(
    id: 202,
    title: 'Popular Series',
    mediaType: 'tv',
  );

  static const Movie _topRatedSeries = Movie(
    id: 203,
    title: 'Top Rated Series',
    mediaType: 'tv',
  );

  static const Movie _airingTodaySeries = Movie(
    id: 204,
    title: 'Airing Today',
    mediaType: 'tv',
  );

  static const Movie _onTheAirSeries = Movie(
    id: 205,
    title: 'Currently On Air',
    mediaType: 'tv',
  );

  static const Person _featuredPerson = Person(id: 301, name: 'Jordan Flux');

  PaginatedResponse<Movie> _moviePage(List<Movie> items) =>
      PaginatedResponse<Movie>(
        page: 1,
        totalPages: 1,
        totalResults: items.length,
        results: items,
      );

  PaginatedResponse<Person> _personPage(List<Person> items) =>
      PaginatedResponse<Person>(
        page: 1,
        totalPages: 1,
        totalResults: items.length,
        results: items,
      );

  @override
  Future<List<Movie>> fetchTrendingMovies({
    String timeWindow = 'day',
    bool forceRefresh = false,
  }) async => [_trendingMovie];

  @override
  Future<List<Movie>> fetchPopularMovies({
    int page = 1,
    bool forceRefresh = false,
  }) async => [_popularMovie];

  @override
  Future<List<Movie>> fetchTopRatedMovies({
    int page = 1,
    bool forceRefresh = false,
  }) async => [_topRatedMovie];

  @override
  Future<List<Movie>> fetchNowPlayingMovies({int page = 1}) async =>
      [_nowPlayingMovie];

  @override
  Future<List<Movie>> fetchUpcomingMovies({int page = 1}) async =>
      [_upcomingMovie];

  @override
  Future<PaginatedResponse<Movie>> fetchTrendingMoviesPaginated({
    String timeWindow = 'day',
    int page = 1,
    bool forceRefresh = false,
  }) async => _moviePage([_trendingMovie]);

  @override
  Future<PaginatedResponse<Movie>> fetchPopularMoviesPaginated({
    int page = 1,
    bool forceRefresh = false,
  }) async => _moviePage([_popularMovie]);

  @override
  Future<PaginatedResponse<Movie>> fetchTopRatedMoviesPaginated({
    int page = 1,
    bool forceRefresh = false,
  }) async => _moviePage([_topRatedMovie]);

  @override
  Future<PaginatedResponse<Movie>> fetchNowPlayingMoviesPaginated({
    int page = 1,
    bool forceRefresh = false,
  }) async => _moviePage([_nowPlayingMovie]);

  @override
  Future<PaginatedResponse<Movie>> fetchUpcomingMoviesPaginated({
    int page = 1,
    bool forceRefresh = false,
  }) async => _moviePage([_upcomingMovie]);

  @override
  Future<PaginatedResponse<Movie>> discoverMovies({
    int page = 1,
    discoverFilters,
    Map<String, String>? filters,
    bool forceRefresh = false,
  }) async => _moviePage([_discoverMovie]);

  @override
  Future<PaginatedResponse<Movie>> discoverTvSeries({
    int page = 1,
    Map<String, String>? filters,
    bool forceRefresh = false,
  }) async => _moviePage([_popularSeries]);

  @override
  Future<PaginatedResponse<Movie>> fetchTrendingTv({
    String timeWindow = 'day',
    int page = 1,
    bool forceRefresh = false,
  }) async => _moviePage([_trendingSeries]);

  @override
  Future<PaginatedResponse<Movie>> fetchPopularTv({int page = 1}) async =>
      _moviePage([_popularSeries]);

  @override
  Future<PaginatedResponse<Movie>> fetchTopRatedTv({int page = 1}) async =>
      _moviePage([_topRatedSeries]);

  @override
  Future<PaginatedResponse<Movie>> fetchAiringTodayTv({int page = 1}) async =>
      _moviePage([_airingTodaySeries]);

  @override
  Future<PaginatedResponse<Movie>> fetchOnTheAirTv({int page = 1}) async =>
      _moviePage([_onTheAirSeries]);

  @override
  Future<PaginatedResponse<Movie>> fetchNetworkTvShows({
    required int networkId,
    int page = 1,
    String sortBy = 'popularity.desc',
    double? minVoteAverage,
    String? originalLanguage,
    bool forceRefresh = false,
  }) async => _moviePage([_popularSeries]);

  @override
  Future<List<Person>> fetchTrendingPeople({String timeWindow = 'day'}) async =>
      [_featuredPerson];

  @override
  Future<PaginatedResponse<Person>> fetchPopularPeople({
    int page = 1,
    bool forceRefresh = false,
  }) async => _personPage([_featuredPerson]);

  @override
  Future<CollectionDetails> fetchCollectionDetails(
    int collectionId, {
    bool forceRefresh = false,
  }) async {
    return CollectionDetails(
      id: collectionId,
      name: 'Saga Collection $collectionId',
      overview: 'A curated saga for testing',
      parts: const [
        MovieRef(id: 401, title: 'Collection Highlight', mediaType: 'movie'),
      ],
    );
  }
}

class _HomeTestHarness {
  _HomeTestHarness({
    required this.prefs,
    required this.storage,
    required this.repository,
    required this.watchRegion,
    required this.preferences,
    required this.moviesProvider,
    required this.seriesProvider,
    required this.peopleProvider,
    required this.collectionsProvider,
    required this.recommendationsProvider,
    required this.watchlistProvider,
    required this.notificationsProvider,
  });

  final SharedPreferences prefs;
  final LocalStorageService storage;
  final _HomeScreenTestRepository repository;
  final WatchRegionProvider watchRegion;
  final PreferencesProvider preferences;
  final MoviesProvider moviesProvider;
  final SeriesProvider seriesProvider;
  final PeopleProvider peopleProvider;
  final CollectionsProvider collectionsProvider;
  final RecommendationsProvider recommendationsProvider;
  final WatchlistProvider watchlistProvider;
  final NotificationsProvider notificationsProvider;

  List<SingleChildWidget> get providers => [
        ChangeNotifierProvider<WatchRegionProvider>.value(value: watchRegion),
        ChangeNotifierProvider<PreferencesProvider>.value(value: preferences),
        ChangeNotifierProvider<MoviesProvider>.value(value: moviesProvider),
        ChangeNotifierProvider<SeriesProvider>.value(value: seriesProvider),
        ChangeNotifierProvider<PeopleProvider>.value(value: peopleProvider),
        ChangeNotifierProvider<CollectionsProvider>.value(
          value: collectionsProvider,
        ),
        ChangeNotifierProvider<RecommendationsProvider>.value(
          value: recommendationsProvider,
        ),
        ChangeNotifierProvider<WatchlistProvider>.value(
          value: watchlistProvider,
        ),
        ChangeNotifierProvider<NotificationsProvider>.value(
          value: notificationsProvider,
        ),
      ];

  void dispose() {
    watchRegion.dispose();
    preferences.dispose();
    moviesProvider.dispose();
    seriesProvider.dispose();
    peopleProvider.dispose();
    collectionsProvider.dispose();
    recommendationsProvider.dispose();
    watchlistProvider.dispose();
    notificationsProvider.dispose();
  }

  static Future<_HomeTestHarness> create() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final storage = LocalStorageService(prefs);
    final repository = _HomeScreenTestRepository();

    final watchRegion = WatchRegionProvider(prefs);
    final preferences = PreferencesProvider(prefs);

    final moviesProvider = MoviesProvider(
      repository,
      regionProvider: watchRegion,
      preferencesProvider: preferences,
      storageService: storage,
      autoInitialize: false,
    );
    await moviesProvider.refresh(force: true);

    final seriesProvider = SeriesProvider(
      repository,
      preferencesProvider: preferences,
      autoInitialize: false,
    );
    await seriesProvider.refresh(force: true);

    final peopleProvider = PeopleProvider(
      repository,
      autoInitialize: false,
    );
    await peopleProvider.refresh(force: true);

    final collectionsProvider = CollectionsProvider(repository);
    await collectionsProvider.ensureInitialized();

    final favoritesItem = SavedMediaItem(
      id: 101,
      type: SavedMediaType.movie,
      title: 'Favorite Hit',
      releaseDate: '2020-01-01',
    );
    await storage.saveFavoriteItems([favoritesItem]);

    final watchlistItem = SavedMediaItem(
      id: 901,
      type: SavedMediaType.movie,
      title: 'Watchlist Story',
      releaseDate: '2022-06-15',
    );
    await storage.saveWatchlistItems([watchlistItem]);

    await storage.saveNotifications([
      AppNotification(
        id: 'n1',
        title: 'Watch update',
        message: 'Episode 2 now available',
      ),
    ]);

    final recommendationsProvider = RecommendationsProvider(
      repository,
      storage,
    );
    await recommendationsProvider.fetchPersonalizedRecommendations();

    final watchlistProvider = WatchlistProvider(storage);
    final notificationsProvider = NotificationsProvider(
      storage: storage,
      preferences: preferences,
    );

    return _HomeTestHarness(
      prefs: prefs,
      storage: storage,
      repository: repository,
      watchRegion: watchRegion,
      preferences: preferences,
      moviesProvider: moviesProvider,
      seriesProvider: seriesProvider,
      peopleProvider: peopleProvider,
      collectionsProvider: collectionsProvider,
      recommendationsProvider: recommendationsProvider,
      watchlistProvider: watchlistProvider,
      notificationsProvider: notificationsProvider,
    );
  }
}

class _RecordingNavigatorObserver extends NavigatorObserver {
  final List<Route<dynamic>> pushedRoutes = <Route<dynamic>>[];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushedRoutes.add(route);
    super.didPush(route, previousRoute);
  }
}

const _localizationDelegates = <LocalizationsDelegate<dynamic>>[
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HomeScreen', () {
    testWidgets('renders key sections with hydrated providers', (tester) async {
      final harness = await _HomeTestHarness.create();
      addTearDown(harness.dispose);

      await pumpApp(
        tester,
        const HomeScreen(),
        providers: harness.providers,
        localizationsDelegates: _localizationDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      );

      await tester.pumpAndSettle();

      expect(find.text('Quick Access'), findsOneWidget);
      expect(find.textContaining('Of the moment'), findsNWidgets(2));
      expect(find.text('Popular people'), findsOneWidget);
      expect(find.text('Featured collections'), findsOneWidget);
      expect(find.text('New Releases'), findsOneWidget);
      expect(find.text('Continue Watching'), findsOneWidget);
      expect(find.text('Recommended for you'), findsOneWidget);

      expect(find.text('Trending Hit'), findsWidgets);
      expect(find.text('Watchlist Story'), findsOneWidget);
      expect(find.byType(RefreshIndicator), findsOneWidget);
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    });

    testWidgets('submitting a search query opens the search screen', (tester) async {
      final harness = await _HomeTestHarness.create();
      addTearDown(harness.dispose);
      final observer = _RecordingNavigatorObserver();

      await pumpApp(
        tester,
        const HomeScreen(),
        providers: harness.providers,
        localizationsDelegates: _localizationDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        navigatorObserver: observer,
      );

      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Matrix');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();

      expect(observer.pushedRoutes, isNotEmpty);
      final lastRoute = observer.pushedRoutes.last;
      expect(lastRoute.settings.name, SearchScreen.routeName);
      expect(lastRoute.settings.arguments, 'Matrix');
    });

    testWidgets('quick actions and notification badge navigate correctly', (tester) async {
      final harness = await _HomeTestHarness.create();
      addTearDown(harness.dispose);
      final observer = _RecordingNavigatorObserver();

      await pumpApp(
        tester,
        const HomeScreen(),
        providers: harness.providers,
        localizationsDelegates: _localizationDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        navigatorObserver: observer,
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Trending'));
      await tester.pumpAndSettle();

      expect(observer.pushedRoutes.any(
        (route) => route.settings.name == MoviesScreen.routeName,
      ), isTrue);

      await tester.tap(find.byIcon(Icons.notifications_outlined));
      await tester.pumpAndSettle();

      expect(observer.pushedRoutes.any(
        (route) => route.settings.name == NotificationsScreen.routeName,
      ), isTrue);
      expect(find.text('1'), findsWidgets);
    });
  });
}
