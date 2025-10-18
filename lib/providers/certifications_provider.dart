import 'package:flutter/material.dart';

import '../data/models/certification_model.dart';
import '../data/tmdb_repository.dart';

/// Provider responsible for loading and exposing TMDB certification catalogs
/// for both movies and TV shows alongside helpful UI metadata such as
/// localized country names and filter options.
class CertificationsProvider with ChangeNotifier {
  CertificationsProvider(this._repository);

  final TmdbRepository _repository;

  Map<String, List<Certification>> _movieCertifications = const {};
  Map<String, List<Certification>> _tvCertifications = const {};
  Map<String, String> _countryNames = const {};
  bool _isLoadingMovies = false;
  bool _isLoadingTv = false;
  bool _isLoadingCountries = false;
  String? _movieError;
  String? _tvError;
  String? _countryError;
  String? _selectedMovieCertification;
  String? _selectedTvCertification;

  Map<String, List<Certification>> get movieCertifications =>
      _movieCertifications;
  Map<String, List<Certification>> get tvCertifications => _tvCertifications;
  Map<String, String> get countryNames => _countryNames;
  bool get isLoadingMovies => _isLoadingMovies;
  bool get isLoadingTv => _isLoadingTv;
  bool get isLoadingCountries => _isLoadingCountries;
  String? get movieError => _movieError;
  String? get tvError => _tvError;
  String? get countryError => _countryError;
  String? get selectedMovieCertification => _selectedMovieCertification;
  String? get selectedTvCertification => _selectedTvCertification;

  /// Ensures that all certification catalogs and supporting metadata are
  /// available. Subsequent invocations will be ignored unless `forceRefresh`
  /// is set to true.
  Future<void> ensureLoaded({bool forceRefresh = false}) async {
    if (!forceRefresh &&
        _movieCertifications.isNotEmpty &&
        _tvCertifications.isNotEmpty &&
        _countryNames.isNotEmpty) {
      return;
    }

    await Future.wait([
      loadMovieCertifications(forceRefresh: forceRefresh),
      loadTvCertifications(forceRefresh: forceRefresh),
      loadCountryNames(forceRefresh: forceRefresh),
    ]);
  }

  /// Loads movie certifications using TMDB's `GET /3/certification/movie/list`
  /// endpoint. The JSON payload has the shape
  /// `{ "certifications": { "US": [{ "certification": "PG-13", "meaning": "Parents Strongly Cautioned", "order": 4 }] } }`.
  Future<void> loadMovieCertifications({bool forceRefresh = false}) async {
    if (_movieCertifications.isNotEmpty && !forceRefresh) {
      return;
    }

    _isLoadingMovies = true;
    _movieError = null;
    notifyListeners();

    try {
      final results =
          await _repository.fetchMovieCertifications(forceRefresh: forceRefresh);
      if (results.isNotEmpty) {
        _movieCertifications = results;
      }
    } on TmdbException catch (error) {
      _movieError = error.message;
    } catch (error) {
      _movieError = 'Failed to load movie certifications: $error';
    } finally {
      _isLoadingMovies = false;
      notifyListeners();
    }
  }

  /// Loads TV certifications using TMDB's `GET /3/certification/tv/list`
  /// endpoint. The JSON payload mirrors the movie variant with the same
  /// structure as
  /// `{ "certifications": { "US": [{ "certification": "TV-MA", "meaning": "Mature Audiences Only", "order": 6 }] } }`.
  Future<void> loadTvCertifications({bool forceRefresh = false}) async {
    if (_tvCertifications.isNotEmpty && !forceRefresh) {
      return;
    }

    _isLoadingTv = true;
    _tvError = null;
    notifyListeners();

    try {
      final results =
          await _repository.fetchTvCertifications(forceRefresh: forceRefresh);
      if (results.isNotEmpty) {
        _tvCertifications = results;
      }
    } on TmdbException catch (error) {
      _tvError = error.message;
    } catch (error) {
      _tvError = 'Failed to load TV certifications: $error';
    } finally {
      _isLoadingTv = false;
      notifyListeners();
    }
  }

  /// Loads localized country names so that ISO 3166-1 alpha-2 codes can be
  /// displayed as human readable labels. Data originates from
  /// `GET /3/configuration/countries` whose JSON payload looks like
  /// `[ { "iso_3166_1": "US", "english_name": "United States of America" } ]`.
  Future<void> loadCountryNames({bool forceRefresh = false}) async {
    if (_countryNames.isNotEmpty && !forceRefresh) {
      return;
    }

    _isLoadingCountries = true;
    _countryError = null;
    notifyListeners();

    try {
      final countries = await _repository.fetchCountries(forceRefresh: forceRefresh);
      if (countries.isNotEmpty) {
        _countryNames = {
          for (final country in countries)
            country.code.toUpperCase(): country.englishName,
        };
      }
    } on TmdbException catch (error) {
      _countryError = error.message;
    } catch (error) {
      _countryError = 'Failed to load country names: $error';
    } finally {
      _isLoadingCountries = false;
      notifyListeners();
    }
  }

  /// Updates the selected movie certification filter; use `null` to disable.
  void setSelectedMovieCertification(String? value) {
    if (value == _selectedMovieCertification) {
      return;
    }
    _selectedMovieCertification = value?.isEmpty == true ? null : value;
    notifyListeners();
  }

  /// Updates the selected TV certification filter; use `null` to disable.
  void setSelectedTvCertification(String? value) {
    if (value == _selectedTvCertification) {
      return;
    }
    _selectedTvCertification = value?.isEmpty == true ? null : value;
    notifyListeners();
  }

  /// Returns a sorted list of all unique movie certification codes so the UI
  /// can build filter controls.
  List<String> movieCertificationOptions() {
    final orders = <String, int>{};
    for (final entry in _movieCertifications.values) {
      for (final cert in entry) {
        final key = cert.certification.isEmpty ? 'NR' : cert.certification;
        final order = orders[key];
        if (order == null || cert.order < order) {
          orders[key] = cert.order;
        }
      }
    }
    final values = orders.keys.toList()
      ..sort((a, b) {
        final orderA = orders[a] ?? 0;
        final orderB = orders[b] ?? 0;
        final cmp = orderA.compareTo(orderB);
        if (cmp != 0) return cmp;
        return a.compareTo(b);
      });
    return values;
  }

  /// Returns a sorted list of all unique TV certification codes so the UI can
  /// build filter controls.
  List<String> tvCertificationOptions() {
    final orders = <String, int>{};
    for (final entry in _tvCertifications.values) {
      for (final cert in entry) {
        final key = cert.certification.isEmpty ? 'NR' : cert.certification;
        final order = orders[key];
        if (order == null || cert.order < order) {
          orders[key] = cert.order;
        }
      }
    }
    final values = orders.keys.toList()
      ..sort((a, b) {
        final orderA = orders[a] ?? 0;
        final orderB = orders[b] ?? 0;
        final cmp = orderA.compareTo(orderB);
        if (cmp != 0) return cmp;
        return a.compareTo(b);
      });
    return values;
  }

  /// Resolves a display name for the supplied ISO 3166-1 alpha-2 code. The
  /// method gracefully falls back to the uppercase code if no localized name is
  /// available.
  String countryName(String code) {
    if (code.isEmpty) {
      return code;
    }
    final normalized = code.toUpperCase();
    return _countryNames[normalized] ?? normalized;
  }
}
