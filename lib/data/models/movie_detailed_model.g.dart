// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie_detailed_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MovieDetailedImpl _$$MovieDetailedImplFromJson(Map<String, dynamic> json) =>
    _$MovieDetailedImpl(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      originalTitle: json['original_title'] as String,
      voteAverage: (json['vote_average'] as num).toDouble(),
      voteCount: (json['vote_count'] as num).toInt(),
      overview: json['overview'] as String?,
      tagline: json['tagline'] as String?,
      releaseDate: json['release_date'] as String?,
      runtime: (json['runtime'] as num?)?.toInt(),
      genres:
          (json['genres'] as List<dynamic>?)
              ?.map((e) => Genre.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      productionCompanies:
          (json['production_companies'] as List<dynamic>?)
              ?.map((e) => Company.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      productionCountries:
          (json['production_countries'] as List<dynamic>?)
              ?.map((e) => Country.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      spokenLanguages:
          (json['spoken_languages'] as List<dynamic>?)
              ?.map((e) => Language.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      popularity: (json['popularity'] as num?)?.toDouble(),
      status: json['status'] as String?,
      homepage: json['homepage'] as String?,
      externalIds: json['external_ids'] == null
          ? const ExternalIds()
          : ExternalIds.fromJson(json['external_ids'] as Map<String, dynamic>),
      budget: (json['budget'] as num?)?.toInt(),
      revenue: (json['revenue'] as num?)?.toInt(),
      videos:
          (json['videos'] as List<dynamic>?)
              ?.map((e) => Video.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => ImageModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      recommendations:
          (json['recommendations'] as List<dynamic>?)
              ?.map((e) => MovieRef.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      similar:
          (json['similar'] as List<dynamic>?)
              ?.map((e) => MovieRef.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$MovieDetailedImplToJson(_$MovieDetailedImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'original_title': instance.originalTitle,
      'vote_average': instance.voteAverage,
      'vote_count': instance.voteCount,
      'overview': instance.overview,
      'tagline': instance.tagline,
      'release_date': instance.releaseDate,
      'runtime': instance.runtime,
      'genres': instance.genres,
      'production_companies': instance.productionCompanies,
      'production_countries': instance.productionCountries,
      'spoken_languages': instance.spokenLanguages,
      'poster_path': instance.posterPath,
      'backdrop_path': instance.backdropPath,
      'popularity': instance.popularity,
      'status': instance.status,
      'homepage': instance.homepage,
      'external_ids': instance.externalIds,
      'budget': instance.budget,
      'revenue': instance.revenue,
      'videos': instance.videos,
      'images': instance.images,
      'recommendations': instance.recommendations,
      'similar': instance.similar,
    };
