import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/localization/app_localizations.dart';
import 'core/navigation/deep_link_handler.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/foreground_refresh_observer.dart';
import 'core/utils/memory_optimizer.dart';
import 'data/models/company_model.dart';
import 'data/models/movie.dart';
import 'data/models/person_model.dart';
import 'data/services/background_prefetch_service.dart';
import 'data/services/local_storage_service.dart';
import 'data/services/network_quality_service.dart';
import 'data/services/offline_service.dart';
import 'data/tmdb_repository.dart';
import 'presentation/navigation/app_navigation_shell.dart';
import 'presentation/navigation/episode_detail_args.dart';
import 'presentation/navigation/season_detail_args.dart';
import 'presentation/screens/collections/browse_collections_screen.dart';
import 'presentation/screens/collections/collection_detail_screen.dart';
import 'presentation/screens/companies/companies_screen.dart';
import 'presentation/screens/company_detail/company_detail_screen.dart';
import 'presentation/screens/episode_detail/episode_detail_screen.dart';
import 'presentation/screens/explorer/api_explorer_screen.dart';
import 'presentation/screens/favorites/favorites_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/keywords/keyword_browser_screen.dart';
import 'presentation/screens/keywords/keyword_detail_screen.dart';
import 'presentation/screens/lists/lists_screen.dart';
import 'presentation/screens/movie_detail/movie_detail_screen.dart';
import 'presentation/screens/movies/movies_filters_screen.dart';
import 'presentation/screens/movies/movies_screen.dart';
import 'presentation/screens/network_detail/network_detail_screen.dart';
import 'presentation/screens/networks/networks_screen.dart';
import 'presentation/screens/people/people_screen.dart';
import 'presentation/screens/person_detail/person_detail_screen.dart';
import 'presentation/screens/search/search_results_list_screen.dart';
import 'presentation/screens/search/search_screen.dart';
import 'presentation/screens/season_detail/season_detail_screen.dart';
import 'presentation/screens/series/series_filters_screen.dart';
import 'presentation/screens/series/series_screen.dart';
import 'presentation/screens/settings/settings_screen.dart';
import 'presentation/screens/tv_detail/tv_detail_screen.dart';
import 'presentation/screens/video_player/video_player_screen.dart';
import 'presentation/screens/videos/videos_screen.dart';
import 'presentation/screens/watchlist/watchlist_screen.dart';
import 'providers/accessibility_provider.dart';
import 'providers/app_state_provider.dart';
import 'providers/collections_provider.dart';
import 'providers/companies_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/genres_provider.dart';
import 'providers/lists_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/movies_provider.dart';
import 'providers/networks_provider.dart';
import 'providers/offline_provider.dart';
import 'providers/people_provider.dart';
import 'providers/preferences_provider.dart';
import 'providers/recommendations_provider.dart';
import 'providers/search_provider.dart';
import 'providers/series_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/trending_titles_provider.dart';
import 'providers/watch_region_provider.dart';
import 'providers/watchlist_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  MemoryOptimizer.instance.initialize();

  final prefs = await SharedPreferences.getInstance();
  final storageService = LocalStorageService(prefs);
  final offlineService = OfflineService(prefs: prefs);
  final networkQualityNotifier = NetworkQualityNotifier();
  await networkQualityNotifier.initialize();

  runApp(
    AllMoviesApp(
      storageService: storageService,
      prefs: prefs,
      offlineService: offlineService,
      networkQualityNotifier: networkQualityNotifier,
    ),
  );
}

class AllMoviesApp extends StatefulWidget {
  const AllMoviesApp({
    super.key,
    required this.storageService,
    required this.prefs,
    required this.offlineService,
    this.tmdbRepository,
    required this.networkQualityNotifier,
  });

  final LocalStorageService storageService;
  final SharedPreferences prefs;
  final OfflineService offlineService;
  final TmdbRepository? tmdbRepository;
  final NetworkQualityNotifier networkQualityNotifier;

  @override
  State<AllMoviesApp> createState() => _AllMoviesAppState();
}

class _AllMoviesAppState extends State<AllMoviesApp> {
  late final TmdbRepository _repository;
  late final DeepLinkHandler _deepLinkHandler;
  late final ForegroundRefreshObserver _foregroundObserver;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  bool _registeredRefreshCallbacks = false;

