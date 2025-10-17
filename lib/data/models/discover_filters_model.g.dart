// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discover_filters_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DiscoverFiltersImpl _$$DiscoverFiltersImplFromJson(
        Map<String, dynamic> json) =>
    _$DiscoverFiltersImpl(
      page: (json['page'] as num?)?.toInt() ?? 1,
      sortBy: $enumDecodeNullable(_$SortByEnumMap, json['sort_by']) ??
          SortBy.popularityDesc,
      includeAdult: json['include_adult'] as bool? ?? false,
      certificationCountry: json['certification_country'] as String?,
      certification: json['certification'] as String?,
      certificationLte: json['certification.lte'] as String?,
      certificationGte: json['certification.gte'] as String?,
      withGenres: json['with_genres'] as String?,
      primaryReleaseYear: (json['primary_release_year'] as num?)?.toInt(),
      primaryReleaseDateGte: json['primary_release_date.gte'] as String?,
      primaryReleaseDateLte: json['primary_release_date.lte'] as String?,
      releaseDateGte: json['release_date.gte'] as String?,
      releaseDateLte: json['release_date.lte'] as String?,
      withReleaseType: json['with_release_type'] as String?,
      withOriginCountry: json['with_origin_country'] as String?,
      withOriginalLanguage: json['with_original_language'] as String?,
      withCast: json['with_cast'] as String?,
      withCrew: json['with_crew'] as String?,
      withCompanies: json['with_companies'] as String?,
      withKeywords: json['with_keywords'] as String?,
      runtimeGte: (json['with_runtime.gte'] as num?)?.toInt(),
      runtimeLte: (json['with_runtime.lte'] as num?)?.toInt(),
      voteAverageGte: (json['vote_average.gte'] as num?)?.toDouble(),
      voteAverageLte: (json['vote_average.lte'] as num?)?.toDouble(),
      voteCountGte: (json['vote_count.gte'] as num?)?.toInt(),
      voteCountLte: (json['vote_count.lte'] as num?)?.toInt(),
      withWatchProviders: json['with_watch_providers'] as String?,
      watchRegion: json['watch_region'] as String?,
      withWatchMonetizationTypes:
          json['with_watch_monetization_types'] as String?,
    );

Map<String, dynamic> _$$DiscoverFiltersImplToJson(
        _$DiscoverFiltersImpl instance) =>
    <String, dynamic>{
      'page': instance.page,
      'sort_by': _$SortByEnumMap[instance.sortBy]!,
      'include_adult': instance.includeAdult,
      'certification_country': instance.certificationCountry,
      'certification': instance.certification,
      'certification.lte': instance.certificationLte,
      'certification.gte': instance.certificationGte,
      'with_genres': instance.withGenres,
      'primary_release_year': instance.primaryReleaseYear,
      'primary_release_date.gte': instance.primaryReleaseDateGte,
      'primary_release_date.lte': instance.primaryReleaseDateLte,
      'release_date.gte': instance.releaseDateGte,
      'release_date.lte': instance.releaseDateLte,
      'with_release_type': instance.withReleaseType,
      'with_origin_country': instance.withOriginCountry,
      'with_original_language': instance.withOriginalLanguage,
      'with_cast': instance.withCast,
      'with_crew': instance.withCrew,
      'with_companies': instance.withCompanies,
      'with_keywords': instance.withKeywords,
      'with_runtime.gte': instance.runtimeGte,
      'with_runtime.lte': instance.runtimeLte,
      'vote_average.gte': instance.voteAverageGte,
      'vote_average.lte': instance.voteAverageLte,
      'vote_count.gte': instance.voteCountGte,
      'vote_count.lte': instance.voteCountLte,
      'with_watch_providers': instance.withWatchProviders,
      'watch_region': instance.watchRegion,
      'with_watch_monetization_types': instance.withWatchMonetizationTypes,
    };

const _$SortByEnumMap = {
  SortBy.popularityDesc: 'popularity.desc',
  SortBy.popularityAsc: 'popularity.asc',
  SortBy.revenueDesc: 'revenue.desc',
  SortBy.revenueAsc: 'revenue.asc',
  SortBy.ratingDesc: 'vote_average.desc',
  SortBy.ratingAsc: 'vote_average.asc',
  SortBy.voteCountDesc: 'vote_count.desc',
  SortBy.voteCountAsc: 'vote_count.asc',
  SortBy.releaseDateDesc: 'release_date.desc',
  SortBy.releaseDateAsc: 'release_date.asc',
  SortBy.titleAsc: 'title.asc',
  SortBy.titleDesc: 'title.desc',
};
