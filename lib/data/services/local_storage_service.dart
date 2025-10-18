import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/custom_list.dart';
import '../models/notification_item.dart';
import '../models/saved_media_item.dart';
import '../models/discover_filters_model.dart';

/// Local persistence gateway handling favorites, watchlist, custom lists,
/// notifications, search history and other lightweight caches.
class LocalStorageService {
  LocalStorageService(this._prefs);

  static const String _favoritesKey = 'allmovies_favorites';
  static const String _watchlistKey = 'allmovies_watchlist';
  static const String _recentlyViewedKey = 'allmovies_recently_viewed';
  static const String _searchHistoryKey = 'allmovies_search_history';
  static const String _customListsKey = 'allmovies_custom_lists';
  static const String _notificationsKey = 'allmovies_notifications';
  static const String _watchAvailabilityKey =
      'allmovies_watch_availability_snapshots';
  static const String _changeTrackerCursorKey =
      'allmovies_change_tracker_cursor';
  static const String _changeTrackerSeenIdsKey =
      'allmovies_change_tracker_seen_ids';

  // Movies browsing persistence
  static const String _discoverFiltersKey = 'allmovies_discover_filters';
  static const String _trendingWindowKey = 'allmovies_trending_window';
  static const String _moviesTabIndexKey = 'allmovies_movies_tab_index';
  static const String _moviesScrollPositionsKey =
      'allmovies_movies_scroll_positions';
  static const String _seriesTabIndexKey = 'allmovies_series_tab_index';
  static const String _seriesScrollPositionsKey =
      'allmovies_series_scroll_positions';
  static const String _peopleTabIndexKey = 'allmovies_people_tab_index';
  static const String _peopleScrollPositionsKey =
      'allmovies_people_scroll_positions';
  static const String _peopleDepartmentFilterKey =
      'allmovies_people_department_filter';

  static const String _favoritesSyncEnabledKey =
      'allmovies_favorites_sync_enabled';
  static const String _watchlistSyncEnabledKey =
      'allmovies_watchlist_sync_enabled';
  static const String _favoritesLastSyncedKey =
      'allmovies_favorites_last_synced';
  static const String _watchlistLastSyncedKey =
      'allmovies_watchlist_last_synced';

  final SharedPreferences _prefs;

  // ---------------------------------------------------------------------------
  // Favorites
  // ---------------------------------------------------------------------------

  List<SavedMediaItem> getFavoriteItems() {
    final raw = _prefs.getString(_favoritesKey);
    return SavedMediaItem.decodeList(raw);
  }

  Set<int> getFavorites() => getFavoriteItems().map((item) => item.id).toSet();

  Future<bool> saveFavoriteItems(List<SavedMediaItem> favorites) {
    final encoded = SavedMediaItem.encodeList(favorites);
    return _prefs.setString(_favoritesKey, encoded);
  }

  Future<bool> saveFavorites(Set<int> ids) {
    final items = ids
        .map(
          (id) => SavedMediaItem(
            id: id,
            type: SavedMediaType.movie,
            title: '', // Mark as incomplete
          ),
        )
        .toList(growable: false);
    return saveFavoriteItems(items);
  }

  Future<bool> addToFavorites(
    int id, {
    SavedMediaItem? item,
    SavedMediaType type = SavedMediaType.movie,
  }) async {
    final favorites = getFavoriteItems().toList();
    final storageId = item?.storageId ?? '${type.storageKey}_$id';
    final index = favorites.indexWhere(
      (candidate) => candidate.storageId == storageId,
    );

    final updatedItem =
        (item ?? SavedMediaItem(id: id, type: type, title: 'Movie #$id'))
            .copyWith(updatedAt: DateTime.now());

    if (index >= 0) {
      favorites[index] = updatedItem;
    } else {
      favorites.add(updatedItem);
    }

    return saveFavoriteItems(favorites);
  }

