import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/preferences_keys.dart';

class PreferencesProvider extends ChangeNotifier {
  PreferencesProvider(this._prefs)
    : _includeAdult = _prefs.getBool(PreferenceKeys.includeAdult) ?? false;

  final SharedPreferences _prefs;

  bool _includeAdult;

  bool get includeAdult => _includeAdult;

  Future<void> setIncludeAdult(bool value) async {
    if (value == _includeAdult) return;
    _includeAdult = value;
    await _prefs.setBool(PreferenceKeys.includeAdult, value);
    notifyListeners();
  }

  bool get notificationsNewReleases =>
      _prefs.getBool(PreferenceKeys.notificationsNewReleases) ?? true;

  Future<void> setNotificationsNewReleases(bool value) async {
    if (value == notificationsNewReleases) return;
    await _prefs.setBool(PreferenceKeys.notificationsNewReleases, value);
    notifyListeners();
  }

  bool get notificationsWatchlistAlerts =>
      _prefs.getBool(PreferenceKeys.notificationsWatchlistAlerts) ?? true;

  Future<void> setNotificationsWatchlistAlerts(bool value) async {
    if (value == notificationsWatchlistAlerts) return;
    await _prefs.setBool(PreferenceKeys.notificationsWatchlistAlerts, value);
    notifyListeners();
  }

  bool get notificationsRecommendations =>
      _prefs.getBool(PreferenceKeys.notificationsRecommendations) ?? true;

  Future<void> setNotificationsRecommendations(bool value) async {
    if (value == notificationsRecommendations) return;
    await _prefs.setBool(PreferenceKeys.notificationsRecommendations, value);
    notifyListeners();
  }

  bool get notificationsMarketing =>
      _prefs.getBool(PreferenceKeys.notificationsMarketing) ?? false;

  Future<void> setNotificationsMarketing(bool value) async {
    if (value == notificationsMarketing) return;
    await _prefs.setBool(PreferenceKeys.notificationsMarketing, value);
    notifyListeners();
  }

  // Default discover sort (stored as raw string like 'popularity.desc')
  String get defaultDiscoverSortRaw =>
      _prefs.getString(PreferenceKeys.defaultSort) ?? 'popularity.desc';

  Future<void> setDefaultDiscoverSortRaw(String raw) async {
    final normalized = raw.trim();
    if (normalized.isEmpty) return;
    if (normalized == defaultDiscoverSortRaw) return;
    await _prefs.setString(PreferenceKeys.defaultSort, normalized);
    notifyListeners();
  }

  int get defaultMinVoteCount =>
      _prefs.getInt(PreferenceKeys.minVoteCount) ?? 0;

  Future<void> setDefaultMinVoteCount(int count) async {
    final normalized = count < 0 ? 0 : count;
    if (normalized == defaultMinVoteCount) return;
    await _prefs.setInt(PreferenceKeys.minVoteCount, normalized);
    notifyListeners();
  }

  double get defaultMinUserScore =>
      _prefs.getDouble(PreferenceKeys.minUserScore) ?? 0.0;

  Future<void> setDefaultMinUserScore(double score) async {
    var normalized = score;
    if (normalized < 0) normalized = 0;
    if (normalized > 10) normalized = 10;
    if (normalized == defaultMinUserScore) return;
    await _prefs.setDouble(PreferenceKeys.minUserScore, normalized);
    notifyListeners();
  }

  // Content rating preferences
  String? get certificationCountry =>
      _prefs.getString(PreferenceKeys.contentRating);

  Future<void> setCertificationCountry(String? country) async {
    if ((country ?? '') == (certificationCountry ?? '')) return;
    if (country == null || country.trim().isEmpty) {
      await _prefs.remove(PreferenceKeys.contentRating);
    } else {
      await _prefs.setString(
        PreferenceKeys.contentRating,
        country.trim().toUpperCase(),
      );
    }
    notifyListeners();
  }

  String? get certificationValue =>
      _prefs.getString('settings.certification.value');

  Future<void> setCertificationValue(String? value) async {
    if ((value ?? '') == (certificationValue ?? '')) return;
    if (value == null || value.trim().isEmpty) {
      await _prefs.remove('settings.certification.value');
    } else {
      await _prefs.setString('settings.certification.value', value.trim());
    }
    notifyListeners();
  }

  // Content rating (e.g., US: G/PG/PG-13/R/NC-17 or TV: TV-Y/TV-PG/TV-14/TV-MA)
  String get contentRating =>
      _prefs.getString(PreferenceKeys.contentRating) ?? '';

  Future<void> setContentRating(String rating) async {
    final normalized = rating.trim();
    if (normalized == contentRating) return;
    await _prefs.setString(PreferenceKeys.contentRating, normalized);
    notifyListeners();
  }

  // Image quality preference (e.g., low/medium/high/original)
  String get imageQuality =>
      _prefs.getString(PreferenceKeys.imageQuality) ?? 'medium';

  Future<void> setImageQuality(String quality) async {
    final normalized = quality.trim();
    if (normalized.isEmpty) return;
    if (normalized == imageQuality) return;
    await _prefs.setString(PreferenceKeys.imageQuality, normalized);
    notifyListeners();
  }
}
