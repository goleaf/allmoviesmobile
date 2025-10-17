// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'configuration_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ImagesConfigurationImpl _$$ImagesConfigurationImplFromJson(
        Map<String, dynamic> json) =>
    _$ImagesConfigurationImpl(
      baseUrl: json['base_url'] as String,
      secureBaseUrl: json['secure_base_url'] as String,
      backdropSizes: (json['backdrop_sizes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      logoSizes: (json['logo_sizes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      posterSizes: (json['poster_sizes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      profileSizes: (json['profile_sizes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      stillSizes: (json['still_sizes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$ImagesConfigurationImplToJson(
        _$ImagesConfigurationImpl instance) =>
    <String, dynamic>{
      'base_url': instance.baseUrl,
      'secure_base_url': instance.secureBaseUrl,
      'backdrop_sizes': instance.backdropSizes,
      'logo_sizes': instance.logoSizes,
      'poster_sizes': instance.posterSizes,
      'profile_sizes': instance.profileSizes,
      'still_sizes': instance.stillSizes,
    };

_$ApiConfigurationImpl _$$ApiConfigurationImplFromJson(
        Map<String, dynamic> json) =>
    _$ApiConfigurationImpl(
      images:
          ImagesConfiguration.fromJson(json['images'] as Map<String, dynamic>),
      changeKeys: (json['change_keys'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$ApiConfigurationImplToJson(
        _$ApiConfigurationImpl instance) =>
    <String, dynamic>{
      'images': instance.images,
      'change_keys': instance.changeKeys,
    };

_$CountryInfoImpl _$$CountryInfoImplFromJson(Map<String, dynamic> json) =>
    _$CountryInfoImpl(
      code: json['iso_3166_1'] as String,
      englishName: json['english_name'] as String,
      nativeName: json['native_name'] as String?,
    );

Map<String, dynamic> _$$CountryInfoImplToJson(_$CountryInfoImpl instance) =>
    <String, dynamic>{
      'iso_3166_1': instance.code,
      'english_name': instance.englishName,
      'native_name': instance.nativeName,
    };

_$LanguageInfoImpl _$$LanguageInfoImplFromJson(Map<String, dynamic> json) =>
    _$LanguageInfoImpl(
      code: json['iso_639_1'] as String,
      englishName: json['english_name'] as String,
      name: json['native_name'] as String?,
    );

Map<String, dynamic> _$$LanguageInfoImplToJson(_$LanguageInfoImpl instance) =>
    <String, dynamic>{
      'iso_639_1': instance.code,
      'english_name': instance.englishName,
      'native_name': instance.name,
    };

_$JobImpl _$$JobImplFromJson(Map<String, dynamic> json) => _$JobImpl(
      department: json['department'] as String,
      jobs:
          (json['jobs'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
    );

Map<String, dynamic> _$$JobImplToJson(_$JobImpl instance) => <String, dynamic>{
      'department': instance.department,
      'jobs': instance.jobs,
    };

_$TimezoneImpl _$$TimezoneImplFromJson(Map<String, dynamic> json) =>
    _$TimezoneImpl(
      countryCode: json['iso_3166_1'] as String,
      zones:
          (json['zones'] as List<dynamic>?)?.map((e) => e as String).toList() ??
              const [],
    );

Map<String, dynamic> _$$TimezoneImplToJson(_$TimezoneImpl instance) =>
    <String, dynamic>{
      'iso_3166_1': instance.countryCode,
      'zones': instance.zones,
    };
