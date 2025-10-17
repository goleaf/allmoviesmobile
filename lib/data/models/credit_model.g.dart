// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credit_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CastImpl _$$CastImplFromJson(Map<String, dynamic> json) => _$CastImpl(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  character: json['character'] as String?,
  profilePath: json['profile_path'] as String?,
  order: (json['order'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$CastImplToJson(_$CastImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'character': instance.character,
      'profile_path': instance.profilePath,
      'order': instance.order,
    };

_$CrewImpl _$$CrewImplFromJson(Map<String, dynamic> json) => _$CrewImpl(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  job: json['job'] as String,
  department: json['department'] as String,
  profilePath: json['profile_path'] as String?,
);

Map<String, dynamic> _$$CrewImplToJson(_$CrewImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'job': instance.job,
      'department': instance.department,
      'profile_path': instance.profilePath,
    };

_$CreditsImpl _$$CreditsImplFromJson(Map<String, dynamic> json) =>
    _$CreditsImpl(
      cast:
          (json['cast'] as List<dynamic>?)
              ?.map((e) => Cast.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      crew:
          (json['crew'] as List<dynamic>?)
              ?.map((e) => Crew.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$CreditsImplToJson(_$CreditsImpl instance) =>
    <String, dynamic>{'cast': instance.cast, 'crew': instance.crew};
