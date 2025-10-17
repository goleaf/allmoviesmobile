import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/services/cache_service.dart';
import '../../data/services/local_storage_service.dart';
import '../../data/tmdb_repository.dart';

final GetIt getIt = GetIt.instance;

/// Initialize all services and repositories
Future<void> setupServiceLocator() async {
  // Logger
  getIt.registerLazySingleton<Logger>(() => Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  ));

  // HTTP Client
  getIt.registerLazySingleton<http.Client>(() => http.Client());

  // Cache Service
  getIt.registerLazySingleton<CacheService>(() => CacheService());

  // Shared Preferences (async initialization)
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // Local Storage Service
  getIt.registerLazySingleton<LocalStorageService>(
    () => LocalStorageService(getIt<SharedPreferences>()),
  );

  // TMDB Repository
  getIt.registerLazySingleton<TmdbRepository>(
    () => TmdbRepository(
      client: getIt<http.Client>(),
    ),
  );

  // Schedule periodic cache cleanup
  getIt<CacheService>().schedulePeriodicCleanup();
}

/// Clean up all services
Future<void> cleanupServiceLocator() async {
  await getIt.reset();
}

