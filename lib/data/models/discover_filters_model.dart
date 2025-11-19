import 'package:freezed_annotation/freezed_annotation.dart';

part 'discover_filters_model.freezed.dart';
part 'discover_filters_model.g.dart';

enum SortBy {
  @JsonValue('popularity.desc')
  popularityDesc,
  @JsonValue('popularity.asc')
  popularityAsc,
  @JsonValue('revenue.desc')
  revenueDesc,
  @JsonValue('revenue.asc')
  revenueAsc,
  @JsonValue('vote_average.desc')
  ratingDesc,
  @JsonValue('vote_average.asc')
  ratingAsc,
  @JsonValue('vote_count.desc')
  voteCountDesc,
  @JsonValue('vote_count.asc')
  voteCountAsc,
  @JsonValue('release_date.desc')
  releaseDateDesc,
  @JsonValue('release_date.asc')
  releaseDateAsc,
  @JsonValue('title.asc')
  titleAsc,
  @JsonValue('title.desc')
  titleDesc,
  @JsonValue('first_air_date.desc')
  firstAirDateDesc,
  @JsonValue('first_air_date.asc')
  firstAirDateAsc,
  @JsonValue('name.asc')
  nameAsc,
  @JsonValue('name.desc')
  nameDesc,
}

@freezed
class DiscoverFilters with _$DiscoverFilters {
  const factory DiscoverFilters({
    @Default(1) int page,
    @JsonKey(name: 'sort_by') @Default(SortBy.popularityDesc) SortBy sortBy,
    @JsonKey(name: 'include_adult') @Default(false) bool includeAdult,
    @JsonKey(name: 'certification_country') String? certificationCountry,
    @JsonKey(name: 'certification') String? certification,
    @JsonKey(name: 'certification.lte') String? certificationLte,
    @JsonKey(name: 'certification.gte') String? certificationGte,
    @JsonKey(name: 'with_genres') String? withGenres,
    @JsonKey(name: 'primary_release_year') int? primaryReleaseYear,
    @JsonKey(name: 'primary_release_date.gte') String? primaryReleaseDateGte,
    @JsonKey(name: 'primary_release_date.lte') String? primaryReleaseDateLte,
    @JsonKey(name: 'release_date.gte') String? releaseDateGte,
    @JsonKey(name: 'release_date.lte') String? releaseDateLte,
    @JsonKey(name: 'with_release_type') String? withReleaseType,
    @JsonKey(name: 'with_origin_country') String? withOriginCountry,
    @JsonKey(name: 'with_original_language') String? withOriginalLanguage,
    @JsonKey(name: 'with_cast') String? withCast,
    @JsonKey(name: 'with_crew') String? withCrew,
    @JsonKey(name: 'with_companies') String? withCompanies,
    @JsonKey(name: 'with_keywords') String? withKeywords,
    @JsonKey(name: 'with_runtime.gte') int? runtimeGte,
    @JsonKey(name: 'with_runtime.lte') int? runtimeLte,
    @JsonKey(name: 'vote_average.gte') double? voteAverageGte,
    @JsonKey(name: 'vote_average.lte') double? voteAverageLte,
    @JsonKey(name: 'vote_count.gte') int? voteCountGte,
    @JsonKey(name: 'vote_count.lte') int? voteCountLte,
    @JsonKey(name: 'with_watch_providers') String? withWatchProviders,
    @JsonKey(name: 'watch_region') String? watchRegion,
    @JsonKey(name: 'with_watch_monetization_types')
    String? withWatchMonetizationTypes,
  }) = _DiscoverFilters;

  factory DiscoverFilters.fromJson(Map<String, dynamic> json) =>
      _$DiscoverFiltersFromJson(json);
}

extension DiscoverFiltersQuery on DiscoverFilters {
  /// Convert the filters into TMDB-friendly query parameters.
  Map<String, String> toQueryParameters({bool includePage = false}) {
    final json = toJson();
    final parameters = <String, String>{};

    for (final entry in json.entries) {
      final key = entry.key;
      final value = entry.value;

      if (value == null) {
        continue;
      }

      if (!includePage && key == 'page') {
        continue;
      }

      if (key == 'include_adult' && value == false) {
        // Avoid sending the default TMDB behaviour unless explicitly enabled.
        continue;
      }

      parameters[key] = value.toString();
    }

    return parameters;
  }
}

extension SortByExtension on SortBy {
  String get value {
    switch (this) {
      case SortBy.popularityDesc:
        return 'popularity.desc';
      case SortBy.popularityAsc:
        return 'popularity.asc';
      case SortBy.revenueDesc:
        return 'revenue.desc';
      case SortBy.revenueAsc:
        return 'revenue.asc';
      case SortBy.ratingDesc:
        return 'vote_average.desc';
      case SortBy.ratingAsc:
        return 'vote_average.asc';
      case SortBy.voteCountDesc:
        return 'vote_count.desc';
      case SortBy.voteCountAsc:
        return 'vote_count.asc';
      case SortBy.releaseDateDesc:
        return 'release_date.desc';
      case SortBy.releaseDateAsc:
        return 'release_date.asc';
      case SortBy.titleAsc:
        return 'title.asc';
      case SortBy.titleDesc:
        return 'title.desc';
      case SortBy.firstAirDateDesc:
        return 'first_air_date.desc';
      case SortBy.firstAirDateAsc:
        return 'first_air_date.asc';
      case SortBy.nameAsc:
        return 'name.asc';
      case SortBy.nameDesc:
        return 'name.desc';
    }
  }

  static SortBy fromString(String? value) {
    if (value == null) return SortBy.popularityDesc;
    return SortBy.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SortBy.popularityDesc,
    );
  }
}
