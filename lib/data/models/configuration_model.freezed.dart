// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'configuration_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ImagesConfiguration _$ImagesConfigurationFromJson(Map<String, dynamic> json) {
  return _ImagesConfiguration.fromJson(json);
}

/// @nodoc
mixin _$ImagesConfiguration {
  @JsonKey(name: 'base_url')
  String get baseUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'secure_base_url')
  String get secureBaseUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'backdrop_sizes')
  List<String> get backdropSizes => throw _privateConstructorUsedError;
  @JsonKey(name: 'logo_sizes')
  List<String> get logoSizes => throw _privateConstructorUsedError;
  @JsonKey(name: 'poster_sizes')
  List<String> get posterSizes => throw _privateConstructorUsedError;
  @JsonKey(name: 'profile_sizes')
  List<String> get profileSizes => throw _privateConstructorUsedError;
  @JsonKey(name: 'still_sizes')
  List<String> get stillSizes => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ImagesConfigurationCopyWith<ImagesConfiguration> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ImagesConfigurationCopyWith<$Res> {
  factory $ImagesConfigurationCopyWith(
          ImagesConfiguration value, $Res Function(ImagesConfiguration) then) =
      _$ImagesConfigurationCopyWithImpl<$Res, ImagesConfiguration>;
  @useResult
  $Res call(
      {@JsonKey(name: 'base_url') String baseUrl,
      @JsonKey(name: 'secure_base_url') String secureBaseUrl,
      @JsonKey(name: 'backdrop_sizes') List<String> backdropSizes,
      @JsonKey(name: 'logo_sizes') List<String> logoSizes,
      @JsonKey(name: 'poster_sizes') List<String> posterSizes,
      @JsonKey(name: 'profile_sizes') List<String> profileSizes,
      @JsonKey(name: 'still_sizes') List<String> stillSizes});
}

/// @nodoc
class _$ImagesConfigurationCopyWithImpl<$Res, $Val extends ImagesConfiguration>
    implements $ImagesConfigurationCopyWith<$Res> {
  _$ImagesConfigurationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? baseUrl = null,
    Object? secureBaseUrl = null,
    Object? backdropSizes = null,
    Object? logoSizes = null,
    Object? posterSizes = null,
    Object? profileSizes = null,
    Object? stillSizes = null,
  }) {
    return _then(_value.copyWith(
      baseUrl: null == baseUrl
          ? _value.baseUrl
          : baseUrl // ignore: cast_nullable_to_non_nullable
              as String,
      secureBaseUrl: null == secureBaseUrl
          ? _value.secureBaseUrl
          : secureBaseUrl // ignore: cast_nullable_to_non_nullable
              as String,
      backdropSizes: null == backdropSizes
          ? _value.backdropSizes
          : backdropSizes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      logoSizes: null == logoSizes
          ? _value.logoSizes
          : logoSizes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      posterSizes: null == posterSizes
          ? _value.posterSizes
          : posterSizes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      profileSizes: null == profileSizes
          ? _value.profileSizes
          : profileSizes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      stillSizes: null == stillSizes
          ? _value.stillSizes
          : stillSizes // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ImagesConfigurationImplCopyWith<$Res>
    implements $ImagesConfigurationCopyWith<$Res> {
  factory _$$ImagesConfigurationImplCopyWith(_$ImagesConfigurationImpl value,
          $Res Function(_$ImagesConfigurationImpl) then) =
      __$$ImagesConfigurationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'base_url') String baseUrl,
      @JsonKey(name: 'secure_base_url') String secureBaseUrl,
      @JsonKey(name: 'backdrop_sizes') List<String> backdropSizes,
      @JsonKey(name: 'logo_sizes') List<String> logoSizes,
      @JsonKey(name: 'poster_sizes') List<String> posterSizes,
      @JsonKey(name: 'profile_sizes') List<String> profileSizes,
      @JsonKey(name: 'still_sizes') List<String> stillSizes});
}

