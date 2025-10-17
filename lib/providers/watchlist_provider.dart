import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WatchlistProvider with ChangeNotifier {
  static const String _watchlistKey = 'watchlist';
  final SharedPreferences _prefs;
  
  Set<int> _watchlist = {};

  WatchlistProvider(this._prefs) {
    _loadWatchlist();
  }

  Set<int> get watchlist => _watchlist;
  
  bool isInWatchlist(int id) => _watchlist.contains(id);
  
  int get count => _watchlist.length;

  void _loadWatchlist() {
    final List<String> stored = _prefs.getStringList(_watchlistKey) ?? [];
    _watchlist = stored.map((e) => int.parse(e)).toSet();
    notifyListeners();
  }

  Future<void> toggleWatchlist(int id) async {
    if (_watchlist.contains(id)) {
      _watchlist.remove(id);
    } else {
      _watchlist.add(id);
    }
    
    await _saveWatchlist();
    notifyListeners();
  }

  Future<void> addToWatchlist(int id) async {
    if (!_watchlist.contains(id)) {
      _watchlist.add(id);
      await _saveWatchlist();
      notifyListeners();
    }
  }

  Future<void> removeFromWatchlist(int id) async {
    if (_watchlist.contains(id)) {
      _watchlist.remove(id);
      await _saveWatchlist();
      notifyListeners();
    }
  }

  Future<void> clearWatchlist() async {
    _watchlist.clear();
    await _saveWatchlist();
    notifyListeners();
  }

  Future<void> _saveWatchlist() async {
    final List<String> toStore = _watchlist.map((e) => e.toString()).toList();
    await _prefs.setStringList(_watchlistKey, toStore);
  }
}
