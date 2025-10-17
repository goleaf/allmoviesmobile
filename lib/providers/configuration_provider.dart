import 'package:flutter/foundation.dart';

import '../data/models/certification_model.dart';
import '../data/models/configuration_model.dart';
import '../data/tmdb_repository.dart';

/// Coordinates retrieval of TMDB reference data used by the advanced
/// configuration screen. All values here originate from TMDB v3
/// configuration/catalog endpoints so the UI can document available
/// languages, countries, timezones, jobs, and certifications in one place.
class ConfigurationProvider extends ChangeNotifier {
  ConfigurationProvider(this._repository);

  final TmdbRepository _repository;

  ApiConfiguration? _configuration;
  List<LanguageInfo> _languages = const [];
  List<CountryInfo> _countries = const [];
  List<Timezone> _timezones = const [];
  List<Job> _jobs = const [];
  Map<String, List<Certification>> _movieCertifications = const {};
  Map<String, List<Certification>> _tvCertifications = const {};
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _lastLoaded;

  /// Latest TMDB API configuration payload returned by
  /// `GET /3/configuration`.
  ApiConfiguration? get configuration => _configuration;

  /// Sorted list of supported UI languages from
  /// `GET /3/configuration/languages`.
  List<LanguageInfo> get languages => List<LanguageInfo>.unmodifiable(_languages);

  /// Sorted list of supported countries from
  /// `GET /3/configuration/countries`.
  List<CountryInfo> get countries => List<CountryInfo>.unmodifiable(_countries);

  /// Sorted list of available timezones originating from
  /// `GET /3/configuration/timezones`.
  List<Timezone> get timezones => List<Timezone>.unmodifiable(_timezones);

  /// TMDB jobs grouped by department from `GET /3/configuration/jobs`.
  List<Job> get jobs => List<Job>.unmodifiable(_jobs);

  /// Movie certification catalog returned by `GET /3/certification/movie/list`.
  Map<String, List<Certification>> get movieCertifications =>
      Map<String, List<Certification>>.unmodifiable(_movieCertifications);

  /// TV certification catalog returned by `GET /3/certification/tv/list`.
  Map<String, List<Certification>> get tvCertifications =>
      Map<String, List<Certification>>.unmodifiable(_tvCertifications);

  /// Indicates whether a fetch operation is in progress.
  bool get isLoading => _isLoading;

  /// Indicates if at least one payload has been retrieved.
  bool get hasLoadedOnce => _lastLoaded != null;

  /// Human-readable error captured from the most recent load attempt.
  String? get errorMessage => _errorMessage;

  /// Timestamp of the last successful data refresh.
  DateTime? get lastLoaded => _lastLoaded;

  /// Convenience getter for checking whether the provider currently has
  /// reference content available for presentation.
  bool get hasContent =>
      _configuration != null ||
      _languages.isNotEmpty ||
      _countries.isNotEmpty ||
      _timezones.isNotEmpty ||
      _jobs.isNotEmpty ||
      _movieCertifications.isNotEmpty ||
      _tvCertifications.isNotEmpty;

  /// Fetches all configuration reference datasets from TMDB.
  ///
  /// The following endpoints are invoked (each returns JSON documented inline):
  /// - `GET /3/configuration` → `{ "images": { ... }, "change_keys": [] }`
  /// - `GET /3/configuration/languages` →
  ///   `[ { "english_name": "English", "iso_639_1": "en" } ]`
  /// - `GET /3/configuration/countries` →
  ///   `[ { "english_name": "United States", "iso_3166_1": "US" } ]`
  /// - `GET /3/configuration/timezones` →
  ///   `[ { "iso_3166_1": "US", "zones": ["America/New_York"] } ]`
  /// - `GET /3/configuration/jobs` →
  ///   `[ { "department": "Production", "jobs": ["Producer"] } ]`
  /// - `GET /3/certification/movie/list` →
  ///   `{ "certifications": { "US": [ { "certification": "PG-13" } ] } }`
  /// - `GET /3/certification/tv/list` →
  ///   `{ "certifications": { "US": [ { "certification": "TV-14" } ] } }`
  Future<void> load({bool forceRefresh = false}) async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final configurationFuture =
          _repository.fetchConfiguration(forceRefresh: forceRefresh);
      final languagesFuture =
          _repository.fetchLanguages(forceRefresh: forceRefresh);
      final countriesFuture =
          _repository.fetchCountries(forceRefresh: forceRefresh);
      final timezonesFuture =
          _repository.fetchTimezones(forceRefresh: forceRefresh);
      final jobsFuture = _repository.fetchJobs(forceRefresh: forceRefresh);
      final movieCertificationsFuture =
          _repository.fetchMovieCertifications(forceRefresh: forceRefresh);
      final tvCertificationsFuture =
          _repository.fetchTvCertifications(forceRefresh: forceRefresh);

      final configuration = await configurationFuture;
      final languages = await languagesFuture;
      final countries = await countriesFuture;
      final timezones = await timezonesFuture;
      final jobs = await jobsFuture;
      final movieCertifications = await movieCertificationsFuture;
      final tvCertifications = await tvCertificationsFuture;

      _configuration = configuration;
      _languages = [...languages]..sort(
          (a, b) => a.englishName.compareTo(b.englishName),
        );
      _countries = [...countries]..sort(
          (a, b) => a.englishName.compareTo(b.englishName),
        );
      _timezones = [...timezones]..sort(
          (a, b) => a.countryCode.compareTo(b.countryCode),
        );
      _jobs = [...jobs]
        ..sort((a, b) => a.department.compareTo(b.department));
      _movieCertifications = {
        for (final entry in movieCertifications.entries)
          entry.key: List<Certification>.unmodifiable(entry.value)
      };
      _tvCertifications = {
        for (final entry in tvCertifications.entries)
          entry.key: List<Certification>.unmodifiable(entry.value)
      };
      _lastLoaded = DateTime.now();
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Forces a refresh by bypassing the cache for the next load cycle.
  Future<void> refresh() => load(forceRefresh: true);
}
