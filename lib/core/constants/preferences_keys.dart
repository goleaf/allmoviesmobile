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

  // Presentation
  static const String imageQuality = 'settings.image_quality';
  static const String accessibilityHighContrast =
      'settings.accessibility.high_contrast';
  static const String accessibilityColorBlind =
      'settings.accessibility.color_blind';
  static const String accessibilityBoldText =
      'settings.accessibility.bold_text';
  static const String accessibilityFocusIndicators =
      'settings.accessibility.focus_indicators';
  static const String accessibilityKeyboardHints =
      'settings.accessibility.keyboard_hints';
  static const String accessibilityTextScale =
      'settings.accessibility.text_scale';

  // Notifications
  static const String notificationsNewReleases =
      'settings.notifications.new_releases';
  static const String notificationsWatchlistAlerts =
      'settings.notifications.watchlist_alerts';
  static const String notificationsRecommendations =
      'settings.notifications.recommendations';
  static const String notificationsMarketing =
      'settings.notifications.marketing';
}
