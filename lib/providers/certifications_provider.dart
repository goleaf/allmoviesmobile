import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/models/certification_model.dart';
import '../data/models/configuration_model.dart';
import '../data/tmdb_repository.dart';

/// Supported certification media types for the dedicated ratings screen.
enum CertificationMediaType {
  /// Movie content ratings pulled from `GET /3/certification/movie/list`.
  movie,

  /// TV content ratings pulled from `GET /3/certification/tv/list`.
  tv,
}

/// Immutable view-model describing a country's certification catalog.
class CertificationCountryData {
  const CertificationCountryData({
    required this.countryCode,
    required this.countryName,
    required this.certifications,
  });

  /// ISO 3166-1 alpha-2 country code (e.g. `US`).
  final String countryCode;

  /// Localized country name resolved via `GET /3/configuration/countries`.
  final String countryName;

  /// Certifications available for the selected media type.
  final List<Certification> certifications;
}

/// ChangeNotifier that loads and filters TMDB certification catalogs.
class CertificationsProvider extends ChangeNotifier {
  CertificationsProvider(this._repository);

  final TmdbRepository _repository;

  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _errorMessage;

  Map<String, List<Certification>> _movieCertifications = const {};
  Map<String, List<Certification>> _tvCertifications = const {};
  List<CountryInfo> _countries = const [];
  Map<String, CountryInfo> _countryLookup = const {};

  String? _selectedCountryCode;
  String _searchQuery = '';
  CertificationMediaType _activeMediaType = CertificationMediaType.movie;

  /// Current loading state used for the initial fetch.
  bool get isLoading => _isLoading;

  /// True while a manual refresh is in flight.
  bool get isRefreshing => _isRefreshing;

  /// Non-null when a recoverable loading error is present.
  String? get errorMessage => _errorMessage;

  /// Countries returned from `GET /3/configuration/countries` sorted alphabetically.
  List<CountryInfo> get countries => List.unmodifiable(_countries);

  /// Currently selected media type.
  CertificationMediaType get activeMediaType => _activeMediaType;

  /// Persisted ISO country code filter.
  String? get selectedCountryCode => _selectedCountryCode;

  /// Current search query used to filter certifications by value or description.
  String get searchQuery => _searchQuery;

  /// Whether at least one certification entry is available for the active filters.
  bool get hasResults => filteredEntries.isNotEmpty;

  /// Human friendly country name lookup with ISO fallback.
  String countryNameOf(String isoCode) {
    final normalized = isoCode.toUpperCase();
    return _countryLookup[normalized]?.englishName ?? normalized;
  }

  /// Combined filtered list ready for UI consumption.
  List<CertificationCountryData> get filteredEntries {
    final mediaMap =
        _activeMediaType == CertificationMediaType.movie ? _movieCertifications : _tvCertifications;

    if (mediaMap.isEmpty) {
      return const [];
    }

    final selectedCode = _selectedCountryCode?.toUpperCase();
    final query = _searchQuery.trim().toLowerCase();

    final entries = <CertificationCountryData>[];

    mediaMap.forEach((code, certifications) {
      final normalizedCode = code.toUpperCase();
      if (selectedCode != null && normalizedCode != selectedCode) {
        return;
      }

      final filteredCerts = certifications.where((cert) {
        if (query.isEmpty) {
          return true;
        }
        final rating = cert.certification.toLowerCase();
        final meaning = cert.meaning.toLowerCase();
        return rating.contains(query) || meaning.contains(query);
      }).toList();

      if (filteredCerts.isEmpty) {
        return;
      }

      entries.add(
        CertificationCountryData(
          countryCode: normalizedCode,
          countryName: countryNameOf(normalizedCode),
          certifications: List<Certification>.unmodifiable(filteredCerts),
        ),
      );
    });

    entries.sort(
      (a, b) => a.countryName.toLowerCase().compareTo(b.countryName.toLowerCase()),
    );

    return entries;
  }

  /// Loads the certification catalogs and country metadata.
  ///
  /// Data sources:
  /// - TMDB `GET /3/certification/movie/list`
  ///   ```json
  ///   {
  ///     "certifications": {
  ///       "US": [
  ///         { "certification": "G", "meaning": "General Audiences", "order": 1 }
  ///       ]
  ///     }
  ///   }
  ///   ```
  /// - TMDB `GET /3/certification/tv/list`
  /// - TMDB `GET /3/configuration/countries`
  Future<void> loadAll({bool forceRefresh = false}) async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.fetchMovieCertifications(forceRefresh: forceRefresh),
        _repository.fetchTvCertifications(forceRefresh: forceRefresh),
        _repository.fetchCountries(forceRefresh: forceRefresh),
      ]);

      final movieMap =
          (results[0] as Map<String, List<Certification>>).map((key, value) => MapEntry(key.toUpperCase(), value));
      final tvMap =
          (results[1] as Map<String, List<Certification>>).map((key, value) => MapEntry(key.toUpperCase(), value));
      final sortedCountries = List<CountryInfo>.from(results[2] as List<CountryInfo>);

      _movieCertifications = movieMap;
      _tvCertifications = tvMap;

      sortedCountries.sort(
        (a, b) => a.englishName.toLowerCase().compareTo(b.englishName.toLowerCase()),
      );
      _countries = List<CountryInfo>.unmodifiable(sortedCountries);
      _countryLookup = {
        for (final country in sortedCountries) country.code.toUpperCase(): country,
      };

      if (_selectedCountryCode != null &&
          !_countryLookup.containsKey(_selectedCountryCode!.toUpperCase())) {
        _selectedCountryCode = null;
      }
    } catch (error, stackTrace) {
      _errorMessage = 'Failed to load certifications: $error';
      if (kDebugMode) {
        debugPrint('CertificationsProvider.loadAll error: $error');
        debugPrint('$stackTrace');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Forces a refresh against the TMDB APIs, bypassing caches.
  Future<void> refresh() async {
    if (_isRefreshing) {
      return;
    }
    _isRefreshing = true;
    notifyListeners();
    try {
      await loadAll(forceRefresh: true);
    } finally {
      _isRefreshing = false;
      notifyListeners();
    }
  }

  /// Updates the active media type (movies vs TV) for filtering.
  void updateMediaType(CertificationMediaType type) {
    if (_activeMediaType == type) {
      return;
    }
    _activeMediaType = type;
    notifyListeners();
  }

  /// Sets the ISO 3166-1 country code filter.
  void selectCountry(String? code) {
    final normalized = code?.trim().toUpperCase();
    if (_selectedCountryCode == normalized) {
      return;
    }
    _selectedCountryCode = normalized?.isEmpty ?? true ? null : normalized;
    notifyListeners();
  }

  /// Updates the free-text search query used to filter certifications and notes.
  void updateSearchQuery(String query) {
    final normalized = query.trimLeft();
    if (_searchQuery == normalized) {
      return;
    }
    _searchQuery = normalized;
    notifyListeners();
  }
}
