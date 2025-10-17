// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'person_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Person _$PersonFromJson(Map<String, dynamic> json) {
  return _Person.fromJson(json);
}

/// @nodoc
mixin _$Person {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'profile_path')
  String? get profilePath => throw _privateConstructorUsedError;
  String? get biography => throw _privateConstructorUsedError;
  @JsonKey(name: 'known_for_department')
  String? get knownForDepartment => throw _privateConstructorUsedError;
  String? get birthday => throw _privateConstructorUsedError;
  @JsonKey(name: 'place_of_birth')
  String? get placeOfBirth => throw _privateConstructorUsedError;
  @JsonKey(name: 'also_known_as')
  List<String> get alsoKnownAs => throw _privateConstructorUsedError;
  double? get popularity => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PersonCopyWith<Person> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PersonCopyWith<$Res> {
  factory $PersonCopyWith(Person value, $Res Function(Person) then) =
      _$PersonCopyWithImpl<$Res, Person>;
  @useResult
  $Res call({
    int id,
    String name,
    @JsonKey(name: 'profile_path') String? profilePath,
    String? biography,
    @JsonKey(name: 'known_for_department') String? knownForDepartment,
    String? birthday,
    @JsonKey(name: 'place_of_birth') String? placeOfBirth,
    @JsonKey(name: 'also_known_as') List<String> alsoKnownAs,
    double? popularity,
  });
}

/// @nodoc
class _$PersonCopyWithImpl<$Res, $Val extends Person>
    implements $PersonCopyWith<$Res> {
  _$PersonCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? profilePath = freezed,
    Object? biography = freezed,
    Object? knownForDepartment = freezed,
    Object? birthday = freezed,
    Object? placeOfBirth = freezed,
    Object? alsoKnownAs = null,
    Object? popularity = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            profilePath: freezed == profilePath
                ? _value.profilePath
                : profilePath // ignore: cast_nullable_to_non_nullable
                      as String?,
            biography: freezed == biography
                ? _value.biography
                : biography // ignore: cast_nullable_to_non_nullable
                      as String?,
            knownForDepartment: freezed == knownForDepartment
                ? _value.knownForDepartment
                : knownForDepartment // ignore: cast_nullable_to_non_nullable
                      as String?,
            birthday: freezed == birthday
                ? _value.birthday
                : birthday // ignore: cast_nullable_to_non_nullable
                      as String?,
            placeOfBirth: freezed == placeOfBirth
                ? _value.placeOfBirth
                : placeOfBirth // ignore: cast_nullable_to_non_nullable
                      as String?,
            alsoKnownAs: null == alsoKnownAs
                ? _value.alsoKnownAs
                : alsoKnownAs // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            popularity: freezed == popularity
                ? _value.popularity
                : popularity // ignore: cast_nullable_to_non_nullable
                      as double?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PersonImplCopyWith<$Res> implements $PersonCopyWith<$Res> {
  factory _$$PersonImplCopyWith(
    _$PersonImpl value,
    $Res Function(_$PersonImpl) then,
  ) = __$$PersonImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String name,
    @JsonKey(name: 'profile_path') String? profilePath,
    String? biography,
    @JsonKey(name: 'known_for_department') String? knownForDepartment,
    String? birthday,
    @JsonKey(name: 'place_of_birth') String? placeOfBirth,
    @JsonKey(name: 'also_known_as') List<String> alsoKnownAs,
    double? popularity,
  });
}

