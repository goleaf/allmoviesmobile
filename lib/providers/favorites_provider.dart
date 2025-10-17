import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesProvider with ChangeNotifier {
  static const String _favoritesKey = 'favorites';
  final SharedPreferences _prefs;
  
  Set<int> _favorites = {};

  FavoritesProvider(this._prefs) {
    _loadFavorites();
  }

  Set<int> get favorites => _favorites;
  
  bool isFavorite(int id) => _favorites.contains(id);
  
  int get count => _favorites.length;

  void _loadFavorites() {
    final List<String> stored = _prefs.getStringList(_favoritesKey) ?? [];
    _favorites = stored.map((e) => int.parse(e)).toSet();
    notifyListeners();
  }

  Future<void> toggleFavorite(int id) async {
    if (_favorites.contains(id)) {
      _favorites.remove(id);
    } else {
      _favorites.add(id);
    }
    
    await _saveFavorites();
    notifyListeners();
  }

  Future<void> addFavorite(int id) async {
    if (!_favorites.contains(id)) {
      _favorites.add(id);
      await _saveFavorites();
      notifyListeners();
    }
  }

  Future<void> removeFavorite(int id) async {
    if (_favorites.contains(id)) {
      _favorites.remove(id);
      await _saveFavorites();
      notifyListeners();
    }
  }

  Future<void> clearFavorites() async {
    _favorites.clear();
    await _saveFavorites();
    notifyListeners();
  }

  Future<void> _saveFavorites() async {
    final List<String> toStore = _favorites.map((e) => e.toString()).toList();
    await _prefs.setStringList(_favoritesKey, toStore);
  }
}
