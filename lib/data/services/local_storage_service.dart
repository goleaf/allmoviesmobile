import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/saved_media_item.dart';

class LocalStorageService {
  static const String _favoritesKey = 'allmovies_favorites';
  static const String _watchlistKey = 'allmovies_watchlist';
  static const String _recentlyViewedKey = 'allmovies_recently_viewed';
  static const String _searchHistoryKey = 'allmovies_search_history';

  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  static const String _favoritesSyncEnabledKey = 'allmovies_favorites_sync_enabled';
  static const String _watchlistSyncEnabledKey = 'allmovies_watchlist_sync_enabled';
  static const String _favoritesLastSyncedKey = 'allmovies_favorites_last_synced';
  static const String _watchlistLastSyncedKey = 'allmovies_watchlist_last_synced';

  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  // Favorites Management
  List<SavedMediaItem> getFavoriteItems() {
    final favoritesJson = _prefs.getString(_favoritesKey);
    return SavedMediaItem.decodeList(favoritesJson);
  }

  Future<bool> saveFavoriteItems(List<SavedMediaItem> favorites) async {
    final favoritesJson = SavedMediaItem.encodeList(favorites);
    return _prefs.setString(_favoritesKey, favoritesJson);
  }

  Future<bool> upsertFavorite(SavedMediaItem item) async {
    final favorites = getFavoriteItems();
    final index = favorites.indexWhere((element) => element.storageId == item.storageId);
    if (index >= 0) {
      favorites[index] = item.copyWith(updatedAt: DateTime.now());
    } else {
      favorites.add(item.copyWith(addedAt: DateTime.now(), updatedAt: DateTime.now()));
    }
    return saveFavoriteItems(favorites);
  }

  Future<bool> removeFavorite(int id, SavedMediaType type) async {
    final favorites = getFavoriteItems();
    favorites.removeWhere((item) => item.id == id && item.type == type);
    return saveFavoriteItems(favorites);
  }

  bool isFavorite(int id, SavedMediaType type) {
    final favorites = getFavoriteItems();
    return favorites.any((item) => item.id == id && item.type == type);
  }

  Future<bool> clearFavorites() async {
    return _prefs.remove(_favoritesKey);
  }

  // Watchlist Management
  List<SavedMediaItem> getWatchlistItems() {
    final watchlistJson = _prefs.getString(_watchlistKey);
    return SavedMediaItem.decodeList(watchlistJson);
  }

  Future<bool> saveWatchlistItems(List<SavedMediaItem> watchlist) async {
    final watchlistJson = SavedMediaItem.encodeList(watchlist);
    return _prefs.setString(_watchlistKey, watchlistJson);
  }

  Future<bool> upsertWatchlistItem(SavedMediaItem item) async {
    final watchlist = getWatchlistItems();
    final index = watchlist.indexWhere((element) => element.storageId == item.storageId);
    if (index >= 0) {
      watchlist[index] = item.copyWith(updatedAt: DateTime.now());
    } else {
      watchlist.add(item.copyWith(addedAt: DateTime.now(), updatedAt: DateTime.now()));
    }
    return saveWatchlistItems(watchlist);
  }

  Future<bool> removeFromWatchlist(int id, SavedMediaType type) async {
    final watchlist = getWatchlistItems();
    watchlist.removeWhere((item) => item.id == id && item.type == type);
    return saveWatchlistItems(watchlist);
  }

  bool isInWatchlist(int id, SavedMediaType type) {
    final watchlist = getWatchlistItems();
    return watchlist.any((item) => item.id == id && item.type == type);
  }

  Future<bool> clearWatchlist() async {
    return _prefs.remove(_watchlistKey);
  }

  bool getFavoritesSyncEnabled() {
    return _prefs.getBool(_favoritesSyncEnabledKey) ?? false;
  }

  Future<bool> setFavoritesSyncEnabled(bool value) {
    return _prefs.setBool(_favoritesSyncEnabledKey, value);
  }

  bool getWatchlistSyncEnabled() {
    return _prefs.getBool(_watchlistSyncEnabledKey) ?? false;
  }

  Future<bool> setWatchlistSyncEnabled(bool value) {
    return _prefs.setBool(_watchlistSyncEnabledKey, value);
  }

  DateTime? getFavoritesLastSyncedAt() {
    final raw = _prefs.getString(_favoritesLastSyncedKey);
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
    }

  Future<bool> setFavoritesLastSyncedAt(DateTime timestamp) {
    return _prefs.setString(_favoritesLastSyncedKey, timestamp.toIso8601String());
  }

