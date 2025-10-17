import 'package:http/http.dart' as http;

import 'models/account_model.dart';
import 'models/certification_model.dart';
import 'models/company_model.dart';
import 'models/image_model.dart';
import 'models/configuration_model.dart';
import 'models/movie.dart';
import 'models/movie_detailed_model.dart';
import 'models/network_detailed_model.dart';
import 'models/paginated_response.dart';
import 'models/person_model.dart';
import 'models/search_result_model.dart';
import 'models/tmdb_list_model.dart';
import 'models/tv_detailed_model.dart';
import 'models/watch_provider_model.dart';
import 'services/cache_service.dart';
import 'services/tmdb_api_service.dart';

class TmdbRepository {
  static const String _fallbackApiKey = '755c09802f113640bd146fb59ad22411';

  TmdbRepository({
    http.Client? client,
    CacheService? cacheService,
    TmdbApiService? apiService,
    String? apiKey,
  })  : _apiKey = _resolveApiKey(apiKey),
        _cache = cacheService ?? CacheService(),
        _apiService = apiService ??
            TmdbApiService(
              client: client,
              apiKey: _resolveApiKey(apiKey),
            );

  final String _apiKey;
  final CacheService _cache;
  final TmdbApiService _apiService;

  static String _resolveApiKey(String? providedKey) {
    final envKey = const String.fromEnvironment('TMDB_API_KEY', defaultValue: '');
    final candidate = (providedKey ?? envKey).trim();
    if (candidate.isNotEmpty) {
      return candidate;
    }
    return _fallbackApiKey;
  }

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

  Future<PaginatedResponse<Movie>> discoverMovies({
    Map<String, String>? filters,
    int page = 1,
    bool forceRefresh = false,
  }) async {
    _checkApiKey();

    final sanitizedFilters = _sanitizeFilters(filters);
    final normalizedFilters = _normalizeFilters(sanitizedFilters);
    final cacheKey = 'discover-movies-$normalizedFilters-$page';
    if (!forceRefresh) {
      final cached =
          _cache.get<PaginatedResponse<Movie>>(cacheKey);
      if (cached != null) {
        return cached;
      }
    }

    final payload = await _apiService.discoverMovie(
      page: page,
      queryParameters: sanitizedFilters,
    );

    final response = PaginatedResponse<Movie>.fromJson(
      payload,
      Movie.fromJson,
    );

    _cache.set(cacheKey, response);
    return response;
  }

  Future<PaginatedResponse<Movie>> discoverTvSeries({
    Map<String, String>? filters,
    int page = 1,
    bool forceRefresh = false,
  }) async {
    _checkApiKey();

    final sanitizedFilters = _sanitizeFilters(filters);
    final normalizedFilters = _normalizeFilters(sanitizedFilters);
    final cacheKey = 'discover-tv-$normalizedFilters-$page';
    if (!forceRefresh) {
      final cached =
          _cache.get<PaginatedResponse<Movie>>(cacheKey);
      if (cached != null) {
        return cached;
      }
    }

    final payload = await _apiService.discoverTv(
      page: page,
      queryParameters: sanitizedFilters,
    );

    final response = PaginatedResponse<Movie>.fromJson(
      payload,
      Movie.fromJson,
    );

    _cache.set(cacheKey, response);
    return response;
  }

