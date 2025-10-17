import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WatchRegionProvider extends ChangeNotifier {
  static const String _regionKey = 'watch_region_code';
  final SharedPreferences _prefs;

  String _region;

  WatchRegionProvider(this._prefs)
    : _region = (() {
        final stored = (_prefs.getString(_regionKey) ?? 'US').toUpperCase();
        final supportedCodes = supportedRegions
            .map((r) => r['code'])
            .whereType<String>()
            .toSet();
        return supportedCodes.contains(stored) ? stored : 'US';
      })();

  String get region => _region;

  Future<void> setRegion(String regionCode) async {
    final normalized = regionCode.trim().toUpperCase();
    // Ensure region is one of the supported codes; fallback to default for determinism
    final supportedCodes = supportedRegions
        .map((r) => r['code'])
        .whereType<String>()
        .toSet();
    final next = supportedCodes.contains(normalized) ? normalized : 'US';
    if (next == _region) return;
    _region = next;
    await _prefs.setString(_regionKey, _region);
    notifyListeners();
  }

  static const List<Map<String, String>> supportedRegions = [
    {'code': 'US', 'name': 'United States'},
    {'code': 'GB', 'name': 'United Kingdom'},
    {'code': 'CA', 'name': 'Canada'},
    {'code': 'DE', 'name': 'Germany'},
    {'code': 'FR', 'name': 'France'},
    {'code': 'ES', 'name': 'Spain'},
    {'code': 'IT', 'name': 'Italy'},
    {'code': 'IN', 'name': 'India'},
    {'code': 'JP', 'name': 'Japan'},
    {'code': 'KR', 'name': 'South Korea'},
    {'code': 'BR', 'name': 'Brazil'},
    {'code': 'AU', 'name': 'Australia'},
  ];

  String getRegionName(String code) {
    final match = supportedRegions.firstWhere(
      (r) => r['code'] == code.toUpperCase(),
      orElse: () => const {'code': 'US', 'name': 'United States'},
    );
    return match['name']!;
  }
}
