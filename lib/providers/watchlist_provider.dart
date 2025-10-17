import 'package:flutter/material.dart';
import '../data/services/local_storage_service.dart';

class WatchlistProvider with ChangeNotifier {
  final LocalStorageService _storage;
  
  Set<int> _watchlist = {};

  WatchlistProvider(this._storage) {
    _loadWatchlist();
  }

  Set<int> get watchlist => _watchlist;
  
  bool isInWatchlist(int id) => _watchlist.contains(id);
  
  int get count => _watchlist.length;

  void _loadWatchlist() {
    _watchlist = _storage.getWatchlist();
    notifyListeners();
  }

  Future<void> toggleWatchlist(int id) async {
    if (_watchlist.contains(id)) {
      await _storage.removeFromWatchlist(id);
      _watchlist.remove(id);
    } else {
      await _storage.addToWatchlist(id);
      _watchlist.add(id);
    }
    
    notifyListeners();
  }

  Future<void> addToWatchlist(int id) async {
    if (!_watchlist.contains(id)) {
      await _storage.addToWatchlist(id);
      _watchlist.add(id);
      notifyListeners();
    }
  }

  Future<void> removeFromWatchlist(int id) async {
    if (_watchlist.contains(id)) {
      await _storage.removeFromWatchlist(id);
      _watchlist.remove(id);
      notifyListeners();
    }
  }

  Future<void> clearWatchlist() async {
    await _storage.saveWatchlist({});
    _watchlist.clear();
    notifyListeners();
  }
}
