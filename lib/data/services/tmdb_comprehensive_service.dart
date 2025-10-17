import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config/app_config.dart';

/// Comprehensive TMDB API Service with all v3 endpoints
/// Provides read-only access to all TMDB features
class TmdbComprehensiveService {
  TmdbComprehensiveService({
    http.Client? client,
    String? apiKey,
    String? language,
  })  : _client = client ?? http.Client(),
        _apiKey = apiKey ?? AppConfig.tmdbApiKey,
        _language = language ?? AppConfig.defaultLanguage;

  final http.Client _client;
  final String _apiKey;
  final String _language;

  // ==================== HELPER METHODS ====================

  Future<Map<String, dynamic>> _get(
    String endpoint, [
    Map<String, String>? queryParams,
  ]) async {
    final uri = Uri.https(
      'api.themoviedb.org',
      '/3$endpoint',
      {
        'api_key': _apiKey,
        'language': _language,
        if (queryParams != null) ...queryParams,
      },
    );

    final response = await _client.get(
      uri,
      headers: {'Accept': 'application/json'},
    ).timeout(AppConfig.requestTimeout);

    if (response.statusCode != 200) {
      throw TmdbServiceException(
        'Request failed with status ${response.statusCode}: ${response.body}',
        statusCode: response.statusCode,
      );
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  List<Map<String, dynamic>> _extractResults(Map<String, dynamic> data) {
    final results = data['results'];
    if (results is! List) return [];
    return results.whereType<Map<String, dynamic>>().toList();
  }

  // ==================== MOVIES ====================

  /// Get popular movies
  Future<Map<String, dynamic>> getPopularMovies({int page = 1}) async {
    return await _get('/movie/popular', {'page': '$page'});
  }

  /// Get top rated movies
  Future<Map<String, dynamic>> getTopRatedMovies({int page = 1}) async {
    return await _get('/movie/top_rated', {'page': '$page'});
  }

  /// Get now playing movies
  Future<Map<String, dynamic>> getNowPlayingMovies({int page = 1}) async {
    return await _get('/movie/now_playing', {'page': '$page'});
  }

  /// Get upcoming movies
  Future<Map<String, dynamic>> getUpcomingMovies({int page = 1}) async {
    return await _get('/movie/upcoming', {'page': '$page'});
  }

  /// Get movie details
  Future<Map<String, dynamic>> getMovieDetails(
    int movieId, {
    String? appendToResponse,
  }) async {
    return await _get(
      '/movie/$movieId',
      appendToResponse != null
          ? {'append_to_response': appendToResponse}
          : null,
    );
  }

  /// Get movie credits
  Future<Map<String, dynamic>> getMovieCredits(int movieId) async {
    return await _get('/movie/$movieId/credits');
  }

  /// Get movie videos
  Future<Map<String, dynamic>> getMovieVideos(int movieId) async {
    return await _get('/movie/$movieId/videos');
  }

  /// Get movie images
  Future<Map<String, dynamic>> getMovieImages(int movieId) async {
    return await _get('/movie/$movieId/images', {'include_image_language': 'en,null'});
  }

  /// Get movie keywords
  Future<Map<String, dynamic>> getMovieKeywords(int movieId) async {
    return await _get('/movie/$movieId/keywords');
  }

  /// Get movie recommendations
  Future<Map<String, dynamic>> getMovieRecommendations(
    int movieId, {
    int page = 1,
  }) async {
    return await _get('/movie/$movieId/recommendations', {'page': '$page'});
  }

  /// Get similar movies
  Future<Map<String, dynamic>> getSimilarMovies(
    int movieId, {
    int page = 1,
  }) async {
    return await _get('/movie/$movieId/similar', {'page': '$page'});
  }

  /// Get movie reviews
  Future<Map<String, dynamic>> getMovieReviews(
    int movieId, {
    int page = 1,
  }) async {
    return await _get('/movie/$movieId/reviews', {'page': '$page'});
  }

  /// Get movie watch providers
  Future<Map<String, dynamic>> getMovieWatchProviders(int movieId) async {
    return await _get('/movie/$movieId/watch/providers');
  }

  /// Get movie translations
  Future<Map<String, dynamic>> getMovieTranslations(int movieId) async {
    return await _get('/movie/$movieId/translations');
  }

  /// Get movie alternative titles
  Future<Map<String, dynamic>> getMovieAlternativeTitles(int movieId) async {
    return await _get('/movie/$movieId/alternative_titles');
  }

  /// Get movie release dates
  Future<Map<String, dynamic>> getMovieReleaseDates(int movieId) async {
    return await _get('/movie/$movieId/release_dates');
  }

  /// Get movie external IDs
  Future<Map<String, dynamic>> getMovieExternalIds(int movieId) async {
    return await _get('/movie/$movieId/external_ids');
  }

  /// Get latest movie
  Future<Map<String, dynamic>> getLatestMovie() async {
    return await _get('/movie/latest');
  }

  // ==================== TV SHOWS ====================

  /// Get popular TV shows
  Future<Map<String, dynamic>> getPopularTVShows({int page = 1}) async {
    return await _get('/tv/popular', {'page': '$page'});
  }

  /// Get top rated TV shows
  Future<Map<String, dynamic>> getTopRatedTVShows({int page = 1}) async {
    return await _get('/tv/top_rated', {'page': '$page'});
  }

  /// Get TV shows airing today
  Future<Map<String, dynamic>> getTVShowsAiringToday({int page = 1}) async {
    return await _get('/tv/airing_today', {'page': '$page'});
  }

  /// Get TV shows on the air
  Future<Map<String, dynamic>> getTVShowsOnTheAir({int page = 1}) async {
    return await _get('/tv/on_the_air', {'page': '$page'});
  }

  /// Get TV show details
  Future<Map<String, dynamic>> getTVShowDetails(
    int tvId, {
    String? appendToResponse,
  }) async {
    return await _get(
      '/tv/$tvId',
      appendToResponse != null
          ? {'append_to_response': appendToResponse}
          : null,
    );
  }

  /// Get TV show credits
  Future<Map<String, dynamic>> getTVShowCredits(int tvId) async {
    return await _get('/tv/$tvId/credits');
  }

  /// Get TV show aggregate credits
  Future<Map<String, dynamic>> getTVShowAggregateCredits(int tvId) async {
    return await _get('/tv/$tvId/aggregate_credits');
  }

  /// Get TV show videos
  Future<Map<String, dynamic>> getTVShowVideos(int tvId) async {
    return await _get('/tv/$tvId/videos');
  }

  /// Get TV show images
  Future<Map<String, dynamic>> getTVShowImages(int tvId) async {
    return await _get('/tv/$tvId/images', {'include_image_language': 'en,null'});
  }

  /// Get TV show keywords
  Future<Map<String, dynamic>> getTVShowKeywords(int tvId) async {
    return await _get('/tv/$tvId/keywords');
  }

  /// Get TV show recommendations
  Future<Map<String, dynamic>> getTVShowRecommendations(
    int tvId, {
    int page = 1,
  }) async {
    return await _get('/tv/$tvId/recommendations', {'page': '$page'});
  }

  /// Get similar TV shows
  Future<Map<String, dynamic>> getSimilarTVShows(
    int tvId, {
    int page = 1,
  }) async {
    return await _get('/tv/$tvId/similar', {'page': '$page'});
  }

  /// Get TV show reviews
  Future<Map<String, dynamic>> getTVShowReviews(
    int tvId, {
    int page = 1,
  }) async {
    return await _get('/tv/$tvId/reviews', {'page': '$page'});
  }

  /// Get TV show watch providers
  Future<Map<String, dynamic>> getTVShowWatchProviders(int tvId) async {
    return await _get('/tv/$tvId/watch/providers');
  }

  /// Get TV show content ratings
  Future<Map<String, dynamic>> getTVShowContentRatings(int tvId) async {
    return await _get('/tv/$tvId/content_ratings');
  }

  /// Get TV show alternative titles
  Future<Map<String, dynamic>> getTVShowAlternativeTitles(int tvId) async {
    return await _get('/tv/$tvId/alternative_titles');
  }

  /// Get TV show translations
  Future<Map<String, dynamic>> getTVShowTranslations(int tvId) async {
    return await _get('/tv/$tvId/translations');
  }

  /// Get TV show external IDs
  Future<Map<String, dynamic>> getTVShowExternalIds(int tvId) async {
    return await _get('/tv/$tvId/external_ids');
  }

  /// Get TV show episode groups
  Future<Map<String, dynamic>> getTVShowEpisodeGroups(int tvId) async {
    return await _get('/tv/$tvId/episode_groups');
  }

  /// Get latest TV show
  Future<Map<String, dynamic>> getLatestTVShow() async {
    return await _get('/tv/latest');
  }

  // ==================== TV SEASONS ====================

  /// Get TV season details
  Future<Map<String, dynamic>> getTVSeasonDetails(
    int tvId,
    int seasonNumber, {
    String? appendToResponse,
  }) async {
    return await _get(
      '/tv/$tvId/season/$seasonNumber',
      appendToResponse != null
          ? {'append_to_response': appendToResponse}
          : null,
    );
  }

  /// Get TV season credits
  Future<Map<String, dynamic>> getTVSeasonCredits(
    int tvId,
    int seasonNumber,
  ) async {
    return await _get('/tv/$tvId/season/$seasonNumber/credits');
  }

  /// Get TV season aggregate credits
  Future<Map<String, dynamic>> getTVSeasonAggregateCredits(
    int tvId,
    int seasonNumber,
  ) async {
    return await _get('/tv/$tvId/season/$seasonNumber/aggregate_credits');
  }

  /// Get TV season videos
  Future<Map<String, dynamic>> getTVSeasonVideos(
    int tvId,
    int seasonNumber,
  ) async {
    return await _get('/tv/$tvId/season/$seasonNumber/videos');
  }

  /// Get TV season images
  Future<Map<String, dynamic>> getTVSeasonImages(
    int tvId,
    int seasonNumber,
  ) async {
    return await _get('/tv/$tvId/season/$seasonNumber/images');
  }

  /// Get TV season external IDs
  Future<Map<String, dynamic>> getTVSeasonExternalIds(
    int tvId,
    int seasonNumber,
  ) async {
    return await _get('/tv/$tvId/season/$seasonNumber/external_ids');
  }

  // ==================== TV EPISODES ====================

  /// Get TV episode details
  Future<Map<String, dynamic>> getTVEpisodeDetails(
    int tvId,
    int seasonNumber,
    int episodeNumber, {
    String? appendToResponse,
  }) async {
    return await _get(
      '/tv/$tvId/season/$seasonNumber/episode/$episodeNumber',
      appendToResponse != null
          ? {'append_to_response': appendToResponse}
          : null,
    );
  }

  /// Get TV episode credits
  Future<Map<String, dynamic>> getTVEpisodeCredits(
    int tvId,
    int seasonNumber,
    int episodeNumber,
  ) async {
    return await _get(
        '/tv/$tvId/season/$seasonNumber/episode/$episodeNumber/credits');
  }

  /// Get TV episode videos
  Future<Map<String, dynamic>> getTVEpisodeVideos(
    int tvId,
    int seasonNumber,
    int episodeNumber,
  ) async {
    return await _get(
        '/tv/$tvId/season/$seasonNumber/episode/$episodeNumber/videos');
  }

  /// Get TV episode images
  Future<Map<String, dynamic>> getTVEpisodeImages(
    int tvId,
    int seasonNumber,
    int episodeNumber,
  ) async {
    return await _get(
        '/tv/$tvId/season/$seasonNumber/episode/$episodeNumber/images');
  }

  /// Get TV episode external IDs
  Future<Map<String, dynamic>> getTVEpisodeExternalIds(
    int tvId,
    int seasonNumber,
    int episodeNumber,
  ) async {
    return await _get(
        '/tv/$tvId/season/$seasonNumber/episode/$episodeNumber/external_ids');
  }

  /// Get TV episode translations
  Future<Map<String, dynamic>> getTVEpisodeTranslations(
    int tvId,
    int seasonNumber,
    int episodeNumber,
  ) async {
    return await _get(
        '/tv/$tvId/season/$seasonNumber/episode/$episodeNumber/translations');
  }

  // ==================== PEOPLE ====================

  /// Get popular people
  Future<Map<String, dynamic>> getPopularPeople({int page = 1}) async {
    return await _get('/person/popular', {'page': '$page'});
  }

  /// Get person details
  Future<Map<String, dynamic>> getPersonDetails(
    int personId, {
    String? appendToResponse,
  }) async {
    return await _get(
      '/person/$personId',
      appendToResponse != null
          ? {'append_to_response': appendToResponse}
          : null,
    );
  }

  /// Get person movie credits
  Future<Map<String, dynamic>> getPersonMovieCredits(int personId) async {
    return await _get('/person/$personId/movie_credits');
  }

  /// Get person TV credits
  Future<Map<String, dynamic>> getPersonTVCredits(int personId) async {
    return await _get('/person/$personId/tv_credits');
  }

  /// Get person combined credits
  Future<Map<String, dynamic>> getPersonCombinedCredits(int personId) async {
    return await _get('/person/$personId/combined_credits');
  }

  /// Get person images
  Future<Map<String, dynamic>> getPersonImages(int personId) async {
    return await _get('/person/$personId/images');
  }

  /// Get person external IDs
  Future<Map<String, dynamic>> getPersonExternalIds(int personId) async {
    return await _get('/person/$personId/external_ids');
  }

  /// Get person translations
  Future<Map<String, dynamic>> getPersonTranslations(int personId) async {
    return await _get('/person/$personId/translations');
  }

  /// Get latest person
  Future<Map<String, dynamic>> getLatestPerson() async {
    return await _get('/person/latest');
  }

  // ==================== SEARCH ====================

  /// Search for movies
  Future<Map<String, dynamic>> searchMovies(
    String query, {
    int page = 1,
    bool includeAdult = false,
    int? year,
    int? primaryReleaseYear,
  }) async {
    return await _get('/search/movie', {
      'query': query,
      'page': '$page',
      'include_adult': '$includeAdult',
      if (year != null) 'year': '$year',
      if (primaryReleaseYear != null)
        'primary_release_year': '$primaryReleaseYear',
    });
  }

  /// Search for TV shows
  Future<Map<String, dynamic>> searchTVShows(
    String query, {
    int page = 1,
    bool includeAdult = false,
    int? firstAirDateYear,
  }) async {
    return await _get('/search/tv', {
      'query': query,
      'page': '$page',
      'include_adult': '$includeAdult',
      if (firstAirDateYear != null) 'first_air_date_year': '$firstAirDateYear',
    });
  }

  /// Search for people
  Future<Map<String, dynamic>> searchPeople(
    String query, {
    int page = 1,
    bool includeAdult = false,
  }) async {
    return await _get('/search/person', {
      'query': query,
      'page': '$page',
      'include_adult': '$includeAdult',
    });
  }

  /// Multi-search (movies, TV shows, people)
  Future<Map<String, dynamic>> searchMulti(
    String query, {
    int page = 1,
    bool includeAdult = false,
  }) async {
    return await _get('/search/multi', {
      'query': query,
      'page': '$page',
      'include_adult': '$includeAdult',
    });
  }

  /// Search for companies
  Future<Map<String, dynamic>> searchCompanies(
    String query, {
    int page = 1,
  }) async {
    return await _get('/search/company', {
      'query': query,
      'page': '$page',
    });
  }

  /// Search for keywords
  Future<Map<String, dynamic>> searchKeywords(
    String query, {
    int page = 1,
  }) async {
    return await _get('/search/keyword', {
      'query': query,
      'page': '$page',
    });
  }

  /// Search for collections
  Future<Map<String, dynamic>> searchCollections(
    String query, {
    int page = 1,
  }) async {
    return await _get('/search/collection', {
      'query': query,
      'page': '$page',
    });
  }

  // ==================== DISCOVER ====================

  /// Discover movies with advanced filters
  Future<Map<String, dynamic>> discoverMovies({
    int page = 1,
    String? sortBy,
    String? certificationCountry,
    String? certification,
    String? certificationLte,
    String? certificationGte,
    bool? includeAdult,
    bool? includeVideo,
    int? year,
    int? primaryReleaseYear,
    String? primaryReleaseDateGte,
    String? primaryReleaseDateLte,
    String? releaseDateGte,
    String? releaseDateLte,
    String? withReleaseType,
    double? voteCountGte,
    double? voteCountLte,
    double? voteAverageGte,
    double? voteAverageLte,
    String? withCast,
    String? withCrew,
    String? withPeople,
    String? withCompanies,
    String? withGenres,
    String? withoutGenres,
    String? withKeywords,
    String? withoutKeywords,
    int? withRuntime Gte,
    int? withRuntimeLte,
    String? withOriginalLanguage,
    String? withWatchProviders,
    String? watchRegion,
    String? withWatchMonetizationTypes,
  }) async {
    return await _get('/discover/movie', {
      'page': '$page',
      if (sortBy != null) 'sort_by': sortBy,
      if (certificationCountry != null)
        'certification_country': certificationCountry,
      if (certification != null) 'certification': certification,
      if (certificationLte != null) 'certification.lte': certificationLte,
      if (certificationGte != null) 'certification.gte': certificationGte,
      if (includeAdult != null) 'include_adult': '$includeAdult',
      if (includeVideo != null) 'include_video': '$includeVideo',
      if (year != null) 'year': '$year',
      if (primaryReleaseYear != null) 'primary_release_year': '$primaryReleaseYear',
      if (primaryReleaseDateGte != null)
        'primary_release_date.gte': primaryReleaseDateGte,
      if (primaryReleaseDateLte != null)
        'primary_release_date.lte': primaryReleaseDateLte,
      if (releaseDateGte != null) 'release_date.gte': releaseDateGte,
      if (releaseDateLte != null) 'release_date.lte': releaseDateLte,
      if (withReleaseType != null) 'with_release_type': withReleaseType,
      if (voteCountGte != null) 'vote_count.gte': '$voteCountGte',
      if (voteCountLte != null) 'vote_count.lte': '$voteCountLte',
      if (voteAverageGte != null) 'vote_average.gte': '$voteAverageGte',
      if (voteAverageLte != null) 'vote_average.lte': '$voteAverageLte',
      if (withCast != null) 'with_cast': withCast,
      if (withCrew != null) 'with_crew': withCrew,
      if (withPeople != null) 'with_people': withPeople,
      if (withCompanies != null) 'with_companies': withCompanies,
      if (withGenres != null) 'with_genres': withGenres,
      if (withoutGenres != null) 'without_genres': withoutGenres,
      if (withKeywords != null) 'with_keywords': withKeywords,
      if (withoutKeywords != null) 'without_keywords': withoutKeywords,
      if (withRuntimeGte != null) 'with_runtime.gte': '$withRuntimeGte',
      if (withRuntimeLte != null) 'with_runtime.lte': '$withRuntimeLte',
      if (withOriginalLanguage != null)
        'with_original_language': withOriginalLanguage,
      if (withWatchProviders != null) 'with_watch_providers': withWatchProviders,
      if (watchRegion != null) 'watch_region': watchRegion,
      if (withWatchMonetizationTypes != null)
        'with_watch_monetization_types': withWatchMonetizationTypes,
    });
  }

  /// Discover TV shows with advanced filters
  Future<Map<String, dynamic>> discoverTVShows({
    int page = 1,
    String? sortBy,
    String? airDateGte,
    String? airDateLte,
    String? firstAirDateGte,
    String? firstAirDateLte,
    int? firstAirDateYear,
    double? voteCountGte,
    double? voteCountLte,
    double? voteAverageGte,
    double? voteAverageLte,
    String? withGenres,
    String? withoutGenres,
    String? withKeywords,
    String? withoutKeywords,
    int? withRuntimeGte,
    int? withRuntimeLte,
    String? withOriginalLanguage,
    String? withNetworks,
    String? withCompanies,
    String? withWatchProviders,
    String? watchRegion,
    String? withWatchMonetizationTypes,
    bool? includeAdult,
    bool? screenedTheatrically,
  }) async {
    return await _get('/discover/tv', {
      'page': '$page',
      if (sortBy != null) 'sort_by': sortBy,
      if (airDateGte != null) 'air_date.gte': airDateGte,
      if (airDateLte != null) 'air_date.lte': airDateLte,
      if (firstAirDateGte != null) 'first_air_date.gte': firstAirDateGte,
      if (firstAirDateLte != null) 'first_air_date.lte': firstAirDateLte,
      if (firstAirDateYear != null) 'first_air_date_year': '$firstAirDateYear',
      if (voteCountGte != null) 'vote_count.gte': '$voteCountGte',
      if (voteCountLte != null) 'vote_count.lte': '$voteCountLte',
      if (voteAverageGte != null) 'vote_average.gte': '$voteAverageGte',
      if (voteAverageLte != null) 'vote_average.lte': '$voteAverageLte',
      if (withGenres != null) 'with_genres': withGenres,
      if (withoutGenres != null) 'without_genres': withoutGenres,
      if (withKeywords != null) 'with_keywords': withKeywords,
      if (withoutKeywords != null) 'without_keywords': withoutKeywords,
      if (withRuntimeGte != null) 'with_runtime.gte': '$withRuntimeGte',
      if (withRuntimeLte != null) 'with_runtime.lte': '$withRuntimeLte',
      if (withOriginalLanguage != null)
        'with_original_language': withOriginalLanguage,
      if (withNetworks != null) 'with_networks': withNetworks,
      if (withCompanies != null) 'with_companies': withCompanies,
      if (withWatchProviders != null) 'with_watch_providers': withWatchProviders,
      if (watchRegion != null) 'watch_region': watchRegion,
      if (withWatchMonetizationTypes != null)
        'with_watch_monetization_types': withWatchMonetizationTypes,
      if (includeAdult != null) 'include_adult': '$includeAdult',
      if (screenedTheatrically != null)
        'screened_theatrically': '$screenedTheatrically',
    });
  }

  // ==================== TRENDING ====================

  /// Get trending items (all, movie, tv, person)
  /// timeWindow: 'day' or 'week'
  /// mediaType: 'all', 'movie', 'tv', 'person'
  Future<Map<String, dynamic>> getTrending(
    String mediaType,
    String timeWindow, {
    int page = 1,
  }) async {
    return await _get('/trending/$mediaType/$timeWindow', {'page': '$page'});
  }

  // ==================== GENRES ====================

  /// Get movie genres
  Future<Map<String, dynamic>> getMovieGenres() async {
    return await _get('/genre/movie/list');
  }

  /// Get TV genres
  Future<Map<String, dynamic>> getTVGenres() async {
    return await _get('/genre/tv/list');
  }

  // ==================== KEYWORDS ====================

  /// Get keyword details
  Future<Map<String, dynamic>> getKeywordDetails(int keywordId) async {
    return await _get('/keyword/$keywordId');
  }

  /// Get movies by keyword
  Future<Map<String, dynamic>> getMoviesByKeyword(
    int keywordId, {
    int page = 1,
  }) async {
    return await _get('/keyword/$keywordId/movies', {'page': '$page'});
  }

  // ==================== COLLECTIONS ====================

  /// Get collection details
  Future<Map<String, dynamic>> getCollectionDetails(int collectionId) async {
    return await _get('/collection/$collectionId');
  }

  /// Get collection images
  Future<Map<String, dynamic>> getCollectionImages(int collectionId) async {
    return await _get('/collection/$collectionId/images');
  }

  /// Get collection translations
  Future<Map<String, dynamic>> getCollectionTranslations(int collectionId) async {
    return await _get('/collection/$collectionId/translations');
  }

  // ==================== COMPANIES ====================

  /// Get company details
  Future<Map<String, dynamic>> getCompanyDetails(int companyId) async {
    return await _get('/company/$companyId');
  }

  /// Get company alternative names
  Future<Map<String, dynamic>> getCompanyAlternativeNames(int companyId) async {
    return await _get('/company/$companyId/alternative_names');
  }

  /// Get company images
  Future<Map<String, dynamic>> getCompanyImages(int companyId) async {
    return await _get('/company/$companyId/images');
  }

  // ==================== NETWORKS ====================

  /// Get network details
  Future<Map<String, dynamic>> getNetworkDetails(int networkId) async {
    return await _get('/network/$networkId');
  }

  /// Get network alternative names
  Future<Map<String, dynamic>> getNetworkAlternativeNames(int networkId) async {
    return await _get('/network/$networkId/alternative_names');
  }

  /// Get network images
  Future<Map<String, dynamic>> getNetworkImages(int networkId) async {
    return await _get('/network/$networkId/images');
  }

  // ==================== WATCH PROVIDERS ====================

  /// Get available watch provider regions
  Future<Map<String, dynamic>> getWatchProviderRegions({
    String? language,
  }) async {
    return await _get(
      '/watch/providers/regions',
      language != null ? {'language': language} : null,
    );
  }

  /// Get movie watch providers
  Future<Map<String, dynamic>> getMovieWatchProvidersAvailable({
    String? language,
    String? watchRegion,
  }) async {
    return await _get('/watch/providers/movie', {
      if (language != null) 'language': language,
      if (watchRegion != null) 'watch_region': watchRegion,
    });
  }

  /// Get TV watch providers
  Future<Map<String, dynamic>> getTVWatchProvidersAvailable({
    String? language,
    String? watchRegion,
  }) async {
    return await _get('/watch/providers/tv', {
      if (language != null) 'language': language,
      if (watchRegion != null) 'watch_region': watchRegion,
    });
  }

  // ==================== REVIEWS ====================

  /// Get review details
  Future<Map<String, dynamic>> getReviewDetails(String reviewId) async {
    return await _get('/review/$reviewId');
  }

  // ==================== CERTIFICATIONS ====================

  /// Get movie certifications
  Future<Map<String, dynamic>> getMovieCertifications() async {
    return await _get('/certification/movie/list');
  }

  /// Get TV certifications
  Future<Map<String, dynamic>> getTVCertifications() async {
    return await _get('/certification/tv/list');
  }

  // ==================== CHANGES ====================

  /// Get movie changes
  Future<Map<String, dynamic>> getMovieChanges(
    int movieId, {
    String? startDate,
    String? endDate,
    int page = 1,
  }) async {
    return await _get('/movie/$movieId/changes', {
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      'page': '$page',
    });
  }

  /// Get TV show changes
  Future<Map<String, dynamic>> getTVShowChanges(
    int tvId, {
    String? startDate,
    String? endDate,
    int page = 1,
  }) async {
    return await _get('/tv/$tvId/changes', {
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      'page': '$page',
    });
  }

  /// Get person changes
  Future<Map<String, dynamic>> getPersonChanges(
    int personId, {
    String? startDate,
    String? endDate,
    int page = 1,
  }) async {
    return await _get('/person/$personId/changes', {
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      'page': '$page',
    });
  }

  /// Get movie change list
  Future<Map<String, dynamic>> getMovieChangeList({
    String? startDate,
    String? endDate,
    int page = 1,
  }) async {
    return await _get('/movie/changes', {
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      'page': '$page',
    });
  }

  /// Get TV change list
  Future<Map<String, dynamic>> getTVChangeList({
    String? startDate,
    String? endDate,
    int page = 1,
  }) async {
    return await _get('/tv/changes', {
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      'page': '$page',
    });
  }

  /// Get person change list
  Future<Map<String, dynamic>> getPersonChangeList({
    String? startDate,
    String? endDate,
    int page = 1,
  }) async {
    return await _get('/person/changes', {
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      'page': '$page',
    });
  }

  // ==================== CONFIGURATION ====================

  /// Get API configuration
  Future<Map<String, dynamic>> getConfiguration() async {
    return await _get('/configuration');
  }

  /// Get countries list
  Future<List<Map<String, dynamic>>> getCountries() async {
    final response = await _get('/configuration/countries');
    if (response is List) {
      return response.whereType<Map<String, dynamic>>().toList();
    }
    return [];
  }

  /// Get jobs list
  Future<List<Map<String, dynamic>>> getJobs() async {
    final response = await _get('/configuration/jobs');
    if (response is List) {
      return response.whereType<Map<String, dynamic>>().toList();
    }
    return [];
  }

  /// Get languages list
  Future<List<Map<String, dynamic>>> getLanguages() async {
    final response = await _get('/configuration/languages');
    if (response is List) {
      return response.whereType<Map<String, dynamic>>().toList();
    }
    return [];
  }

  /// Get primary translations
  Future<List<String>> getPrimaryTranslations() async {
    final response = await _get('/configuration/primary_translations');
    if (response is List) {
      return response.whereType<String>().toList();
    }
    return [];
  }

  /// Get timezones
  Future<List<Map<String, dynamic>>> getTimezones() async {
    final response = await _get('/configuration/timezones');
    if (response is List) {
      return response.whereType<Map<String, dynamic>>().toList();
    }
    return [];
  }

  // ==================== FIND ====================

  /// Find by external ID (IMDB, TVDB, etc.)
  /// externalSource: 'imdb_id', 'tvdb_id', 'facebook_id', 'instagram_id', 'twitter_id'
  Future<Map<String, dynamic>> findByExternalId(
    String externalId,
    String externalSource,
  ) async {
    return await _get('/find/$externalId', {'external_source': externalSource});
  }
}

/// Custom exception for TMDB service errors
class TmdbServiceException implements Exception {
  TmdbServiceException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'TmdbServiceException: $message';
}

