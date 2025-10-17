// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movie_ref_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MovieRefImpl _$$MovieRefImplFromJson(Map<String, dynamic> json) =>
    _$MovieRefImpl(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble(),
      releaseDate: json['release_date'] as String?,
      mediaType: json['media_type'] as String?,
    );

Map<String, dynamic> _$$MovieRefImplToJson(_$MovieRefImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'poster_path': instance.posterPath,
      'backdrop_path': instance.backdropPath,
      'vote_average': instance.voteAverage,
      'release_date': instance.releaseDate,
      'media_type': instance.mediaType,
    };
