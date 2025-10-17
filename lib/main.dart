import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_strings.dart';
import 'core/localization/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/memory_optimizer.dart';
import 'data/services/local_storage_service.dart';
import 'data/services/background_sync_service.dart';
import 'data/services/network_quality_service.dart';
import 'data/services/background_prefetch_service.dart';
import 'data/tmdb_repository.dart';
import 'providers/favorites_provider.dart';
import 'providers/genres_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/search_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/trending_titles_provider.dart';
import 'providers/watchlist_provider.dart';
import 'presentation/navigation/app_navigation_shell.dart';
import 'presentation/screens/explorer/api_explorer_screen.dart';
import 'presentation/screens/splash_preload/boot_gate.dart';
import 'presentation/screens/keywords/keyword_browser_screen.dart';
import 'presentation/screens/companies/companies_screen.dart';
import 'presentation/screens/favorites/favorites_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/movie_detail/movie_detail_screen.dart';
import 'presentation/screens/tv_detail/tv_detail_screen.dart';
import 'presentation/screens/person_detail/person_detail_screen.dart';
import 'presentation/screens/company_detail/company_detail_screen.dart';
import 'presentation/screens/network_detail/network_detail_screen.dart';
import 'presentation/screens/episode_detail/episode_detail_screen.dart';
import 'presentation/screens/collections/collection_detail_screen.dart';
import 'presentation/screens/keywords/keyword_detail_screen.dart';
import 'presentation/navigation/season_detail_args.dart';
import 'presentation/screens/season_detail/season_detail_screen.dart';
import 'presentation/screens/collections/browse_collections_screen.dart';
import 'presentation/screens/networks/networks_screen.dart';
import 'presentation/screens/lists/lists_screen.dart';
import 'presentation/screens/videos/videos_screen.dart';
import 'presentation/screens/video_player/video_player_screen.dart';
import 'presentation/screens/search/search_results_list_screen.dart';
import 'data/models/movie.dart';
import 'data/models/person_model.dart';
import 'data/models/company_model.dart';
import 'data/models/episode_model.dart';
import 'presentation/screens/movies/movies_screen.dart';
import 'presentation/screens/movies/movies_filters_screen.dart';
import 'presentation/screens/people/people_screen.dart';
import 'presentation/screens/search/search_screen.dart';
import 'presentation/screens/series/series_screen.dart';
import 'presentation/screens/series/series_filters_screen.dart';
import 'presentation/screens/settings/settings_screen.dart';
import 'presentation/screens/watchlist/watchlist_screen.dart';
import 'providers/companies_provider.dart';
import 'providers/movies_provider.dart';
import 'providers/people_provider.dart';
import 'providers/series_provider.dart';
import 'providers/watch_region_provider.dart';
import 'providers/networks_provider.dart';
import 'providers/collections_provider.dart';
import 'providers/lists_provider.dart';
import 'providers/preferences_provider.dart';
import 'providers/recommendations_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  MemoryOptimizer.instance.initialize();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final storageService = LocalStorageService(prefs);

  await BackgroundSyncService.initialize();
  await BackgroundSyncService.registerTrendingWarmup();

  final networkQualityNotifier = NetworkQualityNotifier();
  await networkQualityNotifier.initialize();

  runApp(
    AllMoviesApp(
      storageService: storageService,
      prefs: prefs,
      networkQualityNotifier: networkQualityNotifier,
    ),
  );
}

class AllMoviesApp extends StatelessWidget {
  final LocalStorageService storageService;
  final SharedPreferences prefs;
  final TmdbRepository? tmdbRepository;
  final NetworkQualityNotifier networkQualityNotifier;
  // Removed unused StaticCatalogService stub (no longer present)

  const AllMoviesApp({
    super.key,
    required this.storageService,
    required this.prefs,
    this.tmdbRepository,
    required this.networkQualityNotifier,
  });

