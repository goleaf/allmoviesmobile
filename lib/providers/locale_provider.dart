import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/analytics/app_analytics.dart';

class LocaleProvider with ChangeNotifier {
  static const String _localeKey = 'selected_locale';
  final SharedPreferences _prefs;
  final AppAnalytics? _analytics;

  Locale _locale;

  LocaleProvider(
    this._prefs, {
    AppAnalytics? analytics,
  })  : _analytics = analytics,
        _locale = Locale(_prefs.getString(_localeKey) ?? 'en') {
    unawaited(_analytics?.setPreferredLanguage(_locale.languageCode));
  }

  Locale get locale => _locale;

  String get languageCode => _locale.languageCode;

  String get languageName {
    switch (_locale.languageCode) {
      case 'en':
        return 'English';
      case 'ru':
        return 'Русский';
      case 'uk':
        return 'Українська';
      default:
        return 'English';
    }
  }

  String getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'ru':
        return 'Русский';
      case 'uk':
        return 'Українська';
      default:
        return 'English';
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;

    _locale = locale;
    await _prefs.setString(_localeKey, locale.languageCode);
    notifyListeners();
    unawaited(
      _analytics?.setPreferredLanguage(locale.languageCode),
    );
  }

  Future<void> setLanguageCode(String languageCode) async {
    await setLocale(Locale(languageCode));
  }

  static List<Map<String, String>> get supportedLanguages => [
    {'code': 'en', 'name': 'English'},
    {'code': 'ru', 'name': 'Русский'},
    {'code': 'uk', 'name': 'Українська'},
  ];
}