  Future<bool> removeFromFavorites(
    int id, {
    SavedMediaType type = SavedMediaType.movie,
  }) {
    final updated = getFavoriteItems()
        .where((item) => !(item.id == id && item.type == type))
        .toList(growable: false);
    return saveFavoriteItems(updated);
  }

  bool isFavorite(int id, {SavedMediaType type = SavedMediaType.movie}) {
    return getFavoriteItems().any((item) => item.id == id && item.type == type);
  }

  Future<bool> clearFavorites() => _prefs.remove(_favoritesKey);

  // ---------------------------------------------------------------------------
  // Watchlist
  // ---------------------------------------------------------------------------

  List<SavedMediaItem> getWatchlistItems() {
    final raw = _prefs.getString(_watchlistKey);
    return SavedMediaItem.decodeList(raw);
  }

  Set<int> getWatchlist() => getWatchlistItems().map((item) => item.id).toSet();

  Future<bool> saveWatchlistItems(List<SavedMediaItem> watchlist) {
    final encoded = SavedMediaItem.encodeList(watchlist);
    return _prefs.setString(_watchlistKey, encoded);
  }

  Future<bool> saveWatchlist(Set<int> ids) {
    final items = ids
        .map(
          (id) => SavedMediaItem(
            id: id,
            type: SavedMediaType.movie,
            title: 'Movie #$id',
          ),
        )
        .toList(growable: false);
    return saveWatchlistItems(items);
  }

  Future<bool> addToWatchlist(
    int id, {
    SavedMediaItem? item,
    SavedMediaType type = SavedMediaType.movie,
  }) async {
    final watchlist = getWatchlistItems().toList();
    final storageId = item?.storageId ?? '${type.storageKey}_$id';
    final index = watchlist.indexWhere(
      (candidate) => candidate.storageId == storageId,
    );

    final updatedItem =
        (item ?? SavedMediaItem(id: id, type: type, title: 'Movie #$id'))
            .copyWith(updatedAt: DateTime.now());

    if (index >= 0) {
      watchlist[index] = updatedItem;
    } else {
      watchlist.add(updatedItem);
    }

    return saveWatchlistItems(watchlist);
  }

  Future<bool> removeFromWatchlist(
    int id, {
    SavedMediaType type = SavedMediaType.movie,
  }) {
    final updated = getWatchlistItems()
        .where((item) => !(item.id == id && item.type == type))
        .toList(growable: false);
    return saveWatchlistItems(updated);
  }

  bool isInWatchlist(int id, {SavedMediaType type = SavedMediaType.movie}) {
    return getWatchlistItems().any(
      (item) => item.id == id && item.type == type,
    );
  }

  Future<bool> clearWatchlist() => _prefs.remove(_watchlistKey);

  // ---------------------------------------------------------------------------
  // Watch provider availability snapshots
  // ---------------------------------------------------------------------------

  /// Builds a deterministic storage key for watch provider snapshots using the
  /// TMDB media type (`movie` or `tv`), the content identifier, and the region
  /// code returned by the watch provider endpoints
  /// (`GET /3/movie/{movie_id}/watch/providers` and
  /// `GET /3/tv/{tv_id}/watch/providers`).
  String _watchAvailabilityStorageKey(
    String mediaType,
    int mediaId,
    String region,
  ) {
    final trimmedType = mediaType.trim().toLowerCase();
    final normalizedRegion = region.trim().toUpperCase();
    return '$trimmedType::$mediaId::$normalizedRegion';
  }

