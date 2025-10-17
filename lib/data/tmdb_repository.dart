import 'package:http/http.dart' as http;

import 'models/account_model.dart';
import 'models/company_model.dart';
import 'models/movie.dart';
import 'models/movie_detailed_model.dart';
import 'models/paginated_response.dart';
import 'models/person_model.dart';
import 'models/search_result_model.dart';
import 'models/tmdb_list_model.dart';
import 'models/tv_detailed_model.dart';
import 'services/cache_service.dart';
import 'services/tmdb_api_service.dart';

class TmdbRepository {
  TmdbRepository({
    http.Client? client,
    CacheService? cacheService,
    TmdbApiService? apiService,
    String? apiKey,
  })  : _apiKey = apiKey ?? const String.fromEnvironment('TMDB_API_KEY', defaultValue: ''),
        _cache = cacheService ?? CacheService(),
        _apiService = apiService ??
            TmdbApiService(
              client: client,
              apiKey: apiKey ?? const String.fromEnvironment('TMDB_API_KEY', defaultValue: ''),
            );

  final String _apiKey;
  final CacheService _cache;
  final TmdbApiService _apiService;

  void _checkApiKey() {
    if (_apiKey.isEmpty) {
      throw const TmdbException('TMDB API key is not configured.');
    }
  }

  Future<PaginatedResponse<Movie>> fetchTrendingTitles({
    int page = 1,
    bool forceRefresh = false,
    String mediaType = 'all',
    String timeWindow = 'week',
  }) async {
    _checkApiKey();

    final cacheKey = 'trending-$mediaType-$timeWindow-$page';
    if (!forceRefresh) {
      final cached = _cache.get<PaginatedResponse<Movie>>(cacheKey);
      if (cached != null) {
        return cached;
      }
    }

    final payload = await _apiService.fetchTrending(
      mediaType: mediaType,
      timeWindow: timeWindow,
      page: page,
    );

    final response = PaginatedResponse<Movie>.fromJson(
      payload,
      Movie.fromJson,
    );

    _cache.set(cacheKey, response, ttlSeconds: CacheService.trendingTTL);
    return response;
  }

  Future<PaginatedResponse<Movie>> fetchMovieCategory({
    String category = 'popular',
    int page = 1,
    bool forceRefresh = false,
  }) async {
    _checkApiKey();

    final cacheKey = 'movies-$category-$page';
    if (!forceRefresh) {
      final cached = _cache.get<PaginatedResponse<Movie>>(cacheKey);
      if (cached != null) {
        return cached;
      }
    }

    final payload = await _apiService.fetchMovieCategory(
      category,
      page: page,
    );

    final response = PaginatedResponse<Movie>.fromJson(
      payload,
      Movie.fromJson,
    );

    _cache.set(cacheKey, response);
    return response;
  }

  Future<PaginatedResponse<Movie>> fetchTvCategory({
    String category = 'popular',
    int page = 1,
    bool forceRefresh = false,
  }) async {
    _checkApiKey();

    final cacheKey = 'tv-$category-$page';
    if (!forceRefresh) {
      final cached = _cache.get<PaginatedResponse<Movie>>(cacheKey);
      if (cached != null) {
        return cached;
      }
    }

    final payload = await _apiService.fetchTvCategory(
      category,
      page: page,
    );

    final response = PaginatedResponse<Movie>.fromJson(
      payload,
      Movie.fromJson,
    );

    _cache.set(cacheKey, response);
    return response;
  }

  Future<MovieDetailed> fetchMovieDetails(int movieId, {bool forceRefresh = false}) async {
    _checkApiKey();

    final cacheKey = 'movie-details-$movieId';
    if (!forceRefresh) {
      final cached = _cache.get<MovieDetailed>(cacheKey);
      if (cached != null) {
        return cached;
      }
    }

    final payload = await _apiService.fetchMovieDetails(
      movieId,
      queryParameters: const {
        'append_to_response':
            'videos,images,credits,recommendations,similar,external_ids',
      },
    );

    final normalized = _normalizeDetailPayload(payload);
    final movie = MovieDetailed.fromJson(normalized);
    _cache.set(cacheKey, movie, ttlSeconds: CacheService.movieDetailsTTL);
    return movie;
  }

