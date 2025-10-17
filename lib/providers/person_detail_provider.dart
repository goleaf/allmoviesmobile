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

String _creditKey(PersonCredit credit) {
  final mediaType = credit.mediaType ?? PersonCombinedTimelineEntry.unknownMediaType;
  final job = credit.job ?? '';
  final character = credit.character ?? '';
  return '${credit.id}::$mediaType::$job::$character';
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
