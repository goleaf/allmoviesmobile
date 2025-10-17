import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:http/http.dart' as http;

import '../core/config/app_config.dart';
import 'models/certification_model.dart';
import 'models/collection_model.dart';
import 'models/company_model.dart';
import 'models/configuration_model.dart';
import 'models/discover_filters_model.dart';
import 'models/genre_model.dart';
import 'models/image_model.dart';
import 'models/keyword_model.dart';
import 'models/media_images.dart';
import 'models/movie.dart';
import 'models/movie_detailed_model.dart';
import 'models/movie_ref_model.dart';
import 'models/network_detailed_model.dart';
import 'models/network_model.dart';
import 'models/paginated_response.dart';
import 'models/person_model.dart';
import 'models/person_detail_model.dart';
import 'models/search_filters.dart';
import 'models/search_result_model.dart';
import 'models/season_model.dart';
import 'models/tv_detailed_model.dart';
import 'models/tv_ref_model.dart';
import 'models/watch_provider_model.dart';
import 'services/cache_service.dart';

class TmdbRepository {
  TmdbRepository({
    http.Client? client,
    CacheService? cacheService,
    String? apiKey,
    String? language,
  }) : _client = client ?? http.Client(),
       _cache = cacheService,
       _language = language ?? AppConfig.defaultLanguage,
       _apiKey = (() {
         final provided =
             apiKey ??
             const String.fromEnvironment('TMDB_API_KEY', defaultValue: '');
         if (provided.isNotEmpty) {
           return provided;
         }
         return AppConfig.tmdbApiKey;
       })();

  static const _host = 'api.themoviedb.org';
  static const _basePath = '/3';

  final http.Client _client;
  final CacheService? _cache;
  final String _apiKey;
  final String _language;
  final RateLimiter _globalRateLimiter = RateLimiter(
    const Duration(milliseconds: 250),
  );
  final Map<String, RateLimiter> _endpointLimiters = {};
  final Map<String, Future<void>> _pendingRevalidations = {};

  void _ensureApiKey() {
    if (_apiKey.isEmpty) {
      throw const TmdbException('TMDB API key is not configured.');
    }
  }

  Uri _buildUri(String endpoint, [Map<String, String>? query]) {
    final params = <String, String>{
      'api_key': _apiKey,
      'language': _language,
      if (query != null) ...query,
    };
    return Uri.https(_host, '$_basePath$endpoint', params);
  }

  Future<Map<String, dynamic>> _getJson(
    String endpoint, {
    Map<String, String>? query,
  }) async {
    _ensureApiKey();
    final uri = _buildUri(endpoint, query);

    Future<Map<String, dynamic>> request() async {
      try {
        final response = await _client
            .get(uri, headers: {'Accept': 'application/json'})
            .timeout(AppConfig.requestTimeout);

        if (response.statusCode != 200) {
          final body = response.body;
          final snippet = body.length > 200 ? body.substring(0, 200) : body;
          throw TmdbException(
            'HTTP ${response.statusCode} at ${uri.path}: $snippet',
          );
        }

        return jsonDecode(response.body) as Map<String, dynamic>;
      } on TimeoutException {
        throw const TmdbException('Network timeout while contacting TMDB');
      } on SocketException catch (e) {
        throw TmdbException('Network error: ${e.message}');
      } on FormatException {
        throw const TmdbException('Invalid JSON received from TMDB');
      }
    }

    final limiter = _endpointLimiters.putIfAbsent(
      endpoint,
      () => RateLimiter(const Duration(milliseconds: 250)),
    );

    return _globalRateLimiter.schedule(
      () => limiter.schedule(request),
    );
  }

  T? _getCached<T>(String key) => _cache?.get<T>(key);

  void _setCached<T>(
    String key,
    T value, {
    int ttlSeconds = 900,
    CachePolicy? policy,
  }) {
    final cache = _cache;
    if (cache == null) {
      return;
    }
    if (policy != null) {
      cache.set<T>(key, value, policy: policy);
    } else {
      cache.set<T>(key, value, ttlSeconds: ttlSeconds);
    }
  }

  Future<T> _cached<T>(
    String key,
    Future<T> Function() loader, {
    bool forceRefresh = false,
    int ttlSeconds = 900,
    CachePolicy? policy,
    int? refreshAfterSeconds,
  }) async {
    final cache = _cache;
    final computedRefreshAfter = refreshAfterSeconds ??
        (ttlSeconds >= 120 ? ttlSeconds ~/ 2 : null);
    final effectivePolicy = policy ?? CachePolicy(
      ttl: Duration(seconds: ttlSeconds),
      refreshAfter: computedRefreshAfter != null && computedRefreshAfter > 0
          ? Duration(seconds: computedRefreshAfter)
          : null,
    );

    if (!forceRefresh && cache != null) {
      final lookup = cache.getWithMeta<T>(key);
      if (lookup != null && lookup.hasValue) {
        final cachedValue = lookup.value;
        if (cachedValue == null) {
          // Defensive guard; treat as miss if value vanished.
          _cache?.remove(key);
          return await _cached(
            key,
            loader,
            forceRefresh: true,
            ttlSeconds: ttlSeconds,
            policy: policy,
            refreshAfterSeconds: refreshAfterSeconds,
          );
        }
        if (lookup.isStale) {
          _scheduleRevalidation<T>(
            key,
            loader,
            effectivePolicy,
          );
        }
        return cachedValue as T;
      }
    }

    final value = await loader();
    _setCached<T>(
      key,
      value,
      ttlSeconds: ttlSeconds,
      policy: effectivePolicy,
    );
    return value;
  }

