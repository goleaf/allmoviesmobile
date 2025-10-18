import 'dart:convert';

import 'package:flutter/foundation.dart';

/// A serializable representation of a saved TV series filter preset.
///
/// Presets are persisted to [SharedPreferences] as JSON payloads so they can
/// be restored the next time the user opens the filter sheet. Keeping this in a
/// dedicated model makes it easy to evolve the structure while maintaining
/// backwards compatibility with previously stored values.
@immutable
class TvFilterPreset {
  const TvFilterPreset({
    required this.name,
    required this.filters,
  });

  /// Human readable name chosen by the user.
  final String name;

  /// Raw TMDB discover query parameters keyed by their API names.
  final Map<String, String> filters;

  /// Deserialize a preset from a JSON map as stored in preferences.
  factory TvFilterPreset.fromJson(Map<String, dynamic> json) {
    final filters = <String, String>{};
    final rawFilters = json['filters'];
    if (rawFilters is Map) {
      rawFilters.forEach((key, value) {
        if (key is String && value is String) {
          filters[key] = value;
        }
      });
    }
    return TvFilterPreset(
      name: json['name'] as String? ?? 'Preset',
      filters: filters,
    );
  }

  /// Serialize the preset into a JSON encodable structure.
  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'filters': filters,
      };

  /// Encode this preset into a JSON string for storage.
  String toJsonString() => jsonEncode(toJson());

  /// Decode a preset from a JSON string. Returns `null` when decoding fails.
  static TvFilterPreset? fromJsonString(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return TvFilterPreset.fromJson(decoded);
      }
    } catch (_) {
      // Ignore malformed entries so that corrupted presets do not crash the
      // application. They will simply be skipped when loading.
    }
    return null;
  }

  /// Create a copy with updated values.
  TvFilterPreset copyWith({
    String? name,
    Map<String, String>? filters,
  }) {
    return TvFilterPreset(
      name: name ?? this.name,
      filters: filters ?? this.filters,
    );
  }
}
