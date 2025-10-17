// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'credit_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Cast _$CastFromJson(Map<String, dynamic> json) {
  return _Cast.fromJson(json);
}

/// @nodoc
mixin _$Cast {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get character => throw _privateConstructorUsedError;
  @JsonKey(name: 'profile_path')
  String? get profilePath => throw _privateConstructorUsedError;
  int get order => throw _privateConstructorUsedError;

  /// Serializes this Cast to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Cast
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CastCopyWith<Cast> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CastCopyWith<$Res> {
  factory $CastCopyWith(Cast value, $Res Function(Cast) then) =
      _$CastCopyWithImpl<$Res, Cast>;
  @useResult
  $Res call({
    int id,
    String name,
    String? character,
    @JsonKey(name: 'profile_path') String? profilePath,
    int order,
  });
}

/// @nodoc
class _$CastCopyWithImpl<$Res, $Val extends Cast>
    implements $CastCopyWith<$Res> {
  _$CastCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Cast
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? character = freezed,
    Object? profilePath = freezed,
    Object? order = null,
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
            character: freezed == character
                ? _value.character
                : character // ignore: cast_nullable_to_non_nullable
                      as String?,
            profilePath: freezed == profilePath
                ? _value.profilePath
                : profilePath // ignore: cast_nullable_to_non_nullable
                      as String?,
            order: null == order
                ? _value.order
                : order // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CastImplCopyWith<$Res> implements $CastCopyWith<$Res> {
  factory _$$CastImplCopyWith(
    _$CastImpl value,
    $Res Function(_$CastImpl) then,
  ) = __$$CastImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String name,
    String? character,
    @JsonKey(name: 'profile_path') String? profilePath,
    int order,
  });
}

/// @nodoc
class __$$CastImplCopyWithImpl<$Res>
    extends _$CastCopyWithImpl<$Res, _$CastImpl>
    implements _$$CastImplCopyWith<$Res> {
  __$$CastImplCopyWithImpl(_$CastImpl _value, $Res Function(_$CastImpl) _then)
    : super(_value, _then);

  /// Create a copy of Cast
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? character = freezed,
    Object? profilePath = freezed,
    Object? order = null,
  }) {
    return _then(
      _$CastImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        character: freezed == character
            ? _value.character
            : character // ignore: cast_nullable_to_non_nullable
                  as String?,
        profilePath: freezed == profilePath
            ? _value.profilePath
            : profilePath // ignore: cast_nullable_to_non_nullable
                  as String?,
        order: null == order
            ? _value.order
            : order // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CastImpl implements _Cast {
  const _$CastImpl({
    required this.id,
    required this.name,
    this.character,
    @JsonKey(name: 'profile_path') this.profilePath,
    this.order = 0,
  });

  factory _$CastImpl.fromJson(Map<String, dynamic> json) =>
      _$$CastImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String? character;
  @override
  @JsonKey(name: 'profile_path')
  final String? profilePath;
  @override
  @JsonKey()
  final int order;

  @override
  String toString() {
    return 'Cast(id: $id, name: $name, character: $character, profilePath: $profilePath, order: $order)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CastImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.character, character) ||
                other.character == character) &&
            (identical(other.profilePath, profilePath) ||
                other.profilePath == profilePath) &&
            (identical(other.order, order) || other.order == order));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, character, profilePath, order);

  /// Create a copy of Cast
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CastImplCopyWith<_$CastImpl> get copyWith =>
      __$$CastImplCopyWithImpl<_$CastImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CastImplToJson(this);
  }
}

abstract class _Cast implements Cast {
  const factory _Cast({
    required final int id,
    required final String name,
    final String? character,
    @JsonKey(name: 'profile_path') final String? profilePath,
    final int order,
  }) = _$CastImpl;

  factory _Cast.fromJson(Map<String, dynamic> json) = _$CastImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  String? get character;
  @override
  @JsonKey(name: 'profile_path')
  String? get profilePath;
  @override
  int get order;

