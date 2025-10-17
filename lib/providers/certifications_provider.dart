import 'package:flutter/foundation.dart';

import '../data/models/certification_model.dart';
import '../data/models/configuration_model.dart';
import '../data/tmdb_repository.dart';

/// Immutable view model describing the certifications that belong to a specific
/// country. The UI consumes this to render grouped country sections.
class CertificationCountryEntry {
  const CertificationCountryEntry({
    required this.code,
    required this.name,
    required this.certifications,
  });

  final String code;
  final String name;
  final List<Certification> certifications;
}

/// Aggregated focus details for a single certification rating across movies and
/// television.
class CertificationFocusSummary {
  const CertificationFocusSummary({
    required this.rating,
    required this.movieCountries,
    required this.tvCountries,
    required this.meanings,
  });

  final String rating;
  final List<String> movieCountries;
  final List<String> tvCountries;
  final List<String> meanings;

  /// Countries where the rating exists for either movies or television.
  List<String> get allCountries {
    final set = <String>{...movieCountries, ...tvCountries};
    final list = set.toList()..sort();
    return list;
  }

  int get totalCountries => allCountries.length;
}

/// Provides certification reference data and exposes helpers for filtering by
/// country, rating value, or textual query.
class CertificationsProvider extends ChangeNotifier {
  CertificationsProvider(this._repository);

  final TmdbRepository _repository;

  final Map<String, CountryInfo> _countryMap = <String, CountryInfo>{};
  Map<String, List<Certification>> _movieCertifications =
      <String, List<Certification>>{};
  Map<String, List<Certification>> _tvCertifications =
      <String, List<Certification>>{};

  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _errorMessage;
  String _query = '';
  String? _selectedCertification;

  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasLoaded;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;
  String get query => _query;
  String? get selectedCertification => _selectedCertification;

  /// All certification tokens encountered across movie and TV endpoints,
  /// ordered by their lowest reported `order` value in TMDB responses.
  List<String> get availableCertifications {
    final ranking = <String, int>{};

    void addEntries(Map<String, List<Certification>> source) {
      source.forEach((_, certs) {
        for (final cert in certs) {
          final key = cert.certification.trim();
          if (key.isEmpty) {
            continue;
          }
          ranking.update(
            key,
            (value) => value < cert.order ? value : cert.order,
            ifAbsent: () => cert.order,
          );
        }
      });
    }

    addEntries(_movieCertifications);
    addEntries(_tvCertifications);

    final items = ranking.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    return items.map((entry) => entry.key).toList(growable: false);
  }

  /// Country entries filtered for movie certifications.
  List<CertificationCountryEntry> get movieEntries =>
      _buildEntries(_movieCertifications);

  /// Country entries filtered for TV certifications.
  List<CertificationCountryEntry> get tvEntries =>
      _buildEntries(_tvCertifications);

  /// Aggregated description for the currently selected certification filter.
  CertificationFocusSummary? get focusSummary {
    final rating = _selectedCertification;
    if (rating == null || rating.trim().isEmpty) {
      return null;
    }

    final target = rating.toLowerCase();
    final movieCountries = <String>{};
    final tvCountries = <String>{};
    final meanings = <String>{};

    void collect(
      Map<String, List<Certification>> source,
      Set<String> accumulator,
    ) {
      source.forEach((code, list) {
        final matches = list.where(
          (cert) => cert.certification.toLowerCase() == target,
        );
        if (matches.isEmpty) {
          return;
        }
        accumulator.add(_countryNameFor(code));
        for (final cert in matches) {
          final meaning = cert.meaning.trim();
          if (meaning.isNotEmpty) {
            meanings.add(meaning);
          }
        }
      });
    }

    collect(_movieCertifications, movieCountries);
    collect(_tvCertifications, tvCountries);

    if (movieCountries.isEmpty && tvCountries.isEmpty) {
      return null;
    }

    final movieList = movieCountries.toList()..sort();
    final tvList = tvCountries.toList()..sort();
    final meaningList = meanings.toList()..sort();

    return CertificationFocusSummary(
      rating: rating,
      movieCountries: movieList,
      tvCountries: tvList,
      meanings: meaningList,
    );
  }

