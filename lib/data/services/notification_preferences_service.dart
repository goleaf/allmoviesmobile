import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/preferences_keys.dart';

/// Thin wrapper around [SharedPreferences] that exposes strongly-typed access
/// to notification preference flags used throughout the app.
class NotificationPreferences {
  NotificationPreferences(this._prefs);

  final SharedPreferences _prefs;

  bool get recommendationsEnabled =>
      _prefs.getBool(PreferenceKeys.notificationsRecommendations) ?? true;

  bool get watchlistAlertsEnabled =>
      _prefs.getBool(PreferenceKeys.notificationsWatchlistAlerts) ?? true;

  bool get newReleasesEnabled =>
      _prefs.getBool(PreferenceKeys.notificationsNewReleases) ?? true;

  bool get marketingEnabled =>
      _prefs.getBool(PreferenceKeys.notificationsMarketing) ?? false;
}
