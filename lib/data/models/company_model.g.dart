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
      parentCompany: json['parent_company'] == null
          ? null
          : ParentCompany.fromJson(
              json['parent_company'] as Map<String, dynamic>,
            ),
      alternativeNames:
          (json['alternative_names'] as List<dynamic>? ?? const [])
              .map((e) => e as String)
              .toList(),
      logoGallery: (json['logo_gallery'] as List<dynamic>? ?? const [])
          .map((e) =>
              CompanyLogo.fromJson(e as Map<String, dynamic>))
          .toList(),
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
      'parent_company': instance.parentCompany?.toJson(),
      'alternative_names': instance.alternativeNames,
      'logo_gallery': instance.logoGallery.map((e) => e.toJson()).toList(),
      'produced_movies': instance.producedMovies,
      'produced_series': instance.producedSeries,
    };

_$ParentCompanyImpl _$$ParentCompanyImplFromJson(Map<String, dynamic> json) =>
    _$ParentCompanyImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      logoPath: json['logo_path'] as String?,
      originCountry: json['origin_country'] as String?,
    );

Map<String, dynamic> _$$ParentCompanyImplToJson(
        _$ParentCompanyImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'logo_path': instance.logoPath,
      'origin_country': instance.originCountry,
    };

_$CompanyLogoImpl _$$CompanyLogoImplFromJson(Map<String, dynamic> json) =>
    _$CompanyLogoImpl(
      filePath: json['file_path'] as String,
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
      aspectRatio: (json['aspect_ratio'] as num?)?.toDouble(),
      voteAverage: (json['vote_average'] as num?)?.toDouble(),
      voteCount: (json['vote_count'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$CompanyLogoImplToJson(_$CompanyLogoImpl instance) =>
    <String, dynamic>{
      'file_path': instance.filePath,
      'width': instance.width,
      'height': instance.height,
      'aspect_ratio': instance.aspectRatio,
      'vote_average': instance.voteAverage,
      'vote_count': instance.voteCount,
    };
