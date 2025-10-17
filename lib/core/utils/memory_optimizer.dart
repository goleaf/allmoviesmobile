import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';

/// Configures global caches to keep memory usage predictable and responds to
/// OS pressure callbacks by eagerly clearing cached images.
class MemoryOptimizer with WidgetsBindingObserver {
  MemoryOptimizer._();

  static final MemoryOptimizer instance = MemoryOptimizer._();

  bool _initialized = false;

  void initialize() {
    if (_initialized) return;
    _initialized = true;
    WidgetsBinding.instance.addObserver(this);
    _configureImageCache();
  }

  void _configureImageCache() {
    final imageCache = PaintingBinding.instance.imageCache;
    imageCache.maximumSize = 200;
    imageCache.maximumSizeBytes = 120 << 20; // ~120 MB
  }

  @override
  void didHaveMemoryPressure() {
    final cache = PaintingBinding.instance.imageCache;
    cache.clear();
    cache.clearLiveImages();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      final cache = PaintingBinding.instance.imageCache;
      cache.clear();
      cache.clearLiveImages();
    }
  }

  void dispose() {
    if (!_initialized) return;
    WidgetsBinding.instance.removeObserver(this);
    _initialized = false;
  }
}
