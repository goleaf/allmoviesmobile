// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tv_ref_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TVRef _$TVRefFromJson(Map<String, dynamic> json) {
  return _TVRef.fromJson(json);
}

/// @nodoc
mixin _$TVRef {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;

  /// Serializes this TVRef to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TVRef
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TVRefCopyWith<TVRef> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TVRefCopyWith<$Res> {
  factory $TVRefCopyWith(TVRef value, $Res Function(TVRef) then) =
      _$TVRefCopyWithImpl<$Res, TVRef>;
  @useResult
  $Res call({int id, String name});
}

/// @nodoc
class _$TVRefCopyWithImpl<$Res, $Val extends TVRef>
    implements $TVRefCopyWith<$Res> {
  _$TVRefCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TVRef
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
abstract class _$$TVRefImplCopyWith<$Res> implements $TVRefCopyWith<$Res> {
  factory _$$TVRefImplCopyWith(
    _$TVRefImpl value,
    $Res Function(_$TVRefImpl) then,
  ) = __$$TVRefImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String name});
}

/// @nodoc
class __$$TVRefImplCopyWithImpl<$Res>
    extends _$TVRefCopyWithImpl<$Res, _$TVRefImpl>
    implements _$$TVRefImplCopyWith<$Res> {
  __$$TVRefImplCopyWithImpl(
    _$TVRefImpl _value,
    $Res Function(_$TVRefImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TVRef
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? name = null}) {
    return _then(
      _$TVRefImpl(
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
class _$TVRefImpl implements _TVRef {
  const _$TVRefImpl({required this.id, required this.name});

  factory _$TVRefImpl.fromJson(Map<String, dynamic> json) =>
      _$$TVRefImplFromJson(json);

  @override
  final int id;
  @override
  final String name;

  @override
  String toString() {
    return 'TVRef(id: $id, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TVRefImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, name);

  /// Create a copy of TVRef
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TVRefImplCopyWith<_$TVRefImpl> get copyWith =>
      __$$TVRefImplCopyWithImpl<_$TVRefImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TVRefImplToJson(this);
  }
}

abstract class _TVRef implements TVRef {
  const factory _TVRef({required final int id, required final String name}) =
      _$TVRefImpl;

  factory _TVRef.fromJson(Map<String, dynamic> json) = _$TVRefImpl.fromJson;

  @override
  int get id;
  @override
  String get name;

  /// Create a copy of TVRef
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TVRefImplCopyWith<_$TVRefImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
