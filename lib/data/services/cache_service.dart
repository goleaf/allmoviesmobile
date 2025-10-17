import 'dart:async';
import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Simple in-memory cache with TTL support
class CacheService {
  CacheService({SharedPreferences? prefs}) : _prefs = prefs;

  final Logger _logger = Logger();
  final Map<String, _CacheEntry> _cache = {};
  
  // Default TTL values (in seconds)
  static const int defaultTTL = 300; // 5 minutes
  static const int movieDetailsTTL = 3600; // 1 hour
  static const int trendingTTL = 1800; // 30 minutes
  static const int searchTTL = 600; // 10 minutes
  static const String _persistentPrefix = '__cache_service__';

  SharedPreferences? _prefs;

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

  /// Clean expired entries from persistent storage
  Future<int> cleanPersistentExpired() async {
    final prefs = _prefs;
    if (prefs == null) {
      return 0;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final keys = prefs.getKeys().where((key) => key.startsWith(_persistentPrefix));
    var removed = 0;

    for (final key in keys) {
      final raw = prefs.getString(key);
      if (raw == null) continue;

      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        final expiresAt = decoded['expiresAt'] as int?;
        if (expiresAt != null && expiresAt <= now) {
          await prefs.remove(key);
          removed++;
        }
      } catch (error) {
        _logger.w('Failed to decode persistent cache entry for $key: $error');
        await prefs.remove(key);
        removed++;
      }
    }

    if (removed > 0) {
      _logger.d('Cleaned $removed expired persistent cache entries');
    }

    return removed;
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
      unawaited(cleanPersistentExpired());
    });
  }

  /// Attach shared preferences for persistent caching
  void attachPreferences(SharedPreferences prefs) {
    _prefs = prefs;
  }

  /// Store value in persistent cache (JSON serializable or primitive/string)
  Future<void> setPersistent<T>(
    String key,
    T value, {
    int? ttlSeconds,
  }) async {
    final prefs = _prefs;
    if (prefs == null) {
      _logger.w('Persistent cache requested but SharedPreferences not attached');
      return;
    }

    final ttl = ttlSeconds ?? defaultTTL;
    final expiresAt = DateTime.now().add(Duration(seconds: ttl)).millisecondsSinceEpoch;
    final isString = value is String;
    final serialized = isString ? value as String : jsonEncode(value);

    final payload = jsonEncode({
      'expiresAt': expiresAt,
      'isString': isString,
      'value': serialized,
    });

    await prefs.setString(_persistentKey(key), payload);
    _logger.d('Persistent cache set: $key (TTL: ${ttl}s)');
  }

  /// Retrieve value from persistent cache
  Future<T?> getPersistent<T>(String key) async {
    final prefs = _prefs;
    if (prefs == null) {
      _logger.w('Persistent cache requested but SharedPreferences not attached');
      return null;
    }

    final raw = prefs.getString(_persistentKey(key));
    if (raw == null) {
      _logger.d('Persistent cache miss: $key');
      return null;
    }

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final expiresAt = decoded['expiresAt'] as int?;
      final isString = decoded['isString'] == true;
      final serialized = decoded['value'] as String?;

      if (expiresAt != null && DateTime.now().millisecondsSinceEpoch > expiresAt) {
        await prefs.remove(_persistentKey(key));
        _logger.d('Persistent cache expired: $key');
        return null;
      }

      if (serialized == null) {
        return null;
      }

      final value = isString ? serialized : jsonDecode(serialized);
      _logger.d('Persistent cache hit: $key');
      return value as T?;
    } catch (error) {
      _logger.w('Failed to decode persistent cache entry for $key: $error');
      await prefs.remove(_persistentKey(key));
      return null;
    }
  }

  /// Remove a key from persistent cache
  Future<void> removePersistent(String key) async {
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.remove(_persistentKey(key));
  }

  /// Clear persistent cache namespace
  Future<void> clearPersistent() async {
    final prefs = _prefs;
    if (prefs == null) return;

    final keys = prefs.getKeys().where((key) => key.startsWith(_persistentPrefix)).toList();
    for (final key in keys) {
      await prefs.remove(key);
    }

    _logger.d('Persistent cache cleared (${keys.length} keys)');
  }

  String _persistentKey(String key) => '$_persistentPrefix$key';

  /// Dispose timers and clear caches
  Future<void> dispose() async {
    _cache.clear();
    await clearPersistent();
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
