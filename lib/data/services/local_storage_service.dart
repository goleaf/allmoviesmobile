import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _favoritesKey = 'allmovies_favorites';
  static const String _watchlistKey = 'allmovies_watchlist';
  static const String _recentlyViewedKey = 'allmovies_recently_viewed';
  static const String _searchHistoryKey = 'allmovies_search_history';

  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  // Favorites Management
  Set<int> getFavorites() {
    final favoritesJson = _prefs.getString(_favoritesKey);
    if (favoritesJson == null || favoritesJson.isEmpty) return {};
    
    final List<dynamic> favoritesList = json.decode(favoritesJson);
    return favoritesList.whereType<int>().toSet();
  }

  Future<bool> saveFavorites(Set<int> favorites) async {
    final favoritesJson = json.encode(favorites.toList());
    return await _prefs.setString(_favoritesKey, favoritesJson);
  }

  Future<bool> addToFavorites(int movieId) async {
    final favorites = getFavorites();
    favorites.add(movieId);
    return await saveFavorites(favorites);
  }

  Future<bool> removeFromFavorites(int movieId) async {
    final favorites = getFavorites();
    favorites.remove(movieId);
    return await saveFavorites(favorites);
  }

  bool isFavorite(int movieId) {
    return getFavorites().contains(movieId);
  }

  // Watchlist Management
  Set<int> getWatchlist() {
    final watchlistJson = _prefs.getString(_watchlistKey);
    if (watchlistJson == null || watchlistJson.isEmpty) return {};
    
    final List<dynamic> watchlist = json.decode(watchlistJson);
    return watchlist.whereType<int>().toSet();
  }

  Future<bool> saveWatchlist(Set<int> watchlist) async {
    final watchlistJson = json.encode(watchlist.toList());
    return await _prefs.setString(_watchlistKey, watchlistJson);
  }

  Future<bool> addToWatchlist(int movieId) async {
    final watchlist = getWatchlist();
    watchlist.add(movieId);
    return await saveWatchlist(watchlist);
  }

  Future<bool> removeFromWatchlist(int movieId) async {
    final watchlist = getWatchlist();
    watchlist.remove(movieId);
    return await saveWatchlist(watchlist);
  }

  bool isInWatchlist(int movieId) {
    return getWatchlist().contains(movieId);
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

