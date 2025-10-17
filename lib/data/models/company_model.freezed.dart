// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'company_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Company _$CompanyFromJson(Map<String, dynamic> json) {
  return _Company.fromJson(json);
}

/// @nodoc
mixin _$Company {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'logo_path')
  String? get logoPath => throw _privateConstructorUsedError;
  @JsonKey(name: 'origin_country')
  String? get originCountry => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get headquarters => throw _privateConstructorUsedError;
  String? get homepage => throw _privateConstructorUsedError;
  @JsonKey(name: 'produced_movies')
  List<dynamic> get producedMovies => throw _privateConstructorUsedError;
  @JsonKey(name: 'produced_series')
  List<dynamic> get producedSeries => throw _privateConstructorUsedError;

  /// Serializes this Company to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Company
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CompanyCopyWith<Company> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CompanyCopyWith<$Res> {
  factory $CompanyCopyWith(Company value, $Res Function(Company) then) =
      _$CompanyCopyWithImpl<$Res, Company>;
  @useResult
  $Res call({
    int id,
    String name,
    @JsonKey(name: 'logo_path') String? logoPath,
    @JsonKey(name: 'origin_country') String? originCountry,
    String? description,
    String? headquarters,
    String? homepage,
    @JsonKey(name: 'produced_movies') List<dynamic> producedMovies,
    @JsonKey(name: 'produced_series') List<dynamic> producedSeries,
  });
}

/// @nodoc
class _$CompanyCopyWithImpl<$Res, $Val extends Company>
    implements $CompanyCopyWith<$Res> {
  _$CompanyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Company
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? logoPath = freezed,
    Object? originCountry = freezed,
    Object? description = freezed,
    Object? headquarters = freezed,
    Object? homepage = freezed,
    Object? producedMovies = null,
    Object? producedSeries = null,
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
            originCountry: freezed == originCountry
                ? _value.originCountry
                : originCountry // ignore: cast_nullable_to_non_nullable
                      as String?,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            headquarters: freezed == headquarters
                ? _value.headquarters
                : headquarters // ignore: cast_nullable_to_non_nullable
                      as String?,
            homepage: freezed == homepage
                ? _value.homepage
                : homepage // ignore: cast_nullable_to_non_nullable
                      as String?,
            producedMovies: null == producedMovies
                ? _value.producedMovies
                : producedMovies // ignore: cast_nullable_to_non_nullable
                      as List<dynamic>,
            producedSeries: null == producedSeries
                ? _value.producedSeries
                : producedSeries // ignore: cast_nullable_to_non_nullable
                      as List<dynamic>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CompanyImplCopyWith<$Res> implements $CompanyCopyWith<$Res> {
  factory _$$CompanyImplCopyWith(
    _$CompanyImpl value,
    $Res Function(_$CompanyImpl) then,
  ) = __$$CompanyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String name,
    @JsonKey(name: 'logo_path') String? logoPath,
    @JsonKey(name: 'origin_country') String? originCountry,
    String? description,
    String? headquarters,
    String? homepage,
    @JsonKey(name: 'produced_movies') List<dynamic> producedMovies,
    @JsonKey(name: 'produced_series') List<dynamic> producedSeries,
  });
}

