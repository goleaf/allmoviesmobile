// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CompanyImpl _$$CompanyImplFromJson(Map<String, dynamic> json) =>
    _$CompanyImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      logoPath: json['logo_path'] as String?,
      originCountry: json['origin_country'] as String?,
      description: json['description'] as String?,
      headquarters: json['headquarters'] as String?,
      homepage: json['homepage'] as String?,
      producedMovies: json['produced_movies'] as List<dynamic>? ?? const [],
      producedSeries: json['produced_series'] as List<dynamic>? ?? const [],
    );

Map<String, dynamic> _$$CompanyImplToJson(_$CompanyImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'logo_path': instance.logoPath,
      'origin_country': instance.originCountry,
      'description': instance.description,
      'headquarters': instance.headquarters,
      'homepage': instance.homepage,
      'produced_movies': instance.producedMovies,
      'produced_series': instance.producedSeries,
    };
