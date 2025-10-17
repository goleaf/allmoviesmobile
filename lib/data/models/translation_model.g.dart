// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'translation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TranslationDataImpl _$$TranslationDataImplFromJson(
        Map<String, dynamic> json) =>
    _$TranslationDataImpl(
      title: json['title'] as String?,
      overview: json['overview'] as String?,
      homepage: json['homepage'] as String?,
      tagline: json['tagline'] as String?,
    );

Map<String, dynamic> _$$TranslationDataImplToJson(
        _$TranslationDataImpl instance) =>
    <String, dynamic>{
      'title': instance.title,
      'overview': instance.overview,
      'homepage': instance.homepage,
      'tagline': instance.tagline,
    };

_$TranslationImpl _$$TranslationImplFromJson(Map<String, dynamic> json) =>
    _$TranslationImpl(
      iso31661: json['iso_3166_1'] as String,
      iso6391: json['iso_639_1'] as String,
      name: json['name'] as String,
      englishName: json['english_name'] as String,
      data: TranslationData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$TranslationImplToJson(_$TranslationImpl instance) =>
    <String, dynamic>{
      'iso_3166_1': instance.iso31661,
      'iso_639_1': instance.iso6391,
      'name': instance.name,
      'english_name': instance.englishName,
      'data': instance.data,
    };
