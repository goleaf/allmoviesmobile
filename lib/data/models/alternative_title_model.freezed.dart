// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'alternative_title_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AlternativeTitle _$AlternativeTitleFromJson(Map<String, dynamic> json) {
  return _AlternativeTitle.fromJson(json);
}

/// @nodoc
mixin _$AlternativeTitle {
  @JsonKey(name: 'iso_3166_1')
  String get iso31661 => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get type => throw _privateConstructorUsedError;

  /// Serializes this AlternativeTitle to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AlternativeTitle
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AlternativeTitleCopyWith<AlternativeTitle> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AlternativeTitleCopyWith<$Res> {
  factory $AlternativeTitleCopyWith(
    AlternativeTitle value,
    $Res Function(AlternativeTitle) then,
  ) = _$AlternativeTitleCopyWithImpl<$Res, AlternativeTitle>;
  @useResult
  $Res call({
    @JsonKey(name: 'iso_3166_1') String iso31661,
    String title,
    String? type,
  });
}

/// @nodoc
class _$AlternativeTitleCopyWithImpl<$Res, $Val extends AlternativeTitle>
    implements $AlternativeTitleCopyWith<$Res> {
  _$AlternativeTitleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AlternativeTitle
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? iso31661 = null,
    Object? title = null,
    Object? type = freezed,
  }) {
    return _then(
      _value.copyWith(
            iso31661: null == iso31661
                ? _value.iso31661
                : iso31661 // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            type: freezed == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AlternativeTitleImplCopyWith<$Res>
    implements $AlternativeTitleCopyWith<$Res> {
  factory _$$AlternativeTitleImplCopyWith(
    _$AlternativeTitleImpl value,
    $Res Function(_$AlternativeTitleImpl) then,
  ) = __$$AlternativeTitleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'iso_3166_1') String iso31661,
    String title,
    String? type,
  });
}

/// @nodoc
class __$$AlternativeTitleImplCopyWithImpl<$Res>
    extends _$AlternativeTitleCopyWithImpl<$Res, _$AlternativeTitleImpl>
    implements _$$AlternativeTitleImplCopyWith<$Res> {
  __$$AlternativeTitleImplCopyWithImpl(
    _$AlternativeTitleImpl _value,
    $Res Function(_$AlternativeTitleImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AlternativeTitle
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? iso31661 = null,
    Object? title = null,
    Object? type = freezed,
  }) {
    return _then(
      _$AlternativeTitleImpl(
        iso31661: null == iso31661
            ? _value.iso31661
            : iso31661 // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        type: freezed == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AlternativeTitleImpl implements _AlternativeTitle {
  const _$AlternativeTitleImpl({
    @JsonKey(name: 'iso_3166_1') required this.iso31661,
    required this.title,
    this.type,
  });

  factory _$AlternativeTitleImpl.fromJson(Map<String, dynamic> json) =>
      _$$AlternativeTitleImplFromJson(json);

  @override
  @JsonKey(name: 'iso_3166_1')
  final String iso31661;
  @override
  final String title;
  @override
  final String? type;

  @override
  String toString() {
    return 'AlternativeTitle(iso31661: $iso31661, title: $title, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AlternativeTitleImpl &&
            (identical(other.iso31661, iso31661) ||
                other.iso31661 == iso31661) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.type, type) || other.type == type));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, iso31661, title, type);

  /// Create a copy of AlternativeTitle
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AlternativeTitleImplCopyWith<_$AlternativeTitleImpl> get copyWith =>
      __$$AlternativeTitleImplCopyWithImpl<_$AlternativeTitleImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AlternativeTitleImplToJson(this);
  }
}

abstract class _AlternativeTitle implements AlternativeTitle {
  const factory _AlternativeTitle({
    @JsonKey(name: 'iso_3166_1') required final String iso31661,
    required final String title,
    final String? type,
  }) = _$AlternativeTitleImpl;

  factory _AlternativeTitle.fromJson(Map<String, dynamic> json) =
      _$AlternativeTitleImpl.fromJson;

  @override
  @JsonKey(name: 'iso_3166_1')
  String get iso31661;
  @override
  String get title;
  @override
  String? get type;

  /// Create a copy of AlternativeTitle
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AlternativeTitleImplCopyWith<_$AlternativeTitleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
