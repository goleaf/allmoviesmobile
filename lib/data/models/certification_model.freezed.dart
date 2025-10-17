// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'certification_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Certification _$CertificationFromJson(Map<String, dynamic> json) {
  return _Certification.fromJson(json);
}

/// @nodoc
mixin _$Certification {
  String get certification => throw _privateConstructorUsedError;
  String get meaning => throw _privateConstructorUsedError;
  int get order => throw _privateConstructorUsedError;

  /// Serializes this Certification to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Certification
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CertificationCopyWith<Certification> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CertificationCopyWith<$Res> {
  factory $CertificationCopyWith(
    Certification value,
    $Res Function(Certification) then,
  ) = _$CertificationCopyWithImpl<$Res, Certification>;
  @useResult
  $Res call({String certification, String meaning, int order});
}

/// @nodoc
class _$CertificationCopyWithImpl<$Res, $Val extends Certification>
    implements $CertificationCopyWith<$Res> {
  _$CertificationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Certification
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? certification = null,
    Object? meaning = null,
    Object? order = null,
  }) {
    return _then(
      _value.copyWith(
            certification: null == certification
                ? _value.certification
                : certification // ignore: cast_nullable_to_non_nullable
                      as String,
            meaning: null == meaning
                ? _value.meaning
                : meaning // ignore: cast_nullable_to_non_nullable
                      as String,
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
abstract class _$$CertificationImplCopyWith<$Res>
    implements $CertificationCopyWith<$Res> {
  factory _$$CertificationImplCopyWith(
    _$CertificationImpl value,
    $Res Function(_$CertificationImpl) then,
  ) = __$$CertificationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String certification, String meaning, int order});
}

/// @nodoc
class __$$CertificationImplCopyWithImpl<$Res>
    extends _$CertificationCopyWithImpl<$Res, _$CertificationImpl>
    implements _$$CertificationImplCopyWith<$Res> {
  __$$CertificationImplCopyWithImpl(
    _$CertificationImpl _value,
    $Res Function(_$CertificationImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Certification
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? certification = null,
    Object? meaning = null,
    Object? order = null,
  }) {
    return _then(
      _$CertificationImpl(
        certification: null == certification
            ? _value.certification
            : certification // ignore: cast_nullable_to_non_nullable
                  as String,
        meaning: null == meaning
            ? _value.meaning
            : meaning // ignore: cast_nullable_to_non_nullable
                  as String,
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
class _$CertificationImpl implements _Certification {
  const _$CertificationImpl({
    required this.certification,
    required this.meaning,
    required this.order,
  });

  factory _$CertificationImpl.fromJson(Map<String, dynamic> json) =>
      _$$CertificationImplFromJson(json);

  @override
  final String certification;
  @override
  final String meaning;
  @override
  final int order;

  @override
  String toString() {
    return 'Certification(certification: $certification, meaning: $meaning, order: $order)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CertificationImpl &&
            (identical(other.certification, certification) ||
                other.certification == certification) &&
            (identical(other.meaning, meaning) || other.meaning == meaning) &&
            (identical(other.order, order) || other.order == order));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, certification, meaning, order);

  /// Create a copy of Certification
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CertificationImplCopyWith<_$CertificationImpl> get copyWith =>
      __$$CertificationImplCopyWithImpl<_$CertificationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CertificationImplToJson(this);
  }
}

abstract class _Certification implements Certification {
  const factory _Certification({
    required final String certification,
    required final String meaning,
    required final int order,
  }) = _$CertificationImpl;

  factory _Certification.fromJson(Map<String, dynamic> json) =
      _$CertificationImpl.fromJson;

  @override
  String get certification;
  @override
  String get meaning;
  @override
  int get order;

  /// Create a copy of Certification
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CertificationImplCopyWith<_$CertificationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReleaseDates _$ReleaseDatesFromJson(Map<String, dynamic> json) {
  return _ReleaseDates.fromJson(json);
}

/// @nodoc
mixin _$ReleaseDates {
  String get certification => throw _privateConstructorUsedError;
  @JsonKey(name: 'iso_639_1')
  String? get language => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  @JsonKey(name: 'release_date')
  String? get releaseDate => throw _privateConstructorUsedError;
  int? get type => throw _privateConstructorUsedError;

  /// Serializes this ReleaseDates to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReleaseDates
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReleaseDatesCopyWith<ReleaseDates> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReleaseDatesCopyWith<$Res> {
  factory $ReleaseDatesCopyWith(
    ReleaseDates value,
    $Res Function(ReleaseDates) then,
  ) = _$ReleaseDatesCopyWithImpl<$Res, ReleaseDates>;
  @useResult
  $Res call({
    String certification,
    @JsonKey(name: 'iso_639_1') String? language,
    String? note,
    @JsonKey(name: 'release_date') String? releaseDate,
    int? type,
  });
}

/// @nodoc
class _$ReleaseDatesCopyWithImpl<$Res, $Val extends ReleaseDates>
    implements $ReleaseDatesCopyWith<$Res> {
  _$ReleaseDatesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReleaseDates
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? certification = null,
    Object? language = freezed,
    Object? note = freezed,
    Object? releaseDate = freezed,
    Object? type = freezed,
  }) {
    return _then(
      _value.copyWith(
            certification: null == certification
                ? _value.certification
                : certification // ignore: cast_nullable_to_non_nullable
                      as String,
            language: freezed == language
                ? _value.language
                : language // ignore: cast_nullable_to_non_nullable
                      as String?,
            note: freezed == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
                      as String?,
            releaseDate: freezed == releaseDate
                ? _value.releaseDate
                : releaseDate // ignore: cast_nullable_to_non_nullable
                      as String?,
            type: freezed == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ReleaseDatesImplCopyWith<$Res>
    implements $ReleaseDatesCopyWith<$Res> {
  factory _$$ReleaseDatesImplCopyWith(
    _$ReleaseDatesImpl value,
    $Res Function(_$ReleaseDatesImpl) then,
  ) = __$$ReleaseDatesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String certification,
    @JsonKey(name: 'iso_639_1') String? language,
    String? note,
    @JsonKey(name: 'release_date') String? releaseDate,
    int? type,
  });
}

/// @nodoc
class __$$ReleaseDatesImplCopyWithImpl<$Res>
    extends _$ReleaseDatesCopyWithImpl<$Res, _$ReleaseDatesImpl>
    implements _$$ReleaseDatesImplCopyWith<$Res> {
  __$$ReleaseDatesImplCopyWithImpl(
    _$ReleaseDatesImpl _value,
    $Res Function(_$ReleaseDatesImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReleaseDates
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? certification = null,
    Object? language = freezed,
    Object? note = freezed,
    Object? releaseDate = freezed,
    Object? type = freezed,
  }) {
    return _then(
      _$ReleaseDatesImpl(
        certification: null == certification
            ? _value.certification
            : certification // ignore: cast_nullable_to_non_nullable
                  as String,
        language: freezed == language
            ? _value.language
            : language // ignore: cast_nullable_to_non_nullable
                  as String?,
        note: freezed == note
            ? _value.note
            : note // ignore: cast_nullable_to_non_nullable
                  as String?,
        releaseDate: freezed == releaseDate
            ? _value.releaseDate
            : releaseDate // ignore: cast_nullable_to_non_nullable
                  as String?,
        type: freezed == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ReleaseDatesImpl implements _ReleaseDates {
  const _$ReleaseDatesImpl({
    required this.certification,
    @JsonKey(name: 'iso_639_1') this.language,
    this.note,
    @JsonKey(name: 'release_date') this.releaseDate,
    this.type,
  });

  factory _$ReleaseDatesImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReleaseDatesImplFromJson(json);

  @override
  final String certification;
  @override
  @JsonKey(name: 'iso_639_1')
  final String? language;
  @override
  final String? note;
  @override
  @JsonKey(name: 'release_date')
  final String? releaseDate;
  @override
  final int? type;

  @override
  String toString() {
    return 'ReleaseDates(certification: $certification, language: $language, note: $note, releaseDate: $releaseDate, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReleaseDatesImpl &&
            (identical(other.certification, certification) ||
                other.certification == certification) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.releaseDate, releaseDate) ||
                other.releaseDate == releaseDate) &&
            (identical(other.type, type) || other.type == type));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    certification,
    language,
    note,
    releaseDate,
    type,
  );

  /// Create a copy of ReleaseDates
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReleaseDatesImplCopyWith<_$ReleaseDatesImpl> get copyWith =>
      __$$ReleaseDatesImplCopyWithImpl<_$ReleaseDatesImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReleaseDatesImplToJson(this);
  }
}

abstract class _ReleaseDates implements ReleaseDates {
  const factory _ReleaseDates({
    required final String certification,
    @JsonKey(name: 'iso_639_1') final String? language,
    final String? note,
    @JsonKey(name: 'release_date') final String? releaseDate,
    final int? type,
  }) = _$ReleaseDatesImpl;

  factory _ReleaseDates.fromJson(Map<String, dynamic> json) =
      _$ReleaseDatesImpl.fromJson;

  @override
  String get certification;
  @override
  @JsonKey(name: 'iso_639_1')
  String? get language;
  @override
  String? get note;
  @override
  @JsonKey(name: 'release_date')
  String? get releaseDate;
  @override
  int? get type;

  /// Create a copy of ReleaseDates
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReleaseDatesImplCopyWith<_$ReleaseDatesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReleaseDatesResult _$ReleaseDatesResultFromJson(Map<String, dynamic> json) {
  return _ReleaseDatesResult.fromJson(json);
}

/// @nodoc
mixin _$ReleaseDatesResult {
  @JsonKey(name: 'iso_3166_1')
  String get countryCode => throw _privateConstructorUsedError;
  List<ReleaseDates> get releaseDates => throw _privateConstructorUsedError;

  /// Serializes this ReleaseDatesResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReleaseDatesResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReleaseDatesResultCopyWith<ReleaseDatesResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReleaseDatesResultCopyWith<$Res> {
  factory $ReleaseDatesResultCopyWith(
    ReleaseDatesResult value,
    $Res Function(ReleaseDatesResult) then,
  ) = _$ReleaseDatesResultCopyWithImpl<$Res, ReleaseDatesResult>;
  @useResult
  $Res call({
    @JsonKey(name: 'iso_3166_1') String countryCode,
    List<ReleaseDates> releaseDates,
  });
}

/// @nodoc
class _$ReleaseDatesResultCopyWithImpl<$Res, $Val extends ReleaseDatesResult>
    implements $ReleaseDatesResultCopyWith<$Res> {
  _$ReleaseDatesResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReleaseDatesResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? countryCode = null, Object? releaseDates = null}) {
    return _then(
      _value.copyWith(
            countryCode: null == countryCode
                ? _value.countryCode
                : countryCode // ignore: cast_nullable_to_non_nullable
                      as String,
            releaseDates: null == releaseDates
                ? _value.releaseDates
                : releaseDates // ignore: cast_nullable_to_non_nullable
                      as List<ReleaseDates>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ReleaseDatesResultImplCopyWith<$Res>
    implements $ReleaseDatesResultCopyWith<$Res> {
  factory _$$ReleaseDatesResultImplCopyWith(
    _$ReleaseDatesResultImpl value,
    $Res Function(_$ReleaseDatesResultImpl) then,
  ) = __$$ReleaseDatesResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'iso_3166_1') String countryCode,
    List<ReleaseDates> releaseDates,
  });
}

/// @nodoc
class __$$ReleaseDatesResultImplCopyWithImpl<$Res>
    extends _$ReleaseDatesResultCopyWithImpl<$Res, _$ReleaseDatesResultImpl>
    implements _$$ReleaseDatesResultImplCopyWith<$Res> {
  __$$ReleaseDatesResultImplCopyWithImpl(
    _$ReleaseDatesResultImpl _value,
    $Res Function(_$ReleaseDatesResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReleaseDatesResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? countryCode = null, Object? releaseDates = null}) {
    return _then(
      _$ReleaseDatesResultImpl(
        countryCode: null == countryCode
            ? _value.countryCode
            : countryCode // ignore: cast_nullable_to_non_nullable
                  as String,
        releaseDates: null == releaseDates
            ? _value._releaseDates
            : releaseDates // ignore: cast_nullable_to_non_nullable
                  as List<ReleaseDates>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ReleaseDatesResultImpl implements _ReleaseDatesResult {
  const _$ReleaseDatesResultImpl({
    @JsonKey(name: 'iso_3166_1') required this.countryCode,
    final List<ReleaseDates> releaseDates = const [],
  }) : _releaseDates = releaseDates;

  factory _$ReleaseDatesResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReleaseDatesResultImplFromJson(json);

  @override
  @JsonKey(name: 'iso_3166_1')
  final String countryCode;
  final List<ReleaseDates> _releaseDates;
  @override
  @JsonKey()
  List<ReleaseDates> get releaseDates {
    if (_releaseDates is EqualUnmodifiableListView) return _releaseDates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_releaseDates);
  }

  @override
  String toString() {
    return 'ReleaseDatesResult(countryCode: $countryCode, releaseDates: $releaseDates)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReleaseDatesResultImpl &&
            (identical(other.countryCode, countryCode) ||
                other.countryCode == countryCode) &&
            const DeepCollectionEquality().equals(
              other._releaseDates,
              _releaseDates,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    countryCode,
    const DeepCollectionEquality().hash(_releaseDates),
  );

  /// Create a copy of ReleaseDatesResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReleaseDatesResultImplCopyWith<_$ReleaseDatesResultImpl> get copyWith =>
      __$$ReleaseDatesResultImplCopyWithImpl<_$ReleaseDatesResultImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ReleaseDatesResultImplToJson(this);
  }
}

abstract class _ReleaseDatesResult implements ReleaseDatesResult {
  const factory _ReleaseDatesResult({
    @JsonKey(name: 'iso_3166_1') required final String countryCode,
    final List<ReleaseDates> releaseDates,
  }) = _$ReleaseDatesResultImpl;

  factory _ReleaseDatesResult.fromJson(Map<String, dynamic> json) =
      _$ReleaseDatesResultImpl.fromJson;

  @override
  @JsonKey(name: 'iso_3166_1')
  String get countryCode;
  @override
  List<ReleaseDates> get releaseDates;

  /// Create a copy of ReleaseDatesResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReleaseDatesResultImplCopyWith<_$ReleaseDatesResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
