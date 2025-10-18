import 'package:flutter/material.dart';
import '../data/models/saved_media_item.dart';
import '../data/models/notification_item.dart';
import '../data/services/local_storage_service.dart';
import '../data/services/notification_preferences_service.dart';
import '../data/services/offline_service.dart';
import 'package:http/http.dart' as http;

class WatchlistProvider with ChangeNotifier {
  final LocalStorageService _storage;
  final NotificationPreferences _notificationPreferences;
  final http.Client _httpClient;
  final OfflineService? _offlineService;

  Set<int> _watchlistIds = {};
  List<SavedMediaItem> _watchlistItems = const <SavedMediaItem>[];

  WatchlistProvider(
    this._storage, {
    required NotificationPreferences notificationPreferences,
    http.Client? httpClient,
    OfflineService? offlineService,
  })  : _notificationPreferences = notificationPreferences,
        _httpClient = httpClient ?? http.Client(),
        _offlineService = offlineService {
    _loadWatchlist();
  }

  // Public getters
  Set<int> get watchlist => _watchlistIds;
  List<SavedMediaItem> get watchlistItems => List.unmodifiable(_watchlistItems);
  bool isInWatchlist(int id) => _watchlistIds.contains(id);
  int get count => _watchlistIds.length;

  bool isWatched(int id, {SavedMediaType type = SavedMediaType.movie}) {
    for (final item in _watchlistItems) {
      if (item.id == id && item.type == type) {
        return item.watched;
      }
    }
    return false;
  }

  void _loadWatchlist() {
    _watchlistItems = _storage.getWatchlistItems();
    _watchlistIds = _watchlistItems.map((e) => e.id).toSet();
    notifyListeners();
  }

  Future<void> refreshWatchlist() async {
    _loadWatchlist();
  }

  Future<void> toggleWatchlist(
    int id, {
    SavedMediaType type = SavedMediaType.movie,
  }) async {
    final wasInWatchlist = _watchlistIds.contains(id);
    final existingItem = _findWatchlistItem(id, type);
    if (wasInWatchlist) {
      await _storage.removeFromWatchlist(id, type: type);
    } else {
      await _storage.addToWatchlist(id, type: type);
    }
    await _offlineService?.recordWatchlistMutation(
      mediaId: id,
      mediaType: type,
      added: !wasInWatchlist,
        snapshot: wasInWatchlist
            ? null
            : _watchlistItems.firstWhere(
                (item) => item.id == id && item.type == type,
                orElse: () => SavedMediaItem(
                id: id,
                type: type,
                title: 'Media #$id',
              ),
            ),
    );
    await _emitWatchlistNotification(
      type: type,
      mediaId: id,
      added: !wasInWatchlist,
      snapshot: wasInWatchlist
          ? existingItem
          : _fetchStoredWatchlistItem(id, type),
    );
    _loadWatchlist();
  }

  Future<void> addToWatchlist(
    int id, {
    SavedMediaItem? item,
    SavedMediaType type = SavedMediaType.movie,
  }) async {
    if (!_watchlistIds.contains(id)) {
      await _storage.addToWatchlist(id, item: item, type: type);
      await _offlineService?.recordWatchlistMutation(
        mediaId: id,
        mediaType: type,
        added: true,
        snapshot: item,
      );
      await _emitWatchlistNotification(
        type: type,
        mediaId: id,
        added: true,
        snapshot: item ?? _fetchStoredWatchlistItem(id, type),
      );
      _loadWatchlist();
    }
  }

  Future<void> removeFromWatchlist(
    int id, {
    SavedMediaType type = SavedMediaType.movie,
  }) async {
    if (_watchlistIds.contains(id)) {
      final existingItem = _findWatchlistItem(id, type);
      await _storage.removeFromWatchlist(id, type: type);
      await _offlineService?.recordWatchlistMutation(
        mediaId: id,
        mediaType: type,
        added: false,
      );
      await _emitWatchlistNotification(
        type: type,
        mediaId: id,
        added: false,
        snapshot: existingItem,
      );
      _loadWatchlist();
    }
  }

  SavedMediaItem? _findWatchlistItem(int id, SavedMediaType type) {
    for (final item in _watchlistItems) {
      if (item.id == id && item.type == type) {
        return item;
      }
    }
    return null;
  }

  SavedMediaItem? _fetchStoredWatchlistItem(int id, SavedMediaType type) {
    for (final item in _storage.getWatchlistItems()) {
      if (item.id == id && item.type == type) {
        return item;
      }
    }
    return null;
  }

  Future<void> _emitWatchlistNotification({
    required SavedMediaType type,
    required int mediaId,
    required bool added,
    SavedMediaItem? snapshot,
  }) async {
    if (!_notificationPreferences.watchlistAlertsEnabled) {
      return;
    }

    final title = _resolveTitle(mediaId, type, snapshot);
    final notification = AppNotification(
      id: 'watchlist_${type.storageKey}_$mediaId',
      title: added ? 'Added to watchlist' : 'Removed from watchlist',
      message: added
          ? '$title was added to your watchlist.'
          : '$title was removed from your watchlist.',
      category: NotificationCategory.list,
      metadata: <String, dynamic>{
        'mediaId': mediaId,
        'mediaType': type.storageKey,
        'action': added ? 'added' : 'removed',
        'title': title,
      },
    );

    await _storage.upsertNotification(notification);
  }

  String _resolveTitle(
    int id,
    SavedMediaType type,
    SavedMediaItem? snapshot,
  ) {
    final candidateTitle = snapshot?.title;
    if (candidateTitle != null && candidateTitle.trim().isNotEmpty) {
      return candidateTitle.trim();
    }

    final fromState = _findWatchlistItem(id, type)?.title;
    if (fromState != null && fromState.trim().isNotEmpty) {
      return fromState.trim();
    }

    return 'Media #$id';
  }

  Future<void> clearWatchlist() async {
    await _storage.saveWatchlistItems(const <SavedMediaItem>[]);
    _loadWatchlist();
  }

  // Watched state management
  Future<void> setWatched(
    int id, {
    required bool watched,
    SavedMediaType type = SavedMediaType.movie,
  }) async {
    final items = List<SavedMediaItem>.from(_watchlistItems);
    final index = items.indexWhere((it) => it.id == id && it.type == type);
    if (index < 0) {
      return;
    }
    final updated = items[index].copyWith(
      watched: watched,
      watchedAt: watched ? DateTime.now() : null,
    );
    items[index] = updated;
    await _storage.saveWatchlistItems(items);
    _loadWatchlist();
  }

  // Export / Import
  String exportToJson() {
    return SavedMediaItem.encodeList(_watchlistItems);
  }

  Future<void> importFromRemoteJson(Uri url) async {
    final response = await _httpClient.get(url);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final items = SavedMediaItem.decodeList(response.body);
      await _storage.saveWatchlistItems(items);
      _loadWatchlist();
      return;
    }
    throw Exception('Failed to import watchlist: HTTP ${response.statusCode}');
  }
}
