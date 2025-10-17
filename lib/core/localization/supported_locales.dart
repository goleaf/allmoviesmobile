import 'package:flutter/material.dart';

/// Metadata describing a supported language and related localization settings.
class SupportedLanguage {
  const SupportedLanguage({
    required this.locale,
    required this.englishName,
    required this.nativeName,
    required this.defaultCurrency,
    this.isRtl = false,
  });

  final Locale locale;
  final String englishName;
  final String nativeName;
  final String defaultCurrency;
  final bool isRtl;

  String get localeTag => locale.toLanguageTag();

  bool matches(Locale other) {
    if (locale.languageCode != other.languageCode) {
      return false;
    }
    if (locale.countryCode == null || locale.countryCode!.isEmpty) {
      return true;
    }
    return locale.countryCode == other.countryCode;
  }
}

/// Full list of locales the application provides translations for.
const supportedLanguages = <SupportedLanguage>[
  SupportedLanguage(
    locale: Locale('en'),
    englishName: 'English',
    nativeName: 'English',
    defaultCurrency: 'USD',
  ),
  SupportedLanguage(
    locale: Locale('es'),
    englishName: 'Spanish',
    nativeName: 'Español',
    defaultCurrency: 'EUR',
  ),
  SupportedLanguage(
    locale: Locale('fr'),
    englishName: 'French',
    nativeName: 'Français',
    defaultCurrency: 'EUR',
  ),
  SupportedLanguage(
    locale: Locale('de'),
    englishName: 'German',
    nativeName: 'Deutsch',
    defaultCurrency: 'EUR',
  ),
  SupportedLanguage(
    locale: Locale('it'),
    englishName: 'Italian',
    nativeName: 'Italiano',
    defaultCurrency: 'EUR',
  ),
  SupportedLanguage(
    locale: Locale('pt'),
    englishName: 'Portuguese',
    nativeName: 'Português',
    defaultCurrency: 'EUR',
  ),
  SupportedLanguage(
    locale: Locale('ru'),
    englishName: 'Russian',
    nativeName: 'Русский',
    defaultCurrency: 'RUB',
  ),
  SupportedLanguage(
    locale: Locale('uk'),
    englishName: 'Ukrainian',
    nativeName: 'Українська',
    defaultCurrency: 'UAH',
  ),
  SupportedLanguage(
    locale: Locale('pl'),
    englishName: 'Polish',
    nativeName: 'Polski',
    defaultCurrency: 'PLN',
  ),
  SupportedLanguage(
    locale: Locale('nl'),
    englishName: 'Dutch',
    nativeName: 'Nederlands',
    defaultCurrency: 'EUR',
  ),
  SupportedLanguage(
    locale: Locale('sv'),
    englishName: 'Swedish',
    nativeName: 'Svenska',
    defaultCurrency: 'SEK',
  ),
  SupportedLanguage(
    locale: Locale('nb'),
    englishName: 'Norwegian',
    nativeName: 'Norsk Bokmål',
    defaultCurrency: 'NOK',
  ),
  SupportedLanguage(
    locale: Locale('fi'),
    englishName: 'Finnish',
    nativeName: 'Suomi',
    defaultCurrency: 'EUR',
  ),
  SupportedLanguage(
    locale: Locale('da'),
    englishName: 'Danish',
    nativeName: 'Dansk',
    defaultCurrency: 'DKK',
  ),
  SupportedLanguage(
    locale: Locale('cs'),
    englishName: 'Czech',
    nativeName: 'Čeština',
    defaultCurrency: 'CZK',
  ),
  SupportedLanguage(
    locale: Locale('sk'),
    englishName: 'Slovak',
    nativeName: 'Slovenčina',
    defaultCurrency: 'EUR',
  ),
  SupportedLanguage(
    locale: Locale('hu'),
    englishName: 'Hungarian',
    nativeName: 'Magyar',
    defaultCurrency: 'HUF',
  ),
  SupportedLanguage(
    locale: Locale('ro'),
    englishName: 'Romanian',
    nativeName: 'Română',
    defaultCurrency: 'RON',
  ),
  SupportedLanguage(
    locale: Locale('bg'),
    englishName: 'Bulgarian',
    nativeName: 'Български',
    defaultCurrency: 'BGN',
  ),
  SupportedLanguage(
    locale: Locale('sr'),
    englishName: 'Serbian',
    nativeName: 'Српски',
    defaultCurrency: 'RSD',
  ),
  SupportedLanguage(
    locale: Locale('hr'),
    englishName: 'Croatian',
    nativeName: 'Hrvatski',
    defaultCurrency: 'EUR',
  ),
  SupportedLanguage(
    locale: Locale('sl'),
    englishName: 'Slovenian',
    nativeName: 'Slovenščina',
    defaultCurrency: 'EUR',
  ),
  SupportedLanguage(
    locale: Locale('tr'),
    englishName: 'Turkish',
    nativeName: 'Türkçe',
    defaultCurrency: 'TRY',
  ),
  SupportedLanguage(
    locale: Locale('el'),
    englishName: 'Greek',
    nativeName: 'Ελληνικά',
    defaultCurrency: 'EUR',
  ),
  SupportedLanguage(
    locale: Locale('he'),
    englishName: 'Hebrew',
    nativeName: 'עברית',
    defaultCurrency: 'ILS',
    isRtl: true,
  ),
  SupportedLanguage(
    locale: Locale('ar'),
    englishName: 'Arabic',
    nativeName: 'العربية',
    defaultCurrency: 'AED',
    isRtl: true,
  ),
  SupportedLanguage(
    locale: Locale('fa'),
    englishName: 'Persian',
    nativeName: 'فارسی',
    defaultCurrency: 'IRR',
    isRtl: true,
  ),
  SupportedLanguage(
    locale: Locale('ur'),
    englishName: 'Urdu',
    nativeName: 'اردو',
    defaultCurrency: 'PKR',
    isRtl: true,
  ),
  SupportedLanguage(
    locale: Locale('hi'),
    englishName: 'Hindi',
    nativeName: 'हिन्दी',
    defaultCurrency: 'INR',
  ),
  SupportedLanguage(
    locale: Locale('bn'),
    englishName: 'Bengali',
    nativeName: 'বাংলা',
    defaultCurrency: 'BDT',
  ),
  SupportedLanguage(
    locale: Locale('ta'),
    englishName: 'Tamil',
    nativeName: 'தமிழ்',
    defaultCurrency: 'INR',
  ),
  SupportedLanguage(
    locale: Locale('te'),
    englishName: 'Telugu',
    nativeName: 'తెలుగు',
    defaultCurrency: 'INR',
  ),
  SupportedLanguage(
    locale: Locale('ml'),
    englishName: 'Malayalam',
    nativeName: 'മലയാളം',
    defaultCurrency: 'INR',
  ),
  SupportedLanguage(
    locale: Locale('mr'),
    englishName: 'Marathi',
    nativeName: 'मराठी',
    defaultCurrency: 'INR',
  ),
  SupportedLanguage(
    locale: Locale('pa'),
    englishName: 'Punjabi',
    nativeName: 'ਪੰਜਾਬੀ',
    defaultCurrency: 'INR',
  ),
  SupportedLanguage(
    locale: Locale('gu'),
    englishName: 'Gujarati',
    nativeName: 'ગુજરાતી',
    defaultCurrency: 'INR',
  ),
  SupportedLanguage(
    locale: Locale('kn'),
    englishName: 'Kannada',
    nativeName: 'ಕನ್ನಡ',
    defaultCurrency: 'INR',
  ),
  SupportedLanguage(
    locale: Locale('zh'),
    englishName: 'Chinese',
    nativeName: '中文',
    defaultCurrency: 'CNY',
  ),
  SupportedLanguage(
    locale: Locale('ja'),
    englishName: 'Japanese',
    nativeName: '日本語',
    defaultCurrency: 'JPY',
  ),
  SupportedLanguage(
    locale: Locale('ko'),
    englishName: 'Korean',
    nativeName: '한국어',
    defaultCurrency: 'KRW',
  ),
  SupportedLanguage(
    locale: Locale('th'),
    englishName: 'Thai',
    nativeName: 'ไทย',
    defaultCurrency: 'THB',
  ),
  SupportedLanguage(
    locale: Locale('vi'),
    englishName: 'Vietnamese',
    nativeName: 'Tiếng Việt',
    defaultCurrency: 'VND',
  ),
  SupportedLanguage(
    locale: Locale('id'),
    englishName: 'Indonesian',
    nativeName: 'Bahasa Indonesia',
    defaultCurrency: 'IDR',
  ),
  SupportedLanguage(
    locale: Locale('ms'),
    englishName: 'Malay',
    nativeName: 'Bahasa Melayu',
    defaultCurrency: 'MYR',
  ),
  SupportedLanguage(
    locale: Locale('tl'),
    englishName: 'Tagalog',
    nativeName: 'Tagalog',
    defaultCurrency: 'PHP',
  ),
  SupportedLanguage(
    locale: Locale('sw'),
    englishName: 'Swahili',
    nativeName: 'Kiswahili',
    defaultCurrency: 'KES',
  ),
];

/// Convenience list of [Locale]s for Flutter widgets.
final List<Locale> supportedLocales = supportedLanguages
    .map((language) => language.locale)
    .toList(growable: false);

/// Language codes that should trigger right-to-left layout.
final Set<String> rtlLanguageCodes = {
  for (final language in supportedLanguages)
    if (language.isRtl) language.locale.languageCode,
};

SupportedLanguage languageForLocale(Locale locale) {
  for (final language in supportedLanguages) {
    if (language.matches(locale)) {
      return language;
    }
  }
  return supportedLanguages.first;
}

SupportedLanguage? languageForTag(String? localeTag) {
  if (localeTag == null || localeTag.isEmpty) {
    return null;
  }
  final normalized = localeTag.toLowerCase();
  for (final language in supportedLanguages) {
    if (language.localeTag.toLowerCase() == normalized) {
      return language;
    }
    if (language.locale.languageCode.toLowerCase() == normalized) {
      return language;
    }
  }
  return null;
}
