import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../core/analytics/app_analytics.dart';
import '../data/models/saved_media_item.dart';
import '../data/services/local_storage_service.dart';
import '../data/services/offline_service.dart';

class WatchlistProvider with ChangeNotifier {
  final LocalStorageService _storage;
  final http.Client _httpClient;
  final OfflineService? _offlineService;
  final AppAnalytics? _analytics;

  Set<int> _watchlistIds = {};
  List<SavedMediaItem> _watchlistItems = const <SavedMediaItem>[];

  WatchlistProvider(
    this._storage, {
    http.Client? httpClient,
    OfflineService? offlineService,
    AppAnalytics? analytics,
  })  : _httpClient = httpClient ?? http.Client(),
        _offlineService = offlineService,
        _analytics = analytics {
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

  Future<void> loadFromStorage() async {
    _loadWatchlist();
  }

  Future<void> toggleWatchlist(
    int id, {
    SavedMediaType type = SavedMediaType.movie,
  }) async {
    final wasInWatchlist = _watchlistIds.contains(id);
    final existing = _findWatchlistItem(id, type);
    final previousTitle = existing?.title ?? existing?.originalTitle;
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
    _loadWatchlist();
    if (wasInWatchlist) {
      _trackWatchlistMutation(
        id: id,
        type: type,
        added: false,
        cachedTitle: previousTitle,
      );
    } else {
      final current = _findWatchlistItem(id, type);
      final newTitle = current?.title ?? current?.originalTitle;
      _trackWatchlistMutation(
        id: id,
        type: type,
        added: true,
        cachedTitle: newTitle,
      );
    }
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
      _loadWatchlist();
      final title = item?.title ??
          item?.originalTitle ??
          _findWatchlistItem(id, type)?.title ??
          _findWatchlistItem(id, type)?.originalTitle;
      _trackWatchlistMutation(
        id: id,
        type: type,
        added: true,
        cachedTitle: title,
      );
    }
  }

  Future<void> removeFromWatchlist(
    int id, {
    SavedMediaType type = SavedMediaType.movie,
  }) async {
    if (_watchlistIds.contains(id)) {
      final existing = _findWatchlistItem(id, type);
      final previousTitle = existing?.title ?? existing?.originalTitle;
      await _storage.removeFromWatchlist(id, type: type);
      await _offlineService?.recordWatchlistMutation(
        mediaId: id,
        mediaType: type,
        added: false,
      );
      _loadWatchlist();
      _trackWatchlistMutation(
        id: id,
        type: type,
        added: false,
        cachedTitle: previousTitle,
      );
    }
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

  /// Returns the cached [SavedMediaItem] if it exists in the watchlist.
  SavedMediaItem? _findWatchlistItem(int id, SavedMediaType type) {
    for (final item in _watchlistItems) {
      if (item.id == id && item.type == type) {
        return item;
      }
    }
    return null;
  }

  /// Reports watchlist mutations so retention metrics can be monitored even
  /// when Firebase Analytics falls back to the debug logger implementation.
  void _trackWatchlistMutation({
    required int id,
    required SavedMediaType type,
    required bool added,
    String? cachedTitle,
  }) {
    final current = _findWatchlistItem(id, type);
    final resolvedTitle = cachedTitle ??
        current?.title ??
        current?.originalTitle ??
        (added ? 'Media #$id' : null);
    unawaited(
      _analytics?.logWatchlistChange(
        mediaId: id,
        mediaType: type.storageKey,
        added: added,
        title: resolvedTitle,
      ),
    );
  }
}
