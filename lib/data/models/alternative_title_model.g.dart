// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alternative_title_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AlternativeTitleImpl _$$AlternativeTitleImplFromJson(
  Map<String, dynamic> json,
) => _$AlternativeTitleImpl(
  iso31661: json['iso_3166_1'] as String,
  title: json['title'] as String,
  type: json['type'] as String?,
);

Map<String, dynamic> _$$AlternativeTitleImplToJson(
  _$AlternativeTitleImpl instance,
) => <String, dynamic>{
  'iso_3166_1': instance.iso31661,
  'title': instance.title,
  'type': instance.type,
};
