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
      originalLanguage: json['original_language'] as String?,
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
      collection: json['belongs_to_collection'] == null
          ? null
          : Collection.fromJson(
              json['belongs_to_collection'] as Map<String, dynamic>,
            ),
      popularity: (json['popularity'] as num?)?.toDouble(),
      status: json['status'] as String?,
      homepage: json['homepage'] as String?,
      externalIds: json['external_ids'] == null
          ? const ExternalIds()
          : ExternalIds.fromJson(json['external_ids'] as Map<String, dynamic>),
      budget: (json['budget'] as num?)?.toInt(),
      revenue: (json['revenue'] as num?)?.toInt(),
      cast:
          (json['cast'] as List<dynamic>?)
              ?.map((e) => Cast.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      crew:
          (json['crew'] as List<dynamic>?)
              ?.map((e) => Crew.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      keywords:
          (json['keywords'] as List<dynamic>?)
              ?.map((e) => Keyword.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      reviews:
          (json['reviews'] as List<dynamic>?)
              ?.map((e) => Review.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      releaseDates:
          (json['release_dates'] as List<dynamic>?)
              ?.map(
                (e) => ReleaseDatesResult.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      watchProviders: json['watchProviders'] == null
          ? const {}
          : MovieDetailed._watchProvidersFromJson(
              json['watchProviders'] as Map<String, dynamic>?,
            ),
      alternativeTitles:
          (json['alternative_titles'] as List<dynamic>?)
              ?.map((e) => AlternativeTitle.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      translations:
          (json['translations'] as List<dynamic>?)
              ?.map((e) => Translation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      videos:
          (json['videos'] as List<dynamic>?)
              ?.map((e) => Video.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      imageBackdrops:
          (json['imageBackdrops'] as List<dynamic>?)
              ?.map((e) => ImageModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      imagePosters:
          (json['imagePosters'] as List<dynamic>?)
              ?.map((e) => ImageModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      imageProfiles:
          (json['imageProfiles'] as List<dynamic>?)
              ?.map((e) => ImageModel.fromJson(e as Map<String, dynamic>))
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
      'original_language': instance.originalLanguage,
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
      'belongs_to_collection': instance.collection,
      'popularity': instance.popularity,
      'status': instance.status,
      'homepage': instance.homepage,
      'external_ids': instance.externalIds,
      'budget': instance.budget,
      'revenue': instance.revenue,
      'cast': instance.cast,
      'crew': instance.crew,
      'keywords': instance.keywords,
      'reviews': instance.reviews,
      'release_dates': instance.releaseDates,
      'watchProviders': MovieDetailed._watchProvidersToJson(
        instance.watchProviders,
      ),
      'alternative_titles': instance.alternativeTitles,
      'translations': instance.translations,
      'videos': instance.videos,
      'imageBackdrops': instance.imageBackdrops,
      'imagePosters': instance.imagePosters,
      'imageProfiles': instance.imageProfiles,
      'images': instance.images,
      'recommendations': instance.recommendations,
      'similar': instance.similar,
    };
