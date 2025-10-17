import '../../core/utils/media_image_helper.dart';

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
    return _buildUrl(
      path,
      type: MediaImageType.poster,
      size: size,
      fallback: posterSizeMedium,
    );
  }

  static String getBackdropUrl(String? path, {String size = backdropSizeMedium}) {
    return _buildUrl(
      path,
      type: MediaImageType.backdrop,
      size: size,
      fallback: backdropSizeMedium,
    );
  }

  static String getProfileUrl(String? path, {String size = profileSizeMedium}) {
    return _buildUrl(
      path,
      type: MediaImageType.profile,
      size: size,
      fallback: profileSizeMedium,
    );
  }

  static String getLogoUrl(String? path, {String size = posterSizeSmall}) {
    return _buildUrl(
      path,
      type: MediaImageType.logo,
      size: size,
      fallback: posterSizeSmall,
    );
  }

  // Cache TTL values (in seconds)
  static const int cacheTTLShort = 300; // 5 minutes
  static const int cacheTTLMedium = 1800; // 30 minutes
  static const int cacheTTLLong = 3600; // 1 hour
  static const int cacheTTLVeryLong = 86400; // 24 hours

  static String _buildUrl(
    String? path, {
    required MediaImageType type,
    required String size,
    required String fallback,
  }) {
    final resolvedSize = _sizeFromString(size) ?? _sizeFromString(fallback);
    final url = MediaImageHelper.buildUrl(
      path,
      type: type,
      size: resolvedSize,
    );
    return url ?? '';
  }

  static MediaImageSize? _sizeFromString(String value) {
    switch (value) {
      case 'w45':
        return MediaImageSize.w45;
      case 'w92':
        return MediaImageSize.w92;
      case 'w154':
        return MediaImageSize.w154;
      case 'w185':
        return MediaImageSize.w185;
      case 'w300':
        return MediaImageSize.w300;
      case 'w342':
        return MediaImageSize.w342;
      case 'w500':
        return MediaImageSize.w500;
      case 'w780':
        return MediaImageSize.w780;
      case 'w1280':
        return MediaImageSize.w1280;
      case 'h632':
        return MediaImageSize.h632;
      case 'original':
        return MediaImageSize.original;
    }
    return null;
  }
}