  DateTime? getWatchlistLastSyncedAt() {
    final raw = _prefs.getString(_watchlistLastSyncedKey);
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  Future<bool> setWatchlistLastSyncedAt(DateTime timestamp) {
    return _prefs.setString(_watchlistLastSyncedKey, timestamp.toIso8601String());
  }

  String exportFavorites() {
    final favorites = getFavoriteItems();
    return SavedMediaItem.encodeList(favorites);
  }

  Future<bool> importFavorites(
    String exportJson, {
    bool replaceExisting = false,
  }) async {
    final decoded = SavedMediaItem.decodeList(exportJson);
    if (decoded.isEmpty) return false;

    if (replaceExisting) {
      return saveFavoriteItems(decoded);
    }

    final current = getFavoriteItems();
    final mergedIds = current.map((item) => item.storageId).toSet();
    final mergedItems = <SavedMediaItem>[...current];

    for (final item in decoded) {
      if (mergedIds.add(item.storageId)) {
        mergedItems.add(item);
      }
    }

    mergedItems.sort((a, b) => a.addedAt.compareTo(b.addedAt));

    if (mergedItems.length == current.length) {
      return false;
    }

    return saveFavoriteItems(mergedItems);
  }

  String exportWatchlist() {
    final watchlist = getWatchlistItems();
    return SavedMediaItem.encodeList(watchlist);
  }

  Future<bool> importWatchlist(String exportJson, {bool replaceExisting = false}) async {
    final decoded = SavedMediaItem.decodeList(exportJson);
    if (decoded.isEmpty) return false;

    if (replaceExisting) {
      return saveWatchlistItems(decoded);
    }

    final current = getWatchlistItems();
    final mergedIds = current.map((item) => item.storageId).toSet();
    final mergedItems = <SavedMediaItem>[...current];

    for (final item in decoded) {
      if (mergedIds.add(item.storageId)) {
        mergedItems.add(item);
      }
    }

    mergedItems.sort((a, b) => a.addedAt.compareTo(b.addedAt));

    if (mergedItems.length == current.length) {
      return false;
    }

    return saveWatchlistItems(mergedItems);
  }

  // Recently Viewed Management
  List<int> getRecentlyViewed({int limit = 20}) {
    final recentlyViewedJson = _prefs.getString(_recentlyViewedKey);
    if (recentlyViewedJson == null || recentlyViewedJson.isEmpty) return [];
    
    final List<dynamic> recentlyViewed = json.decode(recentlyViewedJson);
    final movieIds = recentlyViewed.whereType<int>().toList();
    return movieIds.take(limit).toList();
  }

  Future<bool> addToRecentlyViewed(int movieId) async {
    final recentlyViewed = getRecentlyViewed(limit: 100);
    recentlyViewed.remove(movieId); // Remove if exists
    recentlyViewed.insert(0, movieId); // Add to front
    
    final recentlyViewedJson = json.encode(recentlyViewed.take(20).toList());
    return await _prefs.setString(_recentlyViewedKey, recentlyViewedJson);
  }

  Future<bool> clearRecentlyViewed() async {
    return await _prefs.remove(_recentlyViewedKey);
  }

  // Search History Management
  List<String> getSearchHistory({int limit = 10}) {
    final searchHistoryJson = _prefs.getString(_searchHistoryKey);
    if (searchHistoryJson == null || searchHistoryJson.isEmpty) return [];
    
    final List<dynamic> searchHistory = json.decode(searchHistoryJson);
    final queries = searchHistory.whereType<String>().toList();
    return queries.take(limit).toList();
  }

  Future<bool> addToSearchHistory(String query) async {
    if (query.trim().isEmpty) return false;
    
    final searchHistory = getSearchHistory(limit: 50);
    searchHistory.remove(query); // Remove if exists
    searchHistory.insert(0, query); // Add to front
    
    final searchHistoryJson = json.encode(searchHistory.take(10).toList());
    return await _prefs.setString(_searchHistoryKey, searchHistoryJson);
  }

  Future<bool> removeFromSearchHistory(String query) async {
    final searchHistory = getSearchHistory(limit: 50);
    searchHistory.remove(query);
    
    final searchHistoryJson = json.encode(searchHistory);
    return await _prefs.setString(_searchHistoryKey, searchHistoryJson);
  }

  Future<bool> clearSearchHistory() async {
    return await _prefs.remove(_searchHistoryKey);
  }

  // Clear all data
  Future<bool> clearAllData() async {
    await _prefs.remove(_favoritesKey);
    await _prefs.remove(_watchlistKey);
    await _prefs.remove(_recentlyViewedKey);
    await _prefs.remove(_searchHistoryKey);
    return true;
  }
}
