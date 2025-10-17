import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../data/models/certification_model.dart';
import '../data/models/configuration_model.dart';
import '../data/tmdb_repository.dart';

/// Represents broad age buckets inferred from TMDB certification metadata.
enum CertificationAgeBracket {
  everyone,
  parentalGuidance,
  teens,
  mature,
  adultsOnly,
}

/// Immutable view model describing the certifications that belong to a single
/// country for either movies or TV content.
class CountryCertificationEntry {
  const CountryCertificationEntry({
    required this.countryCode,
    required this.countryName,
    required this.certifications,
  });

  final String countryCode;
  final String countryName;
  final List<Certification> certifications;
}

class CertificationsProvider extends ChangeNotifier {
  CertificationsProvider(this._repository);

  final TmdbRepository _repository;

  bool _isLoading = false;
  bool _hasLoadedAtLeastOnce = false;
  String? _errorMessage;

  List<CountryInfo> _countries = <CountryInfo>[];
  Map<String, List<Certification>> _movieCertifications =
      <String, List<Certification>>{};
  Map<String, List<Certification>> _tvCertifications =
      <String, List<Certification>>{};

  String? _selectedCountryCode;
  String _searchQuery = '';
  CertificationAgeBracket? _activeAgeBracket;

  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasLoadedAtLeastOnce;
  String? get errorMessage => _errorMessage;

  UnmodifiableListView<CountryInfo> get countries =>
      UnmodifiableListView<CountryInfo>(_countries);

  String? get selectedCountryCode => _selectedCountryCode;

  String get searchQuery => _searchQuery;

  CertificationAgeBracket? get activeAgeBracket => _activeAgeBracket;

