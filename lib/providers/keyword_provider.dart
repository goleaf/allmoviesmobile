import 'package:flutter/foundation.dart';

import '../data/models/keyword_model.dart';
import '../data/models/movie.dart';
import '../data/models/paginated_response.dart';
import '../data/tmdb_repository.dart';
import 'paginated_resource_provider.dart';

class KeywordDetailsProvider extends ChangeNotifier {
  KeywordDetailsProvider(
    this._repository, {
    required this.keywordId,
    String? initialName,
  })  : _initialName = initialName,
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

  KeywordDetails? get details => _details;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get keywordName =>
      _details?.name ?? _initialName ?? 'Keyword #$keywordId';

  Future<void> fetchDetails({bool forceRefresh = false}) async {
    if (_isLoading && !forceRefresh) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final fetched =
          await _repository.fetchKeywordDetails(keywordId, forceRefresh: forceRefresh);
      _details = fetched;
      _errorMessage = null;
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

abstract class BaseKeywordMediaProvider extends PaginatedResourceProvider<Movie> {
  BaseKeywordMediaProvider(
    this.repository, {
    required this.keywordId,
    String initialSort = 'popularity.desc',
    bool includeAdult = false,
  })  : _sortBy = initialSort,
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
  Future<PaginatedResponse<Movie>> loadPage(int page, {bool forceRefresh = false}) {
    return fetchPage(
      page: page,
      sortBy: _sortBy,
      forceRefresh: forceRefresh,
    );
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
  }) : super(
          repository,
          keywordId: keywordId,
          initialSort: initialSort,
        ) {
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
