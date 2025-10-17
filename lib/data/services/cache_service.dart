import 'dart:async';
import 'package:logger/logger.dart';

/// Simple in-memory cache with TTL support
class CacheService {
  final Logger _logger = Logger();
  final Map<String, _CacheEntry> _cache = {};
  
  // Default TTL values (in seconds)
  static const int defaultTTL = 300; // 5 minutes
  static const int movieDetailsTTL = 3600; // 1 hour
  static const int trendingTTL = 1800; // 30 minutes
  static const int searchTTL = 600; // 10 minutes

  /// Get a value from cache
  T? get<T>(String key) {
    final entry = _cache[key];
    
    if (entry == null) {
      _logger.d('Cache miss: $key');
      return null;
    }

    if (entry.isExpired) {
      _logger.d('Cache expired: $key');
      _cache.remove(key);
      return null;
    }

    _logger.d('Cache hit: $key');
    return entry.value as T?;
  }

  /// Set a value in cache with optional TTL
  void set<T>(String key, T value, {int? ttlSeconds}) {
    final ttl = ttlSeconds ?? defaultTTL;
    final expiresAt = DateTime.now().add(Duration(seconds: ttl));
    
    _cache[key] = _CacheEntry(
      value: value,
      expiresAt: expiresAt,
    );
    
    _logger.d('Cache set: $key (TTL: ${ttl}s)');
  }

  /// Remove a specific key from cache
  void remove(String key) {
    _cache.remove(key);
    _logger.d('Cache removed: $key');
  }

  /// Remove all keys matching a pattern
  void removePattern(String pattern) {
    final regex = RegExp(pattern);
    final keysToRemove = _cache.keys.where((key) => regex.hasMatch(key)).toList();
    
    for (final key in keysToRemove) {
      _cache.remove(key);
    }
    
    _logger.d('Cache removed pattern: $pattern (${keysToRemove.length} keys)');
  }

  /// Clear all cache
  void clear() {
    _cache.clear();
    _logger.d('Cache cleared');
  }

  /// Clean up expired entries
  void cleanExpired() {
    final expiredKeys = _cache.entries
        .where((entry) => entry.value.isExpired)
        .map((entry) => entry.key)
        .toList();

    for (final key in expiredKeys) {
      _cache.remove(key);
    }

    _logger.d('Cleaned ${expiredKeys.length} expired cache entries');
  }

  /// Get cache statistics
  CacheStats getStats() {
    final now = DateTime.now();
    var validCount = 0;
    var expiredCount = 0;

    for (final entry in _cache.values) {
      if (entry.expiresAt.isAfter(now)) {
        validCount++;
      } else {
        expiredCount++;
      }
    }

    return CacheStats(
      totalEntries: _cache.length,
      validEntries: validCount,
      expiredEntries: expiredCount,
    );
  }

  /// Schedule periodic cleanup
  Timer schedulePeriodicCleanup({Duration interval = const Duration(minutes: 5)}) {
    return Timer.periodic(interval, (_) {
      cleanExpired();
    });
  }
}

class _CacheEntry {
  final dynamic value;
  final DateTime expiresAt;

  _CacheEntry({
    required this.value,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

class CacheStats {
  final int totalEntries;
  final int validEntries;
  final int expiredEntries;

  CacheStats({
    required this.totalEntries,
    required this.validEntries,
    required this.expiredEntries,
  });

  @override
  String toString() {
    return 'CacheStats(total: $totalEntries, valid: $validEntries, expired: $expiredEntries)';
  }
}

