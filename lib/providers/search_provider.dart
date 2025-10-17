import 'package:flutter/material.dart';
import '../data/models/movie.dart';
import '../data/services/local_storage_service.dart';
import '../data/tmdb_repository.dart';

class SearchProvider with ChangeNotifier {
  final TmdbRepository _repository;
  final LocalStorageService _storage;

  SearchProvider(this._repository, this._storage) {
    _loadSearchHistory();
  }

  String _query = '';
  List<Movie> _results = [];
  List<String> _searchHistory = [];
  bool _isLoading = false;
  String? _errorMessage;

  String get query => _query;
  List<Movie> get results => _results;
  List<String> get searchHistory => _searchHistory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasQuery => _query.trim().isNotEmpty;
  bool get hasResults => _results.isNotEmpty;

  void _loadSearchHistory() {
    _searchHistory = _storage.getSearchHistory();
    notifyListeners();
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  Future<void> search(String searchQuery) async {
    if (searchQuery.trim().isEmpty) {
      clearResults();
      return;
    }

    _query = searchQuery;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _results = await _repository.searchMulti(searchQuery);
      
      // Save to search history
      await _storage.addToSearchHistory(searchQuery);
      _searchHistory = _storage.getSearchHistory();
    } catch (error) {
      _errorMessage = 'Failed to search: $error';
      _results = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchFromHistory(String query) async {
    await search(query);
  }

  Future<void> removeFromHistory(String query) async {
    await _storage.removeFromSearchHistory(query);
    _searchHistory = _storage.getSearchHistory();
    notifyListeners();
  }

  Future<void> clearHistory() async {
    await _storage.clearSearchHistory();
    _searchHistory = [];
    notifyListeners();
  }

  void clearResults() {
    _results = [];
    _query = '';
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