  /// Create a copy of Cast
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CastImplCopyWith<_$CastImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Crew _$CrewFromJson(Map<String, dynamic> json) {
  return _Crew.fromJson(json);
}

/// @nodoc
mixin _$Crew {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get job => throw _privateConstructorUsedError;
  String get department => throw _privateConstructorUsedError;
  @JsonKey(name: 'profile_path')
  String? get profilePath => throw _privateConstructorUsedError;

  /// Serializes this Crew to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Crew
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CrewCopyWith<Crew> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CrewCopyWith<$Res> {
  factory $CrewCopyWith(Crew value, $Res Function(Crew) then) =
      _$CrewCopyWithImpl<$Res, Crew>;
  @useResult
  $Res call({
    int id,
    String name,
    String job,
    String department,
    @JsonKey(name: 'profile_path') String? profilePath,
  });
}

/// @nodoc
class _$CrewCopyWithImpl<$Res, $Val extends Crew>
    implements $CrewCopyWith<$Res> {
  _$CrewCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Crew
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? job = null,
    Object? department = null,
    Object? profilePath = freezed,
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
            job: null == job
                ? _value.job
                : job // ignore: cast_nullable_to_non_nullable
                      as String,
            department: null == department
                ? _value.department
                : department // ignore: cast_nullable_to_non_nullable
                      as String,
            profilePath: freezed == profilePath
                ? _value.profilePath
                : profilePath // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CrewImplCopyWith<$Res> implements $CrewCopyWith<$Res> {
  factory _$$CrewImplCopyWith(
    _$CrewImpl value,
    $Res Function(_$CrewImpl) then,
  ) = __$$CrewImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String name,
    String job,
    String department,
    @JsonKey(name: 'profile_path') String? profilePath,
  });
}

/// @nodoc
class __$$CrewImplCopyWithImpl<$Res>
    extends _$CrewCopyWithImpl<$Res, _$CrewImpl>
    implements _$$CrewImplCopyWith<$Res> {
  __$$CrewImplCopyWithImpl(_$CrewImpl _value, $Res Function(_$CrewImpl) _then)
    : super(_value, _then);

  /// Create a copy of Crew
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? job = null,
    Object? department = null,
    Object? profilePath = freezed,
  }) {
    return _then(
      _$CrewImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        job: null == job
            ? _value.job
            : job // ignore: cast_nullable_to_non_nullable
                  as String,
        department: null == department
            ? _value.department
            : department // ignore: cast_nullable_to_non_nullable
                  as String,
        profilePath: freezed == profilePath
            ? _value.profilePath
            : profilePath // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CrewImpl implements _Crew {
  const _$CrewImpl({
    required this.id,
    required this.name,
    required this.job,
    required this.department,
    @JsonKey(name: 'profile_path') this.profilePath,
  });

  factory _$CrewImpl.fromJson(Map<String, dynamic> json) =>
      _$$CrewImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  final String job;
  @override
  final String department;
  @override
  @JsonKey(name: 'profile_path')
  final String? profilePath;

  @override
  String toString() {
    return 'Crew(id: $id, name: $name, job: $job, department: $department, profilePath: $profilePath)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CrewImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.job, job) || other.job == job) &&
            (identical(other.department, department) ||
                other.department == department) &&
            (identical(other.profilePath, profilePath) ||
                other.profilePath == profilePath));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, job, department, profilePath);

  /// Create a copy of Crew
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CrewImplCopyWith<_$CrewImpl> get copyWith =>
      __$$CrewImplCopyWithImpl<_$CrewImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CrewImplToJson(this);
  }
}

abstract class _Crew implements Crew {
  const factory _Crew({
    required final int id,
    required final String name,
    required final String job,
    required final String department,
    @JsonKey(name: 'profile_path') final String? profilePath,
  }) = _$CrewImpl;