  Future<TVDetailed> fetchTvDetails(int tvId, {bool forceRefresh = false}) async {
    _checkApiKey();

    final cacheKey = 'tv-details-$tvId';
    if (!forceRefresh) {
      final cached = _cache.get<TVDetailed>(cacheKey);
      if (cached != null) {
        return cached;
      }
    }

    final payload = await _apiService.fetchTvDetails(
      tvId,
      queryParameters: const {
        'append_to_response':
            'videos,images,credits,recommendations,similar,external_ids',
      },
    );

    final normalized = _normalizeDetailPayload(payload);
    final tv = TVDetailed.fromJson(normalized);
    _cache.set(cacheKey, tv, ttlSeconds: CacheService.movieDetailsTTL);
    return tv;
  }

  Future<PaginatedResponse<Person>> fetchPopularPeople({
    int page = 1,
    bool forceRefresh = false,
  }) async {
    _checkApiKey();

    final cacheKey = 'people-popular-$page';
    if (!forceRefresh) {
      final cached = _cache.get<PaginatedResponse<Person>>(cacheKey);
      if (cached != null) {
        return cached;
      }
    }

    final payload = await _apiService.fetchPersonCategory(
      'popular',
      page: page,
    );

    final response = PaginatedResponse<Person>.fromJson(
      payload,
      Person.fromJson,
    );

    _cache.set(cacheKey, response);
    return response;
  }

  Future<Person> fetchPersonDetails(int personId, {bool forceRefresh = false}) async {
    _checkApiKey();

    final cacheKey = 'person-details-$personId';
    if (!forceRefresh) {
      final cached = _cache.get<Person>(cacheKey);
      if (cached != null) {
        return cached;
      }
    }

    final payload = await _apiService.fetchPersonDetails(personId);
    final person = Person.fromJson(payload);
    _cache.set(cacheKey, person, ttlSeconds: CacheService.movieDetailsTTL);
    return person;
  }

  Future<PaginatedResponse<Company>> fetchCompanies({
    String query = '',
    int page = 1,
    bool forceRefresh = false,
  }) async {
    _checkApiKey();

    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      return const PaginatedResponse<Company>(
        page: 1,
        totalPages: 1,
        totalResults: 0,
        results: <Company>[],
      );
    }

    final cacheKey = 'companies-$trimmedQuery-$page';
    if (!forceRefresh) {
      final cached = _cache.get<PaginatedResponse<Company>>(cacheKey);
      if (cached != null) {
        return cached;
      }
    }

    final payload = await _apiService.search(
      'company',
      trimmedQuery,
      page: page,
    );

    final response = PaginatedResponse<Company>.fromJson(
      payload,
      Company.fromJson,
    );

