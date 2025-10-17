import 'package:flutter/foundation.dart';

import '../data/models/collection_model.dart';
import '../data/models/company_model.dart';
import '../data/models/keyword_model.dart';
import '../data/models/movie.dart';
import '../data/models/paginated_response.dart';
import '../data/models/person_model.dart';
import '../data/models/search_filters.dart';
import '../data/tmdb_repository.dart';

abstract class PaginatedSearchProvider<T> extends ChangeNotifier {
  final List<T> _results = [];
  String _query = '';
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasSearched = false;
  String? _errorMessage;
  int _currentPage = 0;
  int _totalPages = 1;

  List<T> get results => List.unmodifiable(_results);
  String get query => _query;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasResults => _results.isNotEmpty;
  bool get hasSearched => _hasSearched;
  bool get canLoadMore => _currentPage < _totalPages;
  String? get errorMessage => _errorMessage;

  @protected
  Future<PaginatedResponse<T>> performSearch(
    String query,
    int page, {
    bool forceRefresh = false,
  });

  Future<void> search(String searchQuery, {bool forceRefresh = false}) async {
    final trimmed = searchQuery.trim();
    if (trimmed.isEmpty) {
      clear();
      return;
    }

    if (_isLoading && !forceRefresh && trimmed == _query) {
      return;
    }

    _isLoading = true;
    _isLoadingMore = false;
    _errorMessage = null;
    _hasSearched = true;
    _query = trimmed;
    notifyListeners();

    try {
      final response = await performSearch(
        trimmed,
        1,
        forceRefresh: forceRefresh,
      );
      _results
        ..clear()
        ..addAll(response.results);
      _currentPage = response.page;
      _totalPages = response.totalPages;
    } catch (error) {
      _results.clear();
      _currentPage = 0;
      _totalPages = 1;
      _errorMessage = 'Failed to search: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingMore ||
        !_hasSearched ||
        !canLoadMore ||
        _query.trim().isEmpty) {
      return;
    }

    _isLoadingMore = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final response = await performSearch(_query, nextPage);
      _results.addAll(response.results);
      _currentPage = response.page;
      _totalPages = response.totalPages;
    } catch (error) {
      _errorMessage = 'Failed to load more: $error';
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  void clear() {
    _results.clear();
    _query = '';
    _isLoading = false;
    _isLoadingMore = false;
    _hasSearched = false;
    _errorMessage = null;
    _currentPage = 0;
    _totalPages = 1;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }
}

class MovieSearchProvider extends PaginatedSearchProvider<Movie> {
  MovieSearchProvider(this._repository);

  final TmdbRepository _repository;
  MovieSearchFilters _filters = const MovieSearchFilters();

  MovieSearchFilters get filters => _filters;

  void updateFilters(MovieSearchFilters filters, {bool triggerSearch = true}) {
    _filters = filters;
    if (query.isNotEmpty && triggerSearch) {
      search(query, forceRefresh: true);
    } else {
      notifyListeners();
    }
  }

  @override
  Future<PaginatedResponse<Movie>> performSearch(
    String query,
    int page, {
    bool forceRefresh = false,
  }) {
    return _repository.searchMovies(
      query,
      filters: _filters,
      page: page,
      forceRefresh: forceRefresh,
    );
  }
}

class TvSearchProvider extends PaginatedSearchProvider<Movie> {
  TvSearchProvider(this._repository);

  final TmdbRepository _repository;
  TvSearchFilters _filters = const TvSearchFilters();

  TvSearchFilters get filters => _filters;

  void updateFilters(TvSearchFilters filters, {bool triggerSearch = true}) {
    _filters = filters;
    if (query.isNotEmpty && triggerSearch) {
      search(query, forceRefresh: true);
    } else {
      notifyListeners();
    }
  }

  @override
  Future<PaginatedResponse<Movie>> performSearch(
    String query,
    int page, {
    bool forceRefresh = false,
  }) {
    return _repository.searchTvSeries(
      query,
      filters: _filters,
      page: page,
      forceRefresh: forceRefresh,
    );
  }
}

class PersonSearchProvider extends PaginatedSearchProvider<Person> {
  PersonSearchProvider(this._repository);

  final TmdbRepository _repository;

  @override
  Future<PaginatedResponse<Person>> performSearch(
    String query,
    int page, {
    bool forceRefresh = false,
  }) {
    return _repository.searchPeople(
      query,
      page: page,
      forceRefresh: forceRefresh,
    );
  }
}

class CompanySearchProvider extends PaginatedSearchProvider<Company> {
  CompanySearchProvider(this._repository);

  final TmdbRepository _repository;

  @override
  Future<PaginatedResponse<Company>> performSearch(
    String query,
    int page, {
    bool forceRefresh = false,
  }) {
    return _repository.fetchCompanies(
      query: query,
      page: page,
      forceRefresh: forceRefresh,
    );
  }
}

class KeywordSearchProvider extends PaginatedSearchProvider<Keyword> {
  KeywordSearchProvider(this._repository);

  final TmdbRepository _repository;

  @override
  Future<PaginatedResponse<Keyword>> performSearch(
    String query,
    int page, {
    bool forceRefresh = false,
  }) {
    return _repository.searchKeywords(
      query,
      page: page,
      forceRefresh: forceRefresh,
    );
  }
}

class CollectionSearchProvider extends PaginatedSearchProvider<Collection> {
  CollectionSearchProvider(this._repository);

  final TmdbRepository _repository;

  @override
  Future<PaginatedResponse<Collection>> performSearch(
    String query,
    int page, {
    bool forceRefresh = false,
  }) {
    return _repository.searchCollections(
      query,
      page: page,
      forceRefresh: forceRefresh,
    );
  }
}
