import 'package:flutter/material.dart';

import '../data/models/person_detail_model.dart';
import '../data/models/person_model.dart';
import '../data/tmdb_repository.dart';

enum PersonCreditsSortOption { year, popularity, rating }

class PersonDetailProvider extends ChangeNotifier {
  PersonDetailProvider(this._repository, this.personId, {Person? seedPerson})
    : _summary = seedPerson;

  final TmdbRepository _repository;
  final int personId;

  Person? _summary;
  PersonDetail? _detail;
  bool _isLoading = false;
  String? _errorMessage;
  PersonCreditsSortOption _combinedCreditsSort = PersonCreditsSortOption.year;

  Person? get summary => _summary;
  PersonDetail? get detail => _detail;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  PersonCreditsSortOption get combinedCreditsSortOption =>
      _combinedCreditsSort;

  bool get hasCombinedCredits => _combinedCredits.isNotEmpty;

  List<PersonCredit> get combinedCreditsSortedByYear =>
      List.unmodifiable(_sortCombinedCredits(PersonCreditsSortOption.year));

  List<PersonCredit> get combinedCreditsSortedByPopularity =>
      List.unmodifiable(
        _sortCombinedCredits(PersonCreditsSortOption.popularity),
      );

  List<PersonCredit> get combinedCreditsSortedByRating =>
      List.unmodifiable(
        _sortCombinedCredits(PersonCreditsSortOption.rating),
      );

  List<PersonCredit> get combinedCreditsSorted => List.unmodifiable(
        _sortCombinedCredits(_combinedCreditsSort),
      );

  void setCombinedCreditsSortOption(PersonCreditsSortOption option) {
    if (_combinedCreditsSort == option) {
      return;
    }
    _combinedCreditsSort = option;
    notifyListeners();
  }

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

  List<PersonCredit> get _combinedCredits {
    final detail = _detail;
    if (detail == null) {
      return const [];
    }

    final combinedCredits = <PersonCredit>[]
      ..addAll(detail.combinedCredits.cast)
      ..addAll(detail.combinedCredits.crew);

    // Deduplicate credits by combining identifiers that uniquely represent a
    // person's involvement in a title. This avoids the same entry appearing
    // twice when a credit is surfaced both as cast and crew.
    final seen = <String>{};
    final unique = <PersonCredit>[];
    for (final credit in combinedCredits) {
      final key = [
        credit.creditId,
        credit.id,
        credit.mediaType,
        credit.department,
        credit.job,
        credit.character,
      ].whereType<Object>().join('-');
      if (seen.add(key)) {
        unique.add(credit);
      }
    }
    return unique;
  }

  List<PersonCredit> _sortCombinedCredits(PersonCreditsSortOption option) {
    final credits = List<PersonCredit>.from(_combinedCredits);

    int compareByDate(PersonCredit a, PersonCredit b) {
      final aDate = a.parsedDate;
      final bDate = b.parsedDate;
      if (aDate == null && bDate == null) {
        return a.displayTitle.compareTo(b.displayTitle);
      }
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      final comparison = bDate.compareTo(aDate);
      if (comparison != 0) {
        return comparison;
      }
      return a.displayTitle.compareTo(b.displayTitle);
    }

    int compareByPopularity(PersonCredit a, PersonCredit b) {
      final aPopularity = a.popularity ?? double.negativeInfinity;
      final bPopularity = b.popularity ?? double.negativeInfinity;
      final comparison = bPopularity.compareTo(aPopularity);
      if (comparison != 0) {
        return comparison;
      }
      return compareByDate(a, b);
    }

    int compareByRating(PersonCredit a, PersonCredit b) {
      final aRating = a.voteAverage ?? double.negativeInfinity;
      final bRating = b.voteAverage ?? double.negativeInfinity;
      final comparison = bRating.compareTo(aRating);
      if (comparison != 0) {
        return comparison;
      }
      final aVotes = a.voteCount ?? -1;
      final bVotes = b.voteCount ?? -1;
      final voteComparison = bVotes.compareTo(aVotes);
      if (voteComparison != 0) {
        return voteComparison;
      }
      return compareByDate(a, b);
    }

    switch (option) {
      case PersonCreditsSortOption.year:
        credits.sort(compareByDate);
        break;
      case PersonCreditsSortOption.popularity:
        credits.sort(compareByPopularity);
        break;
      case PersonCreditsSortOption.rating:
        credits.sort(compareByRating);
        break;
    }

    return credits;
  }
}
