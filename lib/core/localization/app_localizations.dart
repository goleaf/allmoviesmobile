import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'supported_locales.dart' as localization_metadata;

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
      'company': {
        'title': 'Company',
        'companies': 'Companies',
        'description': 'Description',
        'headquarters': 'Headquarters',
        'homepage': 'Homepage',
        'origin_country': 'Origin Country',
        'produced_movies': 'Produced Movies',
        'produced_series': 'Produced Series',
        'filter_label': 'Filter by country',
        'filter_all': 'All countries',
        'filter_empty': 'Country list will load automatically when online.',
        'empty_prompt': 'Search for a production company to get started.',
        'popular_title': 'Popular production companies',
        'popular_subtitle': 'Studios making headlines this week',
        'popular_empty': 'Trending studios will appear here soon.',
        'logo_gallery': 'Logo gallery',
      },
      'common': {
        'cancel': 'Cancel',
        'retry': 'Retry',
        'refresh': 'Refresh',
        'from': 'From',
        'to': 'To',
        'page': 'Page',
        'of': 'of',
        'jump': 'Jump',
        'jumpToPage': 'Jump to page',
        'enterPageNumber': 'Enter page number',
        'apply': 'Apply',
        'viewDetailsHint': 'Double tap to view details',
        'posterLabelPrefix': 'Poster for',
        'profileLabelPrefix': 'Profile image of',
        'addToFavorites': 'Add to favorites',
        'removeFromFavorites': 'Remove from favorites',
      },
      'settings': {
        'title': 'Settings',
        'appearance': 'Appearance',
        'accessibility': 'Accessibility',
        'localization': 'Localization',
        'about': 'About',
        'appVersion': 'App version',
        'theme': 'Theme',
        'chooseTheme': 'Choose Theme',
        'language': 'Language',
        'chooseLanguage': 'Choose Language',
        'region': 'Region',
        'chooseRegion': 'Choose Region',
        'high_contrast': 'High contrast mode',
        'high_contrast_description':
            'Increase color contrast for better readability.',
        'color_blind_friendly': 'Color-blind friendly palette',
        'color_blind_friendly_description':
            'Use palettes that remain legible for common color blindness.',
        'text_size': 'Text size',
        'text_size_description': 'Adjust interface text scale.',
      },
      'home': {
        'trending': 'Trending',
        'quick_access': 'Quick Access',
        'genres': 'Genres',
        'of_the_moment_movies': '“Of the moment” movies',
        'of_the_moment_tv': '“Of the moment” TV shows',
        'popular_people': 'Popular people',
        'featured_collections': 'Featured collections',
        'new_releases': 'New Releases',
        'continue_watching': 'Continue Watching',
        'personalized_recommendations': 'Recommended for you',
      },
      'tv': {
        'overview': 'Overview',
        'season': 'Season',
        'episodes': 'Episodes',
        'no_images': 'No images available for this season',
        'season_images_title': 'Season {seasonNumber} images',
        'no_episodes': 'No episodes available',
        'episode_groups': 'Episode Groups',
        'episode_group_no_episodes': 'No episodes available for this group',
        'episode_group_order': 'Order {order}',
        'episode_group_node_fallback': 'Group {order}',
        'episode_group_group_count': '{count} collections',
        'episode_group_episode_count': '{count} episodes',
        'episode_group_network': 'Network: {network}',
        'episode_group_type_unknown': 'Custom order',
        'episode_group_type_1': 'Original air date order',
        'episode_group_type_2': 'Absolute order',
        'episode_group_type_3': 'DVD release order',
        'episode_group_type_4': 'Digital release order',
        'episode_group_type_5': 'Story arc order',
        'episode_group_type_6': 'Production order',
        'episode_group_type_7': 'TV order',
      },
      'episode': {
        'title': 'Episode',
        'cast': 'Cast',
        'guest_stars': 'Guest stars',
        'crew': 'Crew',
        'videos': 'Videos & trailers',
        'images': 'Episode images',
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
      'people': {
        'departments': {
          'label': 'Department',
          'all': 'All departments',
          'acting': 'Acting',
          'directing': 'Directing',
          'production': 'Production',
          'writing': 'Writing',
          'editing': 'Editing',
          'camera': 'Camera',
          'sound': 'Sound',
          'art': 'Art',
          'costume_and_make_up': 'Costume & Make-Up',
          'crew': 'Crew',
          'lighting': 'Lighting',
          'visual_effects': 'Visual Effects',
        },
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
      'accessibility': {
        'search_hint': 'Search for movies, shows, or people',
        'search_label': 'Search the catalog',
        'quick_access_navigation': 'Quick actions',
        'section_list_hint':
            'Horizontal list. Use left and right arrows to browse items.',
        'open_details': 'Open details',
        'favorite_add': 'Add to favorites',
        'favorite_remove': 'Remove from favorites',
        'navigation_drawer': 'Main navigation menu',
        'poster_label': 'Poster for {title}',
        'profile_label': 'Profile image for {name}',
        'collection_label': 'Collection poster for {title}',
      },
    };
    return fallback;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final List<Locale> supportedLocales = UnmodifiableListView(
    localization_metadata.supportedLocales,
  );

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
  Map<String, dynamic> get episode => _localizedStrings['episode'] ?? {};
  Map<String, dynamic> get person => _localizedStrings['person'] ?? {};
  Map<String, dynamic> get company => _localizedStrings['company'] ?? {};
  Map<String, dynamic> get network => _localizedStrings['network'] ?? {};
  Map<String, dynamic> get search => _localizedStrings['search'] ?? {};
  Map<String, dynamic> get discover => _localizedStrings['discover'] ?? {};
  Map<String, dynamic> get favorites => _localizedStrings['favorites'] ?? {};
  Map<String, dynamic> get watchlist => _localizedStrings['watchlist'] ?? {};
  Map<String, dynamic> get settings => _localizedStrings['settings'] ?? {};
  Map<String, dynamic> get statistics => _localizedStrings['statistics'] ?? {};
  Map<String, dynamic> get common => _localizedStrings['common'] ?? {};
  Map<String, dynamic> get errors => _localizedStrings['errors'] ?? {};
  Map<String, dynamic> get genres => _localizedStrings['genres'] ?? {};
  Map<String, dynamic> get accessibility =>
      _localizedStrings['accessibility'] ?? {};

  // Convenience method for direct access
  String t(String key) => translate(key);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any(
      (supported) =>
          supported.languageCode == locale.languageCode &&
          (supported.countryCode == null ||
              supported.countryCode!.isEmpty ||
              supported.countryCode == locale.countryCode),
    );
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
