// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tv_ref_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TVRefImpl _$$TVRefImplFromJson(Map<String, dynamic> json) => _$TVRefImpl(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  posterPath: json['posterPath'] as String?,
  backdropPath: json['backdropPath'] as String?,
  voteAverage: (json['voteAverage'] as num?)?.toDouble(),
  firstAirDate: json['firstAirDate'] as String?,
);

Map<String, dynamic> _$$TVRefImplToJson(_$TVRefImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'posterPath': instance.posterPath,
      'backdropPath': instance.backdropPath,
      'voteAverage': instance.voteAverage,
      'firstAirDate': instance.firstAirDate,
    };
