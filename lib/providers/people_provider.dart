import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';

import '../data/models/person_model.dart';
import '../data/models/person_detail_model.dart';
import '../data/tmdb_repository.dart';

enum PeopleSection { trending, popular }

class PeopleSectionState {
  const PeopleSectionState({
    this.items = const <Person>[],
    this.isLoading = false,
    this.errorMessage,
  });

  static const _sentinel = Object();

  final List<Person> items;
  final bool isLoading;
  final String? errorMessage;

  PeopleSectionState copyWith({
    List<Person>? items,
    bool? isLoading,
    Object? errorMessage = _sentinel,
  }) {
    return PeopleSectionState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

class PeopleProvider extends ChangeNotifier {
  PeopleProvider(this._repository, {bool autoInitialize = true}) {
    if (autoInitialize) {
      _init();
    }
  }

  final TmdbRepository _repository;

  final Map<PeopleSection, PeopleSectionState> _sections = {
    for (final section in PeopleSection.values)
      section: const PeopleSectionState(),
  };

  final Map<PeopleSection, List<Person>> _allSectionItems = {
    for (final section in PeopleSection.values) section: const <Person>[],
  };

  bool _isInitialized = false;
  bool _isRefreshing = false;
  String? _globalError;
  String? _selectedDepartment;
  List<String> _availableDepartments = const <String>[];

  final Completer<void> _initializedCompleter = Completer<void>();

  Map<PeopleSection, PeopleSectionState> get sections => _sections;
  bool get isInitialized => _isInitialized;
  bool get isRefreshing => _isRefreshing;
  String? get globalError => _globalError;
  String? get selectedDepartment => _selectedDepartment;
  List<String> get availableDepartments =>
      UnmodifiableListView<String>(_availableDepartments);

  PeopleSectionState sectionState(PeopleSection section) => _sections[section]!;

  Future<void> _init() async {
    await refresh(force: true);
  }

  Future<void> get initialized => _initializedCompleter.future;

  Future<void> refresh({bool force = false}) async {
    if (_isRefreshing) {
      return;
    }

    if (_isInitialized && !force) {
      return;
    }

    _isRefreshing = true;
    _globalError = null;
    for (final section in PeopleSection.values) {
      _sections[section] = _sections[section]!.copyWith(
        isLoading: true,
        errorMessage: null,
      );
    }
    notifyListeners();

    try {
      final results = await Future.wait<List<Person>>([
        _repository.fetchTrendingPeople(),
        _repository.fetchPopularPeople().then((r) => r.results),
      ]);

      final sectionsList = PeopleSection.values;
      for (var index = 0; index < sectionsList.length; index++) {
        final section = sectionsList[index];
        final sectionItems = results[index];
        _sections[section] = PeopleSectionState(items: sectionItems);
        _allSectionItems[section] = sectionItems;
      }

      _rebuildAvailableDepartments();
      _applyDepartmentFilter(notifyListeners: false);

      _globalError = null;
      _isInitialized = true;
    } on TmdbException catch (error) {
      _globalError = error.message;
      _setErrorForAll(error.message);
    } catch (error) {
      _globalError = 'Failed to load people: $error';
      _setErrorForAll(_globalError);
    } finally {
      _isRefreshing = false;
      notifyListeners();
      if (!_initializedCompleter.isCompleted) {
        _initializedCompleter.complete();
      }
    }
  }

  void _setErrorForAll(String? message) {
    for (final section in PeopleSection.values) {
      _sections[section] = _sections[section]!.copyWith(
        isLoading: false,
        errorMessage: message,
        items: const <Person>[],
      );
      _allSectionItems[section] = const <Person>[];
    }
    _availableDepartments = const <String>[];
    _selectedDepartment = null;
  }

  Future<PersonDetail> loadDetails(int personId) async {
    try {
      return await _repository.fetchPersonDetails(personId);
    } catch (error) {
      throw TmdbException('Failed to load person details: $error');
    }
  }

  void selectDepartment(String? department) {
    if (_selectedDepartment == department) {
      return;
    }
    _selectedDepartment = department;
    _applyDepartmentFilter();
  }

  void _applyDepartmentFilter({bool notifyListeners = true}) {
    for (final section in PeopleSection.values) {
      final items = _allSectionItems[section] ?? const <Person>[];
      final filteredItems = _filterByDepartment(items);
      _sections[section] = _sections[section]!.copyWith(
        items: filteredItems,
        isLoading: false,
      );
    }
    if (notifyListeners) {
      notifyListeners();
    }
  }

  List<Person> _filterByDepartment(List<Person> people) {
    final department = _selectedDepartment;
    if (department == null || department.isEmpty) {
      return people;
    }

    return people
        .where((person) =>
            (person.knownForDepartment ?? '').toLowerCase().trim() ==
            department.toLowerCase().trim())
        .toList(growable: false);
  }

  void _rebuildAvailableDepartments() {
    final departmentSet = <String>{};
    for (final sectionItems in _allSectionItems.values) {
      for (final person in sectionItems) {
        final department = person.knownForDepartment?.trim();
        if (department != null && department.isNotEmpty) {
          departmentSet.add(department);
        }
      }
    }

    final sortedDepartments = departmentSet.toList()..sort();
    _availableDepartments = sortedDepartments;

    if (_selectedDepartment != null &&
        !_availableDepartments.contains(_selectedDepartment)) {
      _selectedDepartment = null;
    }
  }
}
