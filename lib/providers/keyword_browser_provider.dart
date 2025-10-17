import 'package:flutter/foundation.dart';

import '../data/models/keyword_model.dart';
import '../data/tmdb_repository.dart';

class KeywordBrowserProvider extends ChangeNotifier {
  KeywordBrowserProvider(this._repository);

  final TmdbRepository _repository;

  List<Keyword> _trendingKeywords = const [];
  List<Keyword> get trendingKeywords => _trendingKeywords;

  bool _isLoadingTrending = false;
  bool get isLoadingTrending => _isLoadingTrending;

  String? _trendingError;
  String? get trendingError => _trendingError;

  final List<Keyword> _searchResults = [];
  List<Keyword> get searchResults => List.unmodifiable(_searchResults);

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  String? _searchError;
  String? get searchError => _searchError;

  int _currentPage = 0;
  int _totalPages = 1;
  String _query = '';

  String get query => _query;
  bool get hasQuery => _query.isNotEmpty;
  bool get hasTrendingKeywords => _trendingKeywords.isNotEmpty;
  bool get hasSearchResults => _searchResults.isNotEmpty;
  bool get canLoadMore => _currentPage < _totalPages;

  Future<void> loadTrendingKeywords({bool forceRefresh = false}) async {
    if (_isLoadingTrending) {
      return;
    }

    if (_trendingKeywords.isNotEmpty && !forceRefresh) {
      return;
    }

    _isLoadingTrending = true;
    _trendingError = null;
    notifyListeners();

    try {
      final keywords = await _repository.fetchTrendingKeywords(
        forceRefresh: forceRefresh,
      );
      _trendingKeywords = keywords.results;
    } catch (error) {
      _trendingError = 'Failed to load trending keywords: $error';
      _trendingKeywords = const [];
    } finally {
      _isLoadingTrending = false;
      notifyListeners();
    }
  }

  Future<void> refreshTrendingKeywords() {
    return loadTrendingKeywords(forceRefresh: true);
  }

  Future<void> search(String query, {bool forceRefresh = false}) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      clearSearch();
      return;
    }

    _isSearching = true;
    _searchError = null;
    notifyListeners();

    try {
      final response = await _repository.searchKeywords(
        trimmed,
        page: 1,
        forceRefresh: forceRefresh,
      );

      _query = trimmed;
      _searchResults
        ..clear()
        ..addAll(response.results);
      _currentPage = response.page;
      _totalPages = response.totalPages;
    } catch (error) {
      _searchError = 'Failed to search keywords: $error';
      _searchResults.clear();
      _currentPage = 0;
      _totalPages = 1;
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !canLoadMore || _query.isEmpty) {
      return;
    }

    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final response = await _repository.searchKeywords(
        _query,
        page: nextPage,
      );

      _searchResults.addAll(response.results);
      _currentPage = response.page;
      _totalPages = response.totalPages;
    } catch (error) {
      _searchError = 'Failed to load more keywords: $error';
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> refreshAll() async {
    await Future.wait([
      loadTrendingKeywords(forceRefresh: true),
      if (_query.isNotEmpty)
        search(
          _query,
          forceRefresh: true,
        ),
    ]);
  }

  void clearSearch() {
    _query = '';
    _searchResults.clear();
    _currentPage = 0;
    _totalPages = 1;
    _searchError = null;
    notifyListeners();
  }
}
