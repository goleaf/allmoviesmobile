import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:math';

import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Defines how long entries remain valid and when they should be refreshed.
class CachePolicy {
  const CachePolicy({
    required this.ttl,
    this.refreshAfter,
  });

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
  CacheService({
    SharedPreferences? prefs,
    Duration cleanupInterval = const Duration(minutes: 5),
    int maxEntries = 256,
    int maxEntryBytes = 256 * 1024,
  })  : _prefs = prefs,
        _maxEntries = maxEntries,
        _maxEntryBytes = maxEntryBytes {
    // Schedule eager cleanup so that in-memory caches remain fresh even if the
    // UI does not actively query for values. This improves cache lifecycle
    // management by aggressively pruning stale data.
    _cleanupTimer = schedulePeriodicCleanup(interval: cleanupInterval);
  }

  final Logger _logger = Logger();
  final Map<String, _CacheEntry> _cache = {};
  final Map<String, Future<void>> _refreshing = {};
  final List<_PolicyOverride> _policyOverrides = <_PolicyOverride>[];
  final StreamController<CacheEvent> _events =
      StreamController<CacheEvent>.broadcast();
  final Map<String, int> _inflightPersistentWrites =
      <String, int>{};

  // Default TTL values (in seconds)
  static const int defaultMaxEntries = 256;
  static const int defaultTTL = 300; // 5 minutes
  static const int movieDetailsTTL = 3600; // 1 hour
  static const int trendingTTL = 1800; // 30 minutes
  static const int searchTTL = 600; // 10 minutes
  static const String _persistentPrefix = '__cache_service__';
  static const double _defaultRefreshFactor = 0.6;

  SharedPreferences? _prefs;
  int _maxEntries = 400;
  int _maxEntryBytes;
  int _totalBytes = 0;
  Timer? _cleanupTimer;

  Stream<CacheEvent> get events => _events.stream;

  void configureLimits({int? maxEntries}) {
    if (maxEntries != null && maxEntries > 0) {
      _maxEntries = maxEntries;
      _evictOverflow();
    }
  }

  void registerPolicyOverride({
    required Pattern pattern,
    required CachePolicy policy,
  }) {
    _policyOverrides.removeWhere((override) => override.pattern == pattern);
    _policyOverrides
        .add(_PolicyOverride(pattern: pattern, policy: policy));
  }

  void clearPolicyOverrides() {
    _policyOverrides.clear();
  }

  /// Update cache capacity controls at runtime.
  void configure({int? maxEntries, int? maxEntryBytes}) {
    if (maxEntries != null && maxEntries > 0) {
      _maxEntries = maxEntries;
    }
    if (maxEntryBytes != null && maxEntryBytes > 0) {
      _maxEntryBytes = maxEntryBytes;
    }
    _evictIfNeeded();
  }

  /// Get a value from cache without metadata.
  T? get<T>(String key) {
    final result = lookup<T>(key, removeStale: true);
    if (result.status == CacheStatus.hit) {
      return result.value;
    }
    return null;
  }

  /// Set a value in cache with optional TTL
  void set<T>(
    String key,
    T value, {
    int? ttlSeconds,
    CachePolicy? policy,
  }) {
    final resolvedPolicy = _resolvePolicy(
      key,
      policy ??
          (ttlSeconds != null
              ? CachePolicy.fromSeconds(ttlSeconds)
              : const CachePolicy(ttl: Duration(seconds: defaultTTL))),
    );

    final estimatedSize = _estimateSize(value);

    if (estimatedSize > _maxEntryBytes) {
      _logger.w(
        'Cache entry for $key skipped: $estimatedSize bytes exceeds limit '
        '($_maxEntryBytes).',
      );
      return;
    }

    final previous = _cache[key];
    if (previous != null) {
      _totalBytes -= previous.estimatedSize;
      if (_totalBytes < 0) {
        _totalBytes = 0;
      }
    }

    final entry = _CacheEntry(
      value: value,
      createdAt: DateTime.now(),
      policy: resolvedPolicy,
      estimatedSize: estimatedSize,
    );
    _cache[key] = entry;
    _totalBytes += estimatedSize;
    _emit(CacheEvent.set(key: key, valueType: value.runtimeType));
    _logger.d('Cache set: $key (TTL: ${resolvedPolicy.ttl.inSeconds}s)');
    _evictIfNeeded();
  }

