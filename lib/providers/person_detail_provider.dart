import 'package:flutter/material.dart';

import '../data/models/person_detail_model.dart';
import '../data/models/person_model.dart';
import '../data/tmdb_repository.dart';

class PersonDetailProvider extends ChangeNotifier {
  PersonDetailProvider(this._repository, this.personId, {Person? seedPerson})
      : _summary = seedPerson;

  final TmdbRepository _repository;
  final int personId;

  Person? _summary;
  PersonDetail? _detail;
  bool _isLoading = false;
  String? _errorMessage;

  Person? get summary => _summary;
  PersonDetail? get detail => _detail;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> load({bool forceRefresh = false}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final result = await _repository.fetchPersonDetails(
        personId,
        forceRefresh: forceRefresh,
      );

      _detail = result;
      _summary ??= Person(
        id: result.id,
        name: result.name,
        profilePath: result.profilePath,
        biography: result.biography,
        knownForDepartment: result.knownForDepartment,
        birthday: result.birthday,
        placeOfBirth: result.placeOfBirth,
        alsoKnownAs: result.alsoKnownAs,
        popularity: result.popularity,
      );
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

