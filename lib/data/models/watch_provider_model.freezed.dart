// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'watch_provider_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

WatchProvider _$WatchProviderFromJson(Map<String, dynamic> json) {
  return _WatchProvider.fromJson(json);
}

/// @nodoc
mixin _$WatchProvider {
  int get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'provider_id')
  int? get providerId => throw _privateConstructorUsedError;
  @JsonKey(name: 'provider_name')
  String? get providerName => throw _privateConstructorUsedError;
  @JsonKey(name: 'logo_path')
  String? get logoPath => throw _privateConstructorUsedError;
  @JsonKey(name: 'display_priority')
  int? get displayPriority => throw _privateConstructorUsedError;

  /// Serializes this WatchProvider to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WatchProvider
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WatchProviderCopyWith<WatchProvider> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WatchProviderCopyWith<$Res> {
  factory $WatchProviderCopyWith(
    WatchProvider value,
    $Res Function(WatchProvider) then,
  ) = _$WatchProviderCopyWithImpl<$Res, WatchProvider>;
  @useResult
  $Res call({
    int id,
    @JsonKey(name: 'provider_id') int? providerId,
    @JsonKey(name: 'provider_name') String? providerName,
    @JsonKey(name: 'logo_path') String? logoPath,
    @JsonKey(name: 'display_priority') int? displayPriority,
  });
}

/// @nodoc
class _$WatchProviderCopyWithImpl<$Res, $Val extends WatchProvider>
    implements $WatchProviderCopyWith<$Res> {
  _$WatchProviderCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WatchProvider
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? providerId = freezed,
    Object? providerName = freezed,
    Object? logoPath = freezed,
    Object? displayPriority = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            providerId: freezed == providerId
                ? _value.providerId
                : providerId // ignore: cast_nullable_to_non_nullable
                      as int?,
            providerName: freezed == providerName
                ? _value.providerName
                : providerName // ignore: cast_nullable_to_non_nullable
                      as String?,
            logoPath: freezed == logoPath
                ? _value.logoPath
                : logoPath // ignore: cast_nullable_to_non_nullable
                      as String?,
            displayPriority: freezed == displayPriority
                ? _value.displayPriority
                : displayPriority // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WatchProviderImplCopyWith<$Res>
    implements $WatchProviderCopyWith<$Res> {
  factory _$$WatchProviderImplCopyWith(
    _$WatchProviderImpl value,
    $Res Function(_$WatchProviderImpl) then,
  ) = __$$WatchProviderImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    @JsonKey(name: 'provider_id') int? providerId,
    @JsonKey(name: 'provider_name') String? providerName,
    @JsonKey(name: 'logo_path') String? logoPath,
    @JsonKey(name: 'display_priority') int? displayPriority,
  });
}

/// @nodoc
class __$$WatchProviderImplCopyWithImpl<$Res>
    extends _$WatchProviderCopyWithImpl<$Res, _$WatchProviderImpl>
    implements _$$WatchProviderImplCopyWith<$Res> {
  __$$WatchProviderImplCopyWithImpl(
    _$WatchProviderImpl _value,
    $Res Function(_$WatchProviderImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WatchProvider
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? providerId = freezed,
    Object? providerName = freezed,
    Object? logoPath = freezed,
    Object? displayPriority = freezed,
  }) {
    return _then(
      _$WatchProviderImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        providerId: freezed == providerId
            ? _value.providerId
            : providerId // ignore: cast_nullable_to_non_nullable
                  as int?,
        providerName: freezed == providerName
            ? _value.providerName
            : providerName // ignore: cast_nullable_to_non_nullable
                  as String?,
        logoPath: freezed == logoPath
            ? _value.logoPath
            : logoPath // ignore: cast_nullable_to_non_nullable
                  as String?,
        displayPriority: freezed == displayPriority
            ? _value.displayPriority
            : displayPriority // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WatchProviderImpl implements _WatchProvider {
  const _$WatchProviderImpl({
    required this.id,
    @JsonKey(name: 'provider_id') this.providerId,
    @JsonKey(name: 'provider_name') this.providerName,
    @JsonKey(name: 'logo_path') this.logoPath,
    @JsonKey(name: 'display_priority') this.displayPriority,
  });

  factory _$WatchProviderImpl.fromJson(Map<String, dynamic> json) =>
      _$$WatchProviderImplFromJson(json);

  @override
  final int id;
  @override
  @JsonKey(name: 'provider_id')
  final int? providerId;
  @override
  @JsonKey(name: 'provider_name')
  final String? providerName;
  @override
  @JsonKey(name: 'logo_path')
  final String? logoPath;
  @override
  @JsonKey(name: 'display_priority')
  final int? displayPriority;

  @override
  String toString() {
    return 'WatchProvider(id: $id, providerId: $providerId, providerName: $providerName, logoPath: $logoPath, displayPriority: $displayPriority)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WatchProviderImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.providerId, providerId) ||
                other.providerId == providerId) &&
            (identical(other.providerName, providerName) ||
                other.providerName == providerName) &&
            (identical(other.logoPath, logoPath) ||
                other.logoPath == logoPath) &&
            (identical(other.displayPriority, displayPriority) ||
                other.displayPriority == displayPriority));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    providerId,
    providerName,
    logoPath,
    displayPriority,
  );

  /// Create a copy of WatchProvider
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WatchProviderImplCopyWith<_$WatchProviderImpl> get copyWith =>
      __$$WatchProviderImplCopyWithImpl<_$WatchProviderImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WatchProviderImplToJson(this);
  }
}

