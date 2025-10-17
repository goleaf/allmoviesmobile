import 'dart:async';

import 'package:flutter/material.dart';

import '../data/models/company_model.dart';
import '../data/models/paginated_response.dart';
import '../data/models/search_result_model.dart';
import '../data/services/local_storage_service.dart';
import '../data/tmdb_repository.dart';

class SearchProvider with ChangeNotifier {
  SearchProvider(this._repository, this._storage) {
    _loadSearchHistory();
    _loadTrendingSearches();
  }

  final TmdbRepository _repository;
  final LocalStorageService _storage;

  String _query = '';
  String _inputQuery = '';
  SearchResponse _response = const SearchResponse();
  Map<MediaType, List<SearchResult>> _groupedResults = {
    for (final type in MediaType.values) type: <SearchResult>[],
  };
  List<Company> _companyResults = [];
  List<String> _searchHistory = [];
  List<String> _suggestions = [];
  List<String> _trendingSearches = [];
  bool _isLoading = false;
  bool _isFetchingSuggestions = false;
  bool _isLoadingMore = false;
  bool _isLoadingMoreCompanies = false;
  bool _isLoadingCompanies = false;
  String? _errorMessage;

  int _currentPage = 0;
  int _totalPages = 1;
  int _companyCurrentPage = 0;
  int _companyTotalPages = 1;

  Timer? _suggestionsDebounce;

  String get query => _query;
  String get inputQuery => _inputQuery;
  List<SearchResult> get results => _response.results;
  Map<MediaType, List<SearchResult>> get groupedResults => _groupedResults;
  List<Company> get companyResults => _companyResults;
  List<String> get searchHistory => _searchHistory;
  List<String> get suggestions => _suggestions;
  List<String> get trendingSearches => _trendingSearches;
  bool get isLoading => _isLoading;
  bool get isFetchingSuggestions => _isFetchingSuggestions;
  bool get isLoadingMore => _isLoadingMore;
  bool get isLoadingMoreCompanies => _isLoadingMoreCompanies;
  bool get isLoadingCompanies => _isLoadingCompanies;
  String? get errorMessage => _errorMessage;
  bool get hasQuery => _query.trim().isNotEmpty;
  bool get hasResults => results.isNotEmpty;
  bool get hasCompanyResults => _companyResults.isNotEmpty;
  bool get canLoadMore => _currentPage < _totalPages;
  bool get canLoadMoreCompanies => _companyCurrentPage < _companyTotalPages;

  void _loadSearchHistory() {
    _searchHistory = _storage.getSearchHistory();
    notifyListeners();
  }

  Future<void> _loadTrendingSearches() async {
    try {
      final response = await _repository.fetchTrendingTitles(page: 1);
      final seen = <String>{};
      _trendingSearches = response.results
          .map((movie) => (movie.title ?? movie.name ?? '').trim())
          .where((title) => title.isNotEmpty && seen.add(title))
          .take(10)
          .toList();
    } catch (_) {
      _trendingSearches = [];
    } finally {
      notifyListeners();
    }
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  void updateInputQuery(String value) {
    _inputQuery = value;
    _scheduleSuggestionsFetch(value);
    notifyListeners();
  }

  void _scheduleSuggestionsFetch(String rawQuery) {
    _suggestionsDebounce?.cancel();
    final trimmed = rawQuery.trim();
    if (trimmed.isEmpty) {
      _suggestions = [];
      _isFetchingSuggestions = false;
      notifyListeners();
      return;
    }

    _suggestionsDebounce = Timer(const Duration(milliseconds: 350), () {
      unawaited(_fetchSuggestions(trimmed));
    });
  }

  Future<void> _fetchSuggestions(String query) async {
    _isFetchingSuggestions = true;
    notifyListeners();

    try {
      final responses = await Future.wait([
        _repository.searchMulti(query, page: 1),
        _repository.fetchCompanies(query: query, page: 1),
      ]);

      final multi = responses[0] as SearchResponse;
      final companies = responses[1] as PaginatedResponse<Company>;

      final seen = <String>{};
      final combined = <String>[];

      for (final result in multi.results) {
        final label = (result.title ?? result.name ?? '').trim();
        if (label.isEmpty) continue;
        if (seen.add(label)) {
          combined.add(label);
        }
        if (combined.length >= 10) break;
      }

      if (combined.length < 10) {
        for (final company in companies.results) {
          final label = company.name.trim();
          if (label.isEmpty) continue;
          if (seen.add(label)) {
            combined.add(label);
          }
          if (combined.length >= 10) break;
        }
      }

      _suggestions = combined.take(10).toList();
    } catch (_) {
      _suggestions = [];
    } finally {
      _isFetchingSuggestions = false;
      notifyListeners();
    }
  }

  Future<void> search(String searchQuery) async {
    final trimmed = searchQuery.trim();
    if (trimmed.isEmpty) {
      clearResults();
      return;
    }

    _query = trimmed;
    _inputQuery = trimmed;
    _isLoading = true;
    _isLoadingCompanies = true;
    _errorMessage = null;
    _suggestions = [];
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.searchMulti(trimmed, page: 1, forceRefresh: true),
        _repository.fetchCompanies(query: trimmed, page: 1, forceRefresh: true),
      ]);

