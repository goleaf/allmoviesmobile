import 'package:flutter/material.dart';
import '../data/models/saved_media_item.dart';
import '../data/services/local_storage_service.dart';
import 'package:http/http.dart' as http;

class WatchlistProvider with ChangeNotifier {
  final LocalStorageService _storage;
  final http.Client _httpClient;

  Set<int> _watchlistIds = {};
  List<SavedMediaItem> _watchlistItems = const <SavedMediaItem>[];

  WatchlistProvider(this._storage, {http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client() {
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

  Future<void> toggleWatchlist(
    int id, {
    SavedMediaType type = SavedMediaType.movie,
  }) async {
    if (_watchlistIds.contains(id)) {
      await _storage.removeFromWatchlist(id, type: type);
    } else {
      await _storage.addToWatchlist(id, type: type);
    }
    _loadWatchlist();
  }

  Future<void> addToWatchlist(
    int id, {
    SavedMediaItem? item,
    SavedMediaType type = SavedMediaType.movie,
  }) async {
    if (!_watchlistIds.contains(id)) {
      await _storage.addToWatchlist(id, item: item, type: type);
      _loadWatchlist();
    }
  }

  Future<void> removeFromWatchlist(
    int id, {
    SavedMediaType type = SavedMediaType.movie,
  }) async {
    if (_watchlistIds.contains(id)) {
      await _storage.removeFromWatchlist(id, type: type);
      _loadWatchlist();
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
}