abstract class _WatchProvider implements WatchProvider {
  const factory _WatchProvider({
    required final int id,
    @JsonKey(name: 'provider_id') final int? providerId,
    @JsonKey(name: 'provider_name') final String? providerName,
    @JsonKey(name: 'logo_path') final String? logoPath,
    @JsonKey(name: 'display_priority') final int? displayPriority,
  }) = _$WatchProviderImpl;

  factory _WatchProvider.fromJson(Map<String, dynamic> json) =
      _$WatchProviderImpl.fromJson;

  @override
  int get id;
  @override
  @JsonKey(name: 'provider_id')
  int? get providerId;
  @override
  @JsonKey(name: 'provider_name')
  String? get providerName;
  @override
  @JsonKey(name: 'logo_path')
  String? get logoPath;
  @override
  @JsonKey(name: 'display_priority')
  int? get displayPriority;

  /// Create a copy of WatchProvider
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WatchProviderImplCopyWith<_$WatchProviderImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WatchProviderResults _$WatchProviderResultsFromJson(Map<String, dynamic> json) {
  return _WatchProviderResults.fromJson(json);
}

/// @nodoc
mixin _$WatchProviderResults {
  String? get link => throw _privateConstructorUsedError;
  List<WatchProvider> get flatrate => throw _privateConstructorUsedError;
  List<WatchProvider> get buy => throw _privateConstructorUsedError;
  List<WatchProvider> get rent => throw _privateConstructorUsedError;

  /// Serializes this WatchProviderResults to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WatchProviderResults
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WatchProviderResultsCopyWith<WatchProviderResults> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WatchProviderResultsCopyWith<$Res> {
  factory $WatchProviderResultsCopyWith(
    WatchProviderResults value,
    $Res Function(WatchProviderResults) then,
  ) = _$WatchProviderResultsCopyWithImpl<$Res, WatchProviderResults>;
  @useResult
  $Res call({
    String? link,
    List<WatchProvider> flatrate,
    List<WatchProvider> buy,
    List<WatchProvider> rent,
  });
}

/// @nodoc
class _$WatchProviderResultsCopyWithImpl<
  $Res,
  $Val extends WatchProviderResults
>
    implements $WatchProviderResultsCopyWith<$Res> {
  _$WatchProviderResultsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WatchProviderResults
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? link = freezed,
    Object? flatrate = null,
    Object? buy = null,
    Object? rent = null,
  }) {
    return _then(
      _value.copyWith(
            link: freezed == link
                ? _value.link
                : link // ignore: cast_nullable_to_non_nullable
                      as String?,
            flatrate: null == flatrate
                ? _value.flatrate
                : flatrate // ignore: cast_nullable_to_non_nullable
                      as List<WatchProvider>,
            buy: null == buy
                ? _value.buy
                : buy // ignore: cast_nullable_to_non_nullable
                      as List<WatchProvider>,
            rent: null == rent
                ? _value.rent
                : rent // ignore: cast_nullable_to_non_nullable
                      as List<WatchProvider>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WatchProviderResultsImplCopyWith<$Res>
    implements $WatchProviderResultsCopyWith<$Res> {
  factory _$$WatchProviderResultsImplCopyWith(
    _$WatchProviderResultsImpl value,
    $Res Function(_$WatchProviderResultsImpl) then,
  ) = __$$WatchProviderResultsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? link,
    List<WatchProvider> flatrate,
    List<WatchProvider> buy,
    List<WatchProvider> rent,
  });
}

/// @nodoc
class __$$WatchProviderResultsImplCopyWithImpl<$Res>
    extends _$WatchProviderResultsCopyWithImpl<$Res, _$WatchProviderResultsImpl>
    implements _$$WatchProviderResultsImplCopyWith<$Res> {
  __$$WatchProviderResultsImplCopyWithImpl(
    _$WatchProviderResultsImpl _value,
    $Res Function(_$WatchProviderResultsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WatchProviderResults
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? link = freezed,
    Object? flatrate = null,
    Object? buy = null,
    Object? rent = null,
  }) {
    return _then(
      _$WatchProviderResultsImpl(
        link: freezed == link
            ? _value.link
            : link // ignore: cast_nullable_to_non_nullable
                  as String?,
        flatrate: null == flatrate
            ? _value._flatrate
            : flatrate // ignore: cast_nullable_to_non_nullable
                  as List<WatchProvider>,
        buy: null == buy
            ? _value._buy
            : buy // ignore: cast_nullable_to_non_nullable
                  as List<WatchProvider>,
        rent: null == rent
            ? _value._rent
            : rent // ignore: cast_nullable_to_non_nullable
                  as List<WatchProvider>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WatchProviderResultsImpl implements _WatchProviderResults {
  const _$WatchProviderResultsImpl({
    this.link,
    final List<WatchProvider> flatrate = const [],
    final List<WatchProvider> buy = const [],
    final List<WatchProvider> rent = const [],
  }) : _flatrate = flatrate,
       _buy = buy,
       _rent = rent;

  factory _$WatchProviderResultsImpl.fromJson(Map<String, dynamic> json) =>
      _$$WatchProviderResultsImplFromJson(json);

  @override
  final String? link;
  final List<WatchProvider> _flatrate;
  @override
  @JsonKey()
  List<WatchProvider> get flatrate {
    if (_flatrate is EqualUnmodifiableListView) return _flatrate;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_flatrate);
  }

  final List<WatchProvider> _buy;
  @override
  @JsonKey()
  List<WatchProvider> get buy {
    if (_buy is EqualUnmodifiableListView) return _buy;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_buy);
  }

  final List<WatchProvider> _rent;
  @override
  @JsonKey()
  List<WatchProvider> get rent {
    if (_rent is EqualUnmodifiableListView) return _rent;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_rent);
  }

  @override
  String toString() {
    return 'WatchProviderResults(link: $link, flatrate: $flatrate, buy: $buy, rent: $rent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WatchProviderResultsImpl &&
            (identical(other.link, link) || other.link == link) &&
            const DeepCollectionEquality().equals(other._flatrate, _flatrate) &&
            const DeepCollectionEquality().equals(other._buy, _buy) &&
            const DeepCollectionEquality().equals(other._rent, _rent));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    link,
    const DeepCollectionEquality().hash(_flatrate),
    const DeepCollectionEquality().hash(_buy),
    const DeepCollectionEquality().hash(_rent),
  );

  /// Create a copy of WatchProviderResults
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WatchProviderResultsImplCopyWith<_$WatchProviderResultsImpl>
  get copyWith =>
      __$$WatchProviderResultsImplCopyWithImpl<_$WatchProviderResultsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$WatchProviderResultsImplToJson(this);
  }
}

abstract class _WatchProviderResults implements WatchProviderResults {
  const factory _WatchProviderResults({
    final String? link,
    final List<WatchProvider> flatrate,
    final List<WatchProvider> buy,
    final List<WatchProvider> rent,
  }) = _$WatchProviderResultsImpl;

