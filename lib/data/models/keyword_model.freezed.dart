// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'keyword_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Keyword _$KeywordFromJson(Map<String, dynamic> json) {
  return _Keyword.fromJson(json);
}

/// @nodoc
mixin _$Keyword {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;

  /// Serializes this Keyword to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Keyword
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $KeywordCopyWith<Keyword> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $KeywordCopyWith<$Res> {
  factory $KeywordCopyWith(Keyword value, $Res Function(Keyword) then) =
      _$KeywordCopyWithImpl<$Res, Keyword>;
  @useResult
  $Res call({int id, String name});
}

/// @nodoc
class _$KeywordCopyWithImpl<$Res, $Val extends Keyword>
    implements $KeywordCopyWith<$Res> {
  _$KeywordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Keyword
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? name = null}) {
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
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$KeywordImplCopyWith<$Res> implements $KeywordCopyWith<$Res> {
  factory _$$KeywordImplCopyWith(
    _$KeywordImpl value,
    $Res Function(_$KeywordImpl) then,
  ) = __$$KeywordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String name});
}

/// @nodoc
class __$$KeywordImplCopyWithImpl<$Res>
    extends _$KeywordCopyWithImpl<$Res, _$KeywordImpl>
    implements _$$KeywordImplCopyWith<$Res> {
  __$$KeywordImplCopyWithImpl(
    _$KeywordImpl _value,
    $Res Function(_$KeywordImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Keyword
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? name = null}) {
    return _then(
      _$KeywordImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$KeywordImpl implements _Keyword {
  const _$KeywordImpl({required this.id, required this.name});

  factory _$KeywordImpl.fromJson(Map<String, dynamic> json) =>
      _$$KeywordImplFromJson(json);

  @override
  final int id;
  @override
  final String name;

  @override
  String toString() {
    return 'Keyword(id: $id, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$KeywordImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name);

  /// Create a copy of Keyword
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$KeywordImplCopyWith<_$KeywordImpl> get copyWith =>
      __$$KeywordImplCopyWithImpl<_$KeywordImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$KeywordImplToJson(this);
  }
}

abstract class _Keyword implements Keyword {
  const factory _Keyword({required final int id, required final String name}) =
      _$KeywordImpl;

  factory _Keyword.fromJson(Map<String, dynamic> json) = _$KeywordImpl.fromJson;

  @override
  int get id;
  @override
  String get name;

  /// Create a copy of Keyword
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$KeywordImplCopyWith<_$KeywordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

KeywordDetails _$KeywordDetailsFromJson(Map<String, dynamic> json) {
  return _KeywordDetails.fromJson(json);
}

/// @nodoc
mixin _$KeywordDetails {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;

  /// Serializes this KeywordDetails to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of KeywordDetails
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $KeywordDetailsCopyWith<KeywordDetails> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $KeywordDetailsCopyWith<$Res> {
  factory $KeywordDetailsCopyWith(
    KeywordDetails value,
    $Res Function(KeywordDetails) then,
  ) = _$KeywordDetailsCopyWithImpl<$Res, KeywordDetails>;
  @useResult
  $Res call({int id, String name});
}

/// @nodoc
class _$KeywordDetailsCopyWithImpl<$Res, $Val extends KeywordDetails>
    implements $KeywordDetailsCopyWith<$Res> {
  _$KeywordDetailsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of KeywordDetails
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? name = null}) {
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
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$KeywordDetailsImplCopyWith<$Res>
    implements $KeywordDetailsCopyWith<$Res> {
  factory _$$KeywordDetailsImplCopyWith(
    _$KeywordDetailsImpl value,
    $Res Function(_$KeywordDetailsImpl) then,
  ) = __$$KeywordDetailsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String name});
}

/// @nodoc
class __$$KeywordDetailsImplCopyWithImpl<$Res>
    extends _$KeywordDetailsCopyWithImpl<$Res, _$KeywordDetailsImpl>
    implements _$$KeywordDetailsImplCopyWith<$Res> {
  __$$KeywordDetailsImplCopyWithImpl(
    _$KeywordDetailsImpl _value,
    $Res Function(_$KeywordDetailsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of KeywordDetails
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? name = null}) {
    return _then(
      _$KeywordDetailsImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$KeywordDetailsImpl implements _KeywordDetails {
  const _$KeywordDetailsImpl({required this.id, required this.name});

  factory _$KeywordDetailsImpl.fromJson(Map<String, dynamic> json) =>
      _$$KeywordDetailsImplFromJson(json);

  @override
  final int id;
  @override
  final String name;

  @override
  String toString() {
    return 'KeywordDetails(id: $id, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$KeywordDetailsImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name);

  /// Create a copy of KeywordDetails
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$KeywordDetailsImplCopyWith<_$KeywordDetailsImpl> get copyWith =>
      __$$KeywordDetailsImplCopyWithImpl<_$KeywordDetailsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$KeywordDetailsImplToJson(this);
  }
}

abstract class _KeywordDetails implements KeywordDetails {
  const factory _KeywordDetails({
    required final int id,
    required final String name,
  }) = _$KeywordDetailsImpl;

  factory _KeywordDetails.fromJson(Map<String, dynamic> json) =
      _$KeywordDetailsImpl.fromJson;

  @override
  int get id;
  @override
  String get name;

  /// Create a copy of KeywordDetails
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$KeywordDetailsImplCopyWith<_$KeywordDetailsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
