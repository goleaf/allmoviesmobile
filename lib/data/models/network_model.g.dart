// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NetworkImpl _$$NetworkImplFromJson(Map<String, dynamic> json) =>
    _$NetworkImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      logoPath: json['logo_path'] as String?,
      originCountry: json['origin_country'] as String?,
    );

Map<String, dynamic> _$$NetworkImplToJson(_$NetworkImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'logo_path': instance.logoPath,
      'origin_country': instance.originCountry,
    };
