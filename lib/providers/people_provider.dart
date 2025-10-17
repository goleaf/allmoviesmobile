import 'package:flutter/material.dart';
import 'dart:async';

import '../data/models/person_model.dart';
import '../data/models/person_detail_model.dart';
import '../data/tmdb_repository.dart';

enum PeopleSection { trending, popular }

enum CreditSortOrder { newestFirst, oldestFirst }

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

  final Map<PeopleSection, List<Person>> _rawSectionItems = {
    for (final section in PeopleSection.values) section: const <Person>[],
  };

  final Map<String, String> _availableDepartments = <String, String>{};

  String? _departmentFilter;
  String? _departmentFilterKey;
  CreditSortOrder _creditSortOrder = CreditSortOrder.newestFirst;

  bool _isInitialized = false;
  bool _isRefreshing = false;
  String? _globalError;

  final Completer<void> _initializedCompleter = Completer<void>();

  Map<PeopleSection, PeopleSectionState> get sections => _sections;
  bool get isInitialized => _isInitialized;
  bool get isRefreshing => _isRefreshing;
  String? get globalError => _globalError;
  String? get departmentFilter => _departmentFilter;
  CreditSortOrder get creditSortOrder => _creditSortOrder;
  List<String> get availableDepartments {
    final values = _availableDepartments.values.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return values;
  }

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
      _rawSectionItems[section] = const <Person>[];
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
        _rawSectionItems[section] = List<Person>.unmodifiable(sectionItems);
      }

      _rebuildAvailableDepartments();
      _rebuildFilteredSections();
      for (final section in PeopleSection.values) {
        _sections[section] = _sections[section]!
            .copyWith(isLoading: false, errorMessage: null);
      }

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
      _rawSectionItems[section] = const <Person>[];
    }
    _availableDepartments.clear();
    _departmentFilter = null;
    _departmentFilterKey = null;
  }

  Future<PersonDetail> loadDetails(int personId) async {
    try {
      final detail = await _repository.fetchPersonDetails(personId);
      return _sortDetailCredits(detail);
    } catch (error) {
      throw TmdbException('Failed to load person details: $error');
    }
  }

  void setDepartmentFilter(String? department) {
    final normalized = _normalizeDepartment(department);
    final normalizedKey = normalized?.toLowerCase();

    if (_departmentFilterKey == normalizedKey) {
      return;
    }

    _departmentFilter = normalized;
    _departmentFilterKey = normalizedKey;
    _rebuildFilteredSections();
    notifyListeners();
  }

  void setCreditSortOrder(CreditSortOrder order) {
    if (_creditSortOrder == order) {
      return;
    }
    _creditSortOrder = order;
    notifyListeners();
  }

  List<PersonCredit> transformCredits(Iterable<PersonCredit> credits) {
    final filtered = credits.where(_matchesDepartmentFilter).toList();
    return sortCredits(filtered);
  }

  List<PersonCredit> sortCredits(List<PersonCredit> credits) {
    final sorted = List<PersonCredit>.from(credits);
    sorted.sort(_compareCredits);
    return List<PersonCredit>.unmodifiable(sorted);
  }

  void _rebuildFilteredSections() {
    for (final section in PeopleSection.values) {
      final rawItems = _rawSectionItems[section] ?? const <Person>[];
      final filtered = _applyPeopleFilters(rawItems);
      _sections[section] = _sections[section]!.copyWith(items: filtered);
    }
  }

  List<Person> _applyPeopleFilters(List<Person> source) {
    final filterKey = _departmentFilterKey;
    if (filterKey == null) {
      return List<Person>.unmodifiable(source);
    }

    return List<Person>.unmodifiable(source
        .where((person) {
          final dept = _normalizeDepartment(person.knownForDepartment);
          if (dept == null) {
            return false;
          }
          return dept.toLowerCase() == filterKey;
        })
        .toList());
  }

  void _rebuildAvailableDepartments() {
    _availableDepartments.clear();
    for (final section in PeopleSection.values) {
      for (final person in _rawSectionItems[section] ?? const <Person>[]) {
        final normalized = _normalizeDepartment(person.knownForDepartment);
        if (normalized != null) {
          _availableDepartments.putIfAbsent(
            normalized.toLowerCase(),
            () => normalized,
          );
        }
      }
    }

    if (_departmentFilterKey != null &&
        !_availableDepartments.containsKey(_departmentFilterKey)) {
      _departmentFilter = null;
      _departmentFilterKey = null;
    }
  }

  bool _matchesDepartmentFilter(PersonCredit credit) {
    final filterKey = _departmentFilterKey;
    if (filterKey == null) {
      return true;
    }

    final creditDepartment = _normalizeCreditDepartment(credit);
    if (creditDepartment == null) {
      return false;
    }
    return creditDepartment.toLowerCase() == filterKey;
  }

  int _compareCredits(PersonCredit a, PersonCredit b) {
    switch (_creditSortOrder) {
      case CreditSortOrder.newestFirst:
        return _compareByDate(b, a);
      case CreditSortOrder.oldestFirst:
        return _compareByDate(a, b);
    }
  }

  int _compareByDate(PersonCredit left, PersonCredit right) {
    final leftDate = left.parsedDate;
    final rightDate = right.parsedDate;

    if (leftDate == null && rightDate == null) {
      return _compareByTitle(left, right);
    }
    if (leftDate == null) {
      return 1;
    }
    if (rightDate == null) {
      return -1;
    }

    final comparison = leftDate.compareTo(rightDate);
    if (comparison != 0) {
      return comparison;
    }
    return _compareByTitle(left, right);
  }

  int _compareByTitle(PersonCredit a, PersonCredit b) {
    return a.displayTitle.toLowerCase().compareTo(b.displayTitle.toLowerCase());
  }

  PersonDetail _sortDetailCredits(PersonDetail detail) {
    final combined = detail.combinedCredits;
    final movie = detail.movieCredits;
    final tv = detail.tvCredits;

    return PersonDetail(
      id: detail.id,
      name: detail.name,
      profilePath: detail.profilePath,
      biography: detail.biography,
      knownForDepartment: detail.knownForDepartment,
      birthday: detail.birthday,
      deathday: detail.deathday,
      placeOfBirth: detail.placeOfBirth,
      gender: detail.gender,
      alsoKnownAs: detail.alsoKnownAs,
      popularity: detail.popularity,
      externalIds: detail.externalIds,
      profiles: detail.profiles,
      taggedImages: detail.taggedImages,
      combinedCredits: PersonCredits(
        cast: sortCredits(combined.cast),
        crew: sortCredits(combined.crew),
      ),
      movieCredits: PersonCredits(
        cast: sortCredits(movie.cast),
        crew: sortCredits(movie.crew),
      ),
      tvCredits: PersonCredits(
        cast: sortCredits(tv.cast),
        crew: sortCredits(tv.crew),
      ),
      translations: detail.translations,
    );
  }

  String? _normalizeDepartment(String? value) {
    if (value == null) {
      return null;
    }
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }

  String? _normalizeCreditDepartment(PersonCredit credit) {
    final normalized = _normalizeDepartment(credit.department);
    if (normalized != null) {
      return normalized;
    }
    if (_normalizeDepartment(credit.character) != null) {
      return 'Acting';
    }
    return null;
  }
}
