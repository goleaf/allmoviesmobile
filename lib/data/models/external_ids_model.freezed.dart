// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'external_ids_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ExternalIds _$ExternalIdsFromJson(Map<String, dynamic> json) {
  return _ExternalIds.fromJson(json);
}

/// @nodoc
mixin _$ExternalIds {
  @JsonKey(name: 'imdb_id')
  String? get imdbId => throw _privateConstructorUsedError;
  @JsonKey(name: 'facebook_id')
  String? get facebookId => throw _privateConstructorUsedError;
  @JsonKey(name: 'instagram_id')
  String? get instagramId => throw _privateConstructorUsedError;
  @JsonKey(name: 'twitter_id')
  String? get twitterId => throw _privateConstructorUsedError;

  /// Serializes this ExternalIds to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ExternalIds
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExternalIdsCopyWith<ExternalIds> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExternalIdsCopyWith<$Res> {
  factory $ExternalIdsCopyWith(
    ExternalIds value,
    $Res Function(ExternalIds) then,
  ) = _$ExternalIdsCopyWithImpl<$Res, ExternalIds>;
  @useResult
  $Res call({
    @JsonKey(name: 'imdb_id') String? imdbId,
    @JsonKey(name: 'facebook_id') String? facebookId,
    @JsonKey(name: 'instagram_id') String? instagramId,
    @JsonKey(name: 'twitter_id') String? twitterId,
  });
}

/// @nodoc
class _$ExternalIdsCopyWithImpl<$Res, $Val extends ExternalIds>
    implements $ExternalIdsCopyWith<$Res> {
  _$ExternalIdsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExternalIds
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? imdbId = freezed,
    Object? facebookId = freezed,
    Object? instagramId = freezed,
    Object? twitterId = freezed,
  }) {
    return _then(
      _value.copyWith(
            imdbId: freezed == imdbId
                ? _value.imdbId
                : imdbId // ignore: cast_nullable_to_non_nullable
                      as String?,
            facebookId: freezed == facebookId
                ? _value.facebookId
                : facebookId // ignore: cast_nullable_to_non_nullable
                    as String?,
            instagramId: freezed == instagramId
                ? _value.instagramId
                : instagramId // ignore: cast_nullable_to_non_nullable
                    as String?,
            twitterId: freezed == twitterId
                ? _value.twitterId
                : twitterId // ignore: cast_nullable_to_non_nullable
                    as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExternalIdsImplCopyWith<$Res>
    implements $ExternalIdsCopyWith<$Res> {
  factory _$$ExternalIdsImplCopyWith(
    _$ExternalIdsImpl value,
    $Res Function(_$ExternalIdsImpl) then,
  ) = __$$ExternalIdsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'imdb_id') String? imdbId,
    @JsonKey(name: 'facebook_id') String? facebookId,
    @JsonKey(name: 'instagram_id') String? instagramId,
    @JsonKey(name: 'twitter_id') String? twitterId,
  });
}

/// @nodoc
class __$$ExternalIdsImplCopyWithImpl<$Res>
    extends _$ExternalIdsCopyWithImpl<$Res, _$ExternalIdsImpl>
    implements _$$ExternalIdsImplCopyWith<$Res> {
  __$$ExternalIdsImplCopyWithImpl(
    _$ExternalIdsImpl _value,
    $Res Function(_$ExternalIdsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExternalIds
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? imdbId = freezed,
    Object? facebookId = freezed,
    Object? instagramId = freezed,
    Object? twitterId = freezed,
  }) {
    return _then(
      _$ExternalIdsImpl(
        imdbId: freezed == imdbId
            ? _value.imdbId
            : imdbId // ignore: cast_nullable_to_non_nullable
                  as String?,
        facebookId: freezed == facebookId
            ? _value.facebookId
            : facebookId // ignore: cast_nullable_to_non_nullable
                as String?,
        instagramId: freezed == instagramId
            ? _value.instagramId
            : instagramId // ignore: cast_nullable_to_non_nullable
                as String?,
        twitterId: freezed == twitterId
            ? _value.twitterId
            : twitterId // ignore: cast_nullable_to_non_nullable
                as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ExternalIdsImpl implements _ExternalIds {
  const _$ExternalIdsImpl({
    @JsonKey(name: 'imdb_id') this.imdbId,
    @JsonKey(name: 'facebook_id') this.facebookId,
    @JsonKey(name: 'instagram_id') this.instagramId,
    @JsonKey(name: 'twitter_id') this.twitterId,
  });

  factory _$ExternalIdsImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExternalIdsImplFromJson(json);

  @override
  @JsonKey(name: 'imdb_id')
  final String? imdbId;
  @override
  @JsonKey(name: 'facebook_id')
  final String? facebookId;
  @override
  @JsonKey(name: 'instagram_id')
  final String? instagramId;
  @override
  @JsonKey(name: 'twitter_id')
  final String? twitterId;

  @override
  String toString() {
    return 'ExternalIds(imdbId: $imdbId, facebookId: $facebookId, instagramId: $instagramId, twitterId: $twitterId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExternalIdsImpl &&
            (identical(other.imdbId, imdbId) || other.imdbId == imdbId) &&
            (identical(other.facebookId, facebookId) ||
                other.facebookId == facebookId) &&
            (identical(other.instagramId, instagramId) ||
                other.instagramId == instagramId) &&
            (identical(other.twitterId, twitterId) ||
                other.twitterId == twitterId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, imdbId, facebookId, instagramId, twitterId);

  /// Create a copy of ExternalIds
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExternalIdsImplCopyWith<_$ExternalIdsImpl> get copyWith =>
      __$$ExternalIdsImplCopyWithImpl<_$ExternalIdsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExternalIdsImplToJson(this);
  }
}

abstract class _ExternalIds implements ExternalIds {
  const factory _ExternalIds({
    @JsonKey(name: 'imdb_id') final String? imdbId,
    @JsonKey(name: 'facebook_id') final String? facebookId,
    @JsonKey(name: 'instagram_id') final String? instagramId,
    @JsonKey(name: 'twitter_id') final String? twitterId,
  }) = _$ExternalIdsImpl;

  factory _ExternalIds.fromJson(Map<String, dynamic> json) =
      _$ExternalIdsImpl.fromJson;

  @override
  @JsonKey(name: 'imdb_id')
  String? get imdbId;
  @override
  @JsonKey(name: 'facebook_id')
  String? get facebookId;
  @override
  @JsonKey(name: 'instagram_id')
  String? get instagramId;
  @override
  @JsonKey(name: 'twitter_id')
  String? get twitterId;

  /// Create a copy of ExternalIds
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExternalIdsImplCopyWith<_$ExternalIdsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
