// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discover_filters_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DiscoverFiltersImpl _$$DiscoverFiltersImplFromJson(
  Map<String, dynamic> json,
) => _$DiscoverFiltersImpl(
  page: (json['page'] as num?)?.toInt() ?? 1,
  sortBy:
      $enumDecodeNullable(_$SortByEnumMap, json['sort_by']) ??
      SortBy.popularityDesc,
  withGenres: json['with_genres'] as String?,
  primaryReleaseYear: (json['primary_release_year'] as num?)?.toInt(),
  releaseDateGte: json['primary_release_date.gte'] as String?,
  releaseDateLte: json['primary_release_date.lte'] as String?,
  withOriginCountry: json['with_origin_country'] as String?,
  withOriginalLanguage: json['with_original_language'] as String?,
  runtimeGte: (json['with_runtime.gte'] as num?)?.toInt(),
  runtimeLte: (json['with_runtime.lte'] as num?)?.toInt(),
  voteAverageGte: (json['vote_average.gte'] as num?)?.toDouble(),
  voteCountGte: (json['vote_count.gte'] as num?)?.toInt(),
);

Map<String, dynamic> _$$DiscoverFiltersImplToJson(
  _$DiscoverFiltersImpl instance,
) => <String, dynamic>{
  'page': instance.page,
  'sort_by': _$SortByEnumMap[instance.sortBy]!,
  'with_genres': instance.withGenres,
  'primary_release_year': instance.primaryReleaseYear,
  'primary_release_date.gte': instance.releaseDateGte,
  'primary_release_date.lte': instance.releaseDateLte,
  'with_origin_country': instance.withOriginCountry,
  'with_original_language': instance.withOriginalLanguage,
  'with_runtime.gte': instance.runtimeGte,
  'with_runtime.lte': instance.runtimeLte,
  'vote_average.gte': instance.voteAverageGte,
  'vote_count.gte': instance.voteCountGte,
};

const _$SortByEnumMap = {
  SortBy.popularityDesc: 'popularity.desc',
  SortBy.popularityAsc: 'popularity.asc',
  SortBy.ratingDesc: 'vote_average.desc',
  SortBy.ratingAsc: 'vote_average.asc',
  SortBy.releaseDateDesc: 'release_date.desc',
  SortBy.releaseDateAsc: 'release_date.asc',
  SortBy.titleAsc: 'title.asc',
  SortBy.titleDesc: 'title.desc',
};