  Future<NetworkDetailed> fetchNetworkDetails(
    int networkId, {
    bool forceRefresh = false,
  }) async {
    _checkApiKey();

    final cacheKey = 'network-details-$networkId';
    if (!forceRefresh) {
      final cached = _cache.get<NetworkDetailed>(cacheKey);
      if (cached != null) {
        return cached;
      }
    }

    final results = await Future.wait([
      _apiService.fetchNetworkDetails(networkId),
      _apiService.fetchNetworkAlternativeNames(networkId),
    ]);

    final detailsPayload = results[0] as Map<String, dynamic>;
    final alternativeNamesPayload = results[1] as Map<String, dynamic>;

    final network = NetworkDetailed.fromJson(detailsPayload);
    final alternativeNames = (alternativeNamesPayload['results'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(AlternativeName.fromJson)
        .toList();

    final enriched = network.copyWith(alternativeNames: alternativeNames);
    _cache.set(cacheKey, enriched, ttlSeconds: CacheService.movieDetailsTTL);
    return enriched;
  }

  Future<List<ImageModel>> fetchNetworkLogos(
    int networkId, {
    bool forceRefresh = false,
  }) async {
    _checkApiKey();

    final cacheKey = 'network-logos-$networkId';
    if (!forceRefresh) {
      final cached = _cache.get<List<ImageModel>>(cacheKey);
      if (cached != null) {
        return cached;
      }
    }

    final payload = await _apiService.fetchNetworkImages(networkId);
    final logos = (payload['logos'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(ImageModel.fromJson)
        .toList();

    _cache.set(cacheKey, logos, ttlSeconds: CacheService.movieDetailsTTL);
    return logos;
  }

  Future<PaginatedResponse<Movie>> fetchNetworkTvShows({
    required int networkId,
    int page = 1,
    bool forceRefresh = false,
    String sortBy = 'popularity.desc',
    double? minVoteAverage,
    String? originalLanguage,
  }) {
    final filters = <String, String>{
      'with_networks': '$networkId',
      'sort_by': sortBy,
      'include_null_first_air_dates': 'false',
      'include_adult': 'false',
      if (minVoteAverage != null) 'vote_average.gte': minVoteAverage.toString(),
      if (originalLanguage != null && originalLanguage.isNotEmpty)
        'with_original_language': originalLanguage,
    };

    return discoverTvSeries(
      filters: filters,
      page: page,
      forceRefresh: forceRefresh,
    );
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

  Future<ApiConfiguration> fetchConfiguration({bool forceRefresh = false}) async {
    _checkApiKey();

    const cacheKey = 'configuration-core';
    if (!forceRefresh) {
      final cached = _cache.get<ApiConfiguration>(cacheKey);
      if (cached != null) {
        return cached;
      }
    }

    final payload = await _apiService.fetchConfiguration();
    final configuration = ApiConfiguration.fromJson(payload);
    _cache.set(cacheKey, configuration, ttlSeconds: CacheService.movieDetailsTTL);
    return configuration;
  }

  Future<List<LanguageInfo>> fetchLanguages({bool forceRefresh = false}) async {
    _checkApiKey();

    const cacheKey = 'configuration-languages';
    if (!forceRefresh) {
      final cached = _cache.get<List<LanguageInfo>>(cacheKey);
      if (cached != null) {
        return cached;
      }
    }

    final payload = await _apiService.fetchConfigurationLanguages();
    final languages = payload
        .whereType<Map<String, dynamic>>()
        .map(LanguageInfo.fromJson)
        .toList()
      ..sort((a, b) => a.englishName.compareTo(b.englishName));

    _cache.set(cacheKey, languages, ttlSeconds: CacheService.movieDetailsTTL);
    return languages;
  }

  Future<List<CountryInfo>> fetchCountries({bool forceRefresh = false}) async {
    _checkApiKey();

    const cacheKey = 'configuration-countries';
    if (!forceRefresh) {
      final cached = _cache.get<List<CountryInfo>>(cacheKey);
      if (cached != null) {
        return cached;
      }
    }

    final payload = await _apiService.fetchConfigurationCountries();
    final countries = payload
        .whereType<Map<String, dynamic>>()
        .map(CountryInfo.fromJson)
        .toList()
      ..sort((a, b) => a.englishName.compareTo(b.englishName));

    _cache.set(cacheKey, countries, ttlSeconds: CacheService.movieDetailsTTL);
    return countries;
  }

  Future<List<Timezone>> fetchTimezones({bool forceRefresh = false}) async {
    _checkApiKey();

    const cacheKey = 'configuration-timezones';
    if (!forceRefresh) {
      final cached = _cache.get<List<Timezone>>(cacheKey);
      if (cached != null) {
        return cached;
      }
    }

    final payload = await _apiService.fetchConfigurationTimezones();
    final timezones = payload
        .whereType<Map<String, dynamic>>()
        .map(Timezone.fromJson)
        .toList()
      ..sort((a, b) => a.countryCode.compareTo(b.countryCode));

    _cache.set(cacheKey, timezones, ttlSeconds: CacheService.movieDetailsTTL);
    return timezones;
  }

  Future<Map<String, List<Certification>>> fetchMovieCertifications({
    bool forceRefresh = false,
  }) {
    return _fetchCertifications(
      'movies',
      cacheKey: 'certifications-movie',
      forceRefresh: forceRefresh,
    );
  }

  Future<Map<String, List<Certification>>> fetchTvCertifications({
    bool forceRefresh = false,
  }) {
    return _fetchCertifications(
      'tv',
      cacheKey: 'certifications-tv',
      forceRefresh: forceRefresh,
    );
  }

  Future<Map<String, List<Certification>>> _fetchCertifications(
    String mediaType, {
    required String cacheKey,
    bool forceRefresh = false,
  }) async {
    _checkApiKey();

    if (!forceRefresh) {
      final cached = _cache.get<Map<String, List<Certification>>>(cacheKey);
      if (cached != null) {
        return cached;
      }
    }

    final payload = await _apiService.fetchCertifications(mediaType);
    final results = payload['results'];
    final parsed = <String, List<Certification>>{};

    if (results is Map<String, dynamic>) {
      for (final entry in results.entries) {
        final value = entry.value;
        if (value is List) {
          final certifications = value
              .whereType<Map<String, dynamic>>()
              .map(Certification.fromJson)
              .toList()
            ..sort((a, b) => a.order.compareTo(b.order));
          parsed[entry.key] = certifications;
        }
      }
    }

    _cache.set(cacheKey, parsed, ttlSeconds: CacheService.movieDetailsTTL);
    return parsed;
  }

  Map<String, String>? _sanitizeFilters(Map<String, String>? filters) {
    if (filters == null || filters.isEmpty) {
      return null;
    }

    final sanitized = <String, String>{};
    for (final entry in filters.entries) {
      final key = entry.key.trim();
      final value = entry.value.trim();
      if (key.isEmpty || value.isEmpty) {
        continue;
      }
      sanitized[key] = value;
    }

    if (sanitized.isEmpty) {
      return null;
    }

    return sanitized;
  }

  String _normalizeFilters(Map<String, String>? filters) {
    if (filters == null || filters.isEmpty) {
      return 'none';
    }

    final entries = filters.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return entries.map((entry) => '${entry.key}=${entry.value}').join('&');
  }

  Future<Map<String, WatchProviderResults>> fetchWatchProviders({
    String mediaType = 'movie',
    bool forceRefresh = false,
  }) async {
    _checkApiKey();

    final cacheKey = 'watch-providers-$mediaType';
    if (!forceRefresh) {
      final cached =
          _cache.get<Map<String, WatchProviderResults>>(cacheKey);
      if (cached != null) {
        return cached;
      }
    }

    final payload = await _apiService.fetchWatchProviders(mediaType);
    final results = payload['results'];
    final parsed = <String, WatchProviderResults>{};

    if (results is Map<String, dynamic>) {
      for (final entry in results.entries) {
        final value = entry.value;
        if (value is Map<String, dynamic>) {
          parsed[entry.key] = WatchProviderResults.fromJson(value);
        }
      }
    }

    _cache.set(cacheKey, parsed, ttlSeconds: CacheService.movieDetailsTTL);
    return parsed;
  }

  Future<List<WatchProviderRegion>> fetchWatchProviderRegions({
    bool forceRefresh = false,
  }) async {
    _checkApiKey();

    const cacheKey = 'watch-provider-regions';
    if (!forceRefresh) {
      final cached = _cache.get<List<WatchProviderRegion>>(cacheKey);
      if (cached != null) {
        return cached;
      }
    }

    final payload = await _apiService.fetchWatchProviderRegions();
    final regions = payload
        .whereType<Map<String, dynamic>>()
        .map(WatchProviderRegion.fromJson)
        .toList()
      ..sort((a, b) => a.englishName.compareTo(b.englishName));

    _cache.set(cacheKey, regions, ttlSeconds: CacheService.movieDetailsTTL);
    return regions;
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
