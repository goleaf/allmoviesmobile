// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VideoImpl _$$VideoImplFromJson(Map<String, dynamic> json) => _$VideoImpl(
  key: json['key'] as String,
  site: json['site'] as String,
  type: json['type'] as String,
  name: json['name'] as String,
  official: json['official'] as bool,
  publishedAt: json['published_at'] as String,
);

Map<String, dynamic> _$$VideoImplToJson(_$VideoImpl instance) =>
    <String, dynamic>{
      'key': instance.key,
      'site': instance.site,
      'type': instance.type,
      'name': instance.name,
      'official': instance.official,
      'published_at': instance.publishedAt,
    };