  @override
  Widget build(BuildContext context) {
    final repo = tmdbRepository ?? TmdbRepository();

    return MultiProvider(
      providers: [
        Provider<TmdbRepository>.value(value: repo),
        Provider<BackgroundPrefetchService>(
          create: (_) {
            final service = BackgroundPrefetchService(
              repository: repo,
              networkQualityNotifier: networkQualityNotifier,
            );
            service.initialize();
            return service;
          },
          dispose: (_, service) => service.dispose(),
        ),
        Provider<LocalStorageService>.value(value: storageService),
        Provider<SharedPreferences>.value(value: prefs),
        ChangeNotifierProvider<NetworkQualityNotifier>.value(
          value: networkQualityNotifier,
        ),
        ChangeNotifierProvider(create: (_) => LocaleProvider(prefs)),
        ChangeNotifierProvider(create: (_) => ThemeProvider(prefs)),
        ChangeNotifierProvider(
          create: (_) => FavoritesProvider(storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => WatchlistProvider(storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => SearchProvider(repo, storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => RecommendationsProvider(repo, storageService),
        ),
        ChangeNotifierProvider(create: (_) => TrendingTitlesProvider(repo)),
        ChangeNotifierProvider(create: (_) => GenresProvider(repo)),
        ChangeNotifierProvider(create: (_) => WatchRegionProvider(prefs)),
        ChangeNotifierProxyProvider2<
          WatchRegionProvider,
          PreferencesProvider,
          MoviesProvider
        >(
          create: (_) => MoviesProvider(repo, storageService: storageService),
          update: (_, watchRegion, preferences, movies) {
            movies ??= MoviesProvider(repo, storageService: storageService);
            movies.bindRegionProvider(watchRegion);
            movies.bindPreferencesProvider(preferences);
            return movies;
          },
        ),
        ChangeNotifierProxyProvider<PreferencesProvider, SeriesProvider>(
          create: (_) => SeriesProvider(repo),
          update: (_, prefsProvider, series) {
            series ??= SeriesProvider(repo);
            // We can't bind later; re-create with prefs when needed
            return SeriesProvider(repo, preferencesProvider: prefsProvider);
          },
        ),
        ChangeNotifierProvider(create: (_) => PeopleProvider(repo)),
        ChangeNotifierProvider(create: (_) => CompaniesProvider(repo)),
        ChangeNotifierProvider(create: (_) => NetworksProvider(repo)),
        ChangeNotifierProvider(create: (_) => CollectionsProvider(repo)),
        ChangeNotifierProvider(create: (_) => ListsProvider(storageService)),
        ChangeNotifierProvider(create: (_) => PreferencesProvider(prefs)),
      ],
      child: Consumer2<LocaleProvider, ThemeProvider>(
        builder: (context, localeProvider, themeProvider, _) {
          return DynamicColorBuilder(
            builder: (lightDynamic, darkDynamic) {
              final lightTheme = AppTheme.light(dynamicScheme: lightDynamic);
              final darkTheme = AppTheme.dark(dynamicScheme: darkDynamic);

              return MaterialApp(
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
                  SettingsScreen.routeName: (context) => const SettingsScreen(),
                  ApiExplorerScreen.routeName: (context) =>
                      const ApiExplorerScreen(),
                  KeywordBrowserScreen.routeName: (context) =>
                      const KeywordBrowserScreen(),
                  NetworksScreen.routeName: (context) => const NetworksScreen(),
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
                      settings = RouteSettings(
                        name: TVDetailScreen.routeName,
                        arguments: settings.arguments,
                      );
                    // fall through
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
                          builder: (_) => KeywordDetailScreen(keywordId: args),
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
                    case '/person':
                      settings = RouteSettings(
                        name: PersonDetailScreen.routeName,
                        arguments: settings.arguments,
                      );
                    // fall through
                    case PersonDetailScreen.routeName:
                      final args = settings.arguments;
                      if (args is int) {
                        return MaterialPageRoute(
                          builder: (_) => PersonDetailScreen(personId: args),
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
                          builder: (_) => NetworkDetailScreen(networkId: args),
                          settings: settings,
                          fullscreenDialog: true,
                        );
                      }
                      return null;
                    case EpisodeDetailScreen.routeName:
                      final args = settings.arguments;
                      if (args is Episode) {
                        return MaterialPageRoute(
                          builder: (_) => EpisodeDetailScreen(episode: args),
                          settings: settings,
                          fullscreenDialog: true,
                        );
                      }
                      return null;
                    case CollectionDetailScreen.routeName:
                      final args = settings.arguments;
                      if (args is int) {
                        return MaterialPageRoute(
                          builder: (_) =>
                              CollectionDetailScreen(collectionId: args),
                          settings: settings,
                          fullscreenDialog: true,
                        );
                      }
                      return null;
                  }
                  return null;
                },
              );
            },
          );
        },
      ),
    );
  }
}
