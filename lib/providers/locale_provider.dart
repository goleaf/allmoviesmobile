import 'package:allmovies_mobile/core/localization/supported_locales.dart'
    as localization;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider with ChangeNotifier {
  static const String _localeKey = 'selected_locale';
  final SharedPreferences _prefs;

  Locale _locale;

  LocaleProvider(this._prefs)
    : _locale = Locale(_prefs.getString(_localeKey) ?? 'en');

  Locale get locale => _locale;

  String get languageCode => _locale.languageCode;

  String get languageName {
    return _languageDisplayName(localization.languageForLocale(_locale));
  }

  String getLanguageName(Locale locale) {
    return _languageDisplayName(localization.languageForLocale(locale));
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;

    _locale = locale;
    await _prefs.setString(_localeKey, locale.languageCode);
    notifyListeners();
  }

  Future<void> setLanguageCode(String languageCode) async {
    await setLocale(localeForCode(languageCode));
  }

  Locale localeForCode(String code) {
    final language = localization.languageForTag(code);
    if (language != null) {
      return language.locale;
    }

    final segments = code.split(RegExp('[-_]')).where((segment) => segment.isNotEmpty).toList();
    if (segments.isEmpty) {
      return localization.supportedLanguages.first.locale;
    }
    if (segments.length == 1) {
      return Locale(segments.first);
    }
    if (segments.length == 2) {
      return Locale(segments[0], segments[1]);
    }
    return Locale.fromSubtags(
      languageCode: segments[0],
      scriptCode: segments[1],
      countryCode: segments[2],
    );
  }

  static List<Map<String, String>> get supportedLanguages =>
      localization.supportedLanguages
          .map((language) => {
                'code': language.locale.toLanguageTag(),
                'name': language.nativeName.isNotEmpty
                    ? language.nativeName
                    : language.englishName,
              })
          .toList(growable: false);

  String _languageDisplayName(localization.SupportedLanguage language) {
    return language.nativeName.isNotEmpty
        ? language.nativeName
        : language.englishName;
  }
}
