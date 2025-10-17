// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_detailed_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AlternativeNameImpl _$$AlternativeNameImplFromJson(
        Map<String, dynamic> json) =>
    _$AlternativeNameImpl(
      name: json['name'] as String,
      type: json['type'] as String,
    );

Map<String, dynamic> _$$AlternativeNameImplToJson(
        _$AlternativeNameImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'type': instance.type,
    };

_$NetworkDetailedImpl _$$NetworkDetailedImplFromJson(
        Map<String, dynamic> json) =>
    _$NetworkDetailedImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      logoPath: json['logo_path'] as String?,
      originCountry: json['origin_country'] as String,
      headquarters: json['headquarters'] as String?,
      homepage: json['homepage'] as String?,
      alternativeNames: (json['alternative_names'] as List<dynamic>?)
              ?.map((e) => AlternativeName.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$NetworkDetailedImplToJson(
        _$NetworkDetailedImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'logo_path': instance.logoPath,
      'origin_country': instance.originCountry,
      'headquarters': instance.headquarters,
      'homepage': instance.homepage,
      'alternative_names': instance.alternativeNames,
    };