    _cache.set(cacheKey, response);
    return response;
  }

  Future<Company> fetchCompanyDetails(int companyId, {bool forceRefresh = false}) async {
    _checkApiKey();

    final cacheKey = 'company-details-$companyId';
    if (!forceRefresh) {
      final cached = _cache.get<Company>(cacheKey);
      if (cached != null) {
        return cached;
      }
    }

    final payload = await _apiService.fetchCompanyDetails(companyId);
    final company = Company.fromJson(payload);
    _cache.set(cacheKey, company);
    return company;
  }

  Future<SearchResponse> searchMulti(String query, {int page = 1, bool forceRefresh = false}) async {
    _checkApiKey();

    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return const SearchResponse();
    }

    final cacheKey = 'search-$trimmed-$page';
    if (!forceRefresh) {
      final cached = _cache.get<SearchResponse>(cacheKey);
      if (cached != null) {
        return cached;
      }
    }

    final payload = await _apiService.search('multi', trimmed, page: page);
    final response = SearchResponse.fromJson(payload);
    _cache.set(cacheKey, response, ttlSeconds: CacheService.searchTTL);
    return response;
  }

  Future<TmdbListDetails> fetchList(String listId, {int page = 1, bool forceRefresh = false}) async {
    _checkApiKey();

    final cacheKey = 'list-$listId-$page';
    if (!forceRefresh) {
      final cached = _cache.get<TmdbListDetails>(cacheKey);
      if (cached != null) {
        return cached;
      }
    }

    final payload = await _apiService.fetchList(listId, page: page);
    final list = TmdbListDetails.fromJson(payload);
    _cache.set(cacheKey, list);
    return list;
  }

  Future<AccountProfile> fetchAccount(String accountId, {bool forceRefresh = false}) async {
    _checkApiKey();

    final cacheKey = 'account-$accountId';
    if (!forceRefresh) {
      final cached = _cache.get<AccountProfile>(cacheKey);
      if (cached != null) {
        return cached;
      }
    }

    final payload = await _apiService.fetchAccount(accountId);
    final account = AccountProfile.fromJson(payload);
    _cache.set(cacheKey, account, ttlSeconds: CacheService.movieDetailsTTL);
    return account;
  }

  Future<PaginatedResponse<AccountListSummary>> fetchAccountLists(
    String accountId, {
    int page = 1,
    bool forceRefresh = false,
  }) async {
    _checkApiKey();

    final cacheKey = 'account-lists-$accountId-$page';
    if (!forceRefresh) {
      final cached = _cache.get<PaginatedResponse<AccountListSummary>>(cacheKey);
      if (cached != null) {
        return cached;
      }
    }

    final payload = await _apiService.fetchAccountLists(accountId, page: page);
    final response = PaginatedResponse<AccountListSummary>.fromJson(
      payload,
      AccountListSummary.fromJson,
    );

    _cache.set(cacheKey, response);
    return response;
  }

  Future<PaginatedResponse<Movie>> fetchAccountFavorites(
    String accountId, {
    String mediaType = 'movie',
    int page = 1,
    bool forceRefresh = false,
  }) async {
    _checkApiKey();

    final cacheKey = 'account-favorites-$accountId-$mediaType-$page';
    if (!forceRefresh) {
      final cached = _cache.get<PaginatedResponse<Movie>>(cacheKey);
      if (cached != null) {
        return cached;
      }
    }

    final payload = await _apiService.fetchAccountFavorites(
      accountId,
      mediaType: mediaType,
      page: page,
    );

    final response = PaginatedResponse<Movie>.fromJson(
      payload,
      Movie.fromJson,
    );

    _cache.set(cacheKey, response);
    return response;
  }

  Future<PaginatedResponse<Movie>> fetchAccountWatchlist(
    String accountId, {
    String mediaType = 'movie',
    int page = 1,
    bool forceRefresh = false,
  }) async {
    _checkApiKey();

    final cacheKey = 'account-watchlist-$accountId-$mediaType-$page';
    if (!forceRefresh) {
      final cached = _cache.get<PaginatedResponse<Movie>>(cacheKey);
      if (cached != null) {
        return cached;
      }
    }

    final payload = await _apiService.fetchAccountWatchlist(
      accountId,
      mediaType: mediaType,
      page: page,
    );

    final response = PaginatedResponse<Movie>.fromJson(
      payload,
      Movie.fromJson,
    );

    _cache.set(cacheKey, response);
    return response;
  }

  Map<String, dynamic> _normalizeDetailPayload(Map<String, dynamic> payload) {
    final normalized = Map<String, dynamic>.from(payload);

    final videos = normalized['videos'];
    if (videos is Map<String, dynamic>) {
      final results = videos['results'];
      if (results is List) {
        normalized['videos'] = results.whereType<Map<String, dynamic>>().toList();
      }
    }

    final recommendations = normalized['recommendations'];
    if (recommendations is Map<String, dynamic>) {
      final results = recommendations['results'];
      if (results is List) {
        normalized['recommendations'] =
            results.whereType<Map<String, dynamic>>().toList();
      }
    }

    final similar = normalized['similar'];
    if (similar is Map<String, dynamic>) {
      final results = similar['results'];
      if (results is List) {
        normalized['similar'] = results.whereType<Map<String, dynamic>>().toList();
      }
    }

    final images = normalized['images'];
    if (images is Map<String, dynamic>) {
      final backdrops = images['backdrops'];
      final posters = images['posters'];
      final profiles = images['profiles'];
      final combined = <Map<String, dynamic>>[];
      if (backdrops is List) {
        combined.addAll(backdrops.whereType<Map<String, dynamic>>());
      }
      if (posters is List) {
        combined.addAll(posters.whereType<Map<String, dynamic>>());
      }
      if (profiles is List) {
        combined.addAll(profiles.whereType<Map<String, dynamic>>());
      }
      normalized['images'] = combined;
    }

    if (normalized['credits'] is Map<String, dynamic>) {
      final credits = normalized['credits'] as Map<String, dynamic>;
      normalized['cast'] = credits['cast'];
      normalized['crew'] = credits['crew'];
    }

    if (normalized['external_ids'] is! Map<String, dynamic>) {
      normalized['external_ids'] = const {};
    }

    return normalized;
  }
}

class TmdbException implements Exception {
  const TmdbException(this.message);

  final String message;

  @override
  String toString() => 'TmdbException: $message';
}
