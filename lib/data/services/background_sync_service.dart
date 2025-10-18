import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';

import 'cache_service.dart';
import '../tmdb_repository.dart';

const String _trendingWarmupTask = 'tmdb_trending_warmup';

bool get _isBackgroundSyncSupported {
  if (kIsWeb) return false;
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
    case TargetPlatform.iOS:
      return true;
    case TargetPlatform.macOS:
    case TargetPlatform.windows:
    case TargetPlatform.linux:
    case TargetPlatform.fuchsia:
      return false;
  }
  return false;
}

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
    if (!_isBackgroundSyncSupported) {
      return;
    }
    if (_initialized) {
      return;
    }
    await Workmanager()
        .initialize(backgroundSyncDispatcher, isInDebugMode: false);
    _initialized = true;
  }

  static Future<void> registerTrendingWarmup() async {
    if (!_isBackgroundSyncSupported) {
      return;
    }
    await initialize();
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

  static bool _initialized = false;
}
