import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/analytics/app_analytics.dart';

enum AppThemeMode { light, dark, system }

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'allmovies_theme_mode';
  final SharedPreferences _prefs;
  final AppAnalytics? _analytics;
  AppThemeMode _themeMode = AppThemeMode.dark;

  ThemeProvider(
    this._prefs, {
    AppAnalytics? analytics,
  })  : _analytics = analytics {
    _loadThemeMode();
    unawaited(_analytics?.setThemeMode(_themeMode.name));
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
      unawaited(_analytics?.setThemeMode(_themeMode.name));
    }
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    _themeMode = mode;
    await _prefs.setString(_themeKey, mode.name);
    notifyListeners();
    unawaited(_analytics?.setThemeMode(mode.name));
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
