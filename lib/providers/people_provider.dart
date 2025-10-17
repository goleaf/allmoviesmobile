import 'package:flutter/material.dart';

import '../data/models/person_model.dart';
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
      errorMessage:
          errorMessage == _sentinel ? this.errorMessage : errorMessage as String?,
    );
  }
}

class PeopleProvider extends ChangeNotifier {
  PeopleProvider(this._repository) {
    _init();
  }

  final TmdbRepository _repository;

  final Map<PeopleSection, PeopleSectionState> _sections = {
    for (final section in PeopleSection.values) section: const PeopleSectionState(),
  };

  bool _isInitialized = false;
  bool _isRefreshing = false;
  String? _globalError;

  Map<PeopleSection, PeopleSectionState> get sections => _sections;
  bool get isInitialized => _isInitialized;
  bool get isRefreshing => _isRefreshing;
  String? get globalError => _globalError;

  PeopleSectionState sectionState(PeopleSection section) => _sections[section]!;

  Future<void> _init() async {
    await refresh(force: true);
  }

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
      _sections[section] =
          _sections[section]!.copyWith(isLoading: true, errorMessage: null);
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
    }
  }

  void _setErrorForAll(String? message) {
    for (final section in PeopleSection.values) {
      _sections[section] = _sections[section]!.copyWith(
        isLoading: false,
        errorMessage: message,
        items: const <Person>[],
      );
    }
  }

  Future<Person> loadDetails(int personId) async {
    try {
      return await _repository.fetchPersonDetails(personId);
    } catch (error) {
      throw TmdbException('Failed to load person details: $error');
    }
  }
}
