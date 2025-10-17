import 'package:freezed_annotation/freezed_annotation.dart';

part 'discover_filters_model.freezed.dart';
part 'discover_filters_model.g.dart';

enum SortBy {
  @JsonValue('popularity.desc')
  popularityDesc,
  @JsonValue('popularity.asc')
  popularityAsc,
  @JsonValue('vote_average.desc')
  ratingDesc,
  @JsonValue('vote_average.asc')
  ratingAsc,
  @JsonValue('release_date.desc')
  releaseDateDesc,
  @JsonValue('release_date.asc')
  releaseDateAsc,
  @JsonValue('title.asc')
  titleAsc,
  @JsonValue('title.desc')
  titleDesc,
}

@freezed
class DiscoverFilters with _$DiscoverFilters {
  const factory DiscoverFilters({
    @Default(1) int page,
    @JsonKey(name: 'sort_by') @Default(SortBy.popularityDesc) SortBy sortBy,
    @JsonKey(name: 'with_genres') String? withGenres,
    @JsonKey(name: 'primary_release_year') int? primaryReleaseYear,
    @JsonKey(name: 'primary_release_date.gte') String? releaseDateGte,
    @JsonKey(name: 'primary_release_date.lte') String? releaseDateLte,
    @JsonKey(name: 'with_origin_country') String? withOriginCountry,
    @JsonKey(name: 'with_original_language') String? withOriginalLanguage,
    @JsonKey(name: 'with_runtime.gte') int? runtimeGte,
    @JsonKey(name: 'with_runtime.lte') int? runtimeLte,
    @JsonKey(name: 'vote_average.gte') double? voteAverageGte,
    @JsonKey(name: 'vote_count.gte') int? voteCountGte,
  }) = _DiscoverFilters;

  factory DiscoverFilters.fromJson(Map<String, dynamic> json) =>
      _$DiscoverFiltersFromJson(json);
}

