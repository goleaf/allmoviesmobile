import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;
  late Map<String, dynamic> _localizedStrings;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    final instance = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );
    if (instance != null) return instance;
    // Fallback instance for tests or contexts without Localizations
    final fallback = AppLocalizations(const Locale('en'));
    fallback._localizedStrings = const <String, dynamic>{
      'app': {'name': 'AllMovies'},
      'navigation': {
        'movies': 'Movies',
        'series': 'Series',
        'people': 'People',
        'companies': 'Companies',
      },
      'common': {
        'cancel': 'Cancel',
        'retry': 'Retry',
        'from': 'From',
        'to': 'To',
        'page': 'Page',
        'of': 'of',
        'jump': 'Jump',
        'jumpToPage': 'Jump to page',
        'enterPageNumber': 'Enter page number',
        'apply': 'Apply',
      },
      'settings': {
        'title': 'Settings',
        'appearance': 'Appearance',
        'localization': 'Localization',
        'about': 'About',
        'appVersion': 'App version',
        'theme': 'Theme',
        'chooseTheme': 'Choose Theme',
        'language': 'Language',
        'chooseLanguage': 'Choose Language',
        'region': 'Region',
        'chooseRegion': 'Choose Region',
      },
      'home': {
        'trending': 'Trending',
        'trending_movies': 'Trending Movies',
        'trending_tv': 'Trending TV Shows',
        'popular': 'Popular',
        'popular_movies': 'Popular Movies',
        'popular_tv': 'Popular TV Shows',
        'top_rated': 'Top Rated',
        'new_releases': 'New Releases',
        'continue_watching': 'Continue Watching',
        'recommended': 'Recommended for You',
        'see_all': 'See All',
        'popular_people': 'Popular People',
        'featured_collections': 'Featured Collections',
        'quick_access': 'Quick Access',
        'quick_discover': 'Discover',
        'quick_trending': 'Trending',
        'quick_genres': 'Genres',
        'search_hint': 'Search movies, TV shows, people...',
      },
      'tv': {
        'overview': 'Overview',
        'season': 'Season',
        'episodes': 'Episodes',
      },
      'movie': {
        'overview': 'Overview',
        'cast': 'Cast',
        'crew': 'Crew',
        'videos': 'Videos',
        'images': 'Images',
        'movies': 'Movies',
      },
      'person': {
        'popularity': 'Popularity',
        'biography': 'Biography',
        'no_biography': 'No biography available',
        'known_for': 'Known for',
        'personal_info': 'Personal Info',
        'gender_female': 'Female',
        'gender_male': 'Male',
        'gender_non_binary': 'Non-binary',
        'known_for_department': 'Known for department',
        'also_known_as': 'Also known as',
        'translations': 'Translations',
        'image_gallery': 'Image gallery',
        'tagged_images': 'Tagged images',
        'movie_actor_timeline': 'Movie acting timeline',
        'no_movie_actor_credits': 'No movie acting credits',
        'movie_crew_departments': 'Movie crew departments',
        'no_movie_crew_credits': 'No movie crew credits',
        'tv_actor_timeline': 'TV acting timeline',
        'no_tv_actor_credits': 'No TV acting credits',
        'tv_crew_departments': 'TV crew departments',
      },
      'errors': {'generic': 'Something went wrong'},
      'discover': {
        'filters': 'Filters',
        'title': 'Discover',
        'byDecade': 'By Decade',
        'certification': 'Certification',
        'releaseDateRange': 'Release Date Range',
        'voteAverage': 'Vote Average',
        'runtimeMinutes': 'Runtime (minutes)',
        'voteCountMinimum': 'Vote Count Minimum',
        'monetizationTypes': 'Monetization Types',
        'watchProvidersIds': 'Watch Providers (IDs)',
        'watchProvidersHint': 'Comma-separated provider IDs, e.g., 8,9,337',
        'releaseType': 'Release Type',
        'includeAdultContent': 'Include Adult Content',
        'peopleCompaniesKeywords': 'People & Companies & Keywords',
        'hintWithCast': 'With Cast (comma-separated person IDs)',
        'hintWithCrew': 'With Crew (comma-separated person IDs)',
        'hintWithCompanies': 'With Companies (comma-separated company IDs)',
        'hintWithKeywords': 'With Keywords (comma-separated keyword IDs)',
      },
      'search': {'no_results': 'No results'},
    };
    return fallback;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en', ''),
    Locale('ru', ''),
    Locale('uk', ''),
  ];

  Future<bool> load() async {
    try {
      String jsonString = await rootBundle.loadString(
        'lib/core/localization/languages/${locale.languageCode}.json',
      );
      Map<String, dynamic> jsonMap = json.decode(jsonString);
      _localizedStrings = jsonMap;
      return true;
    } catch (e) {
      // Fallback to English if the language file is not found
      String jsonString = await rootBundle.loadString(
        'lib/core/localization/languages/en.json',
      );
      Map<String, dynamic> jsonMap = json.decode(jsonString);
      _localizedStrings = jsonMap;
      return true;
    }
  }

  String translate(String key) {
    List<String> keys = key.split('.');
    dynamic value = _localizedStrings;

    for (String k in keys) {
      if (value is Map && value.containsKey(k)) {
        value = value[k];
      } else {
        return key; // Return the key itself if translation is not found
      }
    }

    return value.toString();
  }

  // Convenience getters for common sections
  Map<String, dynamic> get app => _localizedStrings['app'] ?? {};
  Map<String, dynamic> get navigation => _localizedStrings['navigation'] ?? {};
  Map<String, dynamic> get home => _localizedStrings['home'] ?? {};
  Map<String, dynamic> get movie => _localizedStrings['movie'] ?? {};
  Map<String, dynamic> get tv => _localizedStrings['tv'] ?? {};
  Map<String, dynamic> get person => _localizedStrings['person'] ?? {};
  Map<String, dynamic> get company => _localizedStrings['company'] ?? {};
  Map<String, dynamic> get network => _localizedStrings['network'] ?? {};
  Map<String, dynamic> get search => _localizedStrings['search'] ?? {};
  Map<String, dynamic> get discover => _localizedStrings['discover'] ?? {};
  Map<String, dynamic> get favorites => _localizedStrings['favorites'] ?? {};
  Map<String, dynamic> get watchlist => _localizedStrings['watchlist'] ?? {};
  Map<String, dynamic> get settings => _localizedStrings['settings'] ?? {};
  Map<String, dynamic> get common => _localizedStrings['common'] ?? {};
  Map<String, dynamic> get errors => _localizedStrings['errors'] ?? {};
  Map<String, dynamic> get genres => _localizedStrings['genres'] ?? {};

  // Convenience method for direct access
  String t(String key) => translate(key);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ru', 'uk'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
