import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_strings.dart';
import 'core/localization/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'data/services/local_storage_service.dart';
import 'data/tmdb_repository.dart';
import 'data/tmdb_v4_repository.dart';
import 'providers/favorites_provider.dart';
import 'providers/genres_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/search_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/trending_titles_provider.dart';
import 'providers/watchlist_provider.dart';
import 'providers/api_explorer_provider.dart';
import 'presentation/screens/companies/companies_screen.dart';
import 'presentation/screens/explorer/api_explorer_screen.dart';
import 'presentation/screens/explorer/tmdb_v4_reference_screen.dart';
import 'presentation/screens/favorites/favorites_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/movie_detail/movie_detail_screen.dart';
import 'presentation/screens/movies/movies_screen.dart';
import 'presentation/screens/people/people_screen.dart';
import 'presentation/screens/person_detail/person_detail_screen.dart';
import 'presentation/screens/search/search_screen.dart';
import 'presentation/screens/series/series_screen.dart';
import 'presentation/screens/series/series_category_screen.dart';
import 'presentation/screens/settings/settings_screen.dart';
import 'presentation/screens/videos/videos_screen.dart';
import 'presentation/screens/tv_detail/tv_detail_screen.dart';
import 'presentation/screens/watchlist/watchlist_screen.dart';
import 'providers/companies_provider.dart';
import 'providers/movies_provider.dart';
import 'providers/people_provider.dart';
import 'providers/recommendations_provider.dart';

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

  const AllMoviesApp({
    super.key,
    required this.storageService,
    required this.prefs,
  });

  @override
  Widget build(BuildContext context) {
    final tmdbRepository = TmdbRepository();
    final tmdbV4Repository = TmdbV4Repository();

    return MultiProvider(
      providers: [
        Provider<TmdbRepository>.value(value: tmdbRepository),
        Provider<TmdbV4Repository>.value(value: tmdbV4Repository),
        ChangeNotifierProvider(create: (_) => LocaleProvider(prefs)),
        ChangeNotifierProvider(create: (_) => ThemeProvider(prefs)),
        ChangeNotifierProvider(create: (_) => FavoritesProvider(storageService)),
        ChangeNotifierProvider(create: (_) => WatchlistProvider(storageService)),
        ChangeNotifierProvider(create: (_) => SearchProvider(tmdbRepository, storageService)),
        ChangeNotifierProvider(
          create: (_) => TrendingTitlesProvider(tmdbRepository),
        ),
        ChangeNotifierProvider(create: (_) => GenresProvider(tmdbRepository)),
        ChangeNotifierProvider(create: (_) => RecommendationsProvider(tmdbRepository, storageService)),
        ChangeNotifierProvider(create: (_) => MoviesProvider(tmdbRepository)),
        ChangeNotifierProvider(create: (_) => PeopleProvider(tmdbRepository)),
        ChangeNotifierProvider(create: (_) => CompaniesProvider(tmdbRepository)),
        ChangeNotifierProvider(
          create: (_) => ApiExplorerProvider(tmdbRepository),
        ),
      ],
      child: Consumer2<LocaleProvider, ThemeProvider>(
        builder: (context, localeProvider, themeProvider, _) {
          return MaterialApp(
            title: AppStrings.appName,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
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
            initialRoute: HomeScreen.routeName,
            routes: {
              HomeScreen.routeName: (context) => const HomeScreen(),
              SearchScreen.routeName: (context) => const SearchScreen(),
              MoviesScreen.routeName: (context) => const MoviesScreen(),
              VideosScreen.routeName: (context) => const VideosScreen(),
              SeriesScreen.routeName: (context) => const SeriesScreen(),
              SeriesCategoryScreen.routeName: (context) {
                final args = ModalRoute.of(context)?.settings.arguments;
                if (args is! SeriesCategoryArguments) {
                  return const Scaffold(
                    body: Center(
                      child: Text('Missing series category configuration.'),
                    ),
                  );
                }
                return SeriesCategoryScreen(arguments: args);
              },
              PeopleScreen.routeName: (context) => const PeopleScreen(),
              CompaniesScreen.routeName: (context) => const CompaniesScreen(),
              ApiExplorerScreen.routeName: (context) => const ApiExplorerScreen(),
              TmdbV4ReferenceScreen.routeName: (context) =>
                  const TmdbV4ReferenceScreen(),
              FavoritesScreen.routeName: (context) => const FavoritesScreen(),
              WatchlistScreen.routeName: (context) => const WatchlistScreen(),
              SettingsScreen.routeName: (context) => const SettingsScreen(),
            },
          );
        },
      ),
    );
  }
}
