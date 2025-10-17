// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'episode_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EpisodeImpl _$$EpisodeImplFromJson(Map<String, dynamic> json) =>
    _$EpisodeImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      episodeNumber: (json['episode_number'] as num).toInt(),
      seasonNumber: (json['season_number'] as num).toInt(),
      overview: json['overview'] as String?,
      airDate: json['air_date'] as String?,
      stillPath: json['still_path'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble(),
      voteCount: (json['vote_count'] as num?)?.toInt(),
      runtime: (json['runtime'] as num?)?.toInt(),
      cast:
          (json['cast'] as List<dynamic>?)
              ?.map((e) => Cast.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      guestStars:
          (json['guest_stars'] as List<dynamic>?)
              ?.map((e) => Cast.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      crew:
          (json['crew'] as List<dynamic>?)
              ?.map((e) => Crew.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$EpisodeImplToJson(_$EpisodeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'episode_number': instance.episodeNumber,
      'season_number': instance.seasonNumber,
      'overview': instance.overview,
      'air_date': instance.airDate,
      'still_path': instance.stillPath,
      'vote_average': instance.voteAverage,
      'vote_count': instance.voteCount,
      'runtime': instance.runtime,
      'cast': instance.cast,
      'guest_stars': instance.guestStars,
      'crew': instance.crew,
    };