  factory _Crew.fromJson(Map<String, dynamic> json) = _$CrewImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  String get job;
  @override
  String get department;
  @override
  @JsonKey(name: 'profile_path')
  String? get profilePath;

  /// Create a copy of Crew
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CrewImplCopyWith<_$CrewImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Credits _$CreditsFromJson(Map<String, dynamic> json) {
  return _Credits.fromJson(json);
}

/// @nodoc
mixin _$Credits {
  List<Cast> get cast => throw _privateConstructorUsedError;
  List<Crew> get crew => throw _privateConstructorUsedError;

  /// Serializes this Credits to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Credits
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreditsCopyWith<Credits> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreditsCopyWith<$Res> {
  factory $CreditsCopyWith(Credits value, $Res Function(Credits) then) =
      _$CreditsCopyWithImpl<$Res, Credits>;
  @useResult
  $Res call({List<Cast> cast, List<Crew> crew});
}

/// @nodoc
class _$CreditsCopyWithImpl<$Res, $Val extends Credits>
    implements $CreditsCopyWith<$Res> {
  _$CreditsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Credits
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? cast = null, Object? crew = null}) {
    return _then(
      _value.copyWith(
            cast: null == cast
                ? _value.cast
                : cast // ignore: cast_nullable_to_non_nullable
                      as List<Cast>,
            crew: null == crew
                ? _value.crew
                : crew // ignore: cast_nullable_to_non_nullable
                      as List<Crew>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CreditsImplCopyWith<$Res> implements $CreditsCopyWith<$Res> {
  factory _$$CreditsImplCopyWith(
    _$CreditsImpl value,
    $Res Function(_$CreditsImpl) then,
  ) = __$$CreditsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<Cast> cast, List<Crew> crew});
}

/// @nodoc
class __$$CreditsImplCopyWithImpl<$Res>
    extends _$CreditsCopyWithImpl<$Res, _$CreditsImpl>
    implements _$$CreditsImplCopyWith<$Res> {
  __$$CreditsImplCopyWithImpl(
    _$CreditsImpl _value,
    $Res Function(_$CreditsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Credits
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? cast = null, Object? crew = null}) {
    return _then(
      _$CreditsImpl(
        cast: null == cast
            ? _value._cast
            : cast // ignore: cast_nullable_to_non_nullable
                  as List<Cast>,
        crew: null == crew
            ? _value._crew
            : crew // ignore: cast_nullable_to_non_nullable
                  as List<Crew>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CreditsImpl implements _Credits {
  const _$CreditsImpl({
    final List<Cast> cast = const [],
    final List<Crew> crew = const [],
  }) : _cast = cast,
       _crew = crew;

  factory _$CreditsImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreditsImplFromJson(json);

  final List<Cast> _cast;
  @override
  @JsonKey()
  List<Cast> get cast {
    if (_cast is EqualUnmodifiableListView) return _cast;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_cast);
  }

  final List<Crew> _crew;
  @override
  @JsonKey()
  List<Crew> get crew {
    if (_crew is EqualUnmodifiableListView) return _crew;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_crew);
  }

  @override
  String toString() {
    return 'Credits(cast: $cast, crew: $crew)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreditsImpl &&
            const DeepCollectionEquality().equals(other._cast, _cast) &&
            const DeepCollectionEquality().equals(other._crew, _crew));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_cast),
    const DeepCollectionEquality().hash(_crew),
  );

  /// Create a copy of Credits
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreditsImplCopyWith<_$CreditsImpl> get copyWith =>
      __$$CreditsImplCopyWithImpl<_$CreditsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CreditsImplToJson(this);
  }
}

abstract class _Credits implements Credits {
  const factory _Credits({final List<Cast> cast, final List<Crew> crew}) =
      _$CreditsImpl;

  factory _Credits.fromJson(Map<String, dynamic> json) = _$CreditsImpl.fromJson;

  @override
  List<Cast> get cast;
  @override
  List<Crew> get crew;

  /// Create a copy of Credits
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreditsImplCopyWith<_$CreditsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
