import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/models/keyword_model.dart';
import '../data/models/movie.dart';
import '../data/models/paginated_response.dart';
import '../data/tmdb_repository.dart';
import 'paginated_resource_provider.dart';

/// Lightweight statistics snapshot describing how frequently a keyword is used
/// and how popular its associated titles are. The statistics are calculated in
/// the provider by combining `/discover/movie` and `/discover/tv` responses.
@immutable
class KeywordUsageStats {
  const KeywordUsageStats({
    required this.keywordId,
    required this.movieCount,
    required this.tvShowCount,
    required this.averageMoviePopularity,
    required this.averageTvPopularity,
  });

  /// Identifier of the keyword the statistics describe.
  final int keywordId;

  /// Total amount of movie titles tagged with the keyword according to the
  /// TMDB `/discover/movie` response.
  final int movieCount;

  /// Total amount of TV titles tagged with the keyword according to the
  /// TMDB `/discover/tv` response.
  final int tvShowCount;

  /// Average popularity score of the fetched movie sample.
  final double averageMoviePopularity;

  /// Average popularity score of the fetched TV sample.
  final double averageTvPopularity;

  /// Convenience getter returning the combined usage across movies and TV.
  int get totalUsageCount => movieCount + tvShowCount;
}

class KeywordDetailsProvider extends ChangeNotifier {
  KeywordDetailsProvider(
    this._repository, {
    required this.keywordId,
    String? initialName,
  }) : _initialName = initialName,
       _details = initialName != null
           ? KeywordDetails(id: keywordId, name: initialName)
           : null {
    fetchDetails();
  }

  final TmdbRepository _repository;
  final int keywordId;
  final String? _initialName;

  KeywordDetails? _details;
  bool _isLoading = false;
  String? _errorMessage;
  KeywordUsageStats? _statistics;
  bool _isLoadingStatistics = false;
  String? _statisticsError;
  final List<Keyword> _relatedKeywords = [];
  bool _isLoadingRelatedKeywords = false;
  String? _relatedKeywordsError;

  KeywordDetails? get details => _details;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  KeywordUsageStats? get statistics => _statistics;
  bool get isLoadingStatistics => _isLoadingStatistics;
  String? get statisticsError => _statisticsError;
  List<Keyword> get relatedKeywords => List.unmodifiable(_relatedKeywords);
  bool get isLoadingRelatedKeywords => _isLoadingRelatedKeywords;
  String? get relatedKeywordsError => _relatedKeywordsError;

  String get keywordName =>
      _details?.name ?? _initialName ?? 'Keyword #$keywordId';

  Future<void> fetchDetails({bool forceRefresh = false}) async {
    if (_isLoading && !forceRefresh) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final fetched = await _repository.fetchKeywordDetails(
        keywordId,
        forceRefresh: forceRefresh,
      );
      _details = fetched;
      _errorMessage = null;
    } catch (error) {
      _errorMessage = error.toString();
      _details = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    if (_errorMessage == null) {
      unawaited(loadStatistics(forceRefresh: forceRefresh));
      unawaited(loadRelatedKeywords(forceRefresh: forceRefresh));
    }
  }

  /// Fetches combined statistics from the movie and TV discover endpoints to
  /// show how widely the keyword is used across media types.
  Future<void> loadStatistics({bool forceRefresh = false}) async {
    if (_isLoadingStatistics) {
      return;
    }

    _isLoadingStatistics = true;
    notifyListeners();

    try {
      final moviesResponse = await _repository.fetchKeywordMovies(
        keywordId: keywordId,
        page: 1,
        sortBy: 'popularity.desc',
        forceRefresh: forceRefresh,
      );
      final tvResponse = await _repository.fetchKeywordTvShows(
        keywordId: keywordId,
        page: 1,
        sortBy: 'popularity.desc',
        forceRefresh: forceRefresh,
      );

      _statistics = KeywordUsageStats(
        keywordId: keywordId,
        movieCount: moviesResponse.totalResults,
        tvShowCount: tvResponse.totalResults,
        averageMoviePopularity: _averagePopularity(moviesResponse.results),
        averageTvPopularity: _averagePopularity(tvResponse.results),
      );
      _statisticsError = null;
    } catch (error) {
      _statisticsError = error.toString();
      _statistics = null;
    } finally {
      _isLoadingStatistics = false;
      notifyListeners();
    }
  }

