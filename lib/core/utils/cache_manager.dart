import 'dart:async';

/// Enhanced cache manager with TTL and automatic cleanup
class CacheManager {
  CacheManager({
    this.defaultTtl = const Duration(hours: 1),
    this.maxCacheSize = 100,
    this.cleanupInterval = const Duration(minutes: 5),
  }) {
    _startCleanupTimer();
  }

  final Duration defaultTtl;
  final int maxCacheSize;
  final Duration cleanupInterval;

  final Map<String, _CacheEntry> _cache = {};
  Timer? _cleanupTimer;

  /// Get cached value
  T? get<T>(String key) {
    final entry = _cache[key];
    
    if (entry == null) return null;
    
    // Check if expired
    if (entry.isExpired) {
      _cache.remove(key);
      return null;
    }

    entry.updateAccessTime();
    return entry.value as T?;
  }

  /// Set cached value with optional TTL
  void set<T>(String key, T value, {Duration? ttl}) {
    // Enforce cache size limit
    if (_cache.length >= maxCacheSize) {
      _evictLeastRecentlyUsed();
    }

    _cache[key] = _CacheEntry(
      value: value,
      ttl: ttl ?? defaultTtl,
    );
  }

  /// Check if key exists and is not expired
  bool has(String key) {
    final entry = _cache[key];
    if (entry == null) return false;
    
    if (entry.isExpired) {
      _cache.remove(key);
      return false;
    }
    
    return true;
  }

  /// Remove specific cache entry
  void remove(String key) {
    _cache.remove(key);
  }

  /// Remove all cache entries matching pattern
  void removePattern(String pattern) {
    final regex = RegExp(pattern);
    _cache.removeWhere((key, _) => regex.hasMatch(key));
  }

  /// Clear all cache
  void clear() {
    _cache.clear();
  }

  /// Clear expired entries
  void clearExpired() {
    _cache.removeWhere((_, entry) => entry.isExpired);
  }

  /// Get cache statistics
  Map<String, dynamic> getStatistics() {
    var expiredCount = 0;
    var validCount = 0;

    for (final entry in _cache.values) {
      if (entry.isExpired) {
        expiredCount++;
      } else {
        validCount++;
      }
    }

    return {
      'total': _cache.length,
      'valid': validCount,
      'expired': expiredCount,
      'maxSize': maxCacheSize,
      'utilizationPercent': (_cache.length / maxCacheSize * 100).toStringAsFixed(1),
    };
  }

  /// Get all cache keys
  List<String> getKeys() {
    return _cache.keys.toList();
  }

  /// Get cache age for a key
  Duration? getCacheAge(String key) {
    final entry = _cache[key];
    if (entry == null) return null;
    return DateTime.now().difference(entry.createdAt);
  }

  /// Get time until expiration
  Duration? getTimeToExpiration(String key) {
    final entry = _cache[key];
    if (entry == null) return null;
    
    final expiresAt = entry.createdAt.add(entry.ttl);
    final remaining = expiresAt.difference(DateTime.now());
    
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Evict least recently used entry
  void _evictLeastRecentlyUsed() {
    if (_cache.isEmpty) return;

    String? oldestKey;
    DateTime? oldestAccess;

    for (final entry in _cache.entries) {
      if (oldestAccess == null || entry.value.lastAccessTime.isBefore(oldestAccess)) {
        oldestKey = entry.key;
        oldestAccess = entry.value.lastAccessTime;
      }
    }

    if (oldestKey != null) {
      _cache.remove(oldestKey);
    }
  }

  /// Start automatic cleanup timer
  void _startCleanupTimer() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(cleanupInterval, (_) {
      clearExpired();
    });
  }

  /// Dispose resources
  void dispose() {
    _cleanupTimer?.cancel();
    _cache.clear();
  }

  /// Get or set pattern - fetch if not cached
  Future<T> getOrFetch<T>({
    required String key,
    required Future<T> Function() fetch,
    Duration? ttl,
  }) async {
    final cached = get<T>(key);
    if (cached != null) return cached;

    final value = await fetch();
    set(key, value, ttl: ttl);
    return value;
  }

  /// Async get with fallback
  Future<T?> getAsync<T>(String key) async {
    return get<T>(key);
  }

  /// Batch set multiple values
  void setMultiple<T>(Map<String, T> entries, {Duration? ttl}) {
    for (final entry in entries.entries) {
      set(entry.key, entry.value, ttl: ttl);
    }
  }

  /// Batch get multiple values
  Map<String, T?> getMultiple<T>(List<String> keys) {
    final result = <String, T?>{};
    for (final key in keys) {
      result[key] = get<T>(key);
    }
    return result;
  }
}

/// Cache entry with metadata
class _CacheEntry {
  _CacheEntry({
    required this.value,
    required this.ttl,
  })  : createdAt = DateTime.now(),
        lastAccessTime = DateTime.now();

  final dynamic value;
  final Duration ttl;
  final DateTime createdAt;
  DateTime lastAccessTime;

  bool get isExpired {
    final expiresAt = createdAt.add(ttl);
    return DateTime.now().isAfter(expiresAt);
  }

  void updateAccessTime() {
    lastAccessTime = DateTime.now();
  }

  Duration get age => DateTime.now().difference(createdAt);
  
  Duration get timeToExpiration {
    final expiresAt = createdAt.add(ttl);
    final remaining = expiresAt.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }
}

/// Global cache manager instance
final globalCacheManager = CacheManager();

