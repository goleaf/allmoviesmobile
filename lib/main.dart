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
import 'presentation/screens/home/home_screen.dart';

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
