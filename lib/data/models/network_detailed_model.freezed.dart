// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'network_detailed_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AlternativeName _$AlternativeNameFromJson(Map<String, dynamic> json) {
  return _AlternativeName.fromJson(json);
}

/// @nodoc
mixin _$AlternativeName {
  String get name => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AlternativeNameCopyWith<AlternativeName> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AlternativeNameCopyWith<$Res> {
  factory $AlternativeNameCopyWith(
    AlternativeName value,
    $Res Function(AlternativeName) then,
  ) = _$AlternativeNameCopyWithImpl<$Res, AlternativeName>;
  @useResult
  $Res call({String name, String type});
}

/// @nodoc
class _$AlternativeNameCopyWithImpl<$Res, $Val extends AlternativeName>
    implements $AlternativeNameCopyWith<$Res> {
  _$AlternativeNameCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null, Object? type = null}) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AlternativeNameImplCopyWith<$Res>
    implements $AlternativeNameCopyWith<$Res> {
  factory _$$AlternativeNameImplCopyWith(
    _$AlternativeNameImpl value,
    $Res Function(_$AlternativeNameImpl) then,
  ) = __$$AlternativeNameImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, String type});
}

/// @nodoc
class __$$AlternativeNameImplCopyWithImpl<$Res>
    extends _$AlternativeNameCopyWithImpl<$Res, _$AlternativeNameImpl>
    implements _$$AlternativeNameImplCopyWith<$Res> {
  __$$AlternativeNameImplCopyWithImpl(
    _$AlternativeNameImpl _value,
    $Res Function(_$AlternativeNameImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? name = null, Object? type = null}) {
    return _then(
      _$AlternativeNameImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AlternativeNameImpl implements _AlternativeName {
  const _$AlternativeNameImpl({required this.name, required this.type});

  factory _$AlternativeNameImpl.fromJson(Map<String, dynamic> json) =>
      _$$AlternativeNameImplFromJson(json);

  @override
  final String name;
  @override
  final String type;

  @override
  String toString() {
    return 'AlternativeName(name: $name, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AlternativeNameImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, name, type);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AlternativeNameImplCopyWith<_$AlternativeNameImpl> get copyWith =>
      __$$AlternativeNameImplCopyWithImpl<_$AlternativeNameImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AlternativeNameImplToJson(this);
  }
}

abstract class _AlternativeName implements AlternativeName {
  const factory _AlternativeName({
    required final String name,
    required final String type,
  }) = _$AlternativeNameImpl;

  factory _AlternativeName.fromJson(Map<String, dynamic> json) =
      _$AlternativeNameImpl.fromJson;

  @override
  String get name;
  @override
  String get type;
  @override
  @JsonKey(ignore: true)
  _$$AlternativeNameImplCopyWith<_$AlternativeNameImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

NetworkDetailed _$NetworkDetailedFromJson(Map<String, dynamic> json) {
  return _NetworkDetailed.fromJson(json);
}

/// @nodoc
mixin _$NetworkDetailed {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'logo_path')
  String? get logoPath => throw _privateConstructorUsedError;
  @JsonKey(name: 'origin_country')
  String get originCountry => throw _privateConstructorUsedError;
  String? get headquarters => throw _privateConstructorUsedError;
  String? get homepage => throw _privateConstructorUsedError;
  @JsonKey(name: 'alternative_names')
  List<AlternativeName> get alternativeNames =>
      throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $NetworkDetailedCopyWith<NetworkDetailed> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NetworkDetailedCopyWith<$Res> {
  factory $NetworkDetailedCopyWith(
    NetworkDetailed value,
    $Res Function(NetworkDetailed) then,
  ) = _$NetworkDetailedCopyWithImpl<$Res, NetworkDetailed>;
  @useResult
  $Res call({
    int id,
    String name,
    @JsonKey(name: 'logo_path') String? logoPath,
    @JsonKey(name: 'origin_country') String originCountry,
    String? headquarters,
    String? homepage,
    @JsonKey(name: 'alternative_names') List<AlternativeName> alternativeNames,
  });
}

/// @nodoc
class _$NetworkDetailedCopyWithImpl<$Res, $Val extends NetworkDetailed>
    implements $NetworkDetailedCopyWith<$Res> {
  _$NetworkDetailedCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? logoPath = freezed,
    Object? originCountry = null,
    Object? headquarters = freezed,
    Object? homepage = freezed,
    Object? alternativeNames = null,
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
            logoPath: freezed == logoPath
                ? _value.logoPath
                : logoPath // ignore: cast_nullable_to_non_nullable
                      as String?,
            originCountry: null == originCountry
                ? _value.originCountry
                : originCountry // ignore: cast_nullable_to_non_nullable
                      as String,
            headquarters: freezed == headquarters
                ? _value.headquarters
                : headquarters // ignore: cast_nullable_to_non_nullable
                      as String?,
            homepage: freezed == homepage
                ? _value.homepage
                : homepage // ignore: cast_nullable_to_non_nullable
                      as String?,
            alternativeNames: null == alternativeNames
                ? _value.alternativeNames
                : alternativeNames // ignore: cast_nullable_to_non_nullable
                      as List<AlternativeName>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$NetworkDetailedImplCopyWith<$Res>
    implements $NetworkDetailedCopyWith<$Res> {
  factory _$$NetworkDetailedImplCopyWith(
    _$NetworkDetailedImpl value,
    $Res Function(_$NetworkDetailedImpl) then,
  ) = __$$NetworkDetailedImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String name,
    @JsonKey(name: 'logo_path') String? logoPath,
    @JsonKey(name: 'origin_country') String originCountry,
    String? headquarters,
    String? homepage,
    @JsonKey(name: 'alternative_names') List<AlternativeName> alternativeNames,
  });
}

/// @nodoc
class __$$NetworkDetailedImplCopyWithImpl<$Res>
    extends _$NetworkDetailedCopyWithImpl<$Res, _$NetworkDetailedImpl>
    implements _$$NetworkDetailedImplCopyWith<$Res> {
  __$$NetworkDetailedImplCopyWithImpl(
    _$NetworkDetailedImpl _value,
    $Res Function(_$NetworkDetailedImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? logoPath = freezed,
    Object? originCountry = null,
    Object? headquarters = freezed,
    Object? homepage = freezed,
    Object? alternativeNames = null,
  }) {
    return _then(
      _$NetworkDetailedImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        logoPath: freezed == logoPath
            ? _value.logoPath
            : logoPath // ignore: cast_nullable_to_non_nullable
                  as String?,
        originCountry: null == originCountry
            ? _value.originCountry
            : originCountry // ignore: cast_nullable_to_non_nullable
                  as String,
        headquarters: freezed == headquarters
            ? _value.headquarters
            : headquarters // ignore: cast_nullable_to_non_nullable
                  as String?,
        homepage: freezed == homepage
            ? _value.homepage
            : homepage // ignore: cast_nullable_to_non_nullable
                  as String?,
        alternativeNames: null == alternativeNames
            ? _value._alternativeNames
            : alternativeNames // ignore: cast_nullable_to_non_nullable
                  as List<AlternativeName>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$NetworkDetailedImpl implements _NetworkDetailed {
  const _$NetworkDetailedImpl({
    required this.id,
    required this.name,
    @JsonKey(name: 'logo_path') this.logoPath,
    @JsonKey(name: 'origin_country') required this.originCountry,
    this.headquarters,
    this.homepage,
    @JsonKey(name: 'alternative_names')
    final List<AlternativeName> alternativeNames = const [],
  }) : _alternativeNames = alternativeNames;

  factory _$NetworkDetailedImpl.fromJson(Map<String, dynamic> json) =>
      _$$NetworkDetailedImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  @JsonKey(name: 'logo_path')
  final String? logoPath;
  @override
  @JsonKey(name: 'origin_country')
  final String originCountry;
  @override
  final String? headquarters;
  @override
  final String? homepage;
  final List<AlternativeName> _alternativeNames;
  @override
  @JsonKey(name: 'alternative_names')
  List<AlternativeName> get alternativeNames {
    if (_alternativeNames is EqualUnmodifiableListView)
      return _alternativeNames;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_alternativeNames);
  }

  @override
  String toString() {
    return 'NetworkDetailed(id: $id, name: $name, logoPath: $logoPath, originCountry: $originCountry, headquarters: $headquarters, homepage: $homepage, alternativeNames: $alternativeNames)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NetworkDetailedImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.logoPath, logoPath) ||
                other.logoPath == logoPath) &&
            (identical(other.originCountry, originCountry) ||
                other.originCountry == originCountry) &&
            (identical(other.headquarters, headquarters) ||
                other.headquarters == headquarters) &&
            (identical(other.homepage, homepage) ||
                other.homepage == homepage) &&
            const DeepCollectionEquality().equals(
              other._alternativeNames,
              _alternativeNames,
            ));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    logoPath,
    originCountry,
    headquarters,
    homepage,
    const DeepCollectionEquality().hash(_alternativeNames),
  );

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$NetworkDetailedImplCopyWith<_$NetworkDetailedImpl> get copyWith =>
      __$$NetworkDetailedImplCopyWithImpl<_$NetworkDetailedImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$NetworkDetailedImplToJson(this);
  }
}

abstract class _NetworkDetailed implements NetworkDetailed {
  const factory _NetworkDetailed({
    required final int id,
    required final String name,
    @JsonKey(name: 'logo_path') final String? logoPath,
    @JsonKey(name: 'origin_country') required final String originCountry,
    final String? headquarters,
    final String? homepage,
    @JsonKey(name: 'alternative_names')
    final List<AlternativeName> alternativeNames,
  }) = _$NetworkDetailedImpl;

  factory _NetworkDetailed.fromJson(Map<String, dynamic> json) =
      _$NetworkDetailedImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  @JsonKey(name: 'logo_path')
  String? get logoPath;
  @override
  @JsonKey(name: 'origin_country')
  String get originCountry;
  @override
  String? get headquarters;
  @override
  String? get homepage;
  @override
  @JsonKey(name: 'alternative_names')
  List<AlternativeName> get alternativeNames;
  @override
  @JsonKey(ignore: true)
  _$$NetworkDetailedImplCopyWith<_$NetworkDetailedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
