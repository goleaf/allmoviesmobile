import 'package:flutter/material.dart';

import '../data/models/company_model.dart';
import '../data/tmdb_repository.dart';

class CompaniesProvider extends ChangeNotifier {
  CompaniesProvider(this._repository);

  final TmdbRepository _repository;

  final List<Company> _searchResults = [];
  bool _isSearching = false;
  String? _errorMessage;
  String _lastQuery = '';

  List<Company> get searchResults => List.unmodifiable(_searchResults);
  bool get isSearching => _isSearching;
  String? get errorMessage => _errorMessage;
  String get lastQuery => _lastQuery;

  Future<void> searchCompanies(String query) async {
    final normalized = query.trim();
    if (normalized.isEmpty) {
      _searchResults
        ..clear();
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
      final response = await _repository.fetchCompanies(query: normalized, page: 1);
      _searchResults
        ..clear()
        ..addAll(response.results);
      _errorMessage = null;
    } on TmdbException catch (error) {
      _errorMessage = error.message;
      _searchResults.clear();
    } catch (error) {
      _errorMessage = 'Failed to search companies: $error';
      _searchResults.clear();
    } finally {
      _isSearching = false;
      notifyListeners();
    }
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

  void clear() {
    _searchResults.clear();
    _errorMessage = null;
    _lastQuery = '';
    notifyListeners();
  }
}
