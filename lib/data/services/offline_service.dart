import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/logging/app_logger.dart';
import '../models/movie.dart';
import '../models/saved_media_item.dart';
import '../models/tv_ref_model.dart';

/// Describes the type of pending sync action stored while the device is offline.
enum OfflineSyncAction {
  watchlistAdd,
  watchlistRemove,
  favoritesAdd,
  favoritesRemove,
}

/// Payload describing a queued sync task that will be replayed once network
/// connectivity is restored.
class OfflineSyncTask {
  OfflineSyncTask({
    required this.id,
    required this.action,
    required this.mediaId,
    required this.mediaType,
    DateTime? createdAt,
    this.payload,
  }) : createdAt = createdAt ?? DateTime.now();

  factory OfflineSyncTask.fromJson(Map<String, dynamic> json) {
    return OfflineSyncTask(
      id: json['id'] as String? ?? '${json['mediaId']}_${json['action']}',
      action: _decodeAction(json['action'] as String?),
      mediaId: json['mediaId'] is int
          ? json['mediaId'] as int
          : int.tryParse('${json['mediaId']}') ?? 0,
      mediaType: SavedMediaTypeX.fromStorage(json['mediaType'] as String?),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
      payload: json['payload'] as Map<String, dynamic>?,
    );
  }

  final String id;
  final OfflineSyncAction action;
  final int mediaId;
  final SavedMediaType mediaType;
  final DateTime createdAt;
  final Map<String, dynamic>? payload;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'action': _encodeAction(action),
        'mediaId': mediaId,
        'mediaType': mediaType.storageKey,
        'createdAt': createdAt.toIso8601String(),
        if (payload != null) 'payload': payload,
      };

  static OfflineSyncAction _decodeAction(String? raw) {
    switch (raw) {
      case 'favorites_add':
        return OfflineSyncAction.favoritesAdd;
      case 'favorites_remove':
        return OfflineSyncAction.favoritesRemove;
      case 'watchlist_remove':
        return OfflineSyncAction.watchlistRemove;
      case 'watchlist_add':
      default:
        return OfflineSyncAction.watchlistAdd;
    }
  }

  static String _encodeAction(OfflineSyncAction action) {
    switch (action) {
      case OfflineSyncAction.favoritesAdd:
        return 'favorites_add';
      case OfflineSyncAction.favoritesRemove:
        return 'favorites_remove';
      case OfflineSyncAction.watchlistRemove:
        return 'watchlist_remove';
      case OfflineSyncAction.watchlistAdd:
        return 'watchlist_add';
    }
  }
}

/// Describes high-level storage information for offline artifacts so that the
/// Settings screen can give the user insight into local usage.
class OfflineStorageStats {
  const OfflineStorageStats({
    required this.cachedCollections,
    required this.downloadedCount,
    required this.pendingSyncCount,
    required this.approximateBytes,
    this.lastSyncedAt,
  });

  final int cachedCollections;
  final int downloadedCount;
  final int pendingSyncCount;
  final int approximateBytes;
  final DateTime? lastSyncedAt;
}

/// Simple change notification payload for the offline service. The provider
/// listens to [events] and refreshes its cached state accordingly.
class OfflineEvent {
  const OfflineEvent(this.type);

  final OfflineEventType type;
}

/// Enumerates offline events emitted by [OfflineService].
enum OfflineEventType {
  connectivity,
  downloads,
  caches,
  syncQueue,
  cleared,
}

/// Handles local persistence for offline-ready experiences including caching
/// essential TMDB responses, tracking offline downloads, and staging actions to
/// replay when connectivity is restored.
class OfflineService {
  OfflineService({
    required SharedPreferences prefs,
    AppLogger? logger,
  })  : _prefs = prefs,
        _logger = logger ?? AppLogger.instance;

