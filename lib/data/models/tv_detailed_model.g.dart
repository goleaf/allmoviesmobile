// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tv_detailed_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TVDetailedImpl _$$TVDetailedImplFromJson(Map<String, dynamic> json) =>
    _$TVDetailedImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      originalName: json['original_name'] as String,
      voteAverage: (json['vote_average'] as num).toDouble(),
      voteCount: (json['vote_count'] as num).toInt(),
      overview: json['overview'] as String?,
      tagline: json['tagline'] as String?,
      firstAirDate: json['first_air_date'] as String?,
      lastAirDate: json['last_air_date'] as String?,
      numberOfSeasons: (json['number_of_seasons'] as num?)?.toInt(),
      numberOfEpisodes: (json['number_of_episodes'] as num?)?.toInt(),
      episodeRunTime:
          (json['episode_run_time'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
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
      networks:
          (json['networks'] as List<dynamic>?)
              ?.map((e) => Network.fromJson(e as Map<String, dynamic>))
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
      episodeGroups:
          (json['episode_groups'] as List<dynamic>?)
              ?.map((e) => EpisodeGroup.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      seasons:
          (json['seasons'] as List<dynamic>?)
              ?.map((e) => Season.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
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
              ?.map((e) => TVRef.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      similar:
          (json['similar'] as List<dynamic>?)
              ?.map((e) => TVRef.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$TVDetailedImplToJson(_$TVDetailedImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'original_name': instance.originalName,
      'vote_average': instance.voteAverage,
      'vote_count': instance.voteCount,
      'overview': instance.overview,
      'tagline': instance.tagline,
      'first_air_date': instance.firstAirDate,
      'last_air_date': instance.lastAirDate,
      'number_of_seasons': instance.numberOfSeasons,
      'number_of_episodes': instance.numberOfEpisodes,
      'episode_run_time': instance.episodeRunTime,
      'genres': instance.genres,
      'production_companies': instance.productionCompanies,
      'production_countries': instance.productionCountries,
      'spoken_languages': instance.spokenLanguages,
      'networks': instance.networks,
      'poster_path': instance.posterPath,
      'backdrop_path': instance.backdropPath,
      'popularity': instance.popularity,
      'status': instance.status,
      'homepage': instance.homepage,
      'external_ids': instance.externalIds,
      'episode_groups': instance.episodeGroups,
      'seasons': instance.seasons,
      'videos': instance.videos,
      'images': instance.images,
      'recommendations': instance.recommendations,
      'similar': instance.similar,
    };