  /// Remove a specific key from cache
  void remove(String key) {
    final removed = _cache.remove(key);
    if (removed != null) {
      _totalBytes -= removed.estimatedSize;
      if (_totalBytes < 0) {
        _totalBytes = 0;
      }
      _emit(CacheEvent.evict(key: key));
      _logger.d('Cache removed: $key');
    }
  }

  /// Remove all keys matching a pattern
  void removePattern(String pattern) {
    final regex = RegExp(pattern);
    final keysToRemove = _cache.keys
        .where((key) => regex.hasMatch(key))
        .toList();

    for (final key in keysToRemove) {
      remove(key);
    }

    if (keysToRemove.isNotEmpty) {
      _logger.d(
        'Cache removed pattern: $pattern (${keysToRemove.length} keys)',
      );
    }
  }

  /// Clear all cache
  void clear() {
    _cache.clear();
    _totalBytes = 0;
    _logger.d('Cache cleared');
  }

  /// Clean up expired entries
  void cleanExpired() {
    final expiredKeys = _cache.entries
        .where((entry) => entry.value.isExpired || entry.value.isHardStale)
        .map((entry) => entry.key)
        .toList();

    for (final key in expiredKeys) {
      remove(key);
    }

    if (expiredKeys.isNotEmpty) {
      _logger.d('Cleaned ${expiredKeys.length} expired cache entries');
    }
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
          _emit(CacheEvent.evict(key: key));
        }
      } catch (error) {
        _logger.w('Failed to decode persistent cache entry for $key: $error');
        await prefs.remove(key);
        removed++;
        _emit(CacheEvent.evict(key: key));
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

    if (_inflightPersistentWrites.containsKey(key)) {
      _logger.d(
        'Persistent cache write for $key skipped because a write is already in progress.',
      );
      return;
    }

    final resolvedPolicy = _resolvePolicy(
      key,
      policy ??
          (ttlSeconds != null
              ? CachePolicy.fromSeconds(ttlSeconds)
              : const CachePolicy(ttl: Duration(seconds: defaultTTL))),
    );
    final now = DateTime.now();
    final expiresAt = now.add(resolvedPolicy.ttl).millisecondsSinceEpoch;
    final refreshAfter = resolvedPolicy.refreshAfter == null
        ? null
        : now.add(resolvedPolicy.refreshAfter!).millisecondsSinceEpoch;
    final isString = value is String;
    final serialized = isString ? value as String : jsonEncode(value);

    final payload = jsonEncode({
      'expiresAt': expiresAt,
      'isString': isString,
      'value': serialized,
      'refreshAfter': refreshAfter,
    });

    // Track inflight persistent writes to avoid overwhelming disk with the
    // same large payload repeatedly (basic throttling for image compression
    // metadata).
    final writeTicket = DateTime.now().millisecondsSinceEpoch;
    _inflightPersistentWrites[key] = writeTicket;
    try {
      await prefs.setString(_persistentKey(key), payload);
      _emit(CacheEvent.set(key: key, valueType: value.runtimeType));
      _logger.d(
        'Persistent cache set: $key (TTL: ${resolvedPolicy.ttl.inSeconds}s)',
      );
    } finally {
      final currentTicket = _inflightPersistentWrites[key];
      if (currentTicket == writeTicket) {
        _inflightPersistentWrites.remove(key);
      }
    }
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
        _emit(CacheEvent.expired(key: key));
        _logger.d('Persistent cache expired: $key');
        return null;
      }

      final refreshAfter = decoded['refreshAfter'] as int?;
      if (refreshAfter != null && now > refreshAfter) {
        await prefs.remove(_persistentKey(key));
        _emit(CacheEvent.stale(key: key));
        _logger.d('Persistent cache stale: $key');
        return null;
      }

      if (serialized == null) {
        return null;
      }

      final value = isString ? serialized : jsonDecode(serialized);
      _emit(CacheEvent.hit(key: key));
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
    final removed = await prefs.remove(_persistentKey(key));
    if (removed) {
      _emit(CacheEvent.evict(key: key));
    }
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
      _emit(CacheEvent.evict(key: key));
    }

    if (keys.isNotEmpty) {
      _logger.d('Persistent cache cleared (${keys.length} keys)');
    }

    _inflightPersistentWrites.clear();
  }

  String _persistentKey(String key) => '$_persistentPrefix$key';

  /// Dispose timers and clear caches
  Future<void> dispose() async {
    _cleanupTimer?.cancel();
    _cache.clear();
    _totalBytes = 0;
    _inflightPersistentWrites.clear();
    await clearPersistent();
    await _events.close();
  }

  CachePolicy _resolvePolicy(String key, CachePolicy base) {
    for (final override in _policyOverrides) {
      if (override.matches(key)) {
        return override.policy;
      }
    }

    if (base.refreshAfter == null) {
      return CachePolicy(
        ttl: base.ttl,
        refreshAfter: Duration(
          seconds: max(
            1,
            (base.ttl.inSeconds * _defaultRefreshFactor).round(),
          ),
        ),
      );
    }

    return base;
  }

  void _evictOverflow() => _evictIfNeeded();

  CacheLookupResult<T> lookup<T>(String key, {bool removeStale = false}) {
    final entry = _cache[key];

    if (entry == null) {
      _emit(CacheEvent.miss(key: key));
      _logger.d('Cache miss: $key');
      return CacheLookupResult.miss();
    }

    if (entry.isExpired) {
      _emit(CacheEvent.expired(key: key));
      _logger.d('Cache expired: $key');
      _cache.remove(key);
      return CacheLookupResult.expired();
    }

    if (entry.isStale) {
      _emit(CacheEvent.stale(key: key));
      _logger.d('Cache stale: $key');
      if (removeStale) {
        _cache.remove(key);
      }
      return CacheLookupResult.stale(entry.value as T?);
    }

    entry.touch();
    _emit(CacheEvent.hit(key: key));
    _logger.d('Cache hit: $key');
    return CacheLookupResult.hit(entry.value as T?);
  }

  Future<T> getOrLoad<T>(
    String key,
    Future<T> Function() loader, {
    CachePolicy? policy,
    bool allowStale = true,
  }) async {
    final resolvedPolicy =
        _resolvePolicy(key, policy ?? const CachePolicy(ttl: Duration(seconds: defaultTTL)));

    final lookupResult = lookup<T>(key);
    switch (lookupResult.status) {
      case CacheStatus.hit:
        return lookupResult.value as T;
      case CacheStatus.stale:
        if (allowStale && lookupResult.value != null) {
          _scheduleRefresh(key, loader, resolvedPolicy);
          return lookupResult.value as T;
        }
        break;
      case CacheStatus.miss:
      case CacheStatus.expired:
        break;
    }

    final value = await loader();
    set<T>(key, value, policy: resolvedPolicy);
    return value;
  }

  Future<void> refresh<T>(
    String key,
    Future<T> Function() loader, {
    CachePolicy? policy,
  }) {
    return _scheduleRefresh(
      key,
      loader,
      _resolvePolicy(
        key,
        policy ?? const CachePolicy(ttl: Duration(seconds: defaultTTL)),
      ),
    );
  }

  Future<void> _scheduleRefresh<T>(
    String key,
    Future<T> Function() loader,
    CachePolicy policy,
  ) async {
    if (_refreshing.containsKey(key)) {
      return _refreshing[key]!;
    }

    final completer = Completer<void>();
    _refreshing[key] = completer.future;
    _emit(CacheEvent.refreshScheduled(key: key));

    try {
      final value = await loader();
      set<T>(key, value, policy: policy);
      _emit(CacheEvent.refreshCompleted(key: key));
    } catch (error, stackTrace) {
      _logger.w('Failed to refresh cache for $key: $error', error, stackTrace);
      _emit(CacheEvent.refreshFailed(key: key, error: error));
    } finally {
      _refreshing.remove(key);
      completer.complete();
    }

    return completer.future;
  }

  void _emit(CacheEvent event) {
    if (!_events.hasListener) {
      return;
    }

    _events.add(event);
  }

  void _evictIfNeeded() {
    if (_cache.length <= _maxEntries && _totalBytes <= _maxEntryBytes) {
      return;
    }

    final entries = _cache.entries.toList()
      ..sort((a, b) => a.value.lastAccessed.compareTo(b.value.lastAccessed));
    var index = 0;

    while ((_cache.length > _maxEntries || _totalBytes > _maxEntryBytes) &&
        index < entries.length) {
      final key = entries[index].key;
      final removed = _cache.remove(key);
      if (removed != null) {
        _totalBytes -= removed.estimatedSize;
        if (_totalBytes < 0) {
          _totalBytes = 0;
        }
        _emit(CacheEvent.evict(key: key));
      }
      index++;
    }

    if (index > 0) {
      _logger.d('Evicted $index cache entries due to memory pressure');
    }
  }

  int _estimateSize(Object? value) {
    try {
      if (value is String) {
        return utf8.encode(value).length;
      }
      if (value is List<int>) {
        return value.length;
      }
      final encoded = jsonEncode(value);
      return utf8.encode(encoded).length;
    } catch (_) {
      return 512; // Fallback heuristic when serialization fails
    }
  }
}