  static const String _downloadedItemsKey = 'offline.downloaded_items';
  static const String _syncQueueKey = 'offline.sync.queue';
  static const String _lastSyncedKey = 'offline.last_synced';
  static const String _movieSectionIndexKey = 'offline.section.movies';
  static const String _tvSectionIndexKey = 'offline.section.tv';
  static const String _movieSectionPrefix = 'offline.section.movies.';
  static const String _tvSectionPrefix = 'offline.section.tv.';

  final SharedPreferences _prefs;
  final AppLogger _logger;

  bool _isOffline = false;
  List<SavedMediaItem>? _downloadedCache;
  List<OfflineSyncTask>? _syncQueueCache;

  final StreamController<OfflineEvent> _eventController =
      StreamController<OfflineEvent>.broadcast();

  /// Stream of service-level events that consumers can observe to refresh
  /// derived state without tight coupling.
  Stream<OfflineEvent> get events => _eventController.stream;

  /// Whether the application is currently in offline mode. The value is
  /// set by [OfflineProvider] after probing connectivity status with
  /// `connectivity_plus`.
  bool get isOffline => _isOffline;

  /// Update the cached offline state and notify listeners when it changes.
  void setOffline(bool offline) {
    if (_isOffline == offline) {
      return;
    }
    _isOffline = offline;
    _emit(OfflineEventType.connectivity);
  }

  /// Record a list of movies for the given section so they are available when
  /// offline. The data originates from TMDB `GET /3/movie/*` endpoints.
  Future<void> cacheMoviesSection(String sectionKey, List<Movie> movies) async {
    final payload = <String, dynamic>{
      'cachedAt': DateTime.now().toIso8601String(),
      'items': movies.map(_movieToJson).toList(growable: false),
    };

    final key = '$_movieSectionPrefix$sectionKey';
    await _prefs.setString(key, jsonEncode(payload));

    final sections = _prefs.getStringList(_movieSectionIndexKey) ?? <String>[];
    if (!sections.contains(sectionKey)) {
      sections.add(sectionKey);
      await _prefs.setStringList(_movieSectionIndexKey, sections);
    }

    _emit(OfflineEventType.caches);
  }