/// @nodoc
class __$$ImagesConfigurationImplCopyWithImpl<$Res>
    extends _$ImagesConfigurationCopyWithImpl<$Res, _$ImagesConfigurationImpl>
    implements _$$ImagesConfigurationImplCopyWith<$Res> {
  __$$ImagesConfigurationImplCopyWithImpl(_$ImagesConfigurationImpl _value,
      $Res Function(_$ImagesConfigurationImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? baseUrl = null,
    Object? secureBaseUrl = null,
    Object? backdropSizes = null,
    Object? logoSizes = null,
    Object? posterSizes = null,
    Object? profileSizes = null,
    Object? stillSizes = null,
  }) {
    return _then(_$ImagesConfigurationImpl(
      baseUrl: null == baseUrl
          ? _value.baseUrl
          : baseUrl // ignore: cast_nullable_to_non_nullable
              as String,
      secureBaseUrl: null == secureBaseUrl
          ? _value.secureBaseUrl
          : secureBaseUrl // ignore: cast_nullable_to_non_nullable
              as String,
      backdropSizes: null == backdropSizes
          ? _value._backdropSizes
          : backdropSizes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      logoSizes: null == logoSizes
          ? _value._logoSizes
          : logoSizes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      posterSizes: null == posterSizes
          ? _value._posterSizes
          : posterSizes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      profileSizes: null == profileSizes
          ? _value._profileSizes
          : profileSizes // ignore: cast_nullable_to_non_nullable
              as List<String>,
      stillSizes: null == stillSizes
          ? _value._stillSizes
          : stillSizes // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ImagesConfigurationImpl implements _ImagesConfiguration {
  const _$ImagesConfigurationImpl(
      {@JsonKey(name: 'base_url') required this.baseUrl,
      @JsonKey(name: 'secure_base_url') required this.secureBaseUrl,
      @JsonKey(name: 'backdrop_sizes')
      final List<String> backdropSizes = const [],
      @JsonKey(name: 'logo_sizes') final List<String> logoSizes = const [],
      @JsonKey(name: 'poster_sizes') final List<String> posterSizes = const [],
      @JsonKey(name: 'profile_sizes')
      final List<String> profileSizes = const [],
      @JsonKey(name: 'still_sizes') final List<String> stillSizes = const []})
      : _backdropSizes = backdropSizes,
        _logoSizes = logoSizes,
        _posterSizes = posterSizes,
        _profileSizes = profileSizes,
        _stillSizes = stillSizes;

  factory _$ImagesConfigurationImpl.fromJson(Map<String, dynamic> json) =>
      _$$ImagesConfigurationImplFromJson(json);

  @override
  @JsonKey(name: 'base_url')
  final String baseUrl;
  @override
  @JsonKey(name: 'secure_base_url')
  final String secureBaseUrl;
  final List<String> _backdropSizes;
  @override
  @JsonKey(name: 'backdrop_sizes')
  List<String> get backdropSizes {
    if (_backdropSizes is EqualUnmodifiableListView) return _backdropSizes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_backdropSizes);
  }

  final List<String> _logoSizes;
  @override
  @JsonKey(name: 'logo_sizes')
  List<String> get logoSizes {
    if (_logoSizes is EqualUnmodifiableListView) return _logoSizes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_logoSizes);
  }

  final List<String> _posterSizes;
  @override
  @JsonKey(name: 'poster_sizes')
  List<String> get posterSizes {
    if (_posterSizes is EqualUnmodifiableListView) return _posterSizes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_posterSizes);
  }

  final List<String> _profileSizes;
  @override
  @JsonKey(name: 'profile_sizes')
  List<String> get profileSizes {
    if (_profileSizes is EqualUnmodifiableListView) return _profileSizes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_profileSizes);
  }

  final List<String> _stillSizes;
  @override
  @JsonKey(name: 'still_sizes')
  List<String> get stillSizes {
    if (_stillSizes is EqualUnmodifiableListView) return _stillSizes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_stillSizes);
  }

  @override
  String toString() {
    return 'ImagesConfiguration(baseUrl: $baseUrl, secureBaseUrl: $secureBaseUrl, backdropSizes: $backdropSizes, logoSizes: $logoSizes, posterSizes: $posterSizes, profileSizes: $profileSizes, stillSizes: $stillSizes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ImagesConfigurationImpl &&
            (identical(other.baseUrl, baseUrl) || other.baseUrl == baseUrl) &&
            (identical(other.secureBaseUrl, secureBaseUrl) ||
                other.secureBaseUrl == secureBaseUrl) &&
            const DeepCollectionEquality()
                .equals(other._backdropSizes, _backdropSizes) &&
            const DeepCollectionEquality()
                .equals(other._logoSizes, _logoSizes) &&
            const DeepCollectionEquality()
                .equals(other._posterSizes, _posterSizes) &&
            const DeepCollectionEquality()
                .equals(other._profileSizes, _profileSizes) &&
            const DeepCollectionEquality()
                .equals(other._stillSizes, _stillSizes));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      baseUrl,
      secureBaseUrl,
      const DeepCollectionEquality().hash(_backdropSizes),
      const DeepCollectionEquality().hash(_logoSizes),
      const DeepCollectionEquality().hash(_posterSizes),
      const DeepCollectionEquality().hash(_profileSizes),
      const DeepCollectionEquality().hash(_stillSizes));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ImagesConfigurationImplCopyWith<_$ImagesConfigurationImpl> get copyWith =>
      __$$ImagesConfigurationImplCopyWithImpl<_$ImagesConfigurationImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ImagesConfigurationImplToJson(
      this,
    );
  }
}

