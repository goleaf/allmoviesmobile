import 'package:allmovies_mobile/providers/theme_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Prefs implements SharedPreferences {
  final Map<String, Object> _data = {};
  @override
  Set<String> getKeys() => _data.keys.toSet();
  @override
  Object? get(String key) => _data[key];
  @override
  bool containsKey(String key) => _data.containsKey(key);
  @override
  Future<bool> setString(String key, String value) async {
    _data[key] = value;
    return true;
  }

  @override
  Future<bool> clear() async {
    _data.clear();
    return true;
  }

  @override
  Future<bool> remove(String key) async {
    _data.remove(key);
    return true;
  }

  @override
  String? getString(String key) => _data[key] as String?;
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('ThemeProvider persists and exposes theme', () async {
    final prefs = _Prefs();
    final provider = ThemeProvider(prefs);

    // Default from provider is dark (until loaded), then loadThemeMode may not change
    expect(provider.themeMode, isA<AppThemeMode>());

    await provider.setThemeMode(AppThemeMode.light);
    expect(provider.themeMode, AppThemeMode.light);
    expect(prefs.get('allmovies_theme_mode'), 'light');

    await provider.setThemeMode(AppThemeMode.system);
    expect(provider.materialThemeMode.name, 'system');
  });
}
