import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/preferences_keys.dart';
import 'models/tv_filter_preset.dart';

@immutable
class TvFilterSelection {
  const TvFilterSelection({
    this.filters,
    this.presetName,
  });

  final Map<String, String>? filters;
  final String? presetName;
}

class TvFilterPresetsRepository {
  TvFilterPresetsRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _activeFiltersKey = PreferenceKeys.seriesActiveFilters;
  static const _activePresetKey = PreferenceKeys.seriesActivePreset;

  Future<List<TvFilterPreset>> loadPresets() async {
    final raw =
        _prefs.getStringList(PreferenceKeys.seriesFilterPresets) ?? const [];
    return raw
        .map(TvFilterPreset.fromJsonString)
        .whereType<TvFilterPreset>()
        .toList(growable: false);
  }

  Future<void> savePreset(TvFilterPreset preset) async {
    final existing = await loadPresets();
    final updated = existing.toList();
    final index = updated.indexWhere(
      (candidate) =>
          candidate.name.toLowerCase() == preset.name.toLowerCase(),
    );
    if (index >= 0) {
      updated[index] = preset;
    } else {
      updated.add(preset);
    }
    final payload = updated.map((preset) => preset.toJsonString()).toList();
    await _prefs.setStringList(PreferenceKeys.seriesFilterPresets, payload);
  }

  Future<void> deletePreset(String name) async {
    final existing = await loadPresets();
    final filtered = existing
        .where((preset) => preset.name.toLowerCase() != name.toLowerCase())
        .map((preset) => preset.toJsonString())
        .toList();
    await _prefs.setStringList(PreferenceKeys.seriesFilterPresets, filtered);
  }

  Future<TvFilterSelection> loadActiveSelection() async {
    final filtersRaw = _prefs.getString(_activeFiltersKey);
    Map<String, String>? filters;
    if (filtersRaw != null && filtersRaw.isNotEmpty) {
      try {
        final decoded = jsonDecode(filtersRaw);
        if (decoded is Map) {
          filters = <String, String>{};
          decoded.forEach((key, value) {
            if (key is String && value is String) {
              filters![key] = value;
            }
          });
          if (filters!.isEmpty) {
            filters = null;
          }
        }
      } catch (_) {
        // Ignore malformed cache entries.
      }
    }

    final presetName = _prefs.getString(_activePresetKey);
    return TvFilterSelection(filters: filters, presetName: presetName);
  }

  Future<void> persistActiveSelection({
    Map<String, String>? filters,
    String? presetName,
  }) async {
    if (filters == null || filters.isEmpty) {
      await _prefs.remove(_activeFiltersKey);
    } else {
      await _prefs.setString(_activeFiltersKey, jsonEncode(filters));
    }

    final trimmedName = presetName?.trim();
    if (trimmedName == null || trimmedName.isEmpty) {
      await _prefs.remove(_activePresetKey);
    } else {
      await _prefs.setString(_activePresetKey, trimmedName);
    }
  }

  Future<void> clearActiveSelection() {
    return persistActiveSelection(filters: null, presetName: null);
  }
}