  factory _WatchProviderResults.fromJson(Map<String, dynamic> json) =
      _$WatchProviderResultsImpl.fromJson;

  @override
  String? get link;
  @override
  List<WatchProvider> get flatrate;
  @override
  List<WatchProvider> get buy;
  @override
  List<WatchProvider> get rent;

  /// Create a copy of WatchProviderResults
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WatchProviderResultsImplCopyWith<_$WatchProviderResultsImpl>
  get copyWith => throw _privateConstructorUsedError;
}

WatchProviderRegion _$WatchProviderRegionFromJson(Map<String, dynamic> json) {
  return _WatchProviderRegion.fromJson(json);
}

/// @nodoc
mixin _$WatchProviderRegion {
  @JsonKey(name: 'iso_3166_1')
  String get countryCode => throw _privateConstructorUsedError;
  @JsonKey(name: 'english_name')
  String get englishName => throw _privateConstructorUsedError;
  @JsonKey(name: 'native_name')
  String? get nativeName => throw _privateConstructorUsedError;

  /// Serializes this WatchProviderRegion to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WatchProviderRegion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WatchProviderRegionCopyWith<WatchProviderRegion> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WatchProviderRegionCopyWith<$Res> {
  factory $WatchProviderRegionCopyWith(
    WatchProviderRegion value,
    $Res Function(WatchProviderRegion) then,
  ) = _$WatchProviderRegionCopyWithImpl<$Res, WatchProviderRegion>;
  @useResult
  $Res call({
    @JsonKey(name: 'iso_3166_1') String countryCode,
    @JsonKey(name: 'english_name') String englishName,
    @JsonKey(name: 'native_name') String? nativeName,
  });
}

/// @nodoc
class _$WatchProviderRegionCopyWithImpl<$Res, $Val extends WatchProviderRegion>
    implements $WatchProviderRegionCopyWith<$Res> {
  _$WatchProviderRegionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WatchProviderRegion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? countryCode = null,
    Object? englishName = null,
    Object? nativeName = freezed,
  }) {
    return _then(
      _value.copyWith(
            countryCode: null == countryCode
                ? _value.countryCode
                : countryCode // ignore: cast_nullable_to_non_nullable
                      as String,
            englishName: null == englishName
                ? _value.englishName
                : englishName // ignore: cast_nullable_to_non_nullable
                      as String,
            nativeName: freezed == nativeName
                ? _value.nativeName
                : nativeName // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WatchProviderRegionImplCopyWith<$Res>
    implements $WatchProviderRegionCopyWith<$Res> {
  factory _$$WatchProviderRegionImplCopyWith(
    _$WatchProviderRegionImpl value,
    $Res Function(_$WatchProviderRegionImpl) then,
  ) = __$$WatchProviderRegionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'iso_3166_1') String countryCode,
    @JsonKey(name: 'english_name') String englishName,
    @JsonKey(name: 'native_name') String? nativeName,
  });
}