  /// Load cached movies for a previously persisted section. When no cache is
  /// available the method returns `null`.
  Future<OfflineSection<Movie>?> loadMoviesSection(String sectionKey) async {
    final key = '$_movieSectionPrefix$sectionKey';
    final raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final cachedAt = DateTime.tryParse(decoded['cachedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final itemsRaw = decoded['items'] as List<dynamic>? ?? const [];
      final movies = itemsRaw
          .whereType<Map<String, dynamic>>()
          .map(_movieFromJson)
          .toList(growable: false);
      return OfflineSection<Movie>(cachedAt: cachedAt, items: movies);
    } catch (error, stackTrace) {
      _logger.error('Failed to decode cached movie section $sectionKey', error,
          stackTrace);
      return null;
    }
  }

  /// Cache a lightweight list of shows from TMDB `GET /3/tv/*` endpoints so
  /// that the TV tab can render while offline.
  Future<void> cacheTvSection(String sectionKey, List<TVRef> shows) async {
    final payload = <String, dynamic>{
      'cachedAt': DateTime.now().toIso8601String(),
      'items': shows.map((show) => show.toJson()).toList(growable: false),
    };

    final key = '$_tvSectionPrefix$sectionKey';
    await _prefs.setString(key, jsonEncode(payload));

    final sections = _prefs.getStringList(_tvSectionIndexKey) ?? <String>[];
    if (!sections.contains(sectionKey)) {
      sections.add(sectionKey);
      await _prefs.setStringList(_tvSectionIndexKey, sections);
    }

    _emit(OfflineEventType.caches);
  }

  /// Restore a previously cached TV section. Returns `null` if no offline cache
  /// was recorded for the supplied key.
  Future<OfflineSection<TVRef>?> loadTvSection(String sectionKey) async {
    final key = '$_tvSectionPrefix$sectionKey';
    final raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final cachedAt = DateTime.tryParse(decoded['cachedAt'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final itemsRaw = decoded['items'] as List<dynamic>? ?? const [];
      final shows = itemsRaw
          .whereType<Map<String, dynamic>>()
          .map(TVRef.fromJson)
          .toList(growable: false);
      return OfflineSection<TVRef>(cachedAt: cachedAt, items: shows);
    } catch (error, stackTrace) {
      _logger.error('Failed to decode cached TV section $sectionKey', error,
          stackTrace);
      return null;
    }
  }

  /// Returns a cached list of downloaded items. The results are memoized to
  /// avoid repeatedly decoding large JSON payloads from disk.
  Future<List<SavedMediaItem>> getDownloadedItems() async {
    if (_downloadedCache != null) {
      return _downloadedCache!;
    }
    final raw = _prefs.getString(_downloadedItemsKey);
    final decoded = SavedMediaItem.decodeList(raw);
    _downloadedCache = decoded;
    return decoded;
  }

  /// Persist a new set of downloaded media entries and notify listeners.
  Future<void> _saveDownloadedItems(List<SavedMediaItem> items) async {
    _downloadedCache = items;
    final encoded = SavedMediaItem.encodeList(items);
    await _prefs.setString(_downloadedItemsKey, encoded);
    _emit(OfflineEventType.downloads);
  }

  /// Toggle the offline download state for the provided [item]. Returns `true`
  /// when the item is now marked as downloaded, otherwise `false`.
  Future<bool> toggleDownloaded(SavedMediaItem item) async {
    final downloads = (await getDownloadedItems()).toList(growable: true);
    final index = downloads.indexWhere(
      (candidate) => candidate.storageId == item.storageId,
    );

    if (index >= 0) {
      downloads.removeAt(index);
      await _saveDownloadedItems(downloads);
      return false;
    }

    downloads.add(item.copyWith(updatedAt: DateTime.now()));
    await _saveDownloadedItems(downloads);
    return true;
  }

  /// Returns `true` when the given [mediaId]/[type] pair has a local offline
  /// download available.
  Future<bool> isDownloaded(int mediaId, SavedMediaType type) async {
    final downloads = await getDownloadedItems();
    return downloads.any(
      (item) => item.id == mediaId && item.type == type,
    );
  }

  /// Record an add/remove mutation performed on the watchlist while the device
  /// is offline so that it can be replayed when back online.
  Future<void> recordWatchlistMutation({
    required int mediaId,
    required SavedMediaType mediaType,
    required bool added,
    SavedMediaItem? snapshot,
  }) async {
    if (!isOffline) {
      await _removePendingTask(mediaId: mediaId, mediaType: mediaType);
      return;
    }

    final queue = await _loadQueue();
    queue.removeWhere(
      (task) =>
          task.mediaId == mediaId &&
          task.mediaType == mediaType &&
          (task.action == OfflineSyncAction.watchlistAdd ||
              task.action == OfflineSyncAction.watchlistRemove),
    );

    final task = OfflineSyncTask(
      id: '${DateTime.now().microsecondsSinceEpoch}_${mediaId}_watchlist',
      action:
          added ? OfflineSyncAction.watchlistAdd : OfflineSyncAction.watchlistRemove,
      mediaId: mediaId,
      mediaType: mediaType,
      payload: snapshot == null
          ? null
          : <String, dynamic>{
              'title': snapshot.title,
              'posterPath': snapshot.posterPath,
            },
    );

    queue.add(task);
    await _saveQueue(queue);
  }

  /// Record an add/remove mutation performed on the favorites list.
  Future<void> recordFavoritesMutation({
    required int mediaId,
    required SavedMediaType mediaType,
    required bool added,
    SavedMediaItem? snapshot,
  }) async {
    if (!isOffline) {
      await _removePendingTask(mediaId: mediaId, mediaType: mediaType);
      return;
    }

    final queue = await _loadQueue();
    queue.removeWhere(
      (task) =>
          task.mediaId == mediaId &&
          task.mediaType == mediaType &&
          (task.action == OfflineSyncAction.favoritesAdd ||
              task.action == OfflineSyncAction.favoritesRemove),
    );

    final task = OfflineSyncTask(
      id: '${DateTime.now().microsecondsSinceEpoch}_${mediaId}_favorites',
      action: added
          ? OfflineSyncAction.favoritesAdd
          : OfflineSyncAction.favoritesRemove,
      mediaId: mediaId,
      mediaType: mediaType,
      payload: snapshot == null
          ? null
          : <String, dynamic>{
              'title': snapshot.title,
              'posterPath': snapshot.posterPath,
            },
    );
    queue.add(task);
    await _saveQueue(queue);
  }

  /// Returns a memoized list of pending sync tasks.
  Future<List<OfflineSyncTask>> getPendingSyncTasks() => _loadQueue();

  /// Simulate syncing offline actions with the TMDB account once connectivity
  /// is available. In the offline-first build the mutations are already applied
  /// locally, so we simply clear the queue and update the metadata timestamp.
  Future<int> syncPendingActions() async {
    final queue = await _loadQueue();
    final count = queue.length;
    if (count == 0) {
      return 0;
    }

    await _prefs.remove(_syncQueueKey);
    _syncQueueCache = const <OfflineSyncTask>[];
    await _prefs.setString(
      _lastSyncedKey,
      DateTime.now().toIso8601String(),
    );
    _emit(OfflineEventType.syncQueue);
    return count;
  }

  /// Fetch the last successful sync timestamp (if any).
  DateTime? getLastSyncedAt() {
    final raw = _prefs.getString(_lastSyncedKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return DateTime.tryParse(raw);
  }

  /// Provide aggregate storage information for UI diagnostics.
  Future<OfflineStorageStats> getStorageStats() async {
    final downloaded = await getDownloadedItems();
    final queue = await getPendingSyncTasks();
    final movieSections = _prefs.getStringList(_movieSectionIndexKey) ?? const [];
    final tvSections = _prefs.getStringList(_tvSectionIndexKey) ?? const [];

    final payloads = <String>[];
    for (final key in movieSections) {
      final raw = _prefs.getString('$_movieSectionPrefix$key');
      if (raw != null) payloads.add(raw);
    }
    for (final key in tvSections) {
      final raw = _prefs.getString('$_tvSectionPrefix$key');
      if (raw != null) payloads.add(raw);
    }

    final downloadsRaw = _prefs.getString(_downloadedItemsKey);
    if (downloadsRaw != null) {
      payloads.add(downloadsRaw);
    }
    final queueRaw = _prefs.getString(_syncQueueKey);
    if (queueRaw != null) {
      payloads.add(queueRaw);
    }

    final totalBytes = payloads.fold<int>(
      0,
      (sum, item) => sum + item.length,
    );

    return OfflineStorageStats(
      cachedCollections: movieSections.length + tvSections.length,
      downloadedCount: downloaded.length,
      pendingSyncCount: queue.length,
      approximateBytes: totalBytes,
      lastSyncedAt: getLastSyncedAt(),
    );
  }

  /// Clear offline caches, downloads, and sync queues.
  Future<void> clearAll() async {
    final movieSections = _prefs.getStringList(_movieSectionIndexKey) ?? const [];
    final tvSections = _prefs.getStringList(_tvSectionIndexKey) ?? const [];

    for (final key in movieSections) {
      await _prefs.remove('$_movieSectionPrefix$key');
    }
    for (final key in tvSections) {
      await _prefs.remove('$_tvSectionPrefix$key');
    }

    await _prefs.remove(_movieSectionIndexKey);
    await _prefs.remove(_tvSectionIndexKey);
    await _prefs.remove(_downloadedItemsKey);
    await _prefs.remove(_syncQueueKey);
    await _prefs.remove(_lastSyncedKey);

    _downloadedCache = null;
    _syncQueueCache = null;

    _emit(OfflineEventType.cleared);
  }

  Future<void> _removePendingTask({
    required int mediaId,
    required SavedMediaType mediaType,
  }) async {
    final queue = await _loadQueue();
    queue.removeWhere(
      (task) => task.mediaId == mediaId && task.mediaType == mediaType,
    );
    await _saveQueue(queue, silent: true);
  }

  Future<List<OfflineSyncTask>> _loadQueue() async {
    if (_syncQueueCache != null) {
      return _syncQueueCache!;
    }

    final raw = _prefs.getString(_syncQueueKey);
    if (raw == null || raw.isEmpty) {
      _syncQueueCache = const <OfflineSyncTask>[];
      return _syncQueueCache!;
    }

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      final queue = decoded
          .whereType<Map<String, dynamic>>()
          .map(OfflineSyncTask.fromJson)
          .toList(growable: false);
      _syncQueueCache = queue;
      return queue;
    } catch (error, stackTrace) {
      _logger.error('Failed to decode offline sync queue', error, stackTrace);
      _syncQueueCache = const <OfflineSyncTask>[];
      return _syncQueueCache!;
    }
  }

  Future<void> _saveQueue(List<OfflineSyncTask> queue, {bool silent = false}) async {
    _syncQueueCache = queue;
    if (queue.isEmpty) {
      await _prefs.remove(_syncQueueKey);
    } else {
      final encoded = jsonEncode(queue.map((task) => task.toJson()).toList());
      await _prefs.setString(_syncQueueKey, encoded);
    }
    if (!silent) {
      _emit(OfflineEventType.syncQueue);
    }
  }

  void _emit(OfflineEventType type) {
    if (!_eventController.hasListener) {
      return;
    }
    _eventController.add(OfflineEvent(type));
  }

  static Map<String, dynamic> _movieToJson(Movie movie) {
    return <String, dynamic>{
      'id': movie.id,
      'title': movie.title,
      'overview': movie.overview,
      'posterPath': movie.posterPath,
      'backdropPath': movie.backdropPath,
      'mediaType': movie.mediaType,
      'releaseDate': movie.releaseDate,
      'runtime': movie.runtime,
      'voteAverage': movie.voteAverage,
      'voteCount': movie.voteCount,
      'popularity': movie.popularity,
      'originalLanguage': movie.originalLanguage,
      'originalTitle': movie.originalTitle,
      'adult': movie.adult,
      'genreIds': movie.genreIds,
      'status': movie.status,
    };
  }

  static Movie _movieFromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse('${json['id']}') ?? 0,
      title: (json['title'] as String?) ?? '',
      overview: json['overview'] as String?,
      posterPath: json['posterPath'] as String?,
      backdropPath: json['backdropPath'] as String?,
      mediaType: json['mediaType'] as String?,
      releaseDate: json['releaseDate'] as String?,
      runtime: json['runtime'] as int?,
      voteAverage: (json['voteAverage'] as num?)?.toDouble(),
      voteCount: json['voteCount'] as int?,
      popularity: (json['popularity'] as num?)?.toDouble(),
      originalLanguage: json['originalLanguage'] as String?,
      originalTitle: json['originalTitle'] as String?,
      adult: json['adult'] as bool? ?? false,
      genreIds: (json['genreIds'] as List<dynamic>?)?.whereType<int>().toList(),
      status: json['status'] as String?,
    );
  }
}

/// Convenience wrapper containing cached items and the timestamp they were
/// stored. Providers use this to surface "last updated" metadata in the UI.
class OfflineSection<T> {
  const OfflineSection({required this.cachedAt, required this.items});

  final DateTime cachedAt;
  final List<T> items;
}
