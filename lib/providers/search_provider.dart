import 'package:flutter/material.dart';

import '../data/models/search_result_model.dart';
import '../data/services/local_storage_service.dart';
import '../data/tmdb_repository.dart';

class SearchProvider with ChangeNotifier {
  SearchProvider(this._repository, this._storage) {
    _loadSearchHistory();
  }

  final TmdbRepository _repository;
  final LocalStorageService _storage;

  String _query = '';
  SearchResponse _response = const SearchResponse();
  List<String> _searchHistory = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;

  int _currentPage = 0;
  int _totalPages = 1;

  String get query => _query;
  List<SearchResult> get results => _response.results;
  List<String> get searchHistory => _searchHistory;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  bool get hasQuery => _query.trim().isNotEmpty;
  bool get hasResults => results.isNotEmpty;
  bool get canLoadMore => _currentPage < _totalPages;

  void _loadSearchHistory() {
    _searchHistory = _storage.getSearchHistory();
    notifyListeners();
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  Future<void> search(String searchQuery) async {
    final trimmed = searchQuery.trim();
    if (trimmed.isEmpty) {
      clearResults();
      return;
    }

    _query = trimmed;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.searchMulti(trimmed, page: 1, forceRefresh: true);
      _response = response;
      _currentPage = response.page;
      _totalPages = response.totalPages;

      await _storage.addToSearchHistory(trimmed);
      _searchHistory = _storage.getSearchHistory();
    } catch (error) {
      _errorMessage = 'Failed to search: $error';
      _response = const SearchResponse();
      _currentPage = 0;
      _totalPages = 1;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !canLoadMore || _query.trim().isEmpty) {
      return;
    }

    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final response = await _repository.searchMulti(_query, page: nextPage);
      _response = _response.copyWith(
        page: response.page,
        results: [..._response.results, ...response.results],
        totalPages: response.totalPages,
        totalResults: response.totalResults,
      );
      _currentPage = response.page;
      _totalPages = response.totalPages;
    } catch (error) {
      _errorMessage = 'Failed to load more: $error';
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> searchFromHistory(String query) async {
    await search(query);
  }

  Future<void> recordQuery(String searchQuery) async {
    final trimmed = searchQuery.trim();
    if (trimmed.isEmpty) {
      return;
    }

    _query = trimmed;
    await _storage.addToSearchHistory(trimmed);
    _searchHistory = _storage.getSearchHistory();
    notifyListeners();
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
    _response = const SearchResponse();
    _query = '';
    _errorMessage = null;
    _currentPage = 0;
    _totalPages = 1;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
