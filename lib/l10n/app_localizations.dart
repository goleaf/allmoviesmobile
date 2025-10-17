import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('ru'),
  ];

  /// The name of the application
  ///
  /// In en, this message translates to:
  /// **'AllMovies'**
  String get appName;

  /// Welcome message
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// Guest user name
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guestUser;

  /// Search hint text
  ///
  /// In en, this message translates to:
  /// **'Search movies...'**
  String get search;

  /// Movies section
  ///
  /// In en, this message translates to:
  /// **'Movies'**
  String get movies;

  /// Series section
  ///
  /// In en, this message translates to:
  /// **'Series'**
  String get series;

  /// People section
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get people;

  /// Companies section
  ///
  /// In en, this message translates to:
  /// **'Companies'**
  String get companies;

  /// Settings page title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// About section
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Logout button
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Login button
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Register button
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// Email field
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Password field
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Full name field
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// Theme setting
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Language setting
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Appearance settings section
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// Localization settings section
  ///
  /// In en, this message translates to:
  /// **'Localization'**
  String get localization;

  /// App version label
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// Choose theme dialog title
  ///
  /// In en, this message translates to:
  /// **'Choose Theme'**
  String get chooseTheme;

  /// Choose language dialog title
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get chooseLanguage;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Home page
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Subtitle on home screen
  ///
  /// In en, this message translates to:
  /// **'Explore the latest highlights from our catalog.'**
  String get exploreCollections;

  /// No movies found message
  ///
  /// In en, this message translates to:
  /// **'No titles match your search yet.'**
  String get noMoviesFound;

  /// Try again button
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// Keywords section
  ///
  /// In en, this message translates to:
  /// **'Keywords'**
  String get keywords;

  /// API explorer entry
  ///
  /// In en, this message translates to:
  /// **'TMDB Explorer'**
  String get apiExplorer;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @region.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get region;

  /// No description provided for @byDecade.
  ///
  /// In en, this message translates to:
  /// **'By Decade'**
  String get byDecade;

  /// No description provided for @certification.
  ///
  /// In en, this message translates to:
  /// **'Certification'**
  String get certification;

  /// No description provided for @releaseDateRange.
  ///
  /// In en, this message translates to:
  /// **'Release Date Range'**
  String get releaseDateRange;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @voteAverage.
  ///
  /// In en, this message translates to:
  /// **'Vote Average'**
  String get voteAverage;

  /// No description provided for @runtimeMinutes.
  ///
  /// In en, this message translates to:
  /// **'Runtime (minutes)'**
  String get runtimeMinutes;

  /// No description provided for @voteCountMinimum.
  ///
  /// In en, this message translates to:
  /// **'Vote Count Minimum'**
  String get voteCountMinimum;

  /// No description provided for @monetizationTypes.
  ///
  /// In en, this message translates to:
  /// **'Monetization Types'**
  String get monetizationTypes;

  /// No description provided for @watchProvidersIds.
  ///
  /// In en, this message translates to:
  /// **'Watch Providers (IDs)'**
  String get watchProvidersIds;

  /// No description provided for @providerIdsHint.
  ///
  /// In en, this message translates to:
  /// **'Comma-separated provider IDs, e.g., 8,9,337'**
  String get providerIdsHint;

  /// No description provided for @releaseType.
  ///
  /// In en, this message translates to:
  /// **'Release Type'**
  String get releaseType;

  /// No description provided for @releaseTypePremiere.
  ///
  /// In en, this message translates to:
  /// **'Premiere'**
  String get releaseTypePremiere;

  /// No description provided for @releaseTypeTheatricalLimited.
  ///
  /// In en, this message translates to:
  /// **'Theatrical (Limited)'**
  String get releaseTypeTheatricalLimited;

  /// No description provided for @releaseTypeTheatrical.
  ///
  /// In en, this message translates to:
  /// **'Theatrical'**
  String get releaseTypeTheatrical;

  /// No description provided for @releaseTypeDigital.
  ///
  /// In en, this message translates to:
  /// **'Digital'**
  String get releaseTypeDigital;

  /// No description provided for @releaseTypePhysical.
  ///
  /// In en, this message translates to:
  /// **'Physical'**
  String get releaseTypePhysical;

  /// No description provided for @releaseTypeTV.
  ///
  /// In en, this message translates to:
  /// **'TV'**
  String get releaseTypeTV;

  /// No description provided for @includeAdultContent.
  ///
  /// In en, this message translates to:
  /// **'Include Adult Content'**
  String get includeAdultContent;

  /// No description provided for @peopleCompaniesKeywords.
  ///
  /// In en, this message translates to:
  /// **'People & Companies & Keywords'**
  String get peopleCompaniesKeywords;

  /// No description provided for @withCastHint.
  ///
  /// In en, this message translates to:
  /// **'With Cast (comma-separated person IDs)'**
  String get withCastHint;

  /// No description provided for @withCrewHint.
  ///
  /// In en, this message translates to:
  /// **'With Crew (comma-separated person IDs)'**
  String get withCrewHint;

  /// No description provided for @withCompaniesHint.
  ///
  /// In en, this message translates to:
  /// **'With Companies (comma-separated company IDs)'**
  String get withCompaniesHint;

  /// No description provided for @withKeywordsHint.
  ///
  /// In en, this message translates to:
  /// **'With Keywords (comma-separated keyword IDs)'**
  String get withKeywordsHint;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// Label for the department filter on the people screen
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get peopleDepartmentsLabel;

  /// Option to show all departments
  ///
  /// In en, this message translates to:
  /// **'All departments'**
  String get peopleDepartmentsAll;

  /// In en, this message translates to:
  /// **'Acting'**
  String get peopleDepartmentsActing;

  /// In en, this message translates to:
  /// **'Directing'**
  String get peopleDepartmentsDirecting;

  /// In en, this message translates to:
  /// **'Production'**
  String get peopleDepartmentsProduction;

  /// In en, this message translates to:
  /// **'Writing'**
  String get peopleDepartmentsWriting;

  /// In en, this message translates to:
  /// **'Editing'**
  String get peopleDepartmentsEditing;

  /// In en, this message translates to:
  /// **'Camera'**
  String get peopleDepartmentsCamera;

  /// In en, this message translates to:
  /// **'Sound'**
  String get peopleDepartmentsSound;

  /// In en, this message translates to:
  /// **'Art'**
  String get peopleDepartmentsArt;

  /// In en, this message translates to:
  /// **'Costume & Make-Up'**
  String get peopleDepartmentsCostumeAndMakeUp;

  /// In en, this message translates to:
  /// **'Crew'**
  String get peopleDepartmentsCrew;

  /// In en, this message translates to:
  /// **'Lighting'**
  String get peopleDepartmentsLighting;

  /// In en, this message translates to:
  /// **'Visual Effects'**
  String get peopleDepartmentsVisualEffects;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'fr', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