  PaginatedResponse<T> _mapPaginated<T>(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) mapper,
  ) {
    return PaginatedResponse<T>.fromJson(json, mapper);
  }

  // ---------------------------------------------------------------------------
  // Trending
  // ---------------------------------------------------------------------------

  Future<PaginatedResponse<Movie>> fetchTrendingTitles({
    String mediaType = 'all',
    String timeWindow = 'day',
    int page = 1,
    bool forceRefresh = false,
  }) {
    final cacheKey = 'trending::$mediaType::$timeWindow::$page';
    return _cached(
      cacheKey,
      () async {
        final payload = await _getJson(
          '/trending/$mediaType/$timeWindow',
          query: {'page': '$page'},
        );

        return _mapPaginated<Movie>(
          payload,
          (json) => Movie.fromJson(
            json,
            mediaType: mediaType == 'all' ? null : mediaType,
          ),
        );
      },
      forceRefresh: forceRefresh,
      ttlSeconds: CacheService.trendingTTL,
    );
  }

  void _scheduleRevalidation<T>(
    String key,
    Future<T> Function() loader,
    CachePolicy policy,
  ) {
    final cache = _cache;
    if (cache == null || _pendingRevalidations.containsKey(key)) {
      return;
    }

    final future = loader().then((value) {
      cache.set<T>(key, value, policy: policy);
    }).catchError((error) {
      // Silently ignore refresh errors; the stale value was already returned.
    }).whenComplete(() {
      _pendingRevalidations.remove(key);
    });

    _pendingRevalidations[key] = future;
  }

  Future<List<Movie>> fetchTrendingMovies({
    String timeWindow = 'day',
    bool forceRefresh = false,
  }) async {
    final response = await fetchTrendingTitles(
      mediaType: 'movie',
      timeWindow: timeWindow,
      page: 1,
      forceRefresh: forceRefresh,
    );
    return response.results;
  }

  // ---------------------------------------------------------------------------
  // Movies
  // ---------------------------------------------------------------------------

  Future<List<Movie>> fetchPopularMovies({
    int page = 1,
    bool forceRefresh = false,
  }) async {
    final response = await discoverMovies(
      page: page,
      forceRefresh: forceRefresh,
      discoverFilters: const DiscoverFilters(sortBy: SortBy.popularityDesc),
    );
    return response.results;
  }

  Future<List<Movie>> fetchTopRatedMovies({
    int page = 1,
    bool forceRefresh = false,
  }) async {
    final response = await discoverMovies(
      page: page,
      forceRefresh: forceRefresh,
      discoverFilters: const DiscoverFilters(sortBy: SortBy.ratingDesc),
    );
    return response.results;
  }

  Future<List<Movie>> fetchNowPlayingMovies({int page = 1}) async {
    final response = await fetchNowPlayingMoviesPaginated(page: page);
    return response.results;
  }

  Future<List<Movie>> fetchUpcomingMovies({int page = 1}) async {
    final response = await fetchUpcomingMoviesPaginated(page: page);
    return response.results;
  }

  // Paginated wrappers for movie sections
  Future<PaginatedResponse<Movie>> fetchTrendingMoviesPaginated({
    String timeWindow = 'day',
    int page = 1,
    bool forceRefresh = false,
  }) {
    return fetchTrendingTitles(
      mediaType: 'movie',
      timeWindow: timeWindow,
      page: page,
      forceRefresh: forceRefresh,
    );
  }

  Future<PaginatedResponse<Movie>> fetchPopularMoviesPaginated({
    int page = 1,
    bool forceRefresh = false,
  }) {
    return discoverMovies(
      page: page,
      forceRefresh: forceRefresh,
      discoverFilters: const DiscoverFilters(sortBy: SortBy.popularityDesc),
    );
  }

  Future<PaginatedResponse<Movie>> fetchTopRatedMoviesPaginated({
    int page = 1,
    bool forceRefresh = false,
  }) {
    return discoverMovies(
      page: page,
      forceRefresh: forceRefresh,
      discoverFilters: const DiscoverFilters(sortBy: SortBy.ratingDesc),
    );
  }

  Future<PaginatedResponse<Movie>> fetchNowPlayingMoviesPaginated({
    int page = 1,
    bool forceRefresh = false,
  }) async {
    final payload = await _getJson(
      '/movie/now_playing',
      query: {'page': '$page'},
    );
    return _mapPaginated<Movie>(payload, Movie.fromJson);
  }

  Future<PaginatedResponse<Movie>> fetchUpcomingMoviesPaginated({
    int page = 1,
    bool forceRefresh = false,
  }) async {
    final payload = await _getJson('/movie/upcoming', query: {'page': '$page'});
    return _mapPaginated<Movie>(payload, Movie.fromJson);
  }

  Future<PaginatedResponse<Movie>> discoverMovies({
    int page = 1,
    DiscoverFilters? discoverFilters,
    Map<String, String>? filters,
    bool forceRefresh = false,
  }) {
    final params = <String, String>{
      'page': '$page',
      if (discoverFilters != null)
        ...discoverFilters.toQueryParameters(includePage: false),
      if (filters != null) ...filters,
    };

    final cacheKey =
        'discover_movie::${params.entries.map((e) => '${e.key}=${e.value}').join('&')}';

    return _cached(
      cacheKey,
      () async {
        final payload = await _getJson('/discover/movie', query: params);
        return _mapPaginated<Movie>(
          payload,
          (json) => Movie.fromJson(json, mediaType: 'movie'),
        );
      },
      forceRefresh: forceRefresh,
      ttlSeconds: CacheService.defaultTTL,
    );
  }

  Future<PaginatedResponse<Movie>> searchMovies(
    String query, {
    int page = 1,
    MovieSearchFilters? filters,
    bool forceRefresh = false,
  }) {
    final normalized = query.trim();
    if (normalized.isEmpty) {
      return Future.value(
        const PaginatedResponse<Movie>(
          page: 1,
          totalPages: 1,
          totalResults: 0,
          results: <Movie>[],
        ),
      );
    }

    final params = <String, String>{
      'query': normalized,
      'page': '$page',
      if (filters != null) ...filters.toQueryParameters(),
    };

    final cacheKey =
        'search_movie::$normalized::$page::${params.entries.map((e) => e.key + e.value).join('-')}';

    return _cached(
      cacheKey,
      () async {
        final payload = await _getJson('/search/movie', query: params);
        return _mapPaginated<Movie>(payload, Movie.fromJson);
      },
      forceRefresh: forceRefresh,
      ttlSeconds: CacheService.searchTTL,
    );
  }

  Future<MovieDetailed> fetchMovieDetails(
    int movieId, {
    bool forceRefresh = false,
  }) {
    final cacheKey = 'movie_details::$movieId';
    return _cached(
      cacheKey,
      () async {
        final payload = await _getJson(
          '/movie/$movieId',
          query: {
            'append_to_response':
                'videos,images,credits,keywords,reviews,release_dates,watch/providers,alternative_titles,recommendations,similar,translations',
          },
        );

        final normalized = Map<String, dynamic>.from(payload);

        void setList(String key, List? source) {
          normalized[key] =
              source?.whereType<Map<String, dynamic>>().toList(
                growable: false,
              ) ??
              const [];
        }

        final credits = payload['credits'] as Map<String, dynamic>?;
        setList('cast', credits?['cast'] as List?);
        setList('crew', credits?['crew'] as List?);

        final keywords = payload['keywords'];
        if (keywords is Map<String, dynamic>) {
          setList(
            'keywords',
            (keywords['keywords'] ?? keywords['results']) as List?,
          );
        }

        final reviews = payload['reviews'] as Map<String, dynamic>?;
        setList('reviews', reviews?['results'] as List?);

        final releaseDates = payload['release_dates'] as Map<String, dynamic>?;
        setList('release_dates', releaseDates?['results'] as List?);

        final watchProviders =
            payload['watch/providers'] as Map<String, dynamic>?;
        normalized['watchProviders'] = watchProviders?['results'] ?? const {};

        final alternativeTitles =
            payload['alternative_titles'] as Map<String, dynamic>?;
        setList('alternative_titles', alternativeTitles?['titles'] as List?);

        final translations = payload['translations'] as Map<String, dynamic>?;
        setList('translations', translations?['translations'] as List?);

        final videos = payload['videos'] as Map<String, dynamic>?;
        setList('videos', videos?['results'] as List?);

        final images = payload['images'] as Map<String, dynamic>?;
        setList('imageBackdrops', images?['backdrops'] as List?);
        setList('imagePosters', images?['posters'] as List?);
        setList('imageProfiles', images?['profiles'] as List?);
        final combinedImages = <Map<String, dynamic>>[
          ...?images?['backdrops'] as List?,
          ...?images?['posters'] as List?,
        ].whereType<Map<String, dynamic>>().toList(growable: false);
        setList('images', combinedImages);

        final recommendations =
            payload['recommendations'] as Map<String, dynamic>?;
        setList('recommendations', recommendations?['results'] as List?);

        final similar = payload['similar'] as Map<String, dynamic>?;
        setList('similar', similar?['results'] as List?);

        return MovieDetailed.fromJson(normalized);
      },
      forceRefresh: forceRefresh,
      ttlSeconds: CacheService.movieDetailsTTL,
    );
  }

  Future<MediaImages> fetchMovieImages(
    int movieId, {
    bool forceRefresh = false,
  }) async {
    final payload = await _getJson(
      '/movie/$movieId/images',
      query: {'include_image_language': 'en,null'},
    );

    List<ImageModel> _mapImages(String key) {
      final list = payload[key];
      if (list is! List) return const [];
      return list
          .whereType<Map<String, dynamic>>()
          .map(ImageModel.fromJson)
          .toList(growable: false);
    }

    return MediaImages(
      posters: _mapImages('posters'),
      backdrops: _mapImages('backdrops'),
      stills: _mapImages('profiles'),
    );
  }

  Future<List<Movie>> fetchSimilarMovies(int movieId, {int page = 1}) async {
    final payload = await _getJson(
      '/movie/$movieId/similar',
      query: {'page': '$page'},
    );
    return _mapPaginated<Movie>(payload, Movie.fromJson).results;
  }

  Future<List<Movie>> fetchRecommendedMovies(
    int movieId, {
    int page = 1,
  }) async {
    final payload = await _getJson(
      '/movie/$movieId/recommendations',
      query: {'page': '$page'},
    );
    return _mapPaginated<Movie>(payload, Movie.fromJson).results;
  }

  // ---------------------------------------------------------------------------
  // TV
  // ---------------------------------------------------------------------------

  Future<PaginatedResponse<Movie>> discoverTvSeries({
    int page = 1,
    Map<String, String>? filters,
    bool forceRefresh = false,
  }) {
    final params = <String, String>{
      'page': '$page',
      'sort_by': filters?['sort_by'] ?? 'popularity.desc',
      if (filters != null) ...filters,
    };

    final cacheKey =
        'discover_tv::${params.entries.map((e) => '${e.key}=${e.value}').join('&')}';

    return _cached(
      cacheKey,
      () async {
        final payload = await _getJson('/discover/tv', query: params);
        return _mapPaginated<Movie>(
          payload,
          (json) => Movie.fromJson(json, mediaType: 'tv'),
        );
      },
      forceRefresh: forceRefresh,
      ttlSeconds: CacheService.defaultTTL,
    );
  }

  Future<PaginatedResponse<Movie>> fetchTrendingTv({
    String timeWindow = 'day',
    int page = 1,
    bool forceRefresh = false,
  }) async {
    final payload = await _getJson(
      '/trending/tv/$timeWindow',
      query: {'page': '$page'},
    );
    return _mapPaginated<Movie>(
      payload,
      (json) => Movie.fromJson(json, mediaType: 'tv'),
    );
  }

  Future<PaginatedResponse<Movie>> fetchPopularTv({int page = 1}) async {
    final payload = await _getJson('/tv/popular', query: {'page': '$page'});
    return _mapPaginated<Movie>(
      payload,
      (json) => Movie.fromJson(json, mediaType: 'tv'),
    );
  }

  Future<PaginatedResponse<Movie>> fetchTopRatedTv({int page = 1}) async {
    final payload = await _getJson('/tv/top_rated', query: {'page': '$page'});
    return _mapPaginated<Movie>(
      payload,
      (json) => Movie.fromJson(json, mediaType: 'tv'),
    );
  }

  Future<PaginatedResponse<Movie>> fetchAiringTodayTv({int page = 1}) async {
    final payload = await _getJson(
      '/tv/airing_today',
      query: {'page': '$page'},
    );
    return _mapPaginated<Movie>(
      payload,
      (json) => Movie.fromJson(json, mediaType: 'tv'),
    );
  }

  Future<PaginatedResponse<Movie>> fetchOnTheAirTv({int page = 1}) async {
    final payload = await _getJson('/tv/on_the_air', query: {'page': '$page'});
    return _mapPaginated<Movie>(
      payload,
      (json) => Movie.fromJson(json, mediaType: 'tv'),
    );
  }

  Future<TVDetailed> fetchTvDetails(int tvId, {bool forceRefresh = false}) {
    final cacheKey = 'tv_details::$tvId';
    return _cached(
      cacheKey,
      () async {
        final payload = await _getJson(
          '/tv/$tvId',
          query: {
            'append_to_response':
                'videos,images,aggregate_credits,keywords,recommendations,similar,watch/providers,translations',
          },
        );

        final normalized = Map<String, dynamic>.from(payload);
        void setList(String key, List? source) {
          normalized[key] =
              source?.whereType<Map<String, dynamic>>().toList(
                growable: false,
              ) ??
              const [];
        }

        final credits = payload['aggregate_credits'] ?? payload['credits'];
        if (credits is Map<String, dynamic>) {
          setList('cast', credits['cast'] as List?);
        }

        final keywords = payload['keywords'];
        if (keywords is Map<String, dynamic>) {
          setList(
            'keywords',
            (keywords['results'] ?? keywords['keywords']) as List?,
          );
        }

        final videos = payload['videos'] as Map<String, dynamic>?;
        setList('videos', videos?['results'] as List?);

        final images = payload['images'] as Map<String, dynamic>?;
        setList('images', images?['backdrops'] as List?);

        final recommendations =
            payload['recommendations'] as Map<String, dynamic>?;
        setList('recommendations', recommendations?['results'] as List?);

        final similar = payload['similar'] as Map<String, dynamic>?;
        setList('similar', similar?['results'] as List?);

        final watchProviders =
            payload['watch/providers'] as Map<String, dynamic>?;
        normalized['watchProviders'] = watchProviders?['results'] ?? const {};

        final translations = payload['translations'] as Map<String, dynamic>?;
        setList('translations', translations?['translations'] as List?);

        return TVDetailed.fromJson(normalized);
      },
      forceRefresh: forceRefresh,
      ttlSeconds: CacheService.movieDetailsTTL,
    );
  }

  Future<MediaImages> fetchTvImages(
    int tvId, {
    bool forceRefresh = false,
  }) async {
    final payload = await _getJson(
      '/tv/$tvId/images',
      query: {'include_image_language': 'en,null'},
    );

    List<ImageModel> _mapImages(String key) {
      final list = payload[key];
      if (list is! List) return const [];
      return list
          .whereType<Map<String, dynamic>>()
          .map(ImageModel.fromJson)
          .toList(growable: false);
    }

    return MediaImages(
      posters: _mapImages('posters'),
      backdrops: _mapImages('backdrops'),
      stills: _mapImages('stills'),
    );
  }

  Future<MediaImages> fetchTvSeasonImages(
    int tvId,
    int seasonNumber, {
    bool forceRefresh = false,
  }) async {
    final payload = await _getJson(
      '/tv/$tvId/season/$seasonNumber/images',
      query: {'include_image_language': 'en,null'},
    );

    List<ImageModel> _mapImages(String key) {
      final list = payload[key];
      if (list is! List) return const [];
      return list
          .whereType<Map<String, dynamic>>()
          .map(ImageModel.fromJson)
          .toList(growable: false);
    }

    return MediaImages(
      posters: _mapImages('posters'),
      backdrops: _mapImages('backdrops'),
      stills: _mapImages('stills'),
    );
  }

  Future<Map<String, String>> fetchTvContentRatings(
    int tvId, {
    bool forceRefresh = false,
  }) async {
    final payload = await _getJson('/tv/$tvId/content_ratings');
    final results = payload['results'];
    final map = <String, String>{};
    if (results is List) {
      for (final item in results.whereType<Map<String, dynamic>>()) {
        final code = item['iso_3166_1'];
        final rating = item['rating'];
        if (code is String && rating is String && rating.isNotEmpty) {
          map[code.toUpperCase()] = rating;
        }
      }
    }
    return map;
  }

  Future<Season> fetchTvSeason(
    int tvId,
    int seasonNumber, {
    bool forceRefresh = false,
  }) async {
    final payload = await _getJson(
      '/tv/$tvId/season/$seasonNumber',
      query: {'append_to_response': 'credits,videos'},
    );

    final normalized = Map<String, dynamic>.from(payload);
    final credits = payload['credits'] as Map<String, dynamic>?;
    normalized['cast'] = credits?['cast'] ?? const [];
    normalized['crew'] = credits?['crew'] ?? const [];
    final videos = payload['videos'] as Map<String, dynamic>?;
    normalized['videos'] = videos?['results'] ?? const [];

    return Season.fromJson(normalized);
  }

  Future<PaginatedResponse<Movie>> searchTvSeries(
    String query, {
    int page = 1,
    TvSearchFilters? filters,
    bool forceRefresh = false,
  }) {
    final normalized = query.trim();
    if (normalized.isEmpty) {
      return Future.value(
        const PaginatedResponse<Movie>(
          page: 1,
          totalPages: 1,
          totalResults: 0,
          results: <Movie>[],
        ),
      );
    }

    final params = <String, String>{
      'query': normalized,
      'page': '$page',
      if (filters != null) ...filters.toQueryParameters(),
    };

    final cacheKey =
        'search_tv::$normalized::$page::${params.entries.map((e) => e.key + e.value).join('-')}';

    return _cached(
      cacheKey,
      () async {
        final payload = await _getJson('/search/tv', query: params);
        return _mapPaginated<Movie>(
          payload,
          (json) => Movie.fromJson(json, mediaType: 'tv'),
        );
      },
      forceRefresh: forceRefresh,
      ttlSeconds: CacheService.searchTTL,
    );
  }

  // ---------------------------------------------------------------------------
  // People
  // ---------------------------------------------------------------------------

  Future<List<Person>> fetchTrendingPeople({String timeWindow = 'day'}) async {
    final payload = await _getJson('/trending/person/$timeWindow');
    return _mapPaginated<Person>(payload, Person.fromJson).results;
  }

  Future<PaginatedResponse<Person>> fetchPopularPeople({
    int page = 1,
    bool forceRefresh = false,
  }) {
    final cacheKey = 'popular_people::$page';
    return _cached(
      cacheKey,
      () async {
        final payload = await _getJson(
          '/person/popular',
          query: {'page': '$page'},
        );
        return _mapPaginated<Person>(payload, Person.fromJson);
      },
      forceRefresh: forceRefresh,
      ttlSeconds: CacheService.defaultTTL,
    );
  }

  Future<PersonDetail> fetchPersonDetails(
    int personId, {
    bool forceRefresh = false,
  }) async {
    final payload = await _getJson(
      '/person/$personId',
      query: {
        'append_to_response':
            'combined_credits,external_ids,images,tagged_images',
      },
    );
    return PersonDetail.fromJson(payload);
  }

  Future<PaginatedResponse<Person>> searchPeople(
    String query, {
    int page = 1,
    bool forceRefresh = false,
  }) {
    final normalized = query.trim();
    if (normalized.isEmpty) {
      return Future.value(
        const PaginatedResponse<Person>(
          page: 1,
          totalPages: 1,
          totalResults: 0,
          results: <Person>[],
        ),
      );
    }

    final cacheKey = 'search_people::$normalized::$page';
    return _cached(
      cacheKey,
      () async {
        final payload = await _getJson(
          '/search/person',
          query: {'query': normalized, 'page': '$page'},
        );
        return _mapPaginated<Person>(payload, Person.fromJson);
      },
      forceRefresh: forceRefresh,
      ttlSeconds: CacheService.searchTTL,
    );
  }

  // ---------------------------------------------------------------------------
  // Companies
  // ---------------------------------------------------------------------------

  Future<PaginatedResponse<Company>> fetchCompanies({
    required String query,
    int page = 1,
    bool forceRefresh = false,
  }) {
    final normalized = query.trim();
    if (normalized.isEmpty) {
      return Future.value(
        const PaginatedResponse<Company>(
          page: 1,
          totalPages: 1,
          totalResults: 0,
          results: <Company>[],
        ),
      );
    }

    final cacheKey = 'companies::$normalized::$page';
    return _cached(
      cacheKey,
      () async {
        final payload = await _getJson(
          '/search/company',
          query: {'query': normalized, 'page': '$page'},
        );
        return _mapPaginated<Company>(payload, Company.fromJson);
      },
      forceRefresh: forceRefresh,
      ttlSeconds: CacheService.searchTTL,
    );
  }

  Future<Company> fetchCompanyDetails(int companyId) async {
    final payload = await _getJson('/company/$companyId');
    return Company.fromJson(payload);
  }

  // ---------------------------------------------------------------------------
  // Collections
  // ---------------------------------------------------------------------------

  Future<CollectionDetails> fetchCollectionDetails(
    int collectionId, {
    bool forceRefresh = false,
  }) {
    final cacheKey = 'collection::$collectionId';
    return _cached(
      cacheKey,
      () async {
        final payload = await _getJson('/collection/$collectionId');
        final normalized = Map<String, dynamic>.from(payload);
        final parts = payload['parts'];
        if (parts is List) {
          normalized['parts'] = parts
              .whereType<Map<String, dynamic>>()
              .map(
                (item) => {
                  'id': item['id'],
                  'title': item['title'] ?? item['name'] ?? '',
                  'poster_path': item['poster_path'],
                  'backdrop_path': item['backdrop_path'],
                  'vote_average': (item['vote_average'] as num?)?.toDouble(),
                  'release_date':
                      item['release_date'] ?? item['first_air_date'],
                  'media_type': item['media_type'],
                },
              )
              .toList(growable: false);
        }
        return CollectionDetails.fromJson(normalized);
      },
      forceRefresh: forceRefresh,
      ttlSeconds: CacheService.defaultTTL,
    );
  }

  Future<PaginatedResponse<Collection>> searchCollections(
    String query, {
    int page = 1,
    bool forceRefresh = false,
  }) {
    final normalized = query.trim();
    if (normalized.isEmpty) {
      return Future.value(
        const PaginatedResponse<Collection>(
          page: 1,
          totalPages: 1,
          totalResults: 0,
          results: <Collection>[],
        ),
      );
    }

    final cacheKey = 'search_collection::$normalized::$page';
    return _cached(
      cacheKey,
      () async {
        final payload = await _getJson(
          '/search/collection',
          query: {'query': normalized, 'page': '$page'},
        );
        return _mapPaginated<Collection>(payload, Collection.fromJson);
      },
      forceRefresh: forceRefresh,
      ttlSeconds: CacheService.searchTTL,
    );
  }

  // ---------------------------------------------------------------------------
  // Keywords
  // ---------------------------------------------------------------------------

  Future<PaginatedResponse<Keyword>> fetchTrendingKeywords({
    int page = 1,
    bool forceRefresh = false,
  }) async {
    final trendingMovies = await fetchTrendingMovies(
      forceRefresh: forceRefresh,
    );
    final topMovies = trendingMovies.take(5);
    final keywords = <Keyword>[];
    final seen = <int>{};

    for (final movie in topMovies) {
      try {
        final payload = await _getJson('/movie/${movie.id}/keywords');
        final list = payload['keywords'] as List?;
        if (list == null) continue;
        for (final item in list.whereType<Map<String, dynamic>>()) {
          final keyword = Keyword.fromJson(item);
          if (seen.add(keyword.id)) {
            keywords.add(keyword);
          }
        }
      } catch (_) {
        // Ignore individual failures
      }
    }

    return PaginatedResponse<Keyword>(
      page: 1,
      totalPages: 1,
      totalResults: keywords.length,
      results: keywords,
    );
  }

  Future<PaginatedResponse<Keyword>> searchKeywords(
    String query, {
    int page = 1,
    bool forceRefresh = false,
  }) {
    final normalized = query.trim();
    if (normalized.isEmpty) {
      return Future.value(
        const PaginatedResponse<Keyword>(
          page: 1,
          totalPages: 1,
          totalResults: 0,
          results: <Keyword>[],
        ),
      );
    }

    final cacheKey = 'search_keyword::$normalized::$page';
    return _cached(
      cacheKey,
      () async {
        final payload = await _getJson(
          '/search/keyword',
          query: {'query': normalized, 'page': '$page'},
        );
        return _mapPaginated<Keyword>(payload, Keyword.fromJson);
      },
      forceRefresh: forceRefresh,
      ttlSeconds: CacheService.searchTTL,
    );
  }

  Future<KeywordDetails> fetchKeywordDetails(
    int keywordId, {
    bool forceRefresh = false,
  }) {
    final cacheKey = 'keyword_details::$keywordId';
    return _cached(
      cacheKey,
      () async {
        final payload = await _getJson('/keyword/$keywordId');
        return KeywordDetails.fromJson(payload);
      },
      forceRefresh: forceRefresh,
      ttlSeconds: CacheService.defaultTTL,
    );
  }

  Future<PaginatedResponse<Movie>> fetchKeywordMovies({
    required int keywordId,
    int page = 1,
    String sortBy = 'popularity.desc',
    bool includeAdult = false,
    bool forceRefresh = false,
  }) {
    final payload = _getJson(
      '/discover/movie',
      query: {
        'with_keywords': '$keywordId',
        'page': '$page',
        'sort_by': sortBy,
        'include_adult': includeAdult.toString(),
      },
    );

    return payload.then((json) => _mapPaginated<Movie>(json, Movie.fromJson));
  }

  Future<PaginatedResponse<Movie>> fetchKeywordTvShows({
    required int keywordId,
    int page = 1,
    String sortBy = 'popularity.desc',
    bool forceRefresh = false,
  }) {
    final payload = _getJson(
      '/discover/tv',
      query: {
        'with_keywords': '$keywordId',
        'page': '$page',
        'sort_by': sortBy,
      },
    );

    return payload.then(
      (json) => _mapPaginated<Movie>(
        json,
        (raw) => Movie.fromJson(raw, mediaType: 'tv'),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Networks
  // ---------------------------------------------------------------------------

  Future<PaginatedResponse<Network>> fetchNetworks({
    String query = 'netflix',
    String? country,
    int page = 1,
    bool forceRefresh = false,
  }) {
    final normalized = query.trim().isEmpty ? 'netflix' : query.trim();
    final cacheKey = 'search_network::$normalized::$country::$page';

    return _cached(
      cacheKey,
      () async {
        final payload = await _getJson(
          '/search/network',
          query: {'query': normalized, 'page': '$page'},
        );
        final networks = _mapPaginated<Network>(
          payload,
          Network.fromJson,
        ).results;
        final filtered = country == null
            ? networks
            : networks
                  .where(
                    (network) =>
                        (network.originCountry ?? '').toUpperCase() ==
                        country.toUpperCase(),
                  )
                  .toList(growable: false);
        return PaginatedResponse<Network>(
          page: payload['page'] is int
              ? payload['page'] as int
              : int.tryParse('${payload['page']}') ?? 1,
          totalPages: payload['total_pages'] is int
              ? payload['total_pages'] as int
              : int.tryParse('${payload['total_pages']}') ?? 1,
          totalResults: filtered.length,
          results: filtered,
        );
      },
      forceRefresh: forceRefresh,
      ttlSeconds: CacheService.defaultTTL,
    );
  }

  Future<PaginatedResponse<Network>> fetchPopularNetworks({
    int page = 1,
    bool forceRefresh = false,
  }) {
    final cacheKey = 'popular_networks::$page';
    return _cached(
      cacheKey,
      () async {
        final payload = await _getJson(
          '/discover/tv',
          query: {'page': '$page', 'sort_by': 'popularity.desc'},
        );

        final seen = <int>{};
        final networks = <Network>[];
        final results = payload['results'] as List? ?? const [];
        for (final item in results.whereType<Map<String, dynamic>>()) {
          final items = item['networks'];
          if (items is List) {
            for (final network in items.whereType<Map<String, dynamic>>()) {
              final parsed = Network.fromJson(network);
              if (seen.add(parsed.id)) {
                networks.add(parsed);
              }
            }
          }
        }

        return PaginatedResponse<Network>(
          page: payload['page'] is int
              ? payload['page'] as int
              : int.tryParse('${payload['page']}') ?? 1,
          totalPages: payload['total_pages'] is int
              ? payload['total_pages'] as int
              : int.tryParse('${payload['total_pages']}') ?? 1,
          totalResults: networks.length,
          results: networks,
        );
      },
      forceRefresh: forceRefresh,
      ttlSeconds: CacheService.defaultTTL,
    );
  }

  Future<NetworkDetailed> fetchNetworkDetails(
    int networkId, {
    bool forceRefresh = false,
  }) {
    final cacheKey = 'network::$networkId';
    return _cached(
      cacheKey,
      () async {
        final details = await _getJson('/network/$networkId');
        final altNames = await _getJson(
          '/network/$networkId/alternative_names',
        );

        final normalized = Map<String, dynamic>.from(details);
        final alt = altNames['results'];
        if (alt is List) {
          normalized['alternative_names'] = alt
              .whereType<Map<String, dynamic>>()
              .map(
                (item) => {
                  'name': item['name'] ?? '',
                  'type': item['type'] ?? 'official',
                },
              )
              .toList(growable: false);
        }

        return NetworkDetailed.fromJson(normalized);
      },
      forceRefresh: forceRefresh,
      ttlSeconds: CacheService.defaultTTL,
    );
  }

  Future<List<ImageModel>> fetchNetworkLogos(
    int networkId, {
    bool forceRefresh = false,
  }) async {
    final payload = await _getJson('/network/$networkId/images');
    final logos = payload['logos'];
    if (logos is! List) {
      return const [];
    }
    return logos
        .whereType<Map<String, dynamic>>()
        .map(ImageModel.fromJson)
        .toList(growable: false);
  }

  Future<PaginatedResponse<Movie>> fetchNetworkTvShows({
    required int networkId,
    int page = 1,
    String sortBy = 'popularity.desc',
    double? minVoteAverage,
    String? originalLanguage,
    bool forceRefresh = false,
  }) {
    final params = <String, String>{
      'with_networks': '$networkId',
      'page': '$page',
      'sort_by': sortBy,
      if (minVoteAverage != null) 'vote_average.gte': minVoteAverage.toString(),
      if (originalLanguage != null && originalLanguage.trim().isNotEmpty)
        'with_original_language': originalLanguage,
    };

    return _cached(
      'network_tv::$networkId::$page::$sortBy::${minVoteAverage ?? ''}::${originalLanguage ?? ''}',
      () async {
        final payload = await _getJson('/discover/tv', query: params);
        return _mapPaginated<Movie>(
          payload,
          (json) => Movie.fromJson(json, mediaType: 'tv'),
        );
      },
      forceRefresh: forceRefresh,
      ttlSeconds: CacheService.defaultTTL,
    );
  }

  // ---------------------------------------------------------------------------
  // Search & Multi
  // ---------------------------------------------------------------------------

  Future<SearchResponse> searchMulti(
    String query, {
    int page = 1,
    bool forceRefresh = false,
  }) {
    final normalized = query.trim();
    if (normalized.isEmpty) {
      return Future.value(const SearchResponse());
    }

    final cacheKey = 'search_multi::$normalized::$page';
    return _cached(
      cacheKey,
      () async {
        final payload = await _getJson(
          '/search/multi',
          query: {'query': normalized, 'page': '$page'},
        );
        return SearchResponse.fromJson(payload);
      },
      forceRefresh: forceRefresh,
      ttlSeconds: CacheService.searchTTL,
    );
  }

  // ---------------------------------------------------------------------------
  // Configuration / Reference Data
  // ---------------------------------------------------------------------------

  Future<ApiConfiguration> fetchConfiguration({bool forceRefresh = false}) {
    return _cached(
      'configuration',
      () async {
        final payload = await _getJson('/configuration');
        return ApiConfiguration.fromJson(payload);
      },
      forceRefresh: forceRefresh,
      ttlSeconds: CacheService.movieDetailsTTL,
    );
  }

  Future<List<LanguageInfo>> fetchLanguages({bool forceRefresh = false}) {
    return _cached(
      'languages',
      () async {
        final payload = await _getJson('/configuration/languages');
        final list = payload['results'] ?? payload;
        if (list is List) {
          return list
              .whereType<Map<String, dynamic>>()
              .map(LanguageInfo.fromJson)
              .toList(growable: false);
        }
        return const [];
      },
      forceRefresh: forceRefresh,
      ttlSeconds: CacheService.movieDetailsTTL,
    );
  }

  Future<List<CountryInfo>> fetchCountries({bool forceRefresh = false}) {
    return _cached(
      'countries',
      () async {
        final payload = await _getJson('/configuration/countries');
        final list = payload['results'] ?? payload;
        if (list is List) {
          return list
              .map((e) => e as Map<String, dynamic>)
              .map(CountryInfo.fromJson)
              .toList(growable: false);
        }
        return const [];
      },
      forceRefresh: forceRefresh,
      ttlSeconds: CacheService.movieDetailsTTL,
    );
  }

  Future<List<Timezone>> fetchTimezones({bool forceRefresh = false}) {
    return _cached(
      'timezones',
      () async {
        final payload = await _getJson('/configuration/timezones');
        final list = payload is List
            ? payload
            : (payload is Map<String, dynamic> ? payload['results'] : null);
        if (list is List) {
          return list
              .map((e) => e as Map<String, dynamic>)
              .map(Timezone.fromJson)
              .toList(growable: false);
        }
        return const [];
      },
      forceRefresh: forceRefresh,
      ttlSeconds: CacheService.movieDetailsTTL,
    );
  }

  Future<List<WatchProviderRegion>> fetchWatchProviderRegions({
    bool forceRefresh = false,
  }) {
    return _cached(
      'watch_provider_regions',
      () async {
        final payload = await _getJson('/watch/providers/regions');
        final results = payload['results'];
        if (results is! List) {
          return const [];
        }
        return results
            .whereType<Map<String, dynamic>>()
            .map(WatchProviderRegion.fromJson)
            .toList(growable: false);
      },
      forceRefresh: forceRefresh,
      ttlSeconds: CacheService.movieDetailsTTL,
    );
  }

  // Returns the catalog of watch providers for a media type localized by language
  Future<List<WatchProvider>> fetchProvidersCatalog({
    required String mediaType, // 'movie' | 'tv'
    required String language,
    bool forceRefresh = false,
  }) async {
    final key = 'providers_catalog::$mediaType::$language';
    return _cached(
      key,
      () async {
        final payload = await _getJson(
          '/watch/providers/$mediaType',
          query: {'language': language},
        );
        final results = payload['results'];
        if (results is! List) return const [];
        return results
            .whereType<Map<String, dynamic>>()
            .map(WatchProvider.fromJson)
            .toList(growable: false);
      },
      forceRefresh: forceRefresh,
      ttlSeconds: CacheService.movieDetailsTTL,
    );
  }

  Future<Map<String, WatchProviderResults>> fetchMovieWatchProviders(
    int movieId, {
    bool forceRefresh = false,
  }) async {
    final payload = await _getJson('/movie/$movieId/watch/providers');
    final results = payload['results'];
    if (results is! Map<String, dynamic>) {
      return const {};
    }

    return results.map((key, value) {
      if (value is Map<String, dynamic>) {
        return MapEntry(key, WatchProviderResults.fromJson(value));
      }
      return MapEntry(key, const WatchProviderResults());
    });
  }

  Future<Map<String, WatchProviderResults>> fetchTvWatchProviders(
    int tvId, {
    bool forceRefresh = false,
  }) async {
    final payload = await _getJson('/tv/$tvId/watch/providers');
    final results = payload['results'];
    if (results is! Map<String, dynamic>) {
      return const {};
    }

    return results.map((key, value) {
      if (value is Map<String, dynamic>) {
        return MapEntry(key, WatchProviderResults.fromJson(value));
      }
      return MapEntry(key, const WatchProviderResults());
    });
  }

  Future<Map<String, WatchProviderResults>> fetchWatchProviders({
    required String mediaType,
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'watch_providers::$mediaType';
    return _cached(
      cacheKey,
      () async {
        if (mediaType == 'movie') {
          final movies = await fetchTrendingMovies(forceRefresh: forceRefresh);
          if (movies.isNotEmpty) {
            return fetchMovieWatchProviders(
              movies.first.id,
              forceRefresh: forceRefresh,
            );
          }
        } else {
          final shows = await fetchTrendingTv(forceRefresh: forceRefresh);
          if (shows.results.isNotEmpty) {
            return fetchTvWatchProviders(
              shows.results.first.id,
              forceRefresh: forceRefresh,
            );
          }
        }
        return const {};
      },
      forceRefresh: forceRefresh,
      ttlSeconds: CacheService.defaultTTL,
    );
  }

  Future<Map<String, List<Certification>>> fetchMovieCertifications({
    bool forceRefresh = false,
  }) async {
    final payload = await _getJson('/certification/movie/list');
    final results = payload['certifications'];
    if (results is! Map<String, dynamic>) {
      return const {};
    }

    return results.map((key, value) {
      if (value is List) {
        final items = value
            .whereType<Map<String, dynamic>>()
            .map(Certification.fromJson)
            .toList(growable: false);
        return MapEntry(key, items);
      }
      return MapEntry(key, const <Certification>[]);
    });
  }

  Future<Map<String, List<Certification>>> fetchTvCertifications({
    bool forceRefresh = false,
  }) async {
    final payload = await _getJson('/certification/tv/list');
    final results = payload['certifications'];
    if (results is! Map<String, dynamic>) {
      return const {};
    }

    return results.map((key, value) {
      if (value is List) {
        final items = value
            .whereType<Map<String, dynamic>>()
            .map(Certification.fromJson)
            .toList(growable: false);
        return MapEntry(key, items);
      }
      return MapEntry(key, const <Certification>[]);
    });
  }

  Future<List<Genre>> fetchMovieGenres() async {
    final payload = await _getJson('/genre/movie/list');
    final genres = payload['genres'];
    if (genres is List) {
      return genres
          .whereType<Map<String, dynamic>>()
          .map(Genre.fromJson)
          .toList(growable: false);
    }
    return const [];
  }

  Future<List<Genre>> fetchTVGenres() async {
    final payload = await _getJson('/genre/tv/list');
    final genres = payload['genres'];
    if (genres is List) {
      return genres
          .whereType<Map<String, dynamic>>()
          .map(Genre.fromJson)
          .toList(growable: false);
    }
    return const [];
  }

  // Localized variants (explicit language parameter)
  Future<List<Genre>> fetchMovieGenresLocalized(String language) async {
    final payload = await _getJson(
      '/genre/movie/list',
      query: {'language': language},
    );
    final genres = payload['genres'];
    if (genres is List) {
      return genres
          .whereType<Map<String, dynamic>>()
          .map(Genre.fromJson)
          .toList(growable: false);
    }
    return const [];
  }

  Future<List<Genre>> fetchTVGenresLocalized(String language) async {
    final payload = await _getJson(
      '/genre/tv/list',
      query: {'language': language},
    );
    final genres = payload['genres'];
    if (genres is List) {
      return genres
          .whereType<Map<String, dynamic>>()
          .map(Genre.fromJson)
          .toList(growable: false);
    }
    return const [];
  }

  Future<List<CountryInfo>> fetchCountriesLocalized(
    String language, {
    bool forceRefresh = false,
  }) {
    return _cached(
      'countries::$language',
      () async {
        final payload = await _getJson(
          '/configuration/countries',
          query: {'language': language},
        );
        final list = payload['results'] ?? payload;
        if (list is List) {
          return list
              .whereType<Map<String, dynamic>>()
              .map(CountryInfo.fromJson)
              .toList(growable: false);
        }
        return const [];
      },
      forceRefresh: forceRefresh,
      ttlSeconds: CacheService.movieDetailsTTL,
    );
  }
}

class TmdbException implements Exception {
  const TmdbException(this.message);
  final String message;
  @override
  String toString() => 'TmdbException: $message';
}