  Map<String, dynamic> _getWatchAvailabilityMap() {
    final raw = _prefs.getString(_watchAvailabilityKey);
    if (raw == null || raw.isEmpty) {
      return <String, dynamic>{};
    }

    try {
      final decoded = json.decode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return decoded.map(
          (key, value) => MapEntry(key.toString(), value),
        );
      }
    } catch (_) {
      // Ignore malformed data and reset below by returning empty map.
    }
    return <String, dynamic>{};
  }

  Future<bool> _saveWatchAvailabilityMap(Map<String, dynamic> map) {
    if (map.isEmpty) {
      return _prefs.remove(_watchAvailabilityKey);
    }

    return _prefs.setString(
      _watchAvailabilityKey,
      json.encode(map),
    );
  }

  /// Returns the stored watch provider identifiers for a media/region combo,
  /// mirroring the payload from the TMDB endpoints:
  /// - Movies: `GET /3/movie/{movie_id}/watch/providers`
  /// - TV shows: `GET /3/tv/{tv_id}/watch/providers`
  Set<int> getWatchProviderSnapshot(
    String mediaType,
    int mediaId,
    String region,
  ) {
    final storageKey = _watchAvailabilityStorageKey(mediaType, mediaId, region);
    final map = _getWatchAvailabilityMap();
    final raw = map[storageKey];

    if (raw is List) {
      return raw
          .whereType<num>()
          .map((value) => value.toInt())
          .toSet(growable: false);
    }
    if (raw is Iterable) {
      return raw
          .whereType<num>()
          .map((value) => value.toInt())
          .toSet(growable: false);
    }

    return <int>{};
  }

  /// Whether a snapshot already exists for the provided media/region pair.
  bool hasWatchProviderSnapshot(
    String mediaType,
    int mediaId,
    String region,
  ) {
    final storageKey = _watchAvailabilityStorageKey(mediaType, mediaId, region);
    final map = _getWatchAvailabilityMap();
    return map.containsKey(storageKey);
  }

  /// Persists the set of provider identifiers returned by TMDB watch provider
  /// endpoints so that the app can notify the user when new services become
  /// available in their selected region.
  Future<bool> saveWatchProviderSnapshot(
    String mediaType,
    int mediaId,
    String region,
    Iterable<int> providerIds,
  ) {
    final storageKey = _watchAvailabilityStorageKey(mediaType, mediaId, region);
    final map = _getWatchAvailabilityMap();
    map[storageKey] = providerIds.toSet().toList(growable: false);
    return _saveWatchAvailabilityMap(map);
  }

  /// Removes the stored snapshot for the given media if the user clears
  /// notifications or the record becomes obsolete.
  Future<bool> clearWatchProviderSnapshot(
    String mediaType,
    int mediaId,
    String region,
  ) {
    final storageKey = _watchAvailabilityStorageKey(mediaType, mediaId, region);
    final map = _getWatchAvailabilityMap();
    final removed = map.remove(storageKey);
    if (removed == null) {
      return Future.value(true);
    }
    return _saveWatchAvailabilityMap(map);
  }

  // ---------------------------------------------------------------------------
  // Favorites/watchlist sync toggles
  // ---------------------------------------------------------------------------

  bool getFavoritesSyncEnabled() =>
      _prefs.getBool(_favoritesSyncEnabledKey) ?? false;

  Future<bool> setFavoritesSyncEnabled(bool value) =>
      _prefs.setBool(_favoritesSyncEnabledKey, value);

  bool getWatchlistSyncEnabled() =>
      _prefs.getBool(_watchlistSyncEnabledKey) ?? false;

  Future<bool> setWatchlistSyncEnabled(bool value) =>
      _prefs.setBool(_watchlistSyncEnabledKey, value);

  DateTime? getFavoritesLastSyncedAt() {
    final raw = _prefs.getString(_favoritesLastSyncedKey);
    return raw == null || raw.isEmpty ? null : DateTime.tryParse(raw);
  }

  Future<bool> setFavoritesLastSyncedAt(DateTime timestamp) {
    return _prefs.setString(
      _favoritesLastSyncedKey,
      timestamp.toIso8601String(),
    );
  }

  // ---------------------------------------------------------------------------
  // Movies screen UI state
  // ---------------------------------------------------------------------------

  int getMoviesTabIndex() => _prefs.getInt(_moviesTabIndexKey) ?? 0;

  Future<bool> setMoviesTabIndex(int index) {
    return _prefs.setInt(_moviesTabIndexKey, index);
  }

  int? getMoviesScrollIndex(String sectionKey) {
    final raw = _prefs.getString(_moviesScrollPositionsKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final value = decoded[sectionKey];
      if (value is int) {
        return value;
      }
      if (value is num) {
        return value.toInt();
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  Future<bool> setMoviesScrollIndex(String sectionKey, int index) async {
    final raw = _prefs.getString(_moviesScrollPositionsKey);
    final map = <String, dynamic>{};

    if (raw != null && raw.isNotEmpty) {
      try {
        map.addAll(jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {
        // Corrupted payload; overwrite below
      }
    }

    map[sectionKey] = index;

    return _prefs.setString(
      _moviesScrollPositionsKey,
      jsonEncode(map),
    );
  }

  int getSeriesTabIndex() => _prefs.getInt(_seriesTabIndexKey) ?? 0;

  Future<bool> setSeriesTabIndex(int index) {
    return _prefs.setInt(_seriesTabIndexKey, index);
  }

  double? getSeriesScrollOffset(String sectionKey) {
    final raw = _prefs.getString(_seriesScrollPositionsKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final value = decoded[sectionKey];
      if (value is num) {
        return value.toDouble();
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  Future<bool> setSeriesScrollOffset(String sectionKey, double offset) async {
    final raw = _prefs.getString(_seriesScrollPositionsKey);
    final map = <String, dynamic>{};

    if (raw != null && raw.isNotEmpty) {
      try {
        map.addAll(jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {}
    }

    map[sectionKey] = offset;

    return _prefs.setString(
      _seriesScrollPositionsKey,
      jsonEncode(map),
    );
  }

  int getPeopleTabIndex() => _prefs.getInt(_peopleTabIndexKey) ?? 0;

  Future<bool> setPeopleTabIndex(int index) {
    return _prefs.setInt(_peopleTabIndexKey, index);
  }

  double? getPeopleScrollOffset(String sectionKey) {
    final raw = _prefs.getString(_peopleScrollPositionsKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final value = decoded[sectionKey];
      if (value is num) {
        return value.toDouble();
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  Future<bool> setPeopleScrollOffset(String sectionKey, double offset) async {
    final raw = _prefs.getString(_peopleScrollPositionsKey);
    final map = <String, dynamic>{};

    if (raw != null && raw.isNotEmpty) {
      try {
        map.addAll(jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {}
    }

    map[sectionKey] = offset;

    return _prefs.setString(
      _peopleScrollPositionsKey,
      jsonEncode(map),
    );
  }

  String? getPeopleDepartmentFilter() {
    final stored = _prefs.getString(_peopleDepartmentFilterKey);
    if (stored == null || stored.isEmpty) {
      return null;
    }
    return stored;
  }

  Future<bool> setPeopleDepartmentFilter(String? department) {
    if (department == null || department.isEmpty) {
      return _prefs.remove(_peopleDepartmentFilterKey);
    }
    return _prefs.setString(_peopleDepartmentFilterKey, department);
  }

  DateTime? getWatchlistLastSyncedAt() {
    final raw = _prefs.getString(_watchlistLastSyncedKey);
    return raw == null || raw.isEmpty ? null : DateTime.tryParse(raw);
  }

  Future<bool> setWatchlistLastSyncedAt(DateTime timestamp) {
    return _prefs.setString(
      _watchlistLastSyncedKey,
      timestamp.toIso8601String(),
    );
  }

  // ---------------------------------------------------------------------------
  // Custom lists
  // ---------------------------------------------------------------------------

  List<CustomList> getCustomLists() {
    final raw = _prefs.getString(_customListsKey);
    if (raw == null || raw.isEmpty) {
      return const <CustomList>[];
    }

    try {
      final decoded = json.decode(raw);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(CustomList.fromJson)
            .toList(growable: false);
      }
    } catch (_) {
      // ignore malformed data
    }

    return const <CustomList>[];
  }

  Future<bool> saveCustomLists(List<CustomList> lists) {
    final encoded = json.encode(
      lists.map((list) => list.toJson()).toList(growable: false),
    );
    return _prefs.setString(_customListsKey, encoded);
  }

  Future<bool> upsertCustomList(CustomList list) async {
    final lists = getCustomLists();
    final index = lists.indexWhere((candidate) => candidate.id == list.id);
    final updated = List<CustomList>.from(lists);

    if (index >= 0) {
      updated[index] = list.copyWith(updatedAt: DateTime.now());
    } else {
      updated.add(list.copyWith(updatedAt: DateTime.now()));
    }

    return saveCustomLists(updated);
  }

  Future<bool> removeCustomList(String listId) {
    final updated = getCustomLists()
        .where((list) => list.id != listId)
        .toList(growable: false);
    return saveCustomLists(updated);
  }

  CustomList? findCustomList(String listId) {
    for (final list in getCustomLists()) {
      if (list.id == listId) {
        return list;
      }
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Notifications
  // ---------------------------------------------------------------------------

  List<AppNotification> getNotifications() {
    final raw = _prefs.getString(_notificationsKey);
    if (raw == null || raw.isEmpty) {
      return const <AppNotification>[];
    }

    try {
      final decoded = json.decode(raw);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(AppNotification.fromJson)
            .toList(growable: false);
      }
    } catch (_) {
      // ignore malformed data
    }

    return const <AppNotification>[];
  }

  Future<bool> saveNotifications(List<AppNotification> notifications) {
    final encoded = json.encode(
      notifications
          .map((notification) => notification.toJson())
          .toList(growable: false),
    );
    return _prefs.setString(_notificationsKey, encoded);
  }

  Future<bool> upsertNotification(AppNotification notification) async {
    final notifications = getNotifications();
    final index = notifications.indexWhere(
      (item) => item.id == notification.id,
    );
    final updated = List<AppNotification>.from(notifications);

    if (index >= 0) {
      updated[index] = notification;
    } else {
      updated.insert(0, notification);
    }

    return saveNotifications(updated);
  }

  Future<bool> markNotificationsRead(Iterable<String> ids) {
    final idSet = ids.toSet();
    final updated = getNotifications()
        .map(
          (notification) => idSet.contains(notification.id)
              ? notification.copyWith(isRead: true)
              : notification,
        )
        .toList(growable: false);
    return saveNotifications(updated);
  }

  Future<bool> clearNotifications() => _prefs.remove(_notificationsKey);

  // ---------------------------------------------------------------------------
  // Change tracking state
  // ---------------------------------------------------------------------------

  DateTime? getChangeTrackingCursor() {
    final raw = _prefs.getString(_changeTrackerCursorKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return DateTime.tryParse(raw);
  }

  Future<bool> setChangeTrackingCursor(DateTime cursor) {
    return _prefs.setString(
      _changeTrackerCursorKey,
      cursor.toUtc().toIso8601String(),
    );
  }

  Set<String> getChangeTrackerSeenIds() {
    final raw = _prefs.getString(_changeTrackerSeenIdsKey);
    if (raw == null || raw.isEmpty) {
      return const <String>{};
    }
    try {
      final decoded = json.decode(raw);
      if (decoded is List) {
        return decoded.whereType<String>().toSet();
      }
    } catch (_) {
      // ignore malformed data
    }
    return const <String>{};
  }

  Future<bool> saveChangeTrackerSeenIds(Set<String> ids) {
    final encoded = json.encode(ids.toList(growable: false));
    return _prefs.setString(_changeTrackerSeenIdsKey, encoded);
  }

  Future<void> clearChangeTrackingState() async {
    await _prefs.remove(_changeTrackerCursorKey);
    await _prefs.remove(_changeTrackerSeenIdsKey);
  }

  // ---------------------------------------------------------------------------
  // Recently viewed
  // ---------------------------------------------------------------------------

  List<int> getRecentlyViewed({int limit = 20}) {
    final raw = _prefs.getString(_recentlyViewedKey);
    if (raw == null || raw.isEmpty) {
      return const <int>[];
    }

    try {
      final decoded = json.decode(raw);
      if (decoded is List) {
        return decoded.whereType<int>().take(limit).toList(growable: false);
      }
    } catch (_) {
      // ignore malformed data
    }

    return const <int>[];
  }

  Future<bool> addToRecentlyViewed(int id, {int limit = 20}) async {
    final items = getRecentlyViewed(limit: limit * 2).toList();
    items.remove(id);
    items.insert(0, id);
    final encoded = json.encode(items.take(limit).toList(growable: false));
    return _prefs.setString(_recentlyViewedKey, encoded);
  }

  Future<bool> clearRecentlyViewed() => _prefs.remove(_recentlyViewedKey);

  // ---------------------------------------------------------------------------
  // Search history
  // ---------------------------------------------------------------------------

  List<String> getSearchHistory({int limit = 10}) {
    final raw = _prefs.getString(_searchHistoryKey);
    if (raw == null || raw.isEmpty) {
      return const <String>[];
    }

    try {
      final decoded = json.decode(raw);
      if (decoded is List) {
        return decoded
            .whereType<String>()
            .map((query) => query.trim())
            .where((query) => query.isNotEmpty)
            .toSet()
            .take(limit)
            .toList(growable: false);
      }
    } catch (_) {
      // ignore malformed data
    }

    return const <String>[];
  }

  Future<bool> addToSearchHistory(String query, {int limit = 50}) async {
    final normalized = query.trim();
    if (normalized.isEmpty) {
      return false;
    }

    final history = getSearchHistory(limit: limit).toList();
    history.remove(normalized);
    history.insert(0, normalized);
    final encoded = json.encode(history.take(limit).toList(growable: false));
    return _prefs.setString(_searchHistoryKey, encoded);
  }

  Future<bool> removeFromSearchHistory(String query) {
    final normalized = query.trim();
    final history = getSearchHistory(
      limit: 50,
    ).where((entry) => entry != normalized).toList(growable: false);
    return _prefs.setString(_searchHistoryKey, json.encode(history));
  }

  Future<bool> clearSearchHistory() => _prefs.remove(_searchHistoryKey);

  // ---------------------------------------------------------------------------
  // Movies browsing persistence (filters + trending window)
  // ---------------------------------------------------------------------------

  DiscoverFilters? getDiscoverFilters() {
    final raw = _prefs.getString(_discoverFiltersKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = json.decode(raw);
      if (decoded is Map<String, dynamic>) {
        return DiscoverFilters.fromJson(decoded);
      }
    } catch (_) {
      // ignore malformed data
    }
    return null;
  }

  Future<bool> saveDiscoverFilters(DiscoverFilters filters) {
    final encoded = json.encode(filters.toJson());
    return _prefs.setString(_discoverFiltersKey, encoded);
  }

  String? getTrendingWindow() {
    final raw = _prefs.getString(_trendingWindowKey);
    return (raw == null || raw.isEmpty) ? null : raw;
  }

  Future<bool> setTrendingWindow(String window) {
    return _prefs.setString(_trendingWindowKey, window);
  }

  // ---------------------------------------------------------------------------
  // Utilities
  // ---------------------------------------------------------------------------

  Future<bool> clearAllData() async {
    final results = await Future.wait([
      _prefs.remove(_favoritesKey),
      _prefs.remove(_watchlistKey),
      _prefs.remove(_recentlyViewedKey),
      _prefs.remove(_searchHistoryKey),
      _prefs.remove(_customListsKey),
      _prefs.remove(_notificationsKey),
    ]);

    return results.every((value) => value);
  }
}
