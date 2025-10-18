import 'dart:async';

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../core/analytics/app_analytics.dart';
import '../data/models/company_model.dart';
import '../data/models/movie.dart';
import '../data/models/paginated_response.dart';
import '../data/models/person_model.dart';
import '../data/models/search_result_model.dart';
import '../data/services/local_storage_service.dart';
import '../data/tmdb_repository.dart';

class SearchProvider with ChangeNotifier {
  SearchProvider(
    this._repository,
    this._storage, {
    AppAnalytics? analytics,
  })  : _analytics = analytics {
    _initializePagingControllers();
    _loadSearchHistory();
    _loadTrendingSearches();
  }

  final TmdbRepository _repository;
  final LocalStorageService _storage;
  final AppAnalytics? _analytics;

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
  Timer? _searchDebounce;

  late final Map<MediaType, PagingController<int, SearchResult>>
      _mediaPagingControllers;
  late final PagingController<int, Company> _companyPagingController;
  final Set<MediaType> _pendingForceRefreshMedia = <MediaType>{};
  bool _pendingForceRefreshCompanies = false;

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
  bool get hasResults => results.isNotEmpty || _companyResults.isNotEmpty;
  bool get hasCompanyResults => _companyResults.isNotEmpty;
  bool get canLoadMore => _currentPage < _totalPages;
  bool get canLoadMoreCompanies => _companyCurrentPage < _companyTotalPages;
  /// Indicates whether the autocomplete panel should be visible.
  ///
  /// The panel becomes active whenever the user is typing a query that does
  /// not match the last committed search. This mirrors the behaviour of a
  /// traditional "type-ahead" field, allowing us to fetch suggestions from the
  /// TMDB APIs before the user confirms their final query.
  bool get shouldShowSuggestions {
    final trimmedInput = _inputQuery.trim();
    if (trimmedInput.isEmpty) {
      return false;
    }

    final committedQuery = _query.trim();
    return trimmedInput.toLowerCase() != committedQuery.toLowerCase();
  }
  PagingController<int, SearchResult> mediaPagingController(MediaType type) =>
      _mediaPagingControllers[type]!;
  PagingController<int, Company> get companyPagingController =>
      _companyPagingController;

  /// Returns up to [limit] cached search results for the provided [mediaType].
  ///
  /// These results come from the first page returned by TMDB's
  /// `GET /3/search/{media_type}` endpoints, which are cached in
  /// [_groupedResults] after every multi-search invocation. The method is used
  /// by the multi-search overview UI to render lightweight previews without
  /// incurring any additional network traffic.
  List<SearchResult> previewResults(
    MediaType mediaType, {
    int limit = 6,
  }) {
    final resultsForType = _groupedResults[mediaType] ?? const <SearchResult>[];
    if (resultsForType.length <= limit) {
      return resultsForType;
    }
    return resultsForType.take(limit).toList(growable: false);
  }

  void _initializePagingControllers() {
    _mediaPagingControllers = {
      for (final type in MediaType.values)
        type: PagingController<int, SearchResult>(firstPageKey: 1),
    };
    for (final entry in _mediaPagingControllers.entries) {
      entry.value.addPageRequestListener(
        (pageKey) => unawaited(_fetchPagedMedia(entry.key, pageKey)),
      );
    }

    _companyPagingController = PagingController<int, Company>(firstPageKey: 1)
      ..addPageRequestListener(
        (pageKey) => unawaited(_fetchCompanyPage(pageKey)),
      );
  }

  void _refreshPagedControllers() {
    for (final controller in _mediaPagingControllers.values) {
      controller.refresh();
    }
    _companyPagingController.refresh();
  }

  void _loadSearchHistory() {
    _searchHistory = _storage.getSearchHistory();
    notifyListeners();
  }