/// @nodoc
class __$$PersonImplCopyWithImpl<$Res>
    extends _$PersonCopyWithImpl<$Res, _$PersonImpl>
    implements _$$PersonImplCopyWith<$Res> {
  __$$PersonImplCopyWithImpl(
    _$PersonImpl _value,
    $Res Function(_$PersonImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? profilePath = freezed,
    Object? biography = freezed,
    Object? knownForDepartment = freezed,
    Object? birthday = freezed,
    Object? placeOfBirth = freezed,
    Object? alsoKnownAs = null,
    Object? popularity = freezed,
  }) {
    return _then(
      _$PersonImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        profilePath: freezed == profilePath
            ? _value.profilePath
            : profilePath // ignore: cast_nullable_to_non_nullable
                  as String?,
        biography: freezed == biography
            ? _value.biography
            : biography // ignore: cast_nullable_to_non_nullable
                  as String?,
        knownForDepartment: freezed == knownForDepartment
            ? _value.knownForDepartment
            : knownForDepartment // ignore: cast_nullable_to_non_nullable
                  as String?,
        birthday: freezed == birthday
            ? _value.birthday
            : birthday // ignore: cast_nullable_to_non_nullable
                  as String?,
        placeOfBirth: freezed == placeOfBirth
            ? _value.placeOfBirth
            : placeOfBirth // ignore: cast_nullable_to_non_nullable
                  as String?,
        alsoKnownAs: null == alsoKnownAs
            ? _value._alsoKnownAs
            : alsoKnownAs // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        popularity: freezed == popularity
            ? _value.popularity
            : popularity // ignore: cast_nullable_to_non_nullable
                  as double?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PersonImpl implements _Person {
  const _$PersonImpl({
    required this.id,
    required this.name,
    @JsonKey(name: 'profile_path') this.profilePath,
    this.biography,
    @JsonKey(name: 'known_for_department') this.knownForDepartment,
    this.birthday,
    @JsonKey(name: 'place_of_birth') this.placeOfBirth,
    @JsonKey(name: 'also_known_as')
    final List<String> alsoKnownAs = const <String>[],
    this.popularity,
  }) : _alsoKnownAs = alsoKnownAs;

  factory _$PersonImpl.fromJson(Map<String, dynamic> json) =>
      _$$PersonImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  @JsonKey(name: 'profile_path')
  final String? profilePath;
  @override
  final String? biography;
  @override
  @JsonKey(name: 'known_for_department')
  final String? knownForDepartment;
  @override
  final String? birthday;
  @override
  @JsonKey(name: 'place_of_birth')
  final String? placeOfBirth;
  final List<String> _alsoKnownAs;
  @override
  @JsonKey(name: 'also_known_as')
  List<String> get alsoKnownAs {
    if (_alsoKnownAs is EqualUnmodifiableListView) return _alsoKnownAs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_alsoKnownAs);
  }

  @override
  final double? popularity;

  @override
  String toString() {
    return 'Person(id: $id, name: $name, profilePath: $profilePath, biography: $biography, knownForDepartment: $knownForDepartment, birthday: $birthday, placeOfBirth: $placeOfBirth, alsoKnownAs: $alsoKnownAs, popularity: $popularity)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PersonImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.profilePath, profilePath) ||
                other.profilePath == profilePath) &&
            (identical(other.biography, biography) ||
                other.biography == biography) &&
            (identical(other.knownForDepartment, knownForDepartment) ||
                other.knownForDepartment == knownForDepartment) &&
            (identical(other.birthday, birthday) ||
                other.birthday == birthday) &&
            (identical(other.placeOfBirth, placeOfBirth) ||
                other.placeOfBirth == placeOfBirth) &&
            const DeepCollectionEquality().equals(
              other._alsoKnownAs,
              _alsoKnownAs,
            ) &&
            (identical(other.popularity, popularity) ||
                other.popularity == popularity));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    profilePath,
    biography,
    knownForDepartment,
    birthday,
    placeOfBirth,
    const DeepCollectionEquality().hash(_alsoKnownAs),
    popularity,
  );

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PersonImplCopyWith<_$PersonImpl> get copyWith =>
      __$$PersonImplCopyWithImpl<_$PersonImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PersonImplToJson(this);
  }
}

abstract class _Person implements Person {
  const factory _Person({
    required final int id,
    required final String name,
    @JsonKey(name: 'profile_path') final String? profilePath,
    final String? biography,
    @JsonKey(name: 'known_for_department') final String? knownForDepartment,
    final String? birthday,
    @JsonKey(name: 'place_of_birth') final String? placeOfBirth,
    @JsonKey(name: 'also_known_as') final List<String> alsoKnownAs,
    final double? popularity,
  }) = _$PersonImpl;

  factory _Person.fromJson(Map<String, dynamic> json) = _$PersonImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  @JsonKey(name: 'profile_path')
  String? get profilePath;
  @override
  String? get biography;
  @override
  @JsonKey(name: 'known_for_department')
  String? get knownForDepartment;
  @override
  String? get birthday;
  @override
  @JsonKey(name: 'place_of_birth')
  String? get placeOfBirth;
  @override
  @JsonKey(name: 'also_known_as')
  List<String> get alsoKnownAs;
  @override
  double? get popularity;
  @override
  @JsonKey(ignore: true)
  _$$PersonImplCopyWith<_$PersonImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
