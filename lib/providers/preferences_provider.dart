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
}


