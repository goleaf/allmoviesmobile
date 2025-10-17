// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'certification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CertificationImpl _$$CertificationImplFromJson(Map<String, dynamic> json) =>
    _$CertificationImpl(
      certification: json['certification'] as String,
      meaning: json['meaning'] as String,
      order: (json['order'] as num).toInt(),
    );

Map<String, dynamic> _$$CertificationImplToJson(_$CertificationImpl instance) =>
    <String, dynamic>{
      'certification': instance.certification,
      'meaning': instance.meaning,
      'order': instance.order,
    };

_$ReleaseDatesImpl _$$ReleaseDatesImplFromJson(Map<String, dynamic> json) =>
    _$ReleaseDatesImpl(
      certification: json['certification'] as String,
      language: json['iso_639_1'] as String?,
      note: json['note'] as String?,
      releaseDate: json['release_date'] as String?,
      type: (json['type'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$ReleaseDatesImplToJson(_$ReleaseDatesImpl instance) =>
    <String, dynamic>{
      'certification': instance.certification,
      'iso_639_1': instance.language,
      'note': instance.note,
      'release_date': instance.releaseDate,
      'type': instance.type,
    };

_$ReleaseDatesResultImpl _$$ReleaseDatesResultImplFromJson(
  Map<String, dynamic> json,
) => _$ReleaseDatesResultImpl(
  countryCode: json['iso_3166_1'] as String,
  releaseDates:
      (json['releaseDates'] as List<dynamic>?)
          ?.map((e) => ReleaseDates.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$$ReleaseDatesResultImplToJson(
  _$ReleaseDatesResultImpl instance,
) => <String, dynamic>{
  'iso_3166_1': instance.countryCode,
  'releaseDates': instance.releaseDates,
};
