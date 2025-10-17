import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;
  late Map<String, dynamic> _localizedStrings;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en', ''),
    Locale('ru', ''),
    Locale('uk', ''),
  ];

  Future<bool> load() async {
    try {
      String jsonString = await rootBundle.loadString(
        'lib/core/localization/languages/${locale.languageCode}.json',
      );
      Map<String, dynamic> jsonMap = json.decode(jsonString);
      _localizedStrings = jsonMap;
      return true;
    } catch (e) {
      // Fallback to English if the language file is not found
      String jsonString = await rootBundle.loadString(
        'lib/core/localization/languages/en.json',
      );
      Map<String, dynamic> jsonMap = json.decode(jsonString);
      _localizedStrings = jsonMap;
      return true;
    }
  }

  String translate(String key) {
    List<String> keys = key.split('.');
    dynamic value = _localizedStrings;

    for (String k in keys) {
      if (value is Map && value.containsKey(k)) {
        value = value[k];
      } else {
        return key; // Return the key itself if translation is not found
      }
    }

    return value.toString();
  }

  // Convenience getters for common sections
  Map<String, dynamic> get app => _localizedStrings['app'] ?? {};
  Map<String, dynamic> get navigation => _localizedStrings['navigation'] ?? {};
  Map<String, dynamic> get home => _localizedStrings['home'] ?? {};
  Map<String, dynamic> get movie => _localizedStrings['movie'] ?? {};
  Map<String, dynamic> get tv => _localizedStrings['tv'] ?? {};
  Map<String, dynamic> get person => _localizedStrings['person'] ?? {};
  Map<String, dynamic> get company => _localizedStrings['company'] ?? {};
  Map<String, dynamic> get search => _localizedStrings['search'] ?? {};
  Map<String, dynamic> get discover => _localizedStrings['discover'] ?? {};
  Map<String, dynamic> get favorites => _localizedStrings['favorites'] ?? {};
  Map<String, dynamic> get watchlist => _localizedStrings['watchlist'] ?? {};
  Map<String, dynamic> get settings => _localizedStrings['settings'] ?? {};
  Map<String, dynamic> get common => _localizedStrings['common'] ?? {};
  Map<String, dynamic> get errors => _localizedStrings['errors'] ?? {};
  Map<String, dynamic> get genres => _localizedStrings['genres'] ?? {};

  // Convenience method for direct access
  String t(String key) => translate(key);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ru', 'uk'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

