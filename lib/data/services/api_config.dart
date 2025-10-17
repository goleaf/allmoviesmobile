class ApiConfig {
  ApiConfig._();

  // TMDB API Configuration
  static const String tmdbBaseUrl = 'https://api.themoviedb.org/3';
  static const String tmdbImageBaseUrl = 'https://image.tmdb.org/t/p';
  
  // Image sizes
  static const String posterSizeSmall = 'w185';
  static const String posterSizeMedium = 'w342';
  static const String posterSizeLarge = 'w500';
  static const String posterSizeOriginal = 'original';
  
  static const String backdropSizeSmall = 'w300';
  static const String backdropSizeMedium = 'w780';
  static const String backdropSizeLarge = 'w1280';
  static const String backdropSizeOriginal = 'original';
  
  static const String profileSizeSmall = 'w45';
  static const String profileSizeMedium = 'w185';
  static const String profileSizeLarge = 'h632';
  static const String profileSizeOriginal = 'original';

  // API Endpoints
  static const String trendingMovies = '/trending/movie';
  static const String trendingTV = '/trending/tv';
  static const String trendingAll = '/trending/all';
  
  static const String movieDetails = '/movie';
  static const String tvDetails = '/tv';
  static const String personDetails = '/person';
  static const String companyDetails = '/company';
  
  static const String discoverMovie = '/discover/movie';
  static const String discoverTV = '/discover/tv';
  
  static const String searchMovie = '/search/movie';
  static const String searchTV = '/search/tv';
  static const String searchPerson = '/search/person';
  static const String searchMulti = '/search/multi';
  
  static const String genresMovie = '/genre/movie/list';
  static const String genresTV = '/genre/tv/list';

  // Helper methods to build image URLs
  static String getPosterUrl(String? path, {String size = posterSizeMedium}) {
    if (path == null || path.isEmpty) return '';
    return '$tmdbImageBaseUrl/$size$path';
  }

  static String getBackdropUrl(String? path, {String size = backdropSizeMedium}) {
    if (path == null || path.isEmpty) return '';
    return '$tmdbImageBaseUrl/$size$path';
  }

  static String getProfileUrl(String? path, {String size = profileSizeMedium}) {
    if (path == null || path.isEmpty) return '';
    return '$tmdbImageBaseUrl/$size$path';
  }

  static String getLogoUrl(String? path, {String size = posterSizeSmall}) {
    if (path == null || path.isEmpty) return '';
    return '$tmdbImageBaseUrl/$size$path';
  }

  // Cache TTL values (in seconds)
  static const int cacheTTLShort = 300; // 5 minutes
  static const int cacheTTLMedium = 1800; // 30 minutes
  static const int cacheTTLLong = 3600; // 1 hour
  static const int cacheTTLVeryLong = 86400; // 24 hours
}

