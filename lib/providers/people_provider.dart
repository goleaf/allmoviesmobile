import 'package:flutter/foundation.dart';

import '../data/models/paginated_response.dart';
import '../data/models/person_model.dart';
import '../data/tmdb_repository.dart';
import 'paginated_resource_provider.dart';

const List<String> kPeopleDepartments = <String>[
  'Acting',
  'Directing',
  'Writing',
  'Production',
  'Editing',
  'Sound',
  'Art',
  'Camera',
  'Crew',
];

class PopularPeopleProvider extends PaginatedResourceProvider<Person> {
  PopularPeopleProvider(this._repository) {
    loadInitial();
  }

  final TmdbRepository _repository;

  List<Person> get people => items;
  bool get isLoading => isInitialLoading;
  bool get isLoadingMore => super.isLoadingMore;
  bool get canLoadMore => hasMore;

  Future<void> refreshPeople() => refresh();
  Future<void> loadMorePeople() => loadMore();

  @override
  Future<PaginatedResponse<Person>> loadPage(int page, {bool forceRefresh = false}) {
    return _repository.fetchPopularPeople(
      page: page,
      forceRefresh: forceRefresh,
    );
  }
}

class TrendingPeopleProvider extends PaginatedResourceProvider<Person> {
  TrendingPeopleProvider(
    this._repository, {
    String initialTimeWindow = 'day',
  }) : _timeWindow = initialTimeWindow {
    loadInitial();
  }

  final TmdbRepository _repository;
  String _timeWindow;

  List<Person> get people => items;
  bool get isLoading => isInitialLoading;
  bool get isLoadingMore => super.isLoadingMore;
  bool get canLoadMore => hasMore;
  String get timeWindow => _timeWindow;

  Future<void> refreshTrendingPeople() => loadInitial(forceRefresh: true);
  Future<void> loadMoreTrendingPeople() => loadMore();

  Future<void> setTimeWindow(String newWindow) async {
    if (newWindow == _timeWindow) {
      return;
    }

    _timeWindow = newWindow;
    await loadInitial(forceRefresh: true);
  }

  @override
  Future<PaginatedResponse<Person>> loadPage(int page, {bool forceRefresh = false}) {
    return _repository.fetchTrendingPeople(
      timeWindow: _timeWindow,
      page: page,
      forceRefresh: forceRefresh,
    );
  }
}

class DepartmentPeopleProvider extends PaginatedResourceProvider<Person> {
  DepartmentPeopleProvider(
    this._repository, {
    List<String>? departments,
    String initialDepartment = 'Acting',
  })  : _departments = departments ?? kPeopleDepartments,
        _selectedDepartment = initialDepartment {
    if (!_departments.contains(_selectedDepartment) && _departments.isNotEmpty) {
      _selectedDepartment = _departments.first;
    }
    loadInitial();
  }

  final TmdbRepository _repository;
  final List<String> _departments;
  String _selectedDepartment;

  List<Person> get people => items;
  bool get isLoading => isInitialLoading;
  bool get isLoadingMore => super.isLoadingMore;
  bool get canLoadMore => hasMore;
  List<String> get departments => List.unmodifiable(_departments);
  String get selectedDepartment => _selectedDepartment;

  Future<void> refreshDepartmentPeople() => loadInitial(forceRefresh: true);
  Future<void> loadMoreDepartmentPeople() => loadMore();

  Future<void> selectDepartment(String department) async {
    if (_selectedDepartment == department || !_departments.contains(department)) {
      return;
    }

    _selectedDepartment = department;
    await loadInitial(forceRefresh: true);
  }

  @override
  Future<PaginatedResponse<Person>> loadPage(int page, {bool forceRefresh = false}) async {
    final response = await _repository.fetchPopularPeople(
      page: page,
      forceRefresh: forceRefresh,
    );

    final filtered = response.results
        .where((person) =>
            (person.knownForDepartment ?? '').toLowerCase() ==
            _selectedDepartment.toLowerCase())
        .toList(growable: false);

    return PaginatedResponse<Person>(
      page: response.page,
      totalPages: response.totalPages,
      totalResults: response.totalResults,
      results: filtered,
    );
  }
}

class LatestPersonProvider extends ChangeNotifier {
  LatestPersonProvider(this._repository) {
    loadLatestPerson();
  }

  final TmdbRepository _repository;

  Person? _person;
  bool _isLoading = false;
  String? _errorMessage;

  Person? get person => _person;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadLatestPerson({bool forceRefresh = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _person = await _repository.fetchLatestPerson(forceRefresh: forceRefresh);
    } catch (error) {
      _errorMessage = error.toString();
      _person = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshLatestPerson() => loadLatestPerson(forceRefresh: true);
}

class PeopleSearchProvider extends ChangeNotifier {
  PeopleSearchProvider(this._repository);

  final TmdbRepository _repository;

  final List<Person> _results = [];
  String _query = '';
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _currentPage = 0;
  int _totalPages = 1;

  List<Person> get results => List.unmodifiable(_results);
  String get query => _query;
  bool get hasQuery => _query.trim().isNotEmpty;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  bool get canLoadMore => _currentPage < _totalPages;

  Future<void> search(String value) async {
    final trimmed = value.trim();

    if (trimmed.isEmpty) {
      _query = '';
      _results.clear();
      _errorMessage = null;
      _currentPage = 0;
      _totalPages = 1;
      notifyListeners();
      return;
    }

    _query = trimmed;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _repository.searchPeople(trimmed, page: 1, forceRefresh: true);
      _results
        ..clear()
        ..addAll(response.results);
      _currentPage = response.page;
      _totalPages = response.totalPages;
    } catch (error) {
      _errorMessage = error.toString();
      _results.clear();
      _currentPage = 0;
      _totalPages = 1;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !canLoadMore || !hasQuery) {
      return;
    }

    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final response = await _repository.searchPeople(_query, page: nextPage);
      _results.addAll(response.results);
      _currentPage = response.page;
      _totalPages = response.totalPages;
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> retry() async {
    if (_query.isNotEmpty) {
      await search(_query);
    }
  }
}
