class PreferenceKeys {
  PreferenceKeys._();

  // General content preferences
  static const String contentLanguage = 'settings.content_language';
  static const String region = 'settings.region';
  static const String contentRating = 'settings.content_rating';
  static const String includeAdult = 'settings.include_adult';

  // Sorting and filtering
  static const String defaultSort = 'settings.default_sort';
  static const String minUserScore = 'settings.min_user_score';
  static const String minVoteCount = 'settings.min_vote_count';
  static const String releaseYear = 'settings.release_year';
  static const String seriesFilterPresets =
      'settings.series.filter_presets';
  // Persist the last applied /discover/tv query so pagination and filters can
  // resume seamlessly when the app restarts.
  static const String tvDiscoverActiveFilters =
      'settings.series.active_filters';
  // Track which preset (if any) was used so we can highlight it in the UI.
  static const String tvDiscoverActivePresetName =
      'settings.series.active_preset';

  // Presentation
  static const String imageQuality = 'settings.image_quality';

  // Notifications
  static const String notificationsNewReleases =
      'settings.notifications.new_releases';
  static const String notificationsWatchlistAlerts =
      'settings.notifications.watchlist_alerts';
  static const String notificationsRecommendations =
      'settings.notifications.recommendations';
  static const String notificationsMarketing =
      'settings.notifications.marketing';
  static const String notificationsEnabled =
      'settings.notifications.enabled';
  static const String notificationsDeviceToken =
      'settings.notifications.device_token';
  static const String notificationsPermissionStatus =
      'settings.notifications.permission_status';
}
