// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'translation_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TranslationData _$TranslationDataFromJson(Map<String, dynamic> json) {
  return _TranslationData.fromJson(json);
}

/// @nodoc
mixin _$TranslationData {
  String? get title => throw _privateConstructorUsedError;
  String? get overview => throw _privateConstructorUsedError;
  String? get homepage => throw _privateConstructorUsedError;
  String? get tagline => throw _privateConstructorUsedError;

  /// Serializes this TranslationData to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TranslationData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TranslationDataCopyWith<TranslationData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TranslationDataCopyWith<$Res> {
  factory $TranslationDataCopyWith(
    TranslationData value,
    $Res Function(TranslationData) then,
  ) = _$TranslationDataCopyWithImpl<$Res, TranslationData>;
  @useResult
  $Res call({
    String? title,
    String? overview,
    String? homepage,
    String? tagline,
  });
}

/// @nodoc
class _$TranslationDataCopyWithImpl<$Res, $Val extends TranslationData>
    implements $TranslationDataCopyWith<$Res> {
  _$TranslationDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TranslationData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = freezed,
    Object? overview = freezed,
    Object? homepage = freezed,
    Object? tagline = freezed,
  }) {
    return _then(
      _value.copyWith(
            title: freezed == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String?,
            overview: freezed == overview
                ? _value.overview
                : overview // ignore: cast_nullable_to_non_nullable
                      as String?,
            homepage: freezed == homepage
                ? _value.homepage
                : homepage // ignore: cast_nullable_to_non_nullable
                      as String?,
            tagline: freezed == tagline
                ? _value.tagline
                : tagline // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TranslationDataImplCopyWith<$Res>
    implements $TranslationDataCopyWith<$Res> {
  factory _$$TranslationDataImplCopyWith(
    _$TranslationDataImpl value,
    $Res Function(_$TranslationDataImpl) then,
  ) = __$$TranslationDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? title,
    String? overview,
    String? homepage,
    String? tagline,
  });
}

/// @nodoc
class __$$TranslationDataImplCopyWithImpl<$Res>
    extends _$TranslationDataCopyWithImpl<$Res, _$TranslationDataImpl>
    implements _$$TranslationDataImplCopyWith<$Res> {
  __$$TranslationDataImplCopyWithImpl(
    _$TranslationDataImpl _value,
    $Res Function(_$TranslationDataImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TranslationData
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = freezed,
    Object? overview = freezed,
    Object? homepage = freezed,
    Object? tagline = freezed,
  }) {
    return _then(
      _$TranslationDataImpl(
        title: freezed == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String?,
        overview: freezed == overview
            ? _value.overview
            : overview // ignore: cast_nullable_to_non_nullable
                  as String?,
        homepage: freezed == homepage
            ? _value.homepage
            : homepage // ignore: cast_nullable_to_non_nullable
                  as String?,
        tagline: freezed == tagline
            ? _value.tagline
            : tagline // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TranslationDataImpl implements _TranslationData {
  const _$TranslationDataImpl({
    this.title,
    this.overview,
    this.homepage,
    this.tagline,
  });

  factory _$TranslationDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$TranslationDataImplFromJson(json);

  @override
  final String? title;
  @override
  final String? overview;
  @override
  final String? homepage;
  @override
  final String? tagline;

  @override
  String toString() {
    return 'TranslationData(title: $title, overview: $overview, homepage: $homepage, tagline: $tagline)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TranslationDataImpl &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.overview, overview) ||
                other.overview == overview) &&
            (identical(other.homepage, homepage) ||
                other.homepage == homepage) &&
            (identical(other.tagline, tagline) || other.tagline == tagline));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, title, overview, homepage, tagline);

  /// Create a copy of TranslationData
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TranslationDataImplCopyWith<_$TranslationDataImpl> get copyWith =>
      __$$TranslationDataImplCopyWithImpl<_$TranslationDataImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$TranslationDataImplToJson(this);
  }
}

abstract class _TranslationData implements TranslationData {
  const factory _TranslationData({
    final String? title,
    final String? overview,
    final String? homepage,
    final String? tagline,
  }) = _$TranslationDataImpl;

  factory _TranslationData.fromJson(Map<String, dynamic> json) =
      _$TranslationDataImpl.fromJson;

  @override
  String? get title;
  @override
  String? get overview;
  @override
  String? get homepage;
  @override
  String? get tagline;

  /// Create a copy of TranslationData
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TranslationDataImplCopyWith<_$TranslationDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Translation _$TranslationFromJson(Map<String, dynamic> json) {
  return _Translation.fromJson(json);
}

/// @nodoc
mixin _$Translation {
  @JsonKey(name: 'iso_3166_1')
  String get iso31661 => throw _privateConstructorUsedError;
  @JsonKey(name: 'iso_639_1')
  String get iso6391 => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'english_name')
  String get englishName => throw _privateConstructorUsedError;
  TranslationData get data => throw _privateConstructorUsedError;

  /// Serializes this Translation to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Translation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TranslationCopyWith<Translation> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TranslationCopyWith<$Res> {
  factory $TranslationCopyWith(
    Translation value,
    $Res Function(Translation) then,
  ) = _$TranslationCopyWithImpl<$Res, Translation>;
  @useResult
  $Res call({
    @JsonKey(name: 'iso_3166_1') String iso31661,
    @JsonKey(name: 'iso_639_1') String iso6391,
    String name,
    @JsonKey(name: 'english_name') String englishName,
    TranslationData data,
  });

  $TranslationDataCopyWith<$Res> get data;
}

/// @nodoc
class _$TranslationCopyWithImpl<$Res, $Val extends Translation>
    implements $TranslationCopyWith<$Res> {
  _$TranslationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Translation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? iso31661 = null,
    Object? iso6391 = null,
    Object? name = null,
    Object? englishName = null,
    Object? data = null,
  }) {
    return _then(
      _value.copyWith(
            iso31661: null == iso31661
                ? _value.iso31661
                : iso31661 // ignore: cast_nullable_to_non_nullable
                      as String,
            iso6391: null == iso6391
                ? _value.iso6391
                : iso6391 // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            englishName: null == englishName
                ? _value.englishName
                : englishName // ignore: cast_nullable_to_non_nullable
                      as String,
            data: null == data
                ? _value.data
                : data // ignore: cast_nullable_to_non_nullable
                      as TranslationData,
          )
          as $Val,
    );
  }

  /// Create a copy of Translation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TranslationDataCopyWith<$Res> get data {
    return $TranslationDataCopyWith<$Res>(_value.data, (value) {
      return _then(_value.copyWith(data: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$TranslationImplCopyWith<$Res>
    implements $TranslationCopyWith<$Res> {
  factory _$$TranslationImplCopyWith(
    _$TranslationImpl value,
    $Res Function(_$TranslationImpl) then,
  ) = __$$TranslationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'iso_3166_1') String iso31661,
    @JsonKey(name: 'iso_639_1') String iso6391,
    String name,
    @JsonKey(name: 'english_name') String englishName,
    TranslationData data,
  });

  @override
  $TranslationDataCopyWith<$Res> get data;
}

/// @nodoc
class __$$TranslationImplCopyWithImpl<$Res>
    extends _$TranslationCopyWithImpl<$Res, _$TranslationImpl>
    implements _$$TranslationImplCopyWith<$Res> {
  __$$TranslationImplCopyWithImpl(
    _$TranslationImpl _value,
    $Res Function(_$TranslationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Translation
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? iso31661 = null,
    Object? iso6391 = null,
    Object? name = null,
    Object? englishName = null,
    Object? data = null,
  }) {
    return _then(
      _$TranslationImpl(
        iso31661: null == iso31661
            ? _value.iso31661
            : iso31661 // ignore: cast_nullable_to_non_nullable
                  as String,
        iso6391: null == iso6391
            ? _value.iso6391
            : iso6391 // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        englishName: null == englishName
            ? _value.englishName
            : englishName // ignore: cast_nullable_to_non_nullable
                  as String,
        data: null == data
            ? _value.data
            : data // ignore: cast_nullable_to_non_nullable
                  as TranslationData,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TranslationImpl implements _Translation {
  const _$TranslationImpl({
    @JsonKey(name: 'iso_3166_1') required this.iso31661,
    @JsonKey(name: 'iso_639_1') required this.iso6391,
    required this.name,
    @JsonKey(name: 'english_name') required this.englishName,
    required this.data,
  });

  factory _$TranslationImpl.fromJson(Map<String, dynamic> json) =>
      _$$TranslationImplFromJson(json);

  @override
  @JsonKey(name: 'iso_3166_1')
  final String iso31661;
  @override
  @JsonKey(name: 'iso_639_1')
  final String iso6391;
  @override
  final String name;
  @override
  @JsonKey(name: 'english_name')
  final String englishName;
  @override
  final TranslationData data;

  @override
  String toString() {
    return 'Translation(iso31661: $iso31661, iso6391: $iso6391, name: $name, englishName: $englishName, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TranslationImpl &&
            (identical(other.iso31661, iso31661) ||
                other.iso31661 == iso31661) &&
            (identical(other.iso6391, iso6391) || other.iso6391 == iso6391) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.englishName, englishName) ||
                other.englishName == englishName) &&
            (identical(other.data, data) || other.data == data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, iso31661, iso6391, name, englishName, data);

  /// Create a copy of Translation
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TranslationImplCopyWith<_$TranslationImpl> get copyWith =>
      __$$TranslationImplCopyWithImpl<_$TranslationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TranslationImplToJson(this);
  }
}

abstract class _Translation implements Translation {
  const factory _Translation({
    @JsonKey(name: 'iso_3166_1') required final String iso31661,
    @JsonKey(name: 'iso_639_1') required final String iso6391,
    required final String name,
    @JsonKey(name: 'english_name') required final String englishName,
    required final TranslationData data,
  }) = _$TranslationImpl;

  factory _Translation.fromJson(Map<String, dynamic> json) =
      _$TranslationImpl.fromJson;

  @override
  @JsonKey(name: 'iso_3166_1')
  String get iso31661;
  @override
  @JsonKey(name: 'iso_639_1')
  String get iso6391;
  @override
  String get name;
  @override
  @JsonKey(name: 'english_name')
  String get englishName;
  @override
  TranslationData get data;

  /// Create a copy of Translation
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TranslationImplCopyWith<_$TranslationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
