import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../core/analytics/app_analytics.dart';
import '../data/models/saved_media_item.dart';
import '../data/services/local_storage_service.dart';
import '../data/services/offline_service.dart';

class FavoritesProvider with ChangeNotifier {
  final LocalStorageService _storage;
  final http.Client _httpClient;
  final OfflineService? _offlineService;
  final AppAnalytics? _analytics;

  Set<int> _favoriteIds = {};
  List<SavedMediaItem> _favoriteItems = const <SavedMediaItem>[];

  FavoritesProvider(
    this._storage, {
    http.Client? httpClient,
    OfflineService? offlineService,
    AppAnalytics? analytics,
  })  : _httpClient = httpClient ?? http.Client(),
        _offlineService = offlineService,
        _analytics = analytics {
    _loadFavorites();
  }

  // Public getters
  Set<int> get favorites => _favoriteIds;
  List<SavedMediaItem> get favoriteItems => List.unmodifiable(_favoriteItems);
  bool isFavorite(int id) => _favoriteIds.contains(id);
  int get count => _favoriteIds.length;

  bool isWatched(int id, {SavedMediaType type = SavedMediaType.movie}) {
    for (final item in _favoriteItems) {
      if (item.id == id && item.type == type) {
        return item.watched;
      }
    }
    return false;
  }

  void _loadFavorites() {
    _favoriteItems = _storage.getFavoriteItems();
    _favoriteIds = _favoriteItems.map((e) => e.id).toSet();
    notifyListeners();
  }

  Future<void> toggleFavorite(
    int id, {
    SavedMediaType type = SavedMediaType.movie,
  }) async {
    final wasFavorite = _favoriteIds.contains(id);
    final existing = _findFavoriteItem(id, type);
    final previousTitle = existing?.title ?? existing?.originalTitle;
    if (wasFavorite) {
      await _storage.removeFromFavorites(id, type: type);
    } else {
      await _storage.addToFavorites(id, type: type);
    }
    await _offlineService?.recordFavoritesMutation(
      mediaId: id,
      mediaType: type,
      added: !wasFavorite,
      snapshot: wasFavorite
          ? null
          : _favoriteItems.firstWhere(
              (item) => item.id == id && item.type == type,
              orElse: () => SavedMediaItem(
                id: id,
                type: type,
                title: 'Media #$id',
              ),
            ),
    );
    _loadFavorites();
    if (wasFavorite) {
      _trackFavoriteMutation(
        id: id,
        type: type,
        added: false,
        cachedTitle: previousTitle,
      );
    } else {
      final current = _findFavoriteItem(id, type);
      final newTitle = current?.title ?? current?.originalTitle;
      _trackFavoriteMutation(
        id: id,
        type: type,
        added: true,
        cachedTitle: newTitle,
      );
    }
  }

  Future<void> addFavorite(
    int id, {
    SavedMediaItem? item,
    SavedMediaType type = SavedMediaType.movie,
  }) async {
    if (!_favoriteIds.contains(id)) {
      await _storage.addToFavorites(id, item: item, type: type);
      await _offlineService?.recordFavoritesMutation(
        mediaId: id,
        mediaType: type,
        added: true,
        snapshot: item,
      );
      _loadFavorites();
      final title = item?.title ??
          item?.originalTitle ??
          _findFavoriteItem(id, type)?.title ??
          _findFavoriteItem(id, type)?.originalTitle;
      _trackFavoriteMutation(
        id: id,
        type: type,
        added: true,
        cachedTitle: title,
      );
    }
  }

  Future<void> removeFavorite(
    int id, {
    SavedMediaType type = SavedMediaType.movie,
  }) async {
    if (_favoriteIds.contains(id)) {
      final existing = _findFavoriteItem(id, type);
      final previousTitle = existing?.title ?? existing?.originalTitle;
      await _storage.removeFromFavorites(id, type: type);
      await _offlineService?.recordFavoritesMutation(
        mediaId: id,
        mediaType: type,
        added: false,
      );
      _loadFavorites();
      _trackFavoriteMutation(
        id: id,
        type: type,
        added: false,
        cachedTitle: previousTitle,
      );
    }
  }

  Future<void> clearFavorites() async {
    await _storage.saveFavoriteItems(const <SavedMediaItem>[]);
    _loadFavorites();
  }

  // Watched state management
  Future<void> setWatched(
    int id, {
    required bool watched,
    SavedMediaType type = SavedMediaType.movie,
  }) async {
    final items = List<SavedMediaItem>.from(_favoriteItems);
    final index = items.indexWhere((it) => it.id == id && it.type == type);
    if (index < 0) {
      return;
    }
    final updated = items[index].copyWith(
      watched: watched,
      watchedAt: watched ? DateTime.now() : null,
    );
    items[index] = updated;
    await _storage.saveFavoriteItems(items);
    _loadFavorites();
  }

  // Export / Import
  String exportToJson() {
    return SavedMediaItem.encodeList(_favoriteItems);
  }

  Future<void> importFromRemoteJson(Uri url) async {
    final response = await _httpClient.get(url);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final items = SavedMediaItem.decodeList(response.body);
      await _storage.saveFavoriteItems(items);
      _loadFavorites();
      return;
    }
    throw Exception('Failed to import favorites: HTTP ${response.statusCode}');
  }

  /// Returns the cached [SavedMediaItem] if it exists in the favourites list.
  SavedMediaItem? _findFavoriteItem(int id, SavedMediaType type) {
    for (final item in _favoriteItems) {
      if (item.id == id && item.type == type) {
        return item;
      }
    }
    return null;
  }

  /// Forwards favourite mutations to the analytics service so we can quantify
  /// engagement with saved content even when operating offline.
  void _trackFavoriteMutation({
    required int id,
    required SavedMediaType type,
    required bool added,
    String? cachedTitle,
  }) {
    final current = _findFavoriteItem(id, type);
    final resolvedTitle = cachedTitle ??
        current?.title ??
        current?.originalTitle ??
        (added ? 'Media #$id' : null);
    unawaited(
      _analytics?.logFavoriteChange(
        mediaId: id,
        mediaType: type.storageKey,
        added: added,
        title: resolvedTitle,
      ),
    );
  }
}
