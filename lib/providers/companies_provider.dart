import 'package:flutter/material.dart';

import '../data/models/company_model.dart';
import '../data/models/configuration_model.dart';
import '../data/tmdb_repository.dart';

class CompaniesProvider extends ChangeNotifier {
  CompaniesProvider(this._repository);

  final TmdbRepository _repository;

  final List<Company> _allResults = [];
  final List<Company> _filteredResults = [];
  final List<Company> _popularCompanies = [];
  final List<CountryInfo> _countries = [];

  bool _isSearching = false;
  bool _isLoadingCountries = false;
  bool _isLoadingPopular = false;
  bool _initialized = false;

  String? _errorMessage;
  String? _countriesError;
  String? _popularError;
  String _lastQuery = '';
  String? _selectedCountry;

  List<Company> get searchResults => List.unmodifiable(_filteredResults);
  List<Company> get popularCompanies => List.unmodifiable(_popularCompanies);
  List<CountryInfo> get countries => List.unmodifiable(_countries);

  bool get isSearching => _isSearching;
  bool get isLoadingCountries => _isLoadingCountries;
  bool get isLoadingPopular => _isLoadingPopular;

  String? get errorMessage => _errorMessage;
  String? get countriesError => _countriesError;
  String? get popularError => _popularError;
  String get lastQuery => _lastQuery;
  String? get selectedCountry => _selectedCountry;

  Future<void> ensureInitialized() async {
    if (_initialized) {
      if (_countries.isEmpty && !_isLoadingCountries) {
        await loadCountries();
      }
      if (_popularCompanies.isEmpty && !_isLoadingPopular) {
        await loadPopularCompanies();
      }
      return;
    }

    _initialized = true;
    await Future.wait([loadCountries(), loadPopularCompanies()]);
  }

  Future<void> loadCountries({bool forceRefresh = false}) async {
    if (_isLoadingCountries) {
      return;
    }

    _isLoadingCountries = true;
    _countriesError = null;
    notifyListeners();

    try {
      final results = await _repository.fetchCountries(
        forceRefresh: forceRefresh,
      );
      final sorted = List<CountryInfo>.from(results)
        ..sort((a, b) => a.englishName.compareTo(b.englishName));
      _countries
        ..clear()
        ..addAll(sorted);
    } catch (error) {
      _countriesError = 'Failed to load countries: $error';
    } finally {
      _isLoadingCountries = false;
      notifyListeners();
    }
  }

  Future<void> loadPopularCompanies({
    bool forceRefresh = false,
    int limit = 12,
  }) async {
    if (_isLoadingPopular) {
      return;
    }

    _isLoadingPopular = true;
    _popularError = null;
    notifyListeners();

    try {
      final results = await _repository.fetchPopularProductionCompanies(
        limit: limit,
        forceRefresh: forceRefresh,
      );
      _popularCompanies
        ..clear()
        ..addAll(results);
    } catch (error) {
      _popularError = 'Failed to load popular companies: $error';
    } finally {
      _isLoadingPopular = false;
      notifyListeners();
    }
  }

  Future<void> searchCompanies(String query) async {
    final normalized = query.trim();
    if (normalized.isEmpty) {
      _allResults.clear();
      _filteredResults.clear();
      _errorMessage = null;
      _lastQuery = '';
      notifyListeners();
      return;
    }

    if (_isSearching && normalized == _lastQuery) {
      return;
    }

    _isSearching = true;
    _errorMessage = null;
    _lastQuery = normalized;
    notifyListeners();

    try {
      final response = await _repository.fetchCompanies(
        query: normalized,
        page: 1,
      );
      _allResults
        ..clear()
        ..addAll(response.results);
      _applyFilters();
      _errorMessage = null;
    } on TmdbException catch (error) {
      _errorMessage = error.message;
      _allResults.clear();
      _filteredResults.clear();
    } catch (error) {
      _errorMessage = 'Failed to search companies: $error';
      _allResults.clear();
      _filteredResults.clear();
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  Future<void> refreshPopularCompanies() {
    final desiredLimit = _popularCompanies.isNotEmpty
        ? _popularCompanies.length
        : 12;
    return loadPopularCompanies(forceRefresh: true, limit: desiredLimit);
  }

  Future<Company?> fetchCompanyDetails(int companyId) async {
    try {
      return await _repository.fetchCompanyDetails(companyId);
    } catch (error) {
      _errorMessage = 'Failed to load company details: $error';
      notifyListeners();
      return null;
    }
  }

  void setCountryFilter(String? countryCode) {
    final normalized = countryCode?.trim().toUpperCase();
    final nextValue = (normalized == null || normalized.isEmpty)
        ? null
        : normalized;
    if (_selectedCountry == nextValue) {
      return;
    }
    _selectedCountry = nextValue;
    _applyFilters();
    notifyListeners();
  }

  void clear() {
    _allResults.clear();
    _filteredResults.clear();
    _errorMessage = null;
    _lastQuery = '';
    _isSearching = false;
    notifyListeners();
  }

  void _applyFilters() {
    Iterable<Company> results = _allResults;
    final country = _selectedCountry;
    if (country != null && country.isNotEmpty) {
      results = results.where(
        (company) => (company.originCountry ?? '').toUpperCase() == country,
      );
    }

    _filteredResults
      ..clear()
      ..addAll(results);
  }
}
