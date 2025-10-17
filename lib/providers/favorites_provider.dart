import 'package:flutter/material.dart';
import '../data/services/local_storage_service.dart';

class FavoritesProvider with ChangeNotifier {
  final LocalStorageService _storage;
  
  Set<int> _favorites = {};

  FavoritesProvider(this._storage) {
    _loadFavorites();
  }

  Set<int> get favorites => _favorites;
  
  bool isFavorite(int id) => _favorites.contains(id);
  
  int get count => _favorites.length;

  void _loadFavorites() {
    _favorites = _storage.getFavorites();
    notifyListeners();
  }

  Future<void> toggleFavorite(int id) async {
    if (_favorites.contains(id)) {
      await _storage.removeFromFavorites(id);
      _favorites.remove(id);
    } else {
      await _storage.addToFavorites(id);
      _favorites.add(id);
    }
    
    notifyListeners();
  }

  Future<void> addFavorite(int id) async {
    if (!_favorites.contains(id)) {
      await _storage.addToFavorites(id);
      _favorites.add(id);
      notifyListeners();
    }
  }

  Future<void> removeFavorite(int id) async {
    if (_favorites.contains(id)) {
      await _storage.removeFromFavorites(id);
      _favorites.remove(id);
      notifyListeners();
    }
  }

  Future<void> clearFavorites() async {
    await _storage.saveFavorites({});
    _favorites.clear();
    notifyListeners();
  }
}