abstract class _ImagesConfiguration implements ImagesConfiguration {
  const factory _ImagesConfiguration(
          {@JsonKey(name: 'base_url') required final String baseUrl,
          @JsonKey(name: 'secure_base_url') required final String secureBaseUrl,
          @JsonKey(name: 'backdrop_sizes') final List<String> backdropSizes,
          @JsonKey(name: 'logo_sizes') final List<String> logoSizes,
          @JsonKey(name: 'poster_sizes') final List<String> posterSizes,
          @JsonKey(name: 'profile_sizes') final List<String> profileSizes,
          @JsonKey(name: 'still_sizes') final List<String> stillSizes}) =
      _$ImagesConfigurationImpl;

  factory _ImagesConfiguration.fromJson(Map<String, dynamic> json) =
      _$ImagesConfigurationImpl.fromJson;

  @override
  @JsonKey(name: 'base_url')
  String get baseUrl;
  @override
  @JsonKey(name: 'secure_base_url')
  String get secureBaseUrl;
  @override
  @JsonKey(name: 'backdrop_sizes')
  List<String> get backdropSizes;
  @override
  @JsonKey(name: 'logo_sizes')
  List<String> get logoSizes;
  @override
  @JsonKey(name: 'poster_sizes')
  List<String> get posterSizes;
  @override
  @JsonKey(name: 'profile_sizes')
  List<String> get profileSizes;
  @override
  @JsonKey(name: 'still_sizes')
  List<String> get stillSizes;
  @override
  @JsonKey(ignore: true)
  _$$ImagesConfigurationImplCopyWith<_$ImagesConfigurationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ApiConfiguration _$ApiConfigurationFromJson(Map<String, dynamic> json) {
  return _ApiConfiguration.fromJson(json);
}

/// @nodoc
mixin _$ApiConfiguration {
  ImagesConfiguration get images => throw _privateConstructorUsedError;
  @JsonKey(name: 'change_keys')
  List<String> get changeKeys => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ApiConfigurationCopyWith<ApiConfiguration> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ApiConfigurationCopyWith<$Res> {
  factory $ApiConfigurationCopyWith(
          ApiConfiguration value, $Res Function(ApiConfiguration) then) =
      _$ApiConfigurationCopyWithImpl<$Res, ApiConfiguration>;
  @useResult
  $Res call(
      {ImagesConfiguration images,
      @JsonKey(name: 'change_keys') List<String> changeKeys});

  $ImagesConfigurationCopyWith<$Res> get images;
}

/// @nodoc
class _$ApiConfigurationCopyWithImpl<$Res, $Val extends ApiConfiguration>
    implements $ApiConfigurationCopyWith<$Res> {
  _$ApiConfigurationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? images = null,
    Object? changeKeys = null,
  }) {
    return _then(_value.copyWith(
      images: null == images
          ? _value.images
          : images // ignore: cast_nullable_to_non_nullable
              as ImagesConfiguration,
      changeKeys: null == changeKeys
          ? _value.changeKeys
          : changeKeys // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $ImagesConfigurationCopyWith<$Res> get images {
    return $ImagesConfigurationCopyWith<$Res>(_value.images, (value) {
      return _then(_value.copyWith(images: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ApiConfigurationImplCopyWith<$Res>
    implements $ApiConfigurationCopyWith<$Res> {
  factory _$$ApiConfigurationImplCopyWith(_$ApiConfigurationImpl value,
          $Res Function(_$ApiConfigurationImpl) then) =
      __$$ApiConfigurationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {ImagesConfiguration images,
      @JsonKey(name: 'change_keys') List<String> changeKeys});

  @override
  $ImagesConfigurationCopyWith<$Res> get images;
}

/// @nodoc
class __$$ApiConfigurationImplCopyWithImpl<$Res>
    extends _$ApiConfigurationCopyWithImpl<$Res, _$ApiConfigurationImpl>
    implements _$$ApiConfigurationImplCopyWith<$Res> {
  __$$ApiConfigurationImplCopyWithImpl(_$ApiConfigurationImpl _value,
      $Res Function(_$ApiConfigurationImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? images = null,
    Object? changeKeys = null,
  }) {
    return _then(_$ApiConfigurationImpl(
      images: null == images
          ? _value.images
          : images // ignore: cast_nullable_to_non_nullable
              as ImagesConfiguration,
      changeKeys: null == changeKeys
          ? _value._changeKeys
          : changeKeys // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ApiConfigurationImpl implements _ApiConfiguration {
  const _$ApiConfigurationImpl(
      {required this.images,
      @JsonKey(name: 'change_keys') final List<String> changeKeys = const []})
      : _changeKeys = changeKeys;

  factory _$ApiConfigurationImpl.fromJson(Map<String, dynamic> json) =>
      _$$ApiConfigurationImplFromJson(json);

  @override
  final ImagesConfiguration images;
  final List<String> _changeKeys;
  @override
  @JsonKey(name: 'change_keys')
  List<String> get changeKeys {
    if (_changeKeys is EqualUnmodifiableListView) return _changeKeys;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_changeKeys);
  }

  @override
  String toString() {
    return 'ApiConfiguration(images: $images, changeKeys: $changeKeys)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ApiConfigurationImpl &&
            (identical(other.images, images) || other.images == images) &&
            const DeepCollectionEquality()
                .equals(other._changeKeys, _changeKeys));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, images, const DeepCollectionEquality().hash(_changeKeys));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ApiConfigurationImplCopyWith<_$ApiConfigurationImpl> get copyWith =>
      __$$ApiConfigurationImplCopyWithImpl<_$ApiConfigurationImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ApiConfigurationImplToJson(
      this,
    );
  }
}

abstract class _ApiConfiguration implements ApiConfiguration {
  const factory _ApiConfiguration(
          {required final ImagesConfiguration images,
          @JsonKey(name: 'change_keys') final List<String> changeKeys}) =
      _$ApiConfigurationImpl;

  factory _ApiConfiguration.fromJson(Map<String, dynamic> json) =
      _$ApiConfigurationImpl.fromJson;

  @override
  ImagesConfiguration get images;
  @override
  @JsonKey(name: 'change_keys')
  List<String> get changeKeys;
  @override
  @JsonKey(ignore: true)
  _$$ApiConfigurationImplCopyWith<_$ApiConfigurationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CountryInfo _$CountryInfoFromJson(Map<String, dynamic> json) {
  return _CountryInfo.fromJson(json);
}

/// @nodoc
mixin _$CountryInfo {
  @JsonKey(name: 'iso_3166_1')
  String get code => throw _privateConstructorUsedError;
  @JsonKey(name: 'english_name')
  String get englishName => throw _privateConstructorUsedError;
  @JsonKey(name: 'native_name')
  String? get nativeName => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CountryInfoCopyWith<CountryInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CountryInfoCopyWith<$Res> {
  factory $CountryInfoCopyWith(
          CountryInfo value, $Res Function(CountryInfo) then) =
      _$CountryInfoCopyWithImpl<$Res, CountryInfo>;
  @useResult
  $Res call(
      {@JsonKey(name: 'iso_3166_1') String code,
      @JsonKey(name: 'english_name') String englishName,
      @JsonKey(name: 'native_name') String? nativeName});
}

/// @nodoc
class _$CountryInfoCopyWithImpl<$Res, $Val extends CountryInfo>
    implements $CountryInfoCopyWith<$Res> {
  _$CountryInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? englishName = null,
    Object? nativeName = freezed,
  }) {
    return _then(_value.copyWith(
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      englishName: null == englishName
          ? _value.englishName
          : englishName // ignore: cast_nullable_to_non_nullable
              as String,
      nativeName: freezed == nativeName
          ? _value.nativeName
          : nativeName // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CountryInfoImplCopyWith<$Res>
    implements $CountryInfoCopyWith<$Res> {
  factory _$$CountryInfoImplCopyWith(
          _$CountryInfoImpl value, $Res Function(_$CountryInfoImpl) then) =
      __$$CountryInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'iso_3166_1') String code,
      @JsonKey(name: 'english_name') String englishName,
      @JsonKey(name: 'native_name') String? nativeName});
}

/// @nodoc
class __$$CountryInfoImplCopyWithImpl<$Res>
    extends _$CountryInfoCopyWithImpl<$Res, _$CountryInfoImpl>
    implements _$$CountryInfoImplCopyWith<$Res> {
  __$$CountryInfoImplCopyWithImpl(
      _$CountryInfoImpl _value, $Res Function(_$CountryInfoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? englishName = null,
    Object? nativeName = freezed,
  }) {
    return _then(_$CountryInfoImpl(
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      englishName: null == englishName
          ? _value.englishName
          : englishName // ignore: cast_nullable_to_non_nullable
              as String,
      nativeName: freezed == nativeName
          ? _value.nativeName
          : nativeName // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CountryInfoImpl implements _CountryInfo {
  const _$CountryInfoImpl(
      {@JsonKey(name: 'iso_3166_1') required this.code,
      @JsonKey(name: 'english_name') required this.englishName,
      @JsonKey(name: 'native_name') this.nativeName});

  factory _$CountryInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CountryInfoImplFromJson(json);

  @override
  @JsonKey(name: 'iso_3166_1')
  final String code;
  @override
  @JsonKey(name: 'english_name')
  final String englishName;
  @override
  @JsonKey(name: 'native_name')
  final String? nativeName;

  @override
  String toString() {
    return 'CountryInfo(code: $code, englishName: $englishName, nativeName: $nativeName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CountryInfoImpl &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.englishName, englishName) ||
                other.englishName == englishName) &&
            (identical(other.nativeName, nativeName) ||
                other.nativeName == nativeName));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, code, englishName, nativeName);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CountryInfoImplCopyWith<_$CountryInfoImpl> get copyWith =>
      __$$CountryInfoImplCopyWithImpl<_$CountryInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CountryInfoImplToJson(
      this,
    );
  }
}

abstract class _CountryInfo implements CountryInfo {
  const factory _CountryInfo(
          {@JsonKey(name: 'iso_3166_1') required final String code,
          @JsonKey(name: 'english_name') required final String englishName,
          @JsonKey(name: 'native_name') final String? nativeName}) =
      _$CountryInfoImpl;

  factory _CountryInfo.fromJson(Map<String, dynamic> json) =
      _$CountryInfoImpl.fromJson;

  @override
  @JsonKey(name: 'iso_3166_1')
  String get code;
  @override
  @JsonKey(name: 'english_name')
  String get englishName;
  @override
  @JsonKey(name: 'native_name')
  String? get nativeName;
  @override
  @JsonKey(ignore: true)
  _$$CountryInfoImplCopyWith<_$CountryInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

LanguageInfo _$LanguageInfoFromJson(Map<String, dynamic> json) {
  return _LanguageInfo.fromJson(json);
}

/// @nodoc
mixin _$LanguageInfo {
  @JsonKey(name: 'iso_639_1')
  String get code => throw _privateConstructorUsedError;
  @JsonKey(name: 'english_name')
  String get englishName => throw _privateConstructorUsedError;
  @JsonKey(name: 'native_name')
  String? get name => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LanguageInfoCopyWith<LanguageInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LanguageInfoCopyWith<$Res> {
  factory $LanguageInfoCopyWith(
          LanguageInfo value, $Res Function(LanguageInfo) then) =
      _$LanguageInfoCopyWithImpl<$Res, LanguageInfo>;
  @useResult
  $Res call(
      {@JsonKey(name: 'iso_639_1') String code,
      @JsonKey(name: 'english_name') String englishName,
      @JsonKey(name: 'native_name') String? name});
}

/// @nodoc
class _$LanguageInfoCopyWithImpl<$Res, $Val extends LanguageInfo>
    implements $LanguageInfoCopyWith<$Res> {
  _$LanguageInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? englishName = null,
    Object? name = freezed,
  }) {
    return _then(_value.copyWith(
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      englishName: null == englishName
          ? _value.englishName
          : englishName // ignore: cast_nullable_to_non_nullable
              as String,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LanguageInfoImplCopyWith<$Res>
    implements $LanguageInfoCopyWith<$Res> {
  factory _$$LanguageInfoImplCopyWith(
          _$LanguageInfoImpl value, $Res Function(_$LanguageInfoImpl) then) =
      __$$LanguageInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'iso_639_1') String code,
      @JsonKey(name: 'english_name') String englishName,
      @JsonKey(name: 'native_name') String? name});
}

/// @nodoc
class __$$LanguageInfoImplCopyWithImpl<$Res>
    extends _$LanguageInfoCopyWithImpl<$Res, _$LanguageInfoImpl>
    implements _$$LanguageInfoImplCopyWith<$Res> {
  __$$LanguageInfoImplCopyWithImpl(
      _$LanguageInfoImpl _value, $Res Function(_$LanguageInfoImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? code = null,
    Object? englishName = null,
    Object? name = freezed,
  }) {
    return _then(_$LanguageInfoImpl(
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      englishName: null == englishName
          ? _value.englishName
          : englishName // ignore: cast_nullable_to_non_nullable
              as String,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LanguageInfoImpl implements _LanguageInfo {
  const _$LanguageInfoImpl(
      {@JsonKey(name: 'iso_639_1') required this.code,
      @JsonKey(name: 'english_name') required this.englishName,
      @JsonKey(name: 'native_name') this.name});

  factory _$LanguageInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$LanguageInfoImplFromJson(json);

  @override
  @JsonKey(name: 'iso_639_1')
  final String code;
  @override
  @JsonKey(name: 'english_name')
  final String englishName;
  @override
  @JsonKey(name: 'native_name')
  final String? name;

  @override
  String toString() {
    return 'LanguageInfo(code: $code, englishName: $englishName, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LanguageInfoImpl &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.englishName, englishName) ||
                other.englishName == englishName) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, code, englishName, name);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LanguageInfoImplCopyWith<_$LanguageInfoImpl> get copyWith =>
      __$$LanguageInfoImplCopyWithImpl<_$LanguageInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LanguageInfoImplToJson(
      this,
    );
  }
}

abstract class _LanguageInfo implements LanguageInfo {
  const factory _LanguageInfo(
      {@JsonKey(name: 'iso_639_1') required final String code,
      @JsonKey(name: 'english_name') required final String englishName,
      @JsonKey(name: 'native_name') final String? name}) = _$LanguageInfoImpl;

  factory _LanguageInfo.fromJson(Map<String, dynamic> json) =
      _$LanguageInfoImpl.fromJson;

  @override
  @JsonKey(name: 'iso_639_1')
  String get code;
  @override
  @JsonKey(name: 'english_name')
  String get englishName;
  @override
  @JsonKey(name: 'native_name')
  String? get name;
  @override
  @JsonKey(ignore: true)
  _$$LanguageInfoImplCopyWith<_$LanguageInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Job _$JobFromJson(Map<String, dynamic> json) {
  return _Job.fromJson(json);
}

/// @nodoc
mixin _$Job {
  String get department => throw _privateConstructorUsedError;
  List<String> get jobs => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $JobCopyWith<Job> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JobCopyWith<$Res> {
  factory $JobCopyWith(Job value, $Res Function(Job) then) =
      _$JobCopyWithImpl<$Res, Job>;
  @useResult
  $Res call({String department, List<String> jobs});
}

/// @nodoc
class _$JobCopyWithImpl<$Res, $Val extends Job> implements $JobCopyWith<$Res> {
  _$JobCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? department = null,
    Object? jobs = null,
  }) {
    return _then(_value.copyWith(
      department: null == department
          ? _value.department
          : department // ignore: cast_nullable_to_non_nullable
              as String,
      jobs: null == jobs
          ? _value.jobs
          : jobs // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$JobImplCopyWith<$Res> implements $JobCopyWith<$Res> {
  factory _$$JobImplCopyWith(_$JobImpl value, $Res Function(_$JobImpl) then) =
      __$$JobImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String department, List<String> jobs});
}

/// @nodoc
class __$$JobImplCopyWithImpl<$Res> extends _$JobCopyWithImpl<$Res, _$JobImpl>
    implements _$$JobImplCopyWith<$Res> {
  __$$JobImplCopyWithImpl(_$JobImpl _value, $Res Function(_$JobImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? department = null,
    Object? jobs = null,
  }) {
    return _then(_$JobImpl(
      department: null == department
          ? _value.department
          : department // ignore: cast_nullable_to_non_nullable
              as String,
      jobs: null == jobs
          ? _value._jobs
          : jobs // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$JobImpl implements _Job {
  const _$JobImpl(
      {required this.department, final List<String> jobs = const []})
      : _jobs = jobs;

  factory _$JobImpl.fromJson(Map<String, dynamic> json) =>
      _$$JobImplFromJson(json);

  @override
  final String department;
  final List<String> _jobs;
  @override
  @JsonKey()
  List<String> get jobs {
    if (_jobs is EqualUnmodifiableListView) return _jobs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_jobs);
  }

  @override
  String toString() {
    return 'Job(department: $department, jobs: $jobs)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$JobImpl &&
            (identical(other.department, department) ||
                other.department == department) &&
            const DeepCollectionEquality().equals(other._jobs, _jobs));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, department, const DeepCollectionEquality().hash(_jobs));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$JobImplCopyWith<_$JobImpl> get copyWith =>
      __$$JobImplCopyWithImpl<_$JobImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$JobImplToJson(
      this,
    );
  }
}

abstract class _Job implements Job {
  const factory _Job(
      {required final String department, final List<String> jobs}) = _$JobImpl;

  factory _Job.fromJson(Map<String, dynamic> json) = _$JobImpl.fromJson;

  @override
  String get department;
  @override
  List<String> get jobs;
  @override
  @JsonKey(ignore: true)
  _$$JobImplCopyWith<_$JobImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Timezone _$TimezoneFromJson(Map<String, dynamic> json) {
  return _Timezone.fromJson(json);
}

/// @nodoc
mixin _$Timezone {
  @JsonKey(name: 'iso_3166_1')
  String get countryCode => throw _privateConstructorUsedError;
  List<String> get zones => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TimezoneCopyWith<Timezone> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimezoneCopyWith<$Res> {
  factory $TimezoneCopyWith(Timezone value, $Res Function(Timezone) then) =
      _$TimezoneCopyWithImpl<$Res, Timezone>;
  @useResult
  $Res call(
      {@JsonKey(name: 'iso_3166_1') String countryCode, List<String> zones});
}

/// @nodoc
class _$TimezoneCopyWithImpl<$Res, $Val extends Timezone>
    implements $TimezoneCopyWith<$Res> {
  _$TimezoneCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? countryCode = null,
    Object? zones = null,
  }) {
    return _then(_value.copyWith(
      countryCode: null == countryCode
          ? _value.countryCode
          : countryCode // ignore: cast_nullable_to_non_nullable
              as String,
      zones: null == zones
          ? _value.zones
          : zones // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TimezoneImplCopyWith<$Res>
    implements $TimezoneCopyWith<$Res> {
  factory _$$TimezoneImplCopyWith(
          _$TimezoneImpl value, $Res Function(_$TimezoneImpl) then) =
      __$$TimezoneImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'iso_3166_1') String countryCode, List<String> zones});
}

/// @nodoc
class __$$TimezoneImplCopyWithImpl<$Res>
    extends _$TimezoneCopyWithImpl<$Res, _$TimezoneImpl>
    implements _$$TimezoneImplCopyWith<$Res> {
  __$$TimezoneImplCopyWithImpl(
      _$TimezoneImpl _value, $Res Function(_$TimezoneImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? countryCode = null,
    Object? zones = null,
  }) {
    return _then(_$TimezoneImpl(
      countryCode: null == countryCode
          ? _value.countryCode
          : countryCode // ignore: cast_nullable_to_non_nullable
              as String,
      zones: null == zones
          ? _value._zones
          : zones // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TimezoneImpl implements _Timezone {
  const _$TimezoneImpl(
      {@JsonKey(name: 'iso_3166_1') required this.countryCode,
      final List<String> zones = const []})
      : _zones = zones;

  factory _$TimezoneImpl.fromJson(Map<String, dynamic> json) =>
      _$$TimezoneImplFromJson(json);

  @override
  @JsonKey(name: 'iso_3166_1')
  final String countryCode;
  final List<String> _zones;
  @override
  @JsonKey()
  List<String> get zones {
    if (_zones is EqualUnmodifiableListView) return _zones;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_zones);
  }

  @override
  String toString() {
    return 'Timezone(countryCode: $countryCode, zones: $zones)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimezoneImpl &&
            (identical(other.countryCode, countryCode) ||
                other.countryCode == countryCode) &&
            const DeepCollectionEquality().equals(other._zones, _zones));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, countryCode, const DeepCollectionEquality().hash(_zones));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TimezoneImplCopyWith<_$TimezoneImpl> get copyWith =>
      __$$TimezoneImplCopyWithImpl<_$TimezoneImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TimezoneImplToJson(
      this,
    );
  }
}

abstract class _Timezone implements Timezone {
  const factory _Timezone(
      {@JsonKey(name: 'iso_3166_1') required final String countryCode,
      final List<String> zones}) = _$TimezoneImpl;

  factory _Timezone.fromJson(Map<String, dynamic> json) =
      _$TimezoneImpl.fromJson;

  @override
  @JsonKey(name: 'iso_3166_1')
  String get countryCode;
  @override
  List<String> get zones;
  @override
  @JsonKey(ignore: true)
  _$$TimezoneImplCopyWith<_$TimezoneImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
