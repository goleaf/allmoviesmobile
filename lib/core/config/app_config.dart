import 'api_keys.dart';

class AppConfig {
  AppConfig._();

  /// TMDB API Key
  static String get tmdbApiKey => ApiKeys.tmdbApiKey;

  /// TMDB API Base URL (v3)
  static const String tmdbBaseUrl = 'https://api.themoviedb.org/3';

  /// TMDB API Base URL (v4)
  static const String tmdbV4BaseUrl = 'https://api.themoviedb.org/4';

  /// TMDB Image Base URL
  static const String tmdbImageBaseUrl = 'https://image.tmdb.org/t/p';

  /// Default language
  static const String defaultLanguage = 'en-US';

  /// Request timeout duration
  static const Duration requestTimeout = Duration(seconds: 30);

  /// Cache duration for API responses
  static const Duration cacheDuration = Duration(hours: 6);
}