      final response = results[0] as SearchResponse;
      final companies = results[1] as PaginatedResponse<Company>;

      _response = response;
      _groupedResults = _groupResults(response.results);
      _currentPage = response.page;
      _totalPages = response.totalPages;

      _companyResults = companies.results;
      _companyCurrentPage = companies.page;
      _companyTotalPages = companies.totalPages;
      _isLoadingCompanies = false;

      await _storage.addToSearchHistory(trimmed);
      _searchHistory = _storage.getSearchHistory();
    } catch (error) {
      _errorMessage = 'Failed to search: $error';
      _response = const SearchResponse();
      _groupedResults = _groupResults(const []);
      _companyResults = [];
      _currentPage = 0;
      _totalPages = 1;
      _companyCurrentPage = 0;
      _companyTotalPages = 1;
      _isLoadingCompanies = false;
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
      _groupedResults = _groupResults(_response.results);
      _currentPage = response.page;
      _totalPages = response.totalPages;
    } catch (error) {
      _errorMessage = 'Failed to load more: $error';
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreCompanies() async {
    if (_isLoadingMoreCompanies || !canLoadMoreCompanies || _query.trim().isEmpty) {
      return;
    }

    _isLoadingMoreCompanies = true;
    notifyListeners();

    try {
      final nextPage = _companyCurrentPage + 1;
      final response = await _repository.fetchCompanies(
        query: _query,
        page: nextPage,
      );

      _companyResults = [..._companyResults, ...response.results];
      _companyCurrentPage = response.page;
      _companyTotalPages = response.totalPages;
    } catch (error) {
      _errorMessage = 'Failed to load more companies: $error';
    } finally {
      _isLoadingMoreCompanies = false;
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
    _response = const SearchResponse();
    _groupedResults = _groupResults(const []);
    _companyResults = [];
    _query = '';
    _inputQuery = '';
    _suggestions = [];
    _isLoadingCompanies = false;
    _companyCurrentPage = 0;
    _companyTotalPages = 1;
    _errorMessage = null;
    _currentPage = 0;
    _totalPages = 1;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearSuggestions() {
    _suggestions = [];
    notifyListeners();
  }

  Map<MediaType, List<SearchResult>> _groupResults(List<SearchResult> results) {
    final grouped = {
      for (final type in MediaType.values) type: <SearchResult>[],
    };

    for (final result in results) {
      grouped[result.mediaType] = [
        ...grouped[result.mediaType]!,
        result,
      ];
    }

    return grouped;
  }

  @override
  void dispose() {
    _suggestionsDebounce?.cancel();
    super.dispose();
  }
}