  /// Searches for related keywords using TMDB's `/search/keyword` endpoint and
  /// surfaces quick suggestions so users can continue exploring.
  Future<void> loadRelatedKeywords({bool forceRefresh = false}) async {
    if (_isLoadingRelatedKeywords) {
      return;
    }

    final query = keywordName.trim();
    if (query.isEmpty) {
      _relatedKeywords
        ..clear();
      _relatedKeywordsError = null;
      notifyListeners();
      return;
    }

    _isLoadingRelatedKeywords = true;
    notifyListeners();

    try {
      final response = await _repository.searchKeywords(
        query,
        page: 1,
        forceRefresh: forceRefresh,
      );
      final seen = <int>{keywordId};
      _relatedKeywords
        ..clear()
        ..addAll(
          response.results.where((keyword) => seen.add(keyword.id)).take(12),
        );
      _relatedKeywordsError = null;
    } catch (error) {
      _relatedKeywordsError = error.toString();
      _relatedKeywords.clear();
    } finally {
      _isLoadingRelatedKeywords = false;
      notifyListeners();
    }
  }

  double _averagePopularity(List<Movie> items) {
    if (items.isEmpty) {
      return 0;
    }

    final values = items
        .map((item) => item.popularity ?? 0)
        .where((value) => value > 0)
        .toList(growable: false);
    if (values.isEmpty) {
      return 0;
    }

    final total = values.reduce((previous, element) => previous + element);
    return total / values.length;
  }
}

abstract class BaseKeywordMediaProvider
    extends PaginatedResourceProvider<Movie> {
  BaseKeywordMediaProvider(
    this.repository, {
    required this.keywordId,
    String initialSort = 'popularity.desc',
    bool includeAdult = false,
  }) : _sortBy = initialSort,
       _includeAdult = includeAdult;

  final TmdbRepository repository;
  final int keywordId;
  String _sortBy;
  final bool _includeAdult;

  String get sortBy => _sortBy;
  bool get includeAdult => _includeAdult;

  List<Movie> get media => items;
  bool get isLoading => isInitialLoading;
  bool get isLoadingMore => super.isLoadingMore;
  bool get canLoadMore => hasMore;

  Future<void> changeSort(String newSort) async {
    if (newSort == _sortBy) {
      return;
    }

    _sortBy = newSort;
    await loadInitial(forceRefresh: true);
  }

  Future<void> refreshMedia() => loadInitial(forceRefresh: true);
  Future<void> loadMoreMedia() => loadMore();

  @protected
  Future<PaginatedResponse<Movie>> fetchPage({
    required int page,
    required String sortBy,
    required bool forceRefresh,
  });

  @override
  Future<PaginatedResponse<Movie>> loadPage(
    int page, {
    bool forceRefresh = false,
  }) {
    return fetchPage(page: page, sortBy: _sortBy, forceRefresh: forceRefresh);
  }
}

class KeywordMoviesProvider extends BaseKeywordMediaProvider {
  KeywordMoviesProvider(
    TmdbRepository repository, {
    required int keywordId,
    String initialSort = 'popularity.desc',
    bool includeAdult = false,
  }) : super(
         repository,
         keywordId: keywordId,
         initialSort: initialSort,
         includeAdult: includeAdult,
       ) {
    loadInitial();
  }

  @override
  Future<PaginatedResponse<Movie>> fetchPage({
    required int page,
    required String sortBy,
    required bool forceRefresh,
  }) {
    return repository.fetchKeywordMovies(
      keywordId: keywordId,
      page: page,
      sortBy: sortBy,
      includeAdult: includeAdult,
      forceRefresh: forceRefresh,
    );
  }
}

class KeywordTvProvider extends BaseKeywordMediaProvider {
  KeywordTvProvider(
    TmdbRepository repository, {
    required int keywordId,
    String initialSort = 'popularity.desc',
  }) : super(repository, keywordId: keywordId, initialSort: initialSort) {
    loadInitial();
  }

  @override
  Future<PaginatedResponse<Movie>> fetchPage({
    required int page,
    required String sortBy,
    required bool forceRefresh,
  }) {
    return repository.fetchKeywordTvShows(
      keywordId: keywordId,
      page: page,
      sortBy: sortBy,
      forceRefresh: forceRefresh,
    );
  }
}
