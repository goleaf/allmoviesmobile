import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode {
  light,
  dark,
  system,
}

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'allmovies_theme_mode';
  final SharedPreferences _prefs;
  AppThemeMode _themeMode = AppThemeMode.dark;

  ThemeProvider(this._prefs) {
    _loadThemeMode();
  }

  AppThemeMode get themeMode => _themeMode;

  ThemeMode get materialThemeMode {
    switch (_themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  Future<void> _loadThemeMode() async {
    final savedMode = _prefs.getString(_themeKey);
    if (savedMode != null) {
      _themeMode = AppThemeMode.values.firstWhere(
        (e) => e.name == savedMode,
        orElse: () => AppThemeMode.dark,
      );
      notifyListeners();
    }
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    _themeMode = mode;
    await _prefs.setString(_themeKey, mode.name);
    notifyListeners();
  }

  String getThemeModeName(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.system:
        return 'System';
    }
  }
}

