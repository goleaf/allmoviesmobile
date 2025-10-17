import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_strings.dart';
import 'core/localization/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'data/services/local_storage_service.dart';
import 'data/tmdb_repository.dart';
import 'providers/favorites_provider.dart';
import 'providers/genres_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/search_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/trending_titles_provider.dart';
import 'providers/watchlist_provider.dart';
import 'package:provider/provider.dart' show Provider; // add Provider for repo injection
import 'presentation/screens/explorer/api_explorer_screen.dart';
import 'presentation/screens/keywords/keyword_browser_screen.dart';
import 'presentation/screens/companies/companies_screen.dart';
import 'presentation/screens/favorites/favorites_screen.dart';
// HomeScreen removed - default to MoviesScreen as initial route
import 'presentation/screens/movie_detail/movie_detail_screen.dart';
import 'presentation/screens/tv_detail/tv_detail_screen.dart';
import 'presentation/screens/person_detail/person_detail_screen.dart';
import 'presentation/screens/company_detail/company_detail_screen.dart';
import 'presentation/screens/network_detail/network_detail_screen.dart';
import 'presentation/screens/episode_detail/episode_detail_screen.dart';
import 'presentation/screens/collections/collection_detail_screen.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final storageService = LocalStorageService(prefs);

  runApp(AllMoviesApp(
    storageService: storageService,
    prefs: prefs,
  ));
}

class AllMoviesApp extends StatelessWidget {
  final LocalStorageService storageService;
  final SharedPreferences prefs;
  final TmdbRepository? tmdbRepository;
  final Object? catalogService; // placeholder to avoid importing isar on web

  const AllMoviesApp({
    super.key,
    required this.storageService,
    required this.prefs,
    this.tmdbRepository,
    this.catalogService,
  });

  @override
  Widget build(BuildContext context) {
    final repo = tmdbRepository ?? TmdbRepository();

    return MultiProvider(
      providers: [
        Provider<TmdbRepository>.value(value: repo),
        ChangeNotifierProvider(create: (_) => LocaleProvider(prefs)),
        ChangeNotifierProvider(create: (_) => ThemeProvider(prefs)),
        ChangeNotifierProvider(create: (_) => FavoritesProvider(storageService)),
        ChangeNotifierProvider(create: (_) => WatchlistProvider(storageService)),
        ChangeNotifierProvider(create: (_) => SearchProvider(repo, storageService)),
        ChangeNotifierProvider(
          create: (_) => TrendingTitlesProvider(repo),
        ),
        ChangeNotifierProvider(create: (_) => GenresProvider(repo)),
        ChangeNotifierProvider(create: (_) => WatchRegionProvider(prefs)),
        ChangeNotifierProxyProvider<WatchRegionProvider, MoviesProvider>(
          create: (_) => MoviesProvider(repo),
          update: (_, watchRegion, movies) {
            movies ??= MoviesProvider(repo);
            movies.bindRegionProvider(watchRegion);
            return movies;
          },
        ),
        ChangeNotifierProvider(create: (_) => SeriesProvider(repo)),
        ChangeNotifierProvider(create: (_) => PeopleProvider(repo)),
        ChangeNotifierProvider(create: (_) => CompaniesProvider(repo)),
      ],
      child: Consumer2<LocaleProvider, ThemeProvider>(
        builder: (context, localeProvider, themeProvider, _) {
          return DynamicColorBuilder(
            builder: (lightDynamic, darkDynamic) {
              final lightTheme = AppTheme.light(dynamicScheme: lightDynamic);
              final darkTheme = AppTheme.dark(dynamicScheme: darkDynamic);

              return MaterialApp(
                title: AppStrings.appName,
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
                initialRoute: MoviesScreen.routeName,
                routes: {
                  MoviesScreen.routeName: (context) => const MoviesScreen(),
                  MoviesFiltersScreen.routeName: (context) => const MoviesFiltersScreen(),
                  SearchScreen.routeName: (context) => const SearchScreen(),
                  SeriesScreen.routeName: (context) => const SeriesScreen(),
                  SeriesFiltersScreen.routeName: (context) => const SeriesFiltersScreen(),
                  PeopleScreen.routeName: (context) => const PeopleScreen(),
                  CompaniesScreen.routeName: (context) => const CompaniesScreen(),
                  FavoritesScreen.routeName: (context) => const FavoritesScreen(),
                  WatchlistScreen.routeName: (context) => const WatchlistScreen(),
                  SettingsScreen.routeName: (context) => const SettingsScreen(),
                  ApiExplorerScreen.routeName: (context) => const ApiExplorerScreen(),
                  KeywordBrowserScreen.routeName: (context) => const KeywordBrowserScreen(),
                },
                onGenerateRoute: (settings) {
                  switch (settings.name) {
                    case '/tv':
                      settings = settings.copyWith(name: TVDetailScreen.routeName);
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
                        // Build minimal Movie with id and empty title; provider will load details
                        return MaterialPageRoute(
                          builder: (_) => MovieDetailScreen(
                            movie: Movie(id: args, title: ''),
                          ),
                          settings: settings,
                          fullscreenDialog: true,
                        );
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
                      settings = settings.copyWith(name: PersonDetailScreen.routeName);
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
                          builder: (_) => CompanyDetailScreen(initialCompany: args),
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
                          builder: (_) => CollectionDetailScreen(collectionId: args),
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
