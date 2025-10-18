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

  List<PersonCombinedTimelineEntry> get combinedCreditsTimeline {
    final detail = _detail;
    if (detail == null) {
      return const <PersonCombinedTimelineEntry>[];
    }

    final combined = <PersonCredit>[
      ...detail.combinedCredits.cast,
      ...detail.combinedCredits.crew,
    ];

    if (combined.isEmpty) {
      return const <PersonCombinedTimelineEntry>[];
    }

    final uniqueCredits = <String>{};
    final credits = <PersonCredit>[];
    for (final credit in combined) {
      final key = _creditKey(credit);
      if (uniqueCredits.add(key)) {
        credits.add(credit);
      }
    }

    if (credits.isEmpty) {
      return const <PersonCombinedTimelineEntry>[];
    }

    credits.sort(_compareCredits);

    final grouped = <String, Map<String, List<PersonCredit>>>{};
    for (final credit in credits) {
      final year = credit.releaseYear ?? PersonCombinedTimelineEntry.unknownYear;
      final mediaType = (credit.mediaType ?? PersonCombinedTimelineEntry.unknownMediaType)
          .trim()
          .toLowerCase();
      final yearBucket = grouped.putIfAbsent(year, () => <String, List<PersonCredit>>{});
      final typeBucket = yearBucket.putIfAbsent(mediaType, () => <PersonCredit>[]);
      typeBucket.add(credit);
    }

    final sortedYears = grouped.keys.toList()
      ..sort(_compareYearLabels);

    return sortedYears
        .map((year) {
          final typeBuckets = grouped[year] ?? const <String, List<PersonCredit>>{};
          final sortedTypes = typeBuckets.keys.toList()..sort();
          final groups = sortedTypes.map((type) {
            final creditsForType = List<PersonCredit>.from(typeBuckets[type] ?? const [])
              ..sort(_compareCredits);
            return PersonCombinedTimelineMediaGroup(
              mediaType: type,
              credits: creditsForType,
            );
          }).toList();
          return PersonCombinedTimelineEntry(
            year: year,
            groups: groups,
          );
        })
        .where((entry) => entry.groups.isNotEmpty)
        .toList(growable: false);
  }

  List<PersonCareerTimelineBucket> get careerTimelineBuckets {
    final detail = _detail;
    if (detail == null) {
      return const <PersonCareerTimelineBucket>[];
    }

    final buckets = <String, _CareerTimelineAccumulator>{};
    final castSeen = <String>{};
    final crewSeen = <String>{};

    for (final credit in detail.combinedCredits.cast) {
      final key = _creditKey(credit);
      if (!castSeen.add(key)) {
        continue;
      }
      final year =
          credit.releaseYear ?? PersonCombinedTimelineEntry.unknownYear;
      final accumulator =
          buckets.putIfAbsent(year, () => _CareerTimelineAccumulator(year));
      accumulator.actingCount++;
    }

    for (final credit in detail.combinedCredits.crew) {
      final key = _creditKey(credit);
      if (!crewSeen.add(key)) {
        continue;
      }
      final year =
          credit.releaseYear ?? PersonCombinedTimelineEntry.unknownYear;
      final accumulator =
          buckets.putIfAbsent(year, () => _CareerTimelineAccumulator(year));
      accumulator.crewCount++;
    }

    if (buckets.isEmpty) {
      return const <PersonCareerTimelineBucket>[];
    }

    final sortedYears = buckets.keys.toList()
      ..sort(_compareYearLabelsAscending);

    return sortedYears
        .map(
          (year) => PersonCareerTimelineBucket(
            year: year,
            actingCredits: buckets[year]?.actingCount ?? 0,
            crewCredits: buckets[year]?.crewCount ?? 0,
          ),
        )
        .toList(growable: false);
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

int _compareCredits(PersonCredit a, PersonCredit b) {
  final dateA = a.parsedDate;
  final dateB = b.parsedDate;
  if (dateA == null && dateB == null) {
    final yearA = a.releaseYear ?? '';
    final yearB = b.releaseYear ?? '';
    final yearComparison = yearB.compareTo(yearA);
    if (yearComparison != 0) {
      return yearComparison;
    }
    return a.displayTitle.compareTo(b.displayTitle);
  }
  if (dateA == null) {
    return 1;
  }
  if (dateB == null) {
    return -1;
  }
  return dateB.compareTo(dateA);
}

int _compareYearLabels(String a, String b) {
  final unknown = PersonCombinedTimelineEntry.unknownYear;
  if (a == unknown && b == unknown) {
    return 0;
  }
  if (a == unknown) {
    return 1;
  }
  if (b == unknown) {
    return -1;
  }
  final parsedA = int.tryParse(a);
  final parsedB = int.tryParse(b);
  if (parsedA != null && parsedB != null) {
    return parsedB.compareTo(parsedA);
  }
  if (parsedA != null) {
    return -1;
  }
  if (parsedB != null) {
    return 1;
  }
  return b.compareTo(a);
}

int _compareYearLabelsAscending(String a, String b) {
  final unknown = PersonCombinedTimelineEntry.unknownYear;
  if (a == unknown && b == unknown) {
    return 0;
  }
  if (a == unknown) {
    return 1;
  }
  if (b == unknown) {
    return -1;
  }
  final parsedA = int.tryParse(a);
  final parsedB = int.tryParse(b);
  if (parsedA != null && parsedB != null) {
    return parsedA.compareTo(parsedB);
  }
  if (parsedA != null) {
    return -1;
  }
  if (parsedB != null) {
    return 1;
  }
  return a.compareTo(b);
}

String _creditKey(PersonCredit credit) {
  final mediaType = credit.mediaType ?? PersonCombinedTimelineEntry.unknownMediaType;
  final job = credit.job ?? '';
  final character = credit.character ?? '';
  return '${credit.id}::$mediaType::$job::$character';
}

class PersonCareerTimelineBucket {
  const PersonCareerTimelineBucket({
    required this.year,
    required this.actingCredits,
    required this.crewCredits,
  });

  final String year;
  final int actingCredits;
  final int crewCredits;

  int get total => actingCredits + crewCredits;
  bool get hasKnownYear => year != PersonCombinedTimelineEntry.unknownYear;
}

class _CareerTimelineAccumulator {
  _CareerTimelineAccumulator(this.year);

  final String year;
  int actingCount = 0;
  int crewCount = 0;
}

class PersonCombinedTimelineEntry {
  const PersonCombinedTimelineEntry({
    required this.year,
    required this.groups,
  });

  static const String unknownYear = 'unknown';
  static const String unknownMediaType = 'other';

  final String year;
  final List<PersonCombinedTimelineMediaGroup> groups;

  bool get hasKnownYear => year != unknownYear;
}

class PersonCombinedTimelineMediaGroup {
  const PersonCombinedTimelineMediaGroup({
    required this.mediaType,
    required this.credits,
  });

  final String mediaType;
  final List<PersonCredit> credits;
}
