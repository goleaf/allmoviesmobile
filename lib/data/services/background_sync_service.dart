import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';

import 'cache_service.dart';
import '../tmdb_repository.dart';

const String _trendingWarmupTask = 'tmdb_trending_warmup';

@pragma('vm:entry-point')
void backgroundSyncDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    final repository = TmdbRepository(cacheService: CacheService());

    try {
      await repository.fetchTrendingTitles();
      await repository.fetchTrendingMovies();
      await repository.fetchPopularMovies();
      return Future.value(true);
    } catch (error) {
      debugPrint('Background sync failed: $error');
      return Future.value(false);
    }
  });
}

class BackgroundSyncService {
  const BackgroundSyncService._();

  static Future<void> initialize() async {
    await Workmanager().initialize(backgroundSyncDispatcher, isInDebugMode: false);
  }

  static Future<void> registerTrendingWarmup() async {
    await Workmanager().cancelByUniqueName(_trendingWarmupTask);
    await Workmanager().registerPeriodicTask(
      _trendingWarmupTask,
      _trendingWarmupTask,
      frequency: const Duration(hours: 6),
      initialDelay: const Duration(minutes: 10),
      constraints: const Constraints(
        networkType: NetworkType.unmetered,
        requiresBatteryNotLow: true,
        requiresCharging: true,
      ),
    );
  }
}
