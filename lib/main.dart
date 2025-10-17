import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/config/app_config.dart';
import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/movie_repository.dart';
import 'data/services/local_storage_service.dart';
import 'data/services/tmdb_api_service.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/home/home_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/movies_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final storageService = LocalStorageService(prefs);
  
  final movieRepository = MovieRepository(
    apiService: TmdbApiService(apiKey: AppConfig.tmdbApiKey),
  );

  runApp(
    AllMoviesApp(
      storageService: storageService,
      movieRepository: movieRepository,
    ),
  );
}

class AllMoviesApp extends StatelessWidget {
  final LocalStorageService storageService;
  final MovieRepository movieRepository;

  const AllMoviesApp({
    super.key,
    required this.storageService,
    required this.movieRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(storageService)),
        ChangeNotifierProvider(
          create: (_) => MoviesProvider(repository: movieRepository)..loadMovies(),
        ),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            return authProvider.isLoggedIn
                ? const HomeScreen()
                : const LoginScreen();
          },
        ),
      ),
    );
  }
}