/// @nodoc
class __$$CompanyImplCopyWithImpl<$Res>
    extends _$CompanyCopyWithImpl<$Res, _$CompanyImpl>
    implements _$$CompanyImplCopyWith<$Res> {
  __$$CompanyImplCopyWithImpl(
    _$CompanyImpl _value,
    $Res Function(_$CompanyImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Company
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? logoPath = freezed,
    Object? originCountry = freezed,
    Object? description = freezed,
    Object? headquarters = freezed,
    Object? homepage = freezed,
    Object? producedMovies = null,
    Object? producedSeries = null,
  }) {
    return _then(
      _$CompanyImpl(
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
        originCountry: freezed == originCountry
            ? _value.originCountry
            : originCountry // ignore: cast_nullable_to_non_nullable
                  as String?,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        headquarters: freezed == headquarters
            ? _value.headquarters
            : headquarters // ignore: cast_nullable_to_non_nullable
                  as String?,
        homepage: freezed == homepage
            ? _value.homepage
            : homepage // ignore: cast_nullable_to_non_nullable
                  as String?,
        producedMovies: null == producedMovies
            ? _value._producedMovies
            : producedMovies // ignore: cast_nullable_to_non_nullable
                  as List<dynamic>,
        producedSeries: null == producedSeries
            ? _value._producedSeries
            : producedSeries // ignore: cast_nullable_to_non_nullable
                  as List<dynamic>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CompanyImpl implements _Company {
  const _$CompanyImpl({
    required this.id,
    required this.name,
    @JsonKey(name: 'logo_path') this.logoPath,
    @JsonKey(name: 'origin_country') this.originCountry,
    this.description,
    this.headquarters,
    this.homepage,
    @JsonKey(name: 'produced_movies')
    final List<dynamic> producedMovies = const [],
    @JsonKey(name: 'produced_series')
    final List<dynamic> producedSeries = const [],
  }) : _producedMovies = producedMovies,
       _producedSeries = producedSeries;

  factory _$CompanyImpl.fromJson(Map<String, dynamic> json) =>
      _$$CompanyImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  @JsonKey(name: 'logo_path')
  final String? logoPath;
  @override
  @JsonKey(name: 'origin_country')
  final String? originCountry;
  @override
  final String? description;
  @override
  final String? headquarters;
  @override
  final String? homepage;
  final List<dynamic> _producedMovies;
  @override
  @JsonKey(name: 'produced_movies')
  List<dynamic> get producedMovies {
    if (_producedMovies is EqualUnmodifiableListView) return _producedMovies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_producedMovies);
  }

  final List<dynamic> _producedSeries;
  @override
  @JsonKey(name: 'produced_series')
  List<dynamic> get producedSeries {
    if (_producedSeries is EqualUnmodifiableListView) return _producedSeries;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_producedSeries);
  }

  @override
  String toString() {
    return 'Company(id: $id, name: $name, logoPath: $logoPath, originCountry: $originCountry, description: $description, headquarters: $headquarters, homepage: $homepage, producedMovies: $producedMovies, producedSeries: $producedSeries)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CompanyImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.logoPath, logoPath) ||
                other.logoPath == logoPath) &&
            (identical(other.originCountry, originCountry) ||
                other.originCountry == originCountry) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.headquarters, headquarters) ||
                other.headquarters == headquarters) &&
            (identical(other.homepage, homepage) ||
                other.homepage == homepage) &&
            const DeepCollectionEquality().equals(
              other._producedMovies,
              _producedMovies,
            ) &&
            const DeepCollectionEquality().equals(
              other._producedSeries,
              _producedSeries,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    logoPath,
    originCountry,
    description,
    headquarters,
    homepage,
    const DeepCollectionEquality().hash(_producedMovies),
    const DeepCollectionEquality().hash(_producedSeries),
  );

  /// Create a copy of Company
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CompanyImplCopyWith<_$CompanyImpl> get copyWith =>
      __$$CompanyImplCopyWithImpl<_$CompanyImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CompanyImplToJson(this);
  }
}

abstract class _Company implements Company {
  const factory _Company({
    required final int id,
    required final String name,
    @JsonKey(name: 'logo_path') final String? logoPath,
    @JsonKey(name: 'origin_country') final String? originCountry,
    final String? description,
    final String? headquarters,
    final String? homepage,
    @JsonKey(name: 'produced_movies') final List<dynamic> producedMovies,
    @JsonKey(name: 'produced_series') final List<dynamic> producedSeries,
  }) = _$CompanyImpl;

  factory _Company.fromJson(Map<String, dynamic> json) = _$CompanyImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  @JsonKey(name: 'logo_path')
  String? get logoPath;
  @override
  @JsonKey(name: 'origin_country')
  String? get originCountry;
  @override
  String? get description;
  @override
  String? get headquarters;
  @override
  String? get homepage;
  @override
  @JsonKey(name: 'produced_movies')
  List<dynamic> get producedMovies;
  @override
  @JsonKey(name: 'produced_series')
  List<dynamic> get producedSeries;

  /// Create a copy of Company
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CompanyImplCopyWith<_$CompanyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
