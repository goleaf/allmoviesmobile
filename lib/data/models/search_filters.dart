import 'package:flutter/foundation.dart';

@immutable
class MovieSearchFilters {
  const MovieSearchFilters({
    this.includeAdult = false,
    this.primaryReleaseYear,
    this.language,
    this.region,
  });

  final bool includeAdult;
  final String? primaryReleaseYear;
  final String? language;
  final String? region;

  MovieSearchFilters copyWith({
    bool? includeAdult,
    String? primaryReleaseYear,
    String? language,
    String? region,
  }) {
    return MovieSearchFilters(
      includeAdult: includeAdult ?? this.includeAdult,
      primaryReleaseYear: primaryReleaseYear ?? this.primaryReleaseYear,
      language: language ?? this.language,
      region: region ?? this.region,
    );
  }

  Map<String, String> toQueryParameters() {
    final params = <String, String>{'include_adult': includeAdult.toString()};

    void addIfNotEmpty(String key, String? value) {
      final trimmed = value?.trim();
      if (trimmed != null && trimmed.isNotEmpty) {
        params[key] = trimmed;
      }
    }

    addIfNotEmpty('primary_release_year', primaryReleaseYear);
    addIfNotEmpty('language', language);
    addIfNotEmpty('region', region);

    return params;
  }

  bool get hasActiveFilters {
    return includeAdult ||
        (primaryReleaseYear?.trim().isNotEmpty ?? false) ||
        (language?.trim().isNotEmpty ?? false) ||
        (region?.trim().isNotEmpty ?? false);
  }
}

@immutable
class TvSearchFilters {
  const TvSearchFilters({
    this.includeAdult = false,
    this.firstAirDateYear,
    this.language,
  });

  final bool includeAdult;
  final String? firstAirDateYear;
  final String? language;

  TvSearchFilters copyWith({
    bool? includeAdult,
    String? firstAirDateYear,
    String? language,
  }) {
    return TvSearchFilters(
      includeAdult: includeAdult ?? this.includeAdult,
      firstAirDateYear: firstAirDateYear ?? this.firstAirDateYear,
      language: language ?? this.language,
    );
  }

  Map<String, String> toQueryParameters() {
    final params = <String, String>{'include_adult': includeAdult.toString()};

    void addIfNotEmpty(String key, String? value) {
      final trimmed = value?.trim();
      if (trimmed != null && trimmed.isNotEmpty) {
        params[key] = trimmed;
      }
    }

    addIfNotEmpty('first_air_date_year', firstAirDateYear);
    addIfNotEmpty('language', language);

    return params;
  }

  bool get hasActiveFilters {
    return includeAdult ||
        (firstAirDateYear?.trim().isNotEmpty ?? false) ||
        (language?.trim().isNotEmpty ?? false);
  }
}
