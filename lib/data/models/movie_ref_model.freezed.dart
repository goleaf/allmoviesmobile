// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'movie_ref_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MovieRef _$MovieRefFromJson(Map<String, dynamic> json) {
  return _MovieRef.fromJson(json);
}

/// @nodoc
mixin _$MovieRef {
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;

  /// Serializes this MovieRef to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MovieRef
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MovieRefCopyWith<MovieRef> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MovieRefCopyWith<$Res> {
  factory $MovieRefCopyWith(MovieRef value, $Res Function(MovieRef) then) =
      _$MovieRefCopyWithImpl<$Res, MovieRef>;
  @useResult
  $Res call({int id, String title});
}

/// @nodoc
class _$MovieRefCopyWithImpl<$Res, $Val extends MovieRef>
    implements $MovieRefCopyWith<$Res> {
  _$MovieRefCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MovieRef
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? title = null}) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MovieRefImplCopyWith<$Res>
    implements $MovieRefCopyWith<$Res> {
  factory _$$MovieRefImplCopyWith(
    _$MovieRefImpl value,
    $Res Function(_$MovieRefImpl) then,
  ) = __$$MovieRefImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, String title});
}

/// @nodoc
class __$$MovieRefImplCopyWithImpl<$Res>
    extends _$MovieRefCopyWithImpl<$Res, _$MovieRefImpl>
    implements _$$MovieRefImplCopyWith<$Res> {
  __$$MovieRefImplCopyWithImpl(
    _$MovieRefImpl _value,
    $Res Function(_$MovieRefImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MovieRef
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? id = null, Object? title = null}) {
    return _then(
      _$MovieRefImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MovieRefImpl implements _MovieRef {
  const _$MovieRefImpl({required this.id, required this.title});

  factory _$MovieRefImpl.fromJson(Map<String, dynamic> json) =>
      _$$MovieRefImplFromJson(json);

  @override
  final int id;
  @override
  final String title;

  @override
  String toString() {
    return 'MovieRef(id: $id, title: $title)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MovieRefImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, title);

  /// Create a copy of MovieRef
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MovieRefImplCopyWith<_$MovieRefImpl> get copyWith =>
      __$$MovieRefImplCopyWithImpl<_$MovieRefImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MovieRefImplToJson(this);
  }
}

abstract class _MovieRef implements MovieRef {
  const factory _MovieRef({
    required final int id,
    required final String title,
  }) = _$MovieRefImpl;

  factory _MovieRef.fromJson(Map<String, dynamic> json) =
      _$MovieRefImpl.fromJson;

  @override
  int get id;
  @override
  String get title;

  /// Create a copy of MovieRef
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MovieRefImplCopyWith<_$MovieRefImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
