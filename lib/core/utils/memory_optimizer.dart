import 'dart:async';

import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';

import '../../data/services/cache_service.dart';

/// Configures global caches to keep memory usage predictable and responds to
/// OS pressure callbacks by eagerly clearing cached images.
class MemoryOptimizer with WidgetsBindingObserver {
  MemoryOptimizer._();

  static final MemoryOptimizer instance = MemoryOptimizer._();
  static const int _cacheSoftLimit = 800;

  bool _initialized = false;
  final List<_TrackedCache> _trackedCaches = [];
  Timer? _maintenanceTimer;

  void initialize() {
    if (_initialized) return;
    _initialized = true;
    WidgetsBinding.instance.addObserver(this);
    _configureImageCache();
    _scheduleMaintenance();
  }

  void _configureImageCache() {
    final imageCache = PaintingBinding.instance.imageCache;
    imageCache.maximumSize = 200;
    imageCache.maximumSizeBytes = 120 << 20; // ~120 MB
  }

  void registerCacheService(CacheService? cache) {
    if (cache == null) return;
    final tracked = _TrackedCache(
      WeakReference<CacheService>(cache),
      cache.events.listen((event) {
        if (event.type == CacheEventType.set) {
          // Shrink caches proactively if they grow aggressively.
          final stats = cache.getStats();
          if (stats.totalEntries > 0 &&
              stats.totalEntries >= 0.9 * _cacheSoftLimit &&
              stats.expiredEntries > 0) {
            cache.cleanExpired();
          }
        }
      }),
    );
    _trackedCaches.add(tracked);
  }

  void unregisterCacheService(CacheService? cache) {
    if (cache == null) return;
    _trackedCaches.removeWhere((tracked) {
      final target = tracked.reference.target;
      final shouldRemove = target == null || target == cache;
      if (shouldRemove) {
        tracked.subscription.cancel();
      }
      return shouldRemove;
    });
  }

  @override
  void didHaveMemoryPressure() {
    final cache = PaintingBinding.instance.imageCache;
    cache.clear();
    cache.clearLiveImages();
    for (final tracked in _trackedCaches.toList()) {
      final target = tracked.reference.target;
      if (target == null) {
        tracked.subscription.cancel();
        _trackedCaches.remove(tracked);
        continue;
      }
      target.cleanExpired();
    }
  }

  void dispose() {
    if (!_initialized) return;
    WidgetsBinding.instance.removeObserver(this);
    _maintenanceTimer?.cancel();
    for (final tracked in _trackedCaches) {
      tracked.subscription.cancel();
    }
    _trackedCaches.clear();
    _initialized = false;
  }

  void _scheduleMaintenance() {
    _maintenanceTimer?.cancel();
    _maintenanceTimer = Timer.periodic(
      const Duration(minutes: 10),
      (_) {
        for (final tracked in _trackedCaches.toList()) {
          final cache = tracked.reference.target;
          if (cache == null) {
            tracked.subscription.cancel();
            _trackedCaches.remove(tracked);
            continue;
          }
          cache.cleanExpired();
        }
      },
    );
  }
}

class _TrackedCache {
  _TrackedCache(this.reference, this.subscription);

  final WeakReference<CacheService> reference;
  final StreamSubscription<CacheEvent> subscription;
}
