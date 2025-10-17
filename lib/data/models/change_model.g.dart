// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'change_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChangeValueImpl _$$ChangeValueImplFromJson(Map<String, dynamic> json) =>
    _$ChangeValueImpl(value: json['value']);

Map<String, dynamic> _$$ChangeValueImplToJson(_$ChangeValueImpl instance) =>
    <String, dynamic>{'value': instance.value};

_$ChangeItemImpl _$$ChangeItemImplFromJson(Map<String, dynamic> json) =>
    _$ChangeItemImpl(
      id: json['id'] as String,
      action: json['action'] as String,
      time: json['time'] as String,
      language: json['iso_639_1'] as String?,
      country: json['iso_3166_1'] as String?,
      value: json['value'],
      originalValue: json['original_value'],
    );

Map<String, dynamic> _$$ChangeItemImplToJson(_$ChangeItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'action': instance.action,
      'time': instance.time,
      'iso_639_1': instance.language,
      'iso_3166_1': instance.country,
      'value': instance.value,
      'original_value': instance.originalValue,
    };

_$ChangeImpl _$$ChangeImplFromJson(Map<String, dynamic> json) => _$ChangeImpl(
  key: json['key'] as String,
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => ChangeItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$$ChangeImplToJson(_$ChangeImpl instance) =>
    <String, dynamic>{'key': instance.key, 'items': instance.items};

_$ChangesResponseImpl _$$ChangesResponseImplFromJson(
  Map<String, dynamic> json,
) => _$ChangesResponseImpl(
  changes:
      (json['changes'] as List<dynamic>?)
          ?.map((e) => Change.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$$ChangesResponseImplToJson(
  _$ChangesResponseImpl instance,
) => <String, dynamic>{'changes': instance.changes};
