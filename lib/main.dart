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
import 'presentation/screens/companies/companies_screen.dart';
import 'presentation/screens/favorites/favorites_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/movie_detail/movie_detail_screen.dart';
import 'presentation/screens/movies/movies_screen.dart';
import 'presentation/screens/people/people_screen.dart';
import 'presentation/screens/search/search_screen.dart';
import 'presentation/screens/series/series_screen.dart';
import 'presentation/screens/settings/settings_screen.dart';
import 'presentation/screens/watchlist/watchlist_screen.dart';
import 'providers/companies_provider.dart';
import 'providers/movies_provider.dart';
import 'providers/people_provider.dart';
import 'providers/series_provider.dart';

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

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider(prefs)),
        ChangeNotifierProvider(create: (_) => ThemeProvider(prefs)),
        ChangeNotifierProvider(create: (_) => FavoritesProvider(storageService)),
        ChangeNotifierProvider(create: (_) => WatchlistProvider(storageService)),
        ChangeNotifierProvider(create: (_) => SearchProvider(tmdbRepository, storageService)),
        ChangeNotifierProvider(
          create: (_) => TrendingTitlesProvider(tmdbRepository),
        ),
        ChangeNotifierProvider(create: (_) => GenresProvider(tmdbRepository)),
        ChangeNotifierProvider(create: (_) => MoviesProvider(tmdbRepository)),
        ChangeNotifierProvider(create: (_) => SeriesProvider(tmdbRepository)),
        ChangeNotifierProvider(create: (_) => PeopleProvider(tmdbRepository)),
        ChangeNotifierProvider(create: (_) => CompaniesProvider(tmdbRepository)),
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
                initialRoute: HomeScreen.routeName,
                routes: {
                  HomeScreen.routeName: (context) => const HomeScreen(),
                  SearchScreen.routeName: (context) => const SearchScreen(),
                  MoviesScreen.routeName: (context) => const MoviesScreen(),
                  SeriesScreen.routeName: (context) => const SeriesScreen(),
                  PeopleScreen.routeName: (context) => const PeopleScreen(),
                  CompaniesScreen.routeName: (context) => const CompaniesScreen(),
                  FavoritesScreen.routeName: (context) => const FavoritesScreen(),
                  WatchlistScreen.routeName: (context) => const WatchlistScreen(),
                  SettingsScreen.routeName: (context) => const SettingsScreen(),
                },
              );
            },
          );
        },
      ),
    );
  }
}
