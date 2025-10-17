import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'data/services/local_storage_service.dart';
import 'data/tmdb_repository.dart';
import 'providers/auth_provider.dart';
import 'providers/trending_titles_provider.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/companies/companies_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/movies/movies_screen.dart';
import 'presentation/screens/people/people_screen.dart';
import 'presentation/screens/series/series_screen.dart';
import 'providers/companies_provider.dart';
import 'providers/movies_provider.dart';
import 'providers/people_provider.dart';
import 'providers/series_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final storageService = LocalStorageService(prefs);

  runApp(AllMoviesApp(storageService: storageService));
}

class AllMoviesApp extends StatelessWidget {
  final LocalStorageService storageService;

  const AllMoviesApp({
    super.key,
    required this.storageService,
  });

  @override
  Widget build(BuildContext context) {
    final tmdbRepository = TmdbRepository();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(storageService)),
        ChangeNotifierProvider(
          create: (_) => TrendingTitlesProvider(tmdbRepository),
        ),
        ChangeNotifierProvider(create: (_) => MoviesProvider()),
        ChangeNotifierProvider(create: (_) => SeriesProvider()),
        ChangeNotifierProvider(create: (_) => PeopleProvider()),
        ChangeNotifierProvider(create: (_) => CompaniesProvider()),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: HomeScreen.routeName,
        routes: {
          HomeScreen.routeName: (context) => Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  return authProvider.isLoggedIn
                      ? const HomeScreen()
                      : const LoginScreen();
                },
              ),
          MoviesScreen.routeName: (context) => const MoviesScreen(),
          SeriesScreen.routeName: (context) => const SeriesScreen(),
          PeopleScreen.routeName: (context) => const PeopleScreen(),
          CompaniesScreen.routeName: (context) => const CompaniesScreen(),
        },
      ),
    );
  }
}