  /// TMDB API Endpoints used: [GET /3/configuration/countries],
  /// [GET /3/certification/movie/list], and [GET /3/certification/tv/list].
  ///
  /// The certification endpoints respond with payloads shaped as follows:
  /// ```json
  /// {
  ///   "certifications": {
  ///     "US": [
  ///       { "certification": "PG-13", "meaning": "Parents strongly cautioned", "order": 4 }
  ///     ]
  ///   }
  /// }
  /// ```
  /// This method eagerly loads both movie and TV ratings so the UI can toggle
  /// without issuing redundant network calls.
  Future<void> ensureLoaded({bool forceRefresh = false}) async {
    if (_isLoading) {
      return;
    }
    if (_hasLoadedAtLeastOnce && !forceRefresh) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait<dynamic>([
        _repository.fetchCountries(forceRefresh: forceRefresh),
        _repository.fetchMovieCertifications(forceRefresh: forceRefresh),
        _repository.fetchTvCertifications(forceRefresh: forceRefresh),
      ]);

      _countries = (results[0] as List<CountryInfo>)
        ..sort((a, b) => a.englishName.compareTo(b.englishName));
      _movieCertifications =
          Map<String, List<Certification>>.from(results[1] as Map);
      _tvCertifications =
          Map<String, List<Certification>>.from(results[2] as Map);

      _hasLoadedAtLeastOnce = true;
    } catch (error, stackTrace) {
      debugPrint('Failed to load certifications: $error\n$stackTrace');
      _errorMessage = 'Unable to load certifications. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Updates the ISO-3166-1 alpha-2 country filter. When null, the UI will show
  /// the complete directory of certifications grouped by country.
  void selectCountry(String? countryCode) {
    final normalized = countryCode?.toUpperCase();
    if (_selectedCountryCode == normalized) {
      return;
    }
    _selectedCountryCode = normalized;
    notifyListeners();
  }

  /// Stores the free-text search query used to match country names, codes, and
  /// individual certification labels or meanings.
  void updateSearchQuery(String query) {
    final normalized = query.trim().toLowerCase();
    if (_searchQuery == normalized) {
      return;
    }
    _searchQuery = normalized;
    notifyListeners();
  }

  /// Applies or clears the active age bracket filter.
  void setAgeBracketFilter(CertificationAgeBracket? bracket) {
    if (_activeAgeBracket == bracket) {
      return;
    }
    _activeAgeBracket = bracket;
    notifyListeners();
  }

  /// Returns movie certification entries after applying the currently selected
  /// search, country, and age filters.
  List<CountryCertificationEntry> get filteredMovieEntries {
    return _buildFilteredEntries(_movieCertifications);
  }

  /// Returns TV certification entries after applying the currently selected
  /// search, country, and age filters.
  List<CountryCertificationEntry> get filteredTvEntries {
    return _buildFilteredEntries(_tvCertifications);
  }

  /// Provides a human-friendly label for the age bracket chip UI.
  String describeBracket(CertificationAgeBracket bracket) {
    switch (bracket) {
      case CertificationAgeBracket.everyone:
        return 'All ages';
      case CertificationAgeBracket.parentalGuidance:
        return 'Parental guidance';
      case CertificationAgeBracket.teens:
        return '13+';
      case CertificationAgeBracket.mature:
        return '16+';
      case CertificationAgeBracket.adultsOnly:
        return '18+';
    }
  }

  /// Builds a short safety warning string for the provided certification by
  /// using the inferred age bracket and TMDB meaning string. A custom
  /// [bracketLabelOverride] may be supplied so the UI can localize the text.
  String buildAgeWarning(
    Certification certification, {
    String? bracketLabelOverride,
  }) {
    final bracket = _inferBracket(certification);
    final bracketLabel = bracketLabelOverride ?? describeBracket(bracket);
    final meaning = certification.meaning.trim();
    if (meaning.isEmpty) {
      return 'Recommended for $bracketLabel audiences.';
    }
    return '$bracketLabel • ${certification.meaning}';
  }

  /// Exposes the inferred [CertificationAgeBracket] for the given
  /// [certification] so widgets can apply localized labeling logic.
  CertificationAgeBracket bracketFor(Certification certification) {
    return _inferBracket(certification);
  }

  /// Internal helper that maps the repository response maps to the view models
  /// consumed by the UI while applying active filters.
  List<CountryCertificationEntry> _buildFilteredEntries(
    Map<String, List<Certification>> source,
  ) {
    if (source.isEmpty) {
      return const <CountryCertificationEntry>[];
    }

    final search = _searchQuery;
    final ageBracket = _activeAgeBracket;
    final selectedCountry = _selectedCountryCode;

    final entries = <CountryCertificationEntry>[];

    source.forEach((code, certifications) {
      if (certifications.isEmpty) {
        return;
      }

      final upperCode = code.toUpperCase();
      if (selectedCountry != null && selectedCountry != upperCode) {
        return;
      }

      final countryName = _resolveCountryName(upperCode);
      final filteredCerts = certifications.where((cert) {
        if (ageBracket != null && _inferBracket(cert) != ageBracket) {
          return false;
        }
        if (search.isEmpty) {
          return true;
        }
        final lowerMeaning = cert.meaning.toLowerCase();
        final lowerLabel = cert.certification.toLowerCase();
        return lowerMeaning.contains(search) || lowerLabel.contains(search);
      }).toList();

      if (filteredCerts.isEmpty) {
        return;
      }

      if (search.isNotEmpty && selectedCountry == null) {
        final lowerName = countryName.toLowerCase();
        if (!lowerName.contains(search) && !upperCode.toLowerCase().contains(search)) {
          final matchesCertification = certifications.any((cert) {
            final lowerMeaning = cert.meaning.toLowerCase();
            final lowerLabel = cert.certification.toLowerCase();
            return lowerMeaning.contains(search) || lowerLabel.contains(search);
          });
          if (!matchesCertification) {
            return;
          }
        }
      }

      filteredCerts.sort((a, b) => a.order.compareTo(b.order));
      entries.add(
        CountryCertificationEntry(
          countryCode: upperCode,
          countryName: countryName,
          certifications: List<Certification>.unmodifiable(filteredCerts),
        ),
      );
    });

    entries.sort((a, b) {
      if (selectedCountry != null) {
        if (a.countryCode == selectedCountry) {
          return -1;
        }
        if (b.countryCode == selectedCountry) {
          return 1;
        }
      }
      return a.countryName.compareTo(b.countryName);
    });

    return entries;
  }

  /// Attempts to infer a descriptive country name from the configuration list.
  String _resolveCountryName(String code) {
    final match = _countries.firstWhere(
      (country) => country.code.toUpperCase() == code,
      orElse: () => CountryInfo(code: code, englishName: code, nativeName: code),
    );
    return match.englishName.isNotEmpty ? match.englishName : match.nativeName;
  }

  /// Coarse heuristics that map certification text to age brackets. TMDB does
  /// not provide explicit age metadata, so we lean on label patterns.
  CertificationAgeBracket _inferBracket(Certification certification) {
    final label = certification.certification.toUpperCase().trim();
    final meaning = certification.meaning.toLowerCase();

    if (label.isEmpty && meaning.isEmpty) {
      return CertificationAgeBracket.everyone;
    }

    if (RegExp(r'18|NC-17|R18').hasMatch(label) ||
        meaning.contains('adults') ||
        meaning.contains('18') ||
        meaning.contains('explicit')) {
      return CertificationAgeBracket.adultsOnly;
    }

    if (RegExp(r'16|MA|M\b').hasMatch(label) ||
        meaning.contains('mature') ||
        meaning.contains('16') ||
        meaning.contains('strong violence')) {
      return CertificationAgeBracket.mature;
    }

    if (RegExp(r'12|13|14|PG-13|TV-14').hasMatch(label) ||
        meaning.contains('teen') ||
        meaning.contains('13') ||
        meaning.contains('young teens')) {
      return CertificationAgeBracket.teens;
    }

    if (label.contains('PG') ||
        meaning.contains('parental guidance') ||
        meaning.contains('parents strongly cautioned')) {
      return CertificationAgeBracket.parentalGuidance;
    }

    return CertificationAgeBracket.everyone;
  }
}
