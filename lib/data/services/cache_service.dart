import 'dart:async';
import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Defines how long entries remain valid and when they should be refreshed.
class CachePolicy {
  const CachePolicy({
    required this.ttl,
    this.refreshAfter,
  }) : assert(!ttl.isNegative, 'TTL must be positive');

  factory CachePolicy.fromSeconds(int seconds) => CachePolicy(
        ttl: Duration(seconds: seconds),
      );

  factory CachePolicy.fromJson(Map<String, dynamic> json) => CachePolicy(
        ttl: Duration(seconds: json['ttl'] as int? ?? CacheService.defaultTTL),
        refreshAfter: json['refreshAfter'] == null
            ? null
            : Duration(seconds: json['refreshAfter'] as int),
      );

  final Duration ttl;
  final Duration? refreshAfter;

  Map<String, dynamic> toJson() => {
        'ttl': ttl.inSeconds,
        if (refreshAfter != null) 'refreshAfter': refreshAfter!.inSeconds,
      };
}

/// Simple in-memory cache with TTL support and stale-entry detection.
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

    if (entry.isExpired || entry.isStale) {
      _logger.d('Cache ${entry.isExpired ? 'expired' : 'stale'}: $key');
      _cache.remove(key);
      return null;
    }

    _logger.d('Cache hit: $key');
    return entry.value as T?;
  }

  /// Set a value in cache with optional TTL
  void set<T>(
    String key,
    T value, {
    int? ttlSeconds,
    CachePolicy? policy,
  }) {
    final effectivePolicy = policy ??
        (ttlSeconds != null
            ? CachePolicy.fromSeconds(ttlSeconds)
            : const CachePolicy(ttl: Duration(seconds: defaultTTL)));

    _cache[key] = _CacheEntry(
      value: value,
      createdAt: DateTime.now(),
      policy: effectivePolicy,
    );

    _logger.d('Cache set: $key (TTL: ${effectivePolicy.ttl.inSeconds}s)');
  }

  /// Remove a specific key from cache
  void remove(String key) {
    _cache.remove(key);
    _logger.d('Cache removed: $key');
  }

  /// Remove all keys matching a pattern
  void removePattern(String pattern) {
    final regex = RegExp(pattern);
    final keysToRemove = _cache.keys
        .where((key) => regex.hasMatch(key))
        .toList();

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
        .where((entry) => entry.value.isExpired || entry.value.isStale)
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

    final keys = prefs.getKeys().where(
      (key) => key.startsWith(_persistentPrefix),
    );
    var removed = 0;

    for (final key in keys) {
      final raw = prefs.getString(key);
      if (raw == null) continue;

      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        final expiresAt = decoded['expiresAt'] as int?;
        final refreshAfter = decoded['refreshAfter'] as int?;
        final now = DateTime.now().millisecondsSinceEpoch;
        final expired = expiresAt != null && expiresAt <= now;
        final stale = refreshAfter != null && refreshAfter <= now;
        if (expired || stale) {
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
    var staleCount = 0;

    for (final entry in _cache.values) {
      if (entry.isExpired) {
        expiredCount++;
      } else if (entry.isStale) {
        staleCount++;
      } else {
        validCount++;
      }
    }

    return CacheStats(
      totalEntries: _cache.length,
      validEntries: validCount,
      expiredEntries: expiredCount,
      staleEntries: staleCount,
    );
  }

  /// Schedule periodic cleanup
  Timer schedulePeriodicCleanup({
    Duration interval = const Duration(minutes: 5),
  }) {
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
    CachePolicy? policy,
  }) async {
    final prefs = _prefs;
    if (prefs == null) {
      _logger.w(
        'Persistent cache requested but SharedPreferences not attached',
      );
      return;
    }

    final effectivePolicy = policy ??
        (ttlSeconds != null
            ? CachePolicy.fromSeconds(ttlSeconds)
            : const CachePolicy(ttl: Duration(seconds: defaultTTL)));
    final now = DateTime.now();
    final expiresAt = now.add(effectivePolicy.ttl).millisecondsSinceEpoch;
    final refreshAfter = effectivePolicy.refreshAfter == null
        ? null
        : now.add(effectivePolicy.refreshAfter!).millisecondsSinceEpoch;
    final isString = value is String;
    final serialized = isString ? value as String : jsonEncode(value);

    final payload = jsonEncode({
      'expiresAt': expiresAt,
      'isString': isString,
      'value': serialized,
      'refreshAfter': refreshAfter,
    });

    await prefs.setString(_persistentKey(key), payload);
    _logger.d(
      'Persistent cache set: $key (TTL: ${effectivePolicy.ttl.inSeconds}s)',
    );
  }

  /// Retrieve value from persistent cache
  Future<T?> getPersistent<T>(String key) async {
    final prefs = _prefs;
    if (prefs == null) {
      _logger.w(
        'Persistent cache requested but SharedPreferences not attached',
      );
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

      final now = DateTime.now().millisecondsSinceEpoch;
      if (expiresAt != null && now > expiresAt) {
        await prefs.remove(_persistentKey(key));
        _logger.d('Persistent cache expired: $key');
        return null;
      }

      final refreshAfter = decoded['refreshAfter'] as int?;
      if (refreshAfter != null && now > refreshAfter) {
        await prefs.remove(_persistentKey(key));
        _logger.d('Persistent cache stale: $key');
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

    final keys = prefs
        .getKeys()
        .where((key) => key.startsWith(_persistentPrefix))
        .toList();
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
  final DateTime createdAt;
  final CachePolicy policy;

  _CacheEntry({
    required this.value,
    required this.createdAt,
    required this.policy,
  });

  DateTime get expiresAt => createdAt.add(policy.ttl);

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  bool get isStale {
    final refreshAfter = policy.refreshAfter;
    if (refreshAfter == null) {
      return false;
    }
    return DateTime.now().isAfter(createdAt.add(refreshAfter));
  }
}

class CacheStats {
  final int totalEntries;
  final int validEntries;
  final int expiredEntries;
  final int staleEntries;

  CacheStats({
    required this.totalEntries,
    required this.validEntries,
    required this.expiredEntries,
    required this.staleEntries,
  });

  @override
  String toString() {
    return 'CacheStats(total: $totalEntries, valid: $validEntries, expired: $expiredEntries, stale: $staleEntries)';
  }
}