  @override
  void initState() {
    super.initState();
    _repository = widget.tmdbRepository ??
        TmdbRepository(networkQualityNotifier: widget.networkQualityNotifier);
    _foregroundObserver = ForegroundRefreshObserver()..attach();
    _deepLinkHandler = DeepLinkHandler(
      navigatorKey: _navigatorKey,
      repository: _repository,
    )..initialize();
  }

  @override
  void dispose() {
    _deepLinkHandler.dispose();
    _foregroundObserver.detach();
    widget.networkQualityNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<LocalStorageService>.value(value: widget.storageService),
        Provider<SharedPreferences>.value(value: widget.prefs),
        Provider<OfflineService>.value(value: widget.offlineService),
        Provider<TmdbRepository>.value(value: _repository),
        Provider<DeepLinkHandler>.value(value: _deepLinkHandler),
        Provider<ForegroundRefreshObserver>.value(value: _foregroundObserver),
        ChangeNotifierProvider<NetworkQualityNotifier>.value(
          value: widget.networkQualityNotifier,
        ),
        ChangeNotifierProvider(
          create: (_) => OfflineProvider(widget.offlineService),
        ),
        ChangeNotifierProvider(
          create: (_) => FavoritesProvider(
            widget.storageService,
            offlineService: widget.offlineService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => WatchlistProvider(
            widget.storageService,
            offlineService: widget.offlineService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => SearchProvider(_repository, widget.storageService),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              RecommendationsProvider(_repository, widget.storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => TrendingTitlesProvider(_repository),
        ),
        ChangeNotifierProvider(
          create: (_) => GenresProvider(_repository),
        ),
        ChangeNotifierProvider(
          create: (_) => PeopleProvider(_repository),
        ),
        ChangeNotifierProvider(
          create: (_) => CompaniesProvider(_repository),
        ),
        ChangeNotifierProvider(
          create: (_) => NetworksProvider(_repository),
        ),
        ChangeNotifierProvider(
          create: (_) => CollectionsProvider(_repository),
        ),
        ChangeNotifierProvider(
          create: (_) => ListsProvider(widget.storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => WatchRegionProvider(widget.prefs),
        ),
        ChangeNotifierProvider(
          create: (_) => LocaleProvider(widget.prefs),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(widget.prefs),
        ),
        ChangeNotifierProvider(
          create: (_) => PreferencesProvider(widget.prefs),
        ),
        ChangeNotifierProvider(
          create: (_) => AccessibilityProvider(widget.prefs),
        ),
        ChangeNotifierProvider(
          create: (_) => AppStateProvider(widget.prefs),
        ),
        ChangeNotifierProxyProvider2<
            WatchRegionProvider, PreferencesProvider, MoviesProvider>(
          create: (_) => MoviesProvider(
            _repository,
            storageService: widget.storageService,
            offlineService: widget.offlineService,
          ),
          update: (_, watchRegion, preferences, movies) {
            movies ??= MoviesProvider(
              _repository,
              storageService: widget.storageService,
              offlineService: widget.offlineService,
            );
            movies
              ..bindRegionProvider(watchRegion)
              ..bindPreferencesProvider(preferences);
            return movies;
          },
        ),
        ChangeNotifierProxyProvider2<PreferencesProvider, OfflineService,
            SeriesProvider>(
          create: (_) => SeriesProvider(
            _repository,
            preferencesProvider: null,
            offlineService: widget.offlineService,
          ),
          update: (_, prefsProvider, offlineService, series) {
            series ??= SeriesProvider(
              _repository,
              preferencesProvider: prefsProvider,
              offlineService: offlineService,
            );
            series.bindPreferencesProvider(prefsProvider);
            return series;
          },
        ),
        Provider<BackgroundPrefetchService>(
          create: (_) {
            final service = BackgroundPrefetchService(
              repository: _repository,
              networkQualityNotifier: widget.networkQualityNotifier,
            );
            service.initialize();
            return service;
          },
          dispose: (_, service) => service.dispose(),
        ),
      ],
      child: Builder(
        builder: (context) {
          if (!_registeredRefreshCallbacks) {
            _registeredRefreshCallbacks = true;
            final observer = context.read<ForegroundRefreshObserver>();
            observer
              ..registerCallback(() async {
                await context.read<MoviesProvider>().refresh(force: true);
              })
              ..registerCallback(() async {
                await context.read<TrendingTitlesProvider>().refreshAll();
              })
              ..registerCallback(() async {
                await context
                    .read<SearchProvider>()
                    .reexecuteLastSearch(forceRefresh: true);
              });
          }

          return Consumer2<LocaleProvider, ThemeProvider>(
            builder: (context, localeProvider, themeProvider, _) {
              return DynamicColorBuilder(
                builder: (lightDynamic, darkDynamic) {
                  final lightTheme = AppTheme.light(dynamicScheme: lightDynamic);
                  final darkTheme = AppTheme.dark(dynamicScheme: darkDynamic);

                  return MaterialApp(
                    navigatorKey: _navigatorKey,
                    title: AppLocalizations.of(context).t('app.name'),
                    theme: lightTheme,
                    darkTheme: darkTheme,
                    themeMode: themeProvider.materialThemeMode,
                    locale: localeProvider.locale,
                    localizationsDelegates: const [
                      AppLocalizations.delegate,
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                      GlobalCupertinoLocalizations.delegate,
                    ],
                    supportedLocales: AppLocalizations.supportedLocales,
                    debugShowCheckedModeBanner: false,
                    home: const AppNavigationShell(),
                    routes: {
                      HomeScreen.routeName: (context) => const HomeScreen(),
                      MoviesScreen.routeName: (context) => const MoviesScreen(),
                      MoviesFiltersScreen.routeName: (context) =>
                          const MoviesFiltersScreen(),
                      SearchScreen.routeName: (context) => const SearchScreen(),
                      SeriesScreen.routeName: (context) => const SeriesScreen(),
                      SeriesFiltersScreen.routeName: (context) =>
                          const SeriesFiltersScreen(),
                      PeopleScreen.routeName: (context) => const PeopleScreen(),
                      CompaniesScreen.routeName: (context) =>
                          const CompaniesScreen(),
                      FavoritesScreen.routeName: (context) =>
                          const FavoritesScreen(),
                      WatchlistScreen.routeName: (context) =>
                          const WatchlistScreen(),
                      SettingsScreen.routeName: (context) =>
                          const SettingsScreen(),
                      ApiExplorerScreen.routeName: (context) =>
                          const ApiExplorerScreen(),
                      KeywordBrowserScreen.routeName: (context) =>
                          const KeywordBrowserScreen(),
                      NetworksScreen.routeName: (context) =>
                          const NetworksScreen(),
                      CollectionsBrowserScreen.routeName: (context) =>
                          const CollectionsBrowserScreen(),
                      SearchResultsListScreen.routeName: (context) =>
                          const SearchResultsListScreen(),
                      VideosScreen.routeName: (context) => const VideosScreen(),
                      VideoPlayerScreen.routeName: (context) {
                        final args =
                            ModalRoute.of(context)?.settings.arguments;
                        return VideoPlayerScreen(
                          args: args is VideoPlayerScreenArgs ? args : null,
                        );
                      },
                      ListsScreen.routeName: (context) => const ListsScreen(),
                    },
                    onGenerateRoute: (settings) {
                      switch (settings.name) {
                        case SeasonDetailScreen.routeName:
                          final args = settings.arguments;
                          if (args is SeasonDetailArgs) {
                            return MaterialPageRoute(
                              builder: (_) => SeasonDetailScreen(args: args),
                              settings: settings,
                              fullscreenDialog: true,
                            );
                          }
                          return null;
                        case '/tv':
                        case TVDetailScreen.routeName:
                          final args = settings.arguments;
                          if (args is Movie) {
                            return MaterialPageRoute(
                              builder: (_) => TVDetailScreen(tvShow: args),
                              settings: settings,
                              fullscreenDialog: true,
                            );
                          }
                          if (args is int) {
                            return MaterialPageRoute(
                              builder: (_) => TVDetailScreen(
                                tvShow: Movie(id: args, title: ''),
                              ),
                              settings: settings,
                              fullscreenDialog: true,
                            );
                          }
                          return null;
                        case MovieDetailScreen.routeName:
                          final args = settings.arguments;
                          if (args is Movie) {
                            return MaterialPageRoute(
                              builder: (_) => MovieDetailScreen(movie: args),
                              settings: settings,
                              fullscreenDialog: true,
                            );
                          }
                          if (args is int) {
                            return MaterialPageRoute(
                              builder: (_) => MovieDetailScreen(
                                movie: Movie(id: args, title: ''),
                              ),
                              settings: settings,
                              fullscreenDialog: true,
                            );
                          }
                          return null;
                        case KeywordDetailScreen.routeName:
                          final args = settings.arguments;
                          if (args is int) {
                            return MaterialPageRoute(
                              builder: (_) =>
                                  KeywordDetailScreen(keywordId: args),
                              settings: settings,
                              fullscreenDialog: true,
                            );
                          }
                          if (args is Map) {
                            final id = args['id'];
                            final name = args['name'];
                            if (id is int) {
                              return MaterialPageRoute(
                                builder: (_) => KeywordDetailScreen(
                                  keywordId: id,
                                  keywordName: name is String ? name : null,
                                ),
                                settings: settings,
                                fullscreenDialog: true,
                              );
                            }
                          }
                          return null;
                        case '/person':
                        case PersonDetailScreen.routeName:
                          final args = settings.arguments;
                          if (args is int) {
                            return MaterialPageRoute(
                              builder: (_) =>
                                  PersonDetailScreen(personId: args),
                              settings: settings,
                              fullscreenDialog: true,
                            );
                          }
                          if (args is Person) {
                            return MaterialPageRoute(
                              builder: (_) => PersonDetailScreen(
                                personId: args.id,
                                initialPerson: args,
                              ),
                              settings: settings,
                              fullscreenDialog: true,
                            );
                          }
                          return null;
                        case CompanyDetailScreen.routeName:
                          final args = settings.arguments;
                          if (args is Company) {
                            return MaterialPageRoute(
                              builder: (_) =>
                                  CompanyDetailScreen(initialCompany: args),
                              settings: settings,
                              fullscreenDialog: true,
                            );
                          }
                          return null;
                        case NetworkDetailScreen.routeName:
                          final args = settings.arguments;
                          if (args is int) {
                            return MaterialPageRoute(
                              builder: (_) =>
                                  NetworkDetailScreen(networkId: args),
                              settings: settings,
                              fullscreenDialog: true,
                            );
                          }
                          return null;
                        case EpisodeDetailScreen.routeName:
                          final args = settings.arguments;
                          if (args is EpisodeDetailArgs) {
                            return MaterialPageRoute(
                              builder: (_) => EpisodeDetailScreen(
                                episode: args.episode,
                                tvId: args.tvId,
                              ),
                              settings: settings,
                              fullscreenDialog: true,
                            );
                          }
                          return null;
                        case CollectionDetailScreen.routeName:
                          final args = settings.arguments;
                          if (args is int) {
                            return MaterialPageRoute(
                              builder: (_) => CollectionDetailScreen(
                                collectionId: args,
                              ),
                              settings: settings,
                              fullscreenDialog: true,
                            );
                          }
                          if (args is Map) {
                            final id = args['id'];
                            if (id is int) {
                              return MaterialPageRoute(
                                builder: (_) => CollectionDetailScreen(
                                  collectionId: id,
                                  initialName: args['name'] as String?,
                                  initialPosterPath:
                                      args['posterPath'] as String?,
                                  initialBackdropPath:
                                      args['backdropPath'] as String?,
                                ),
                                settings: settings,
                                fullscreenDialog: true,
                              );
                            }
                          }
                          return null;
                        default:
                          return null;
                      }
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _DirectionalFocusWrapper extends StatelessWidget {
  const _DirectionalFocusWrapper({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.arrowDown):
            const DirectionalFocusIntent(TraversalDirection.down),
        LogicalKeySet(LogicalKeyboardKey.arrowUp):
            const DirectionalFocusIntent(TraversalDirection.up),
        LogicalKeySet(LogicalKeyboardKey.arrowLeft):
            const DirectionalFocusIntent(TraversalDirection.left),
        LogicalKeySet(LogicalKeyboardKey.arrowRight):
            const DirectionalFocusIntent(TraversalDirection.right),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          DirectionalFocusIntent: CallbackAction<DirectionalFocusIntent>(
            onInvoke: (intent) {
              FocusScope.of(context).focusInDirection(intent.direction);
              return null;
            },
          ),
        },
        child: FocusTraversalGroup(
          policy: const WidgetOrderTraversalPolicy(),
          child: child,
        ),
      ),
    );
  }
}