  Future<void> _loadTrendingSearches() async {
    try {
      final response = await _repository.fetchTrendingTitles(page: 1);
      final seen = <String>{};
      _trendingSearches = response.results
          .map((movie) => movie.title.trim())
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
    _scheduleSearch(value);
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

  void _scheduleSearch(String rawQuery) {
    _searchDebounce?.cancel();
    final trimmed = rawQuery.trim();
    if (trimmed.isEmpty) {
      return;
    }

    // Only trigger a debounced search if it differs from the committed query
    if (trimmed.toLowerCase() == _query.toLowerCase()) {
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      unawaited(search(trimmed));
    });
  }

  /// Pulls up to ten autocomplete suggestions from TMDB.
  ///
  /// Endpoints:
  /// - `GET /3/search/multi`: returns mixed media matches with `results[].title`
  ///   / `results[].name` fields.
  /// - `GET /3/search/company`: returns company matches with
  ///   `results[].name` fields.
  ///
  /// These endpoints both respond with JSON payloads that look similar to:
  /// ```json
  /// {
  ///   "page": 1,
  ///   "results": [
  ///     { "title": "The Godfather", "media_type": "movie" }
  ///   ],
  ///   "total_pages": 1,
  ///   "total_results": 1
  /// }
  /// ```
  /// We flatten the returned names into a unique list to present in the
  /// autocomplete panel.
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

  Future<void> _fetchPagedMedia(MediaType type, int pageKey) async {
    final controller = _mediaPagingControllers[type]!;
    final trimmed = _query.trim();

    if (trimmed.isEmpty) {
      controller.appendLastPage(const []);
      return;
    }

    final shouldForceRefresh = _pendingForceRefreshMedia.remove(type);

    try {
      switch (type) {
        case MediaType.movie:
          final response = await _repository.searchMovies(
            trimmed,
            page: pageKey,
            forceRefresh: shouldForceRefresh,
          );
          final items = response.results
              .map((movie) => _mapMovieToSearchResult(movie, MediaType.movie))
              .toList(growable: false);
          final isLastPage = pageKey >= response.totalPages;
          if (isLastPage) {
            controller.appendLastPage(items);
          } else {
            controller.appendPage(items, pageKey + 1);
          }
          break;
        case MediaType.tv:
          final response = await _repository.searchTvSeries(
            trimmed,
            page: pageKey,
            forceRefresh: shouldForceRefresh,
          );
          final items = response.results
              .map((tv) => _mapMovieToSearchResult(tv, MediaType.tv))
              .toList(growable: false);
          final isLastPage = pageKey >= response.totalPages;
          if (isLastPage) {
            controller.appendLastPage(items);
          } else {
            controller.appendPage(items, pageKey + 1);
          }
          break;
        case MediaType.person:
          final response = await _repository.searchPeople(
            trimmed,
            page: pageKey,
            forceRefresh: shouldForceRefresh,
          );
          final items = response.results
              .map(_mapPersonToSearchResult)
              .toList(growable: false);
          final isLastPage = pageKey >= response.totalPages;
          if (isLastPage) {
            controller.appendLastPage(items);
          } else {
            controller.appendPage(items, pageKey + 1);
          }
          break;
      }
    } catch (error) {
      controller.error = error;
    }
  }

  Future<void> _fetchCompanyPage(int pageKey) async {
    final trimmed = _query.trim();

    if (trimmed.isEmpty) {
      _companyPagingController.appendLastPage(const []);
      return;
    }

    final shouldForceRefresh = _pendingForceRefreshCompanies;
    if (shouldForceRefresh) {
      _pendingForceRefreshCompanies = false;
    }

    try {
      final response = await _repository.fetchCompanies(
        query: trimmed,
        page: pageKey,
        forceRefresh: shouldForceRefresh,
      );
      final isLastPage = pageKey >= response.totalPages;
      if (isLastPage) {
        _companyPagingController.appendLastPage(response.results);
      } else {
        _companyPagingController.appendPage(response.results, pageKey + 1);
      }
    } catch (error) {
      _companyPagingController.error = error;
    }
  }

  SearchResult _mapMovieToSearchResult(Movie movie, MediaType type) {
    return SearchResult(
      id: movie.id,
      mediaType: type,
      title: type == MediaType.movie ? movie.title : movie.originalTitle,
      name: type == MediaType.tv ? movie.title : movie.originalTitle,
      overview: movie.overview,
      posterPath: movie.posterPath,
      backdropPath: movie.backdropPath,
      voteAverage: movie.voteAverage,
      voteCount: movie.voteCount,
      popularity: movie.popularity,
      releaseDate: type == MediaType.movie ? movie.releaseDate : null,
      firstAirDate: type == MediaType.tv ? movie.releaseDate : null,
      originalTitle: movie.originalTitle,
      originalName: movie.originalTitle,
    );
  }

  SearchResult _mapPersonToSearchResult(Person person) {
    return SearchResult(
      id: person.id,
      mediaType: MediaType.person,
      name: person.name,
      overview: person.biography,
      profilePath: person.profilePath,
      popularity: person.popularity,
    );
  }

  Future<void> search(
    String searchQuery, {
    bool forceRefresh = true,
    String origin = 'manual',
  }) async {
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

    _pendingForceRefreshMedia.clear();
    _pendingForceRefreshCompanies = false;
    if (forceRefresh) {
      _pendingForceRefreshMedia.addAll(MediaType.values);
      _pendingForceRefreshCompanies = true;
    }
    _refreshPagedControllers();

    try {
      final results = await Future.wait([
        _repository.searchMulti(
          trimmed,
          page: 1,
          forceRefresh: forceRefresh,
        ),
        _repository.fetchCompanies(
          query: trimmed,
          page: 1,
          forceRefresh: forceRefresh,
        ),
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
      await _analytics?.logSearch(
        query: trimmed,
        origin: origin,
        resultCount: response.totalResults,
      );
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
      await _analytics?.logSearchError(
        query: trimmed,
        origin: origin,
        error: '$error',
      );
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
    if (_isLoadingMoreCompanies ||
        !canLoadMoreCompanies ||
        _query.trim().isEmpty) {
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
    await search(
      query,
      forceRefresh: true,
      origin: 'history',
    );
  }

  Future<void> reexecuteLastSearch({bool forceRefresh = false}) async {
    final trimmed = _query.trim();
    if (trimmed.isEmpty) {
      return;
    }
    await search(
      trimmed,
      forceRefresh: forceRefresh,
      origin: 'retry',
    );
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
    _pendingForceRefreshMedia.clear();
    _pendingForceRefreshCompanies = false;
    _refreshPagedControllers();
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
      grouped[result.mediaType] = [...grouped[result.mediaType]!, result];
    }

    return grouped;
  }

  @override
  void dispose() {
    _suggestionsDebounce?.cancel();
    _searchDebounce?.cancel();
    for (final controller in _mediaPagingControllers.values) {
      controller.dispose();
    }
    _companyPagingController.dispose();
    super.dispose();
  }
}