  /// Fetches certification reference data from the TMDB API.
  ///
  /// - Countries: `GET /3/configuration/countries`
  /// - Movie certifications: `GET /3/certification/movie/list`
  /// - TV certifications: `GET /3/certification/tv/list`
  Future<void> load({bool forceRefresh = false}) async {
    if (_isLoading) {
      return;
    }
    if (_hasLoaded && !forceRefresh) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final countriesFuture =
          _repository.fetchCountries(forceRefresh: forceRefresh);
      final movieFuture =
          _repository.fetchMovieCertifications(forceRefresh: forceRefresh);
      final tvFuture =
          _repository.fetchTvCertifications(forceRefresh: forceRefresh);

      final countries = await countriesFuture;
      final movieCerts = await movieFuture;
      final tvCerts = await tvFuture;

      _applyCountries(countries);
      _movieCertifications = _normalizeCertifications(movieCerts);
      _tvCertifications = _normalizeCertifications(tvCerts);

      _hasLoaded = true;
    } on TmdbException catch (error) {
      _errorMessage = error.message;
    } catch (error) {
      _errorMessage = 'Failed to load certifications: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Ensures the provider has loaded at least once, calling [load] lazily.
  Future<void> ensureInitialized() async {
    if (_hasLoaded || _isLoading) {
      return;
    }
    await load();
  }

  /// Refreshes the cached payloads from TMDB, forcing new network requests.
  Future<void> refresh() => load(forceRefresh: true);

  /// Updates the free-text filter applied to countries or meanings.
  void updateQuery(String value) {
    final normalized = value.trim();
    if (_query == normalized) {
      return;
    }
    _query = normalized;
    notifyListeners();
  }

  /// Toggles the selected certification filter.
  void toggleCertification(String? rating) {
    if (rating == null || rating.isEmpty) {
      _selectedCertification = null;
    } else if (_selectedCertification == rating) {
      _selectedCertification = null;
    } else {
      _selectedCertification = rating;
    }
    notifyListeners();
  }

  void clearFilters() {
    _query = '';
    _selectedCertification = null;
    notifyListeners();
  }

  void _applyCountries(List<CountryInfo> countries) {
    _countryMap
      ..clear()
      ..addEntries(
        countries.map(
          (country) => MapEntry(country.code.toUpperCase(), country),
        ),
      );
  }

  Map<String, List<Certification>> _normalizeCertifications(
    Map<String, List<Certification>> source,
  ) {
    final normalized = <String, List<Certification>>{};
    source.forEach((code, list) {
      if (list.isEmpty) {
        return;
      }
      final normalizedCode = code.toUpperCase();
      final sorted = List<Certification>.from(list)
        ..sort((a, b) => a.order.compareTo(b.order));
      normalized[normalizedCode] = sorted;
    });
    return normalized;
  }

  List<CertificationCountryEntry> _buildEntries(
    Map<String, List<Certification>> source,
  ) {
    if (source.isEmpty) {
      return const <CertificationCountryEntry>[];
    }

    final filter = _query.toLowerCase();
    final rating = _selectedCertification?.toLowerCase();
    final results = <CertificationCountryEntry>[];

    source.forEach((code, list) {
      if (list.isEmpty) {
        return;
      }

      if (rating != null &&
          !list.any((cert) => cert.certification.toLowerCase() == rating)) {
        return;
      }

      final name = _countryNameFor(code);
      if (filter.isNotEmpty) {
        final matchesCountry =
            name.toLowerCase().contains(filter) || code.toLowerCase().contains(filter);
        final matchesCert = list.any((cert) {
          final token = cert.certification.toLowerCase();
          final meaning = cert.meaning.toLowerCase();
          return token.contains(filter) || meaning.contains(filter);
        });
        if (!matchesCountry && !matchesCert) {
          return;
        }
      }

      results.add(
        CertificationCountryEntry(
          code: code,
          name: name,
          certifications: list,
        ),
      );
    });

    results.sort((a, b) => a.name.compareTo(b.name));
    return results;
  }

  String _countryNameFor(String code) {
    final lookup = _countryMap[code.toUpperCase()];
    return lookup?.englishName ?? code.toUpperCase();
  }
}
