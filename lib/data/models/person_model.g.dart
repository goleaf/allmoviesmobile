// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'person_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PersonImpl _$$PersonImplFromJson(Map<String, dynamic> json) => _$PersonImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      profilePath: json['profile_path'] as String?,
      biography: json['biography'] as String?,
      knownForDepartment: json['known_for_department'] as String?,
      birthday: json['birthday'] as String?,
      placeOfBirth: json['place_of_birth'] as String?,
      alsoKnownAs: (json['also_known_as'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
      popularity: (json['popularity'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$$PersonImplToJson(_$PersonImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'profile_path': instance.profilePath,
      'biography': instance.biography,
      'known_for_department': instance.knownForDepartment,
      'birthday': instance.birthday,
      'place_of_birth': instance.placeOfBirth,
      'also_known_as': instance.alsoKnownAs,
      'popularity': instance.popularity,
    };