/// @nodoc
class __$$WatchProviderRegionImplCopyWithImpl<$Res>
    extends _$WatchProviderRegionCopyWithImpl<$Res, _$WatchProviderRegionImpl>
    implements _$$WatchProviderRegionImplCopyWith<$Res> {
  __$$WatchProviderRegionImplCopyWithImpl(
    _$WatchProviderRegionImpl _value,
    $Res Function(_$WatchProviderRegionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WatchProviderRegion
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? countryCode = null,
    Object? englishName = null,
    Object? nativeName = freezed,
  }) {
    return _then(
      _$WatchProviderRegionImpl(
        countryCode: null == countryCode
            ? _value.countryCode
            : countryCode // ignore: cast_nullable_to_non_nullable
                  as String,
        englishName: null == englishName
            ? _value.englishName
            : englishName // ignore: cast_nullable_to_non_nullable
                  as String,
        nativeName: freezed == nativeName
            ? _value.nativeName
            : nativeName // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WatchProviderRegionImpl implements _WatchProviderRegion {
  const _$WatchProviderRegionImpl({
    @JsonKey(name: 'iso_3166_1') required this.countryCode,
    @JsonKey(name: 'english_name') required this.englishName,
    @JsonKey(name: 'native_name') this.nativeName,
  });

  factory _$WatchProviderRegionImpl.fromJson(Map<String, dynamic> json) =>
      _$$WatchProviderRegionImplFromJson(json);

  @override
  @JsonKey(name: 'iso_3166_1')
  final String countryCode;
  @override
  @JsonKey(name: 'english_name')
  final String englishName;
  @override
  @JsonKey(name: 'native_name')
  final String? nativeName;

  @override
  String toString() {
    return 'WatchProviderRegion(countryCode: $countryCode, englishName: $englishName, nativeName: $nativeName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WatchProviderRegionImpl &&
            (identical(other.countryCode, countryCode) ||
                other.countryCode == countryCode) &&
            (identical(other.englishName, englishName) ||
                other.englishName == englishName) &&
            (identical(other.nativeName, nativeName) ||
                other.nativeName == nativeName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, countryCode, englishName, nativeName);

  /// Create a copy of WatchProviderRegion
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WatchProviderRegionImplCopyWith<_$WatchProviderRegionImpl> get copyWith =>
      __$$WatchProviderRegionImplCopyWithImpl<_$WatchProviderRegionImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$WatchProviderRegionImplToJson(this);
  }
}

abstract class _WatchProviderRegion implements WatchProviderRegion {
  const factory _WatchProviderRegion({
    @JsonKey(name: 'iso_3166_1') required final String countryCode,
    @JsonKey(name: 'english_name') required final String englishName,
    @JsonKey(name: 'native_name') final String? nativeName,
  }) = _$WatchProviderRegionImpl;

  factory _WatchProviderRegion.fromJson(Map<String, dynamic> json) =
      _$WatchProviderRegionImpl.fromJson;

  @override
  @JsonKey(name: 'iso_3166_1')
  String get countryCode;
  @override
  @JsonKey(name: 'english_name')
  String get englishName;
  @override
  @JsonKey(name: 'native_name')
  String? get nativeName;

  /// Create a copy of WatchProviderRegion
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WatchProviderRegionImplCopyWith<_$WatchProviderRegionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
