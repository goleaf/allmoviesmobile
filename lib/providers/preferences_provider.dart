import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/preferences_keys.dart';
import '../data/models/series_filter_preset.dart';

class PreferencesProvider extends ChangeNotifier {
  PreferencesProvider(this._prefs)
      : _includeAdult = _prefs.getBool(PreferenceKeys.includeAdult) ?? false,
        _notificationsNewReleases =
            _prefs.getBool(PreferenceKeys.notificationsNewReleases) ?? false,
        _notificationsWatchlistAlerts =
            _prefs.getBool(PreferenceKeys.notificationsWatchlistAlerts) ??
                false,
        _notificationsRecommendations =
            _prefs.getBool(PreferenceKeys.notificationsRecommendations) ??
                false,
        _notificationsMarketing =
            _prefs.getBool(PreferenceKeys.notificationsMarketing) ?? false;

  final SharedPreferences _prefs;

  bool _includeAdult;
  bool _notificationsNewReleases;
  bool _notificationsWatchlistAlerts;
  bool _notificationsRecommendations;
  bool _notificationsMarketing;

  bool get includeAdult => _includeAdult;
  bool get notificationsNewReleases => _notificationsNewReleases;
  bool get notificationsWatchlistAlerts => _notificationsWatchlistAlerts;
  bool get notificationsRecommendations => _notificationsRecommendations;
  bool get notificationsMarketing => _notificationsMarketing;

  Future<void> setIncludeAdult(bool value) async {
    if (value == _includeAdult) return;
    _includeAdult = value;
    await _prefs.setBool(PreferenceKeys.includeAdult, value);
    notifyListeners();
  }

  Future<void> setNotificationsNewReleases(bool value) async {
    if (value == _notificationsNewReleases) return;
    _notificationsNewReleases = value;
    await _prefs.setBool(PreferenceKeys.notificationsNewReleases, value);
    notifyListeners();
  }

  Future<void> setNotificationsWatchlistAlerts(bool value) async {
    if (value == _notificationsWatchlistAlerts) return;
    _notificationsWatchlistAlerts = value;
    await _prefs.setBool(PreferenceKeys.notificationsWatchlistAlerts, value);
    notifyListeners();
  }

  Future<void> setNotificationsRecommendations(bool value) async {
    if (value == _notificationsRecommendations) return;
    _notificationsRecommendations = value;
    await _prefs.setBool(PreferenceKeys.notificationsRecommendations, value);
    notifyListeners();
  }

  Future<void> setNotificationsMarketing(bool value) async {
    if (value == _notificationsMarketing) return;
    _notificationsMarketing = value;
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

  /// Read all saved TV series filter presets from preferences.
  List<SeriesFilterPreset> get seriesFilterPresets {
    final raw =
        _prefs.getStringList(PreferenceKeys.seriesFilterPresets) ?? const [];
    return raw
        .map(SeriesFilterPreset.fromJsonString)
        .whereType<SeriesFilterPreset>()
        .toList(growable: false);
  }

  /// Persist the provided collection of presets to preferences.
  Future<void> _writeSeriesFilterPresets(
    List<SeriesFilterPreset> presets,
  ) async {
    final payload = presets.map((preset) => preset.toJsonString()).toList();
    await _prefs.setStringList(PreferenceKeys.seriesFilterPresets, payload);
  }

  /// Add or replace a preset (matched by name) and notify listeners.
  Future<void> saveSeriesFilterPreset(SeriesFilterPreset preset) async {
    final existing = List<SeriesFilterPreset>.from(seriesFilterPresets);
    final index = existing.indexWhere(
      (element) => element.name.toLowerCase() == preset.name.toLowerCase(),
    );
    if (index >= 0) {
      existing[index] = preset;
    } else {
      existing.add(preset);
    }
    await _writeSeriesFilterPresets(existing);
    notifyListeners();
  }

  /// Remove the preset with the specified [name], if present.
  Future<void> deleteSeriesFilterPreset(String name) async {
    final filtered = seriesFilterPresets
        .where((preset) => preset.name.toLowerCase() != name.toLowerCase())
        .toList();
    await _writeSeriesFilterPresets(filtered);
    notifyListeners();
  }

  /// Restore the last applied `/3/discover/tv` filter query that we persisted so
  /// the TV browse screen can bootstrap itself with the user's previous
  /// selections.
  Map<String, String>? get tvDiscoverFilterPreset {
    final raw = _prefs.getString(PreferenceKeys.tvDiscoverActiveFilters);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        final restored = <String, String>{};
        decoded.forEach((key, value) {
          if (key is String && value is String) {
            restored[key] = value;
          }
        });
        return restored.isEmpty ? null : restored;
      }
    } catch (_) {
      // Ignore malformed payloads so corrupt entries do not crash the app.
    }
    return null;
  }

  /// Returns the name of the preset that produced the persisted filters, if any
  /// was involved during the last visit to the TV filters sheet.
  String? get tvDiscoverPresetName {
    final raw =
        _prefs.getString(PreferenceKeys.tvDiscoverActivePresetName);
    if (raw == null) {
      return null;
    }
    final trimmed = raw.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  /// Persist the latest discover filters alongside the preset name so both the
  /// provider and filter screen can rebuild with the correct context.
  Future<void> setTvDiscoverFilterPreset(
    Map<String, String>? filters, {
    String? presetName,
  }) async {
    final sanitizedFilters = filters == null
        ? null
        : Map<String, String>.fromEntries(
            filters.entries.map(
              (entry) => MapEntry(entry.key.trim(), entry.value.trim()),
            ),
          )
            ..removeWhere(
              (key, value) => key.isEmpty || value.isEmpty,
            );

    final normalizedName = presetName?.trim();
    final currentFilters = tvDiscoverFilterPreset;
    final currentName = tvDiscoverPresetName;

    final filtersChanged = !_stringMapEquals(currentFilters, sanitizedFilters);
    final nameChanged = (currentName ?? '') != (normalizedName ?? '');

    if (!filtersChanged && !nameChanged) {
      return;
    }

    if (sanitizedFilters == null || sanitizedFilters.isEmpty) {
      await _prefs.remove(PreferenceKeys.tvDiscoverActiveFilters);
    } else {
      await _prefs.setString(
        PreferenceKeys.tvDiscoverActiveFilters,
        jsonEncode(sanitizedFilters),
      );
    }

    if (normalizedName == null || normalizedName.isEmpty) {
      await _prefs.remove(PreferenceKeys.tvDiscoverActivePresetName);
    } else {
      await _prefs.setString(
        PreferenceKeys.tvDiscoverActivePresetName,
        normalizedName,
      );
    }

    notifyListeners();
  }

  /// Lightweight equality helper to avoid unnecessary writes to preferences.
  bool _stringMapEquals(
    Map<String, String>? a,
    Map<String, String>? b,
  ) {
    if (identical(a, b)) {
      return true;
    }
    if (a == null || a.isEmpty) {
      return b == null || b.isEmpty;
    }
    if (b == null || b.isEmpty) {
      return false;
    }
    if (a.length != b.length) {
      return false;
    }
    for (final entry in a.entries) {
      if (b[entry.key] != entry.value) {
        return false;
      }
    }
    return true;
  }
}
