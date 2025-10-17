// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'season_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SeasonImpl _$$SeasonImplFromJson(Map<String, dynamic> json) => _$SeasonImpl(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  seasonNumber: (json['season_number'] as num).toInt(),
  overview: json['overview'] as String?,
  airDate: json['air_date'] as String?,
  posterPath: json['poster_path'] as String?,
  episodeCount: (json['episode_count'] as num?)?.toInt(),
  episodes:
      (json['episodes'] as List<dynamic>?)
          ?.map((e) => Episode.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  videos: (json['videos'] as List<dynamic>?)
          ?.map((e) => Video.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$$SeasonImplToJson(_$SeasonImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'season_number': instance.seasonNumber,
      'overview': instance.overview,
      'air_date': instance.airDate,
      'poster_path': instance.posterPath,
      'episode_count': instance.episodeCount,
      'episodes': instance.episodes,
      'videos': instance.videos,
    };
