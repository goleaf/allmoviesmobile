import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/preferences_keys.dart';
import '../data/models/series_filter_preset.dart';

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
}