class _CacheEntry {
  final dynamic value;
  final DateTime createdAt;
  final CachePolicy policy;
  final int estimatedSize;
  DateTime lastAccessed;

  _CacheEntry({
    required this.value,
    required this.createdAt,
    required this.policy,
    required this.estimatedSize,
  }) : lastAccessed = createdAt;

  DateTime get expiresAt => createdAt.add(policy.ttl);

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  bool get isStale {
    final refreshAfter = policy.refreshAfter;
    if (refreshAfter == null) {
      return false;
    }
    return DateTime.now().isAfter(createdAt.add(refreshAfter));
  }

  bool get isHardStale => isExpired || isStale;

  void touch() {
    lastAccessed = DateTime.now();
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

enum CacheStatus { hit, miss, stale, expired }

class CacheLookupResult<T> {
  CacheLookupResult._(this.status, this.value);

  final CacheStatus status;
  final T? value;

  factory CacheLookupResult.hit(T? value) => CacheLookupResult._(CacheStatus.hit, value);

  factory CacheLookupResult.miss() => CacheLookupResult._(CacheStatus.miss, null);

  factory CacheLookupResult.stale(T? value) => CacheLookupResult._(CacheStatus.stale, value);

  factory CacheLookupResult.expired() => CacheLookupResult._(CacheStatus.expired, null);
}

class CacheEvent {
  CacheEvent({
    required this.type,
    required this.key,
    this.valueType,
    this.error,
  }) : timestamp = DateTime.now();

  final CacheEventType type;
  final String key;
  final DateTime timestamp;
  final Type? valueType;
  final Object? error;

  factory CacheEvent.hit({required String key}) =>
      CacheEvent(type: CacheEventType.hit, key: key);

  factory CacheEvent.miss({required String key}) =>
      CacheEvent(type: CacheEventType.miss, key: key);

  factory CacheEvent.stale({required String key}) =>
      CacheEvent(type: CacheEventType.stale, key: key);

  factory CacheEvent.expired({required String key}) =>
      CacheEvent(type: CacheEventType.expired, key: key);

  factory CacheEvent.set({required String key, Type? valueType}) => CacheEvent(
        type: CacheEventType.set,
        key: key,
        valueType: valueType,
      );

  factory CacheEvent.evict({required String key}) =>
      CacheEvent(type: CacheEventType.evict, key: key);

  factory CacheEvent.refreshScheduled({required String key}) => CacheEvent(
        type: CacheEventType.refreshScheduled,
        key: key,
      );

  factory CacheEvent.refreshCompleted({required String key}) => CacheEvent(
        type: CacheEventType.refreshCompleted,
        key: key,
      );

  factory CacheEvent.refreshFailed({
    required String key,
    required Object error,
  }) =>
      CacheEvent(type: CacheEventType.refreshFailed, key: key, error: error);
}

enum CacheEventType {
  hit,
  miss,
  stale,
  expired,
  set,
  evict,
  refreshScheduled,
  refreshCompleted,
  refreshFailed,
}

class _PolicyOverride {
  const _PolicyOverride({required this.pattern, required this.policy});

  final Pattern pattern;
  final CachePolicy policy;

  bool matches(String key) {
    return pattern.matchAsPrefix(key) != null;
  }
}
