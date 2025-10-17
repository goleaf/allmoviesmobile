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
  @JsonKey(name: 'parent_company')
  ParentCompany? get parentCompany => throw _privateConstructorUsedError;
  @JsonKey(name: 'alternative_names')
  List<String> get alternativeNames => throw _privateConstructorUsedError;
  @JsonKey(name: 'logo_gallery')
  List<CompanyLogo> get logoGallery => throw _privateConstructorUsedError;
  @JsonKey(name: 'produced_movies')
  List<dynamic> get producedMovies => throw _privateConstructorUsedError;
  @JsonKey(name: 'produced_series')
  List<dynamic> get producedSeries => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
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
    @JsonKey(name: 'parent_company') ParentCompany? parentCompany,
    @JsonKey(name: 'alternative_names') List<String> alternativeNames,
    @JsonKey(name: 'logo_gallery') List<CompanyLogo> logoGallery,
    @JsonKey(name: 'produced_movies') List<dynamic> producedMovies,
    @JsonKey(name: 'produced_series') List<dynamic> producedSeries,
  });

  $ParentCompanyCopyWith<$Res>? get parentCompany;
}

/// @nodoc
class _$CompanyCopyWithImpl<$Res, $Val extends Company>
    implements $CompanyCopyWith<$Res> {
  _$CompanyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

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
    Object? parentCompany = freezed,
    Object? alternativeNames = null,
    Object? logoGallery = null,
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
            parentCompany: freezed == parentCompany
                ? _value.parentCompany
                : parentCompany // ignore: cast_nullable_to_non_nullable
                      as ParentCompany?,
            alternativeNames: null == alternativeNames
                ? _value.alternativeNames
                : alternativeNames // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            logoGallery: null == logoGallery
                ? _value.logoGallery
                : logoGallery // ignore: cast_nullable_to_non_nullable
                      as List<CompanyLogo>,
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

  @override
  @pragma('vm:prefer-inline')
  $ParentCompanyCopyWith<$Res>? get parentCompany {
    if (_value.parentCompany == null) {
      return null;
    }

    return $ParentCompanyCopyWith<$Res>(_value.parentCompany!, (value) {
      return _then(_value.copyWith(parentCompany: value) as $Val);
    });
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
    @JsonKey(name: 'parent_company') ParentCompany? parentCompany,
    @JsonKey(name: 'alternative_names') List<String> alternativeNames,
    @JsonKey(name: 'logo_gallery') List<CompanyLogo> logoGallery,
    @JsonKey(name: 'produced_movies') List<dynamic> producedMovies,
    @JsonKey(name: 'produced_series') List<dynamic> producedSeries,
  });

  @override
  $ParentCompanyCopyWith<$Res>? get parentCompany;
}

/// @nodoc
class __$$CompanyImplCopyWithImpl<$Res>
    extends _$CompanyCopyWithImpl<$Res, _$CompanyImpl>
    implements _$$CompanyImplCopyWith<$Res> {
  __$$CompanyImplCopyWithImpl(
    _$CompanyImpl _value,
    $Res Function(_$CompanyImpl) _then,
  ) : super(_value, _then);

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
    Object? parentCompany = freezed,
    Object? alternativeNames = null,
    Object? logoGallery = null,
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
        parentCompany: freezed == parentCompany
            ? _value.parentCompany
            : parentCompany // ignore: cast_nullable_to_non_nullable
                  as ParentCompany?,
        alternativeNames: null == alternativeNames
            ? _value._alternativeNames
            : alternativeNames // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        logoGallery: null == logoGallery
            ? _value._logoGallery
            : logoGallery // ignore: cast_nullable_to_non_nullable
                  as List<CompanyLogo>,
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
    @JsonKey(name: 'parent_company') this.parentCompany,
    @JsonKey(name: 'alternative_names')
    final List<String> alternativeNames = const <String>[],
    @JsonKey(name: 'logo_gallery')
    final List<CompanyLogo> logoGallery = const <CompanyLogo>[],
    @JsonKey(name: 'produced_movies')
    final List<dynamic> producedMovies = const [],
    @JsonKey(name: 'produced_series')
    final List<dynamic> producedSeries = const [],
  }) : _alternativeNames = alternativeNames,
       _logoGallery = logoGallery,
       _producedMovies = producedMovies,
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
  @override
  @JsonKey(name: 'parent_company')
  final ParentCompany? parentCompany;
  final List<String> _alternativeNames;
  @override
  @JsonKey(name: 'alternative_names')
  List<String> get alternativeNames {
    if (_alternativeNames is EqualUnmodifiableListView)
      return _alternativeNames;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_alternativeNames);
  }

  final List<CompanyLogo> _logoGallery;
  @override
  @JsonKey(name: 'logo_gallery')
  List<CompanyLogo> get logoGallery {
    if (_logoGallery is EqualUnmodifiableListView) return _logoGallery;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_logoGallery);
  }

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
    return 'Company(id: $id, name: $name, logoPath: $logoPath, originCountry: $originCountry, description: $description, headquarters: $headquarters, homepage: $homepage, parentCompany: $parentCompany, alternativeNames: $alternativeNames, logoGallery: $logoGallery, producedMovies: $producedMovies, producedSeries: $producedSeries)';
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
            (identical(other.parentCompany, parentCompany) ||
                other.parentCompany == parentCompany) &&
            const DeepCollectionEquality().equals(
              other._alternativeNames,
              _alternativeNames,
            ) &&
            const DeepCollectionEquality().equals(
              other._logoGallery,
              _logoGallery,
            ) &&
            const DeepCollectionEquality().equals(
              other._producedMovies,
              _producedMovies,
            ) &&
            const DeepCollectionEquality().equals(
              other._producedSeries,
              _producedSeries,
            ));
  }

  @JsonKey(ignore: true)
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
    parentCompany,
    const DeepCollectionEquality().hash(_alternativeNames),
    const DeepCollectionEquality().hash(_logoGallery),
    const DeepCollectionEquality().hash(_producedMovies),
    const DeepCollectionEquality().hash(_producedSeries),
  );

  @JsonKey(ignore: true)
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
    @JsonKey(name: 'parent_company') final ParentCompany? parentCompany,
    @JsonKey(name: 'alternative_names') final List<String> alternativeNames,
    @JsonKey(name: 'logo_gallery') final List<CompanyLogo> logoGallery,
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
  @JsonKey(name: 'parent_company')
  ParentCompany? get parentCompany;
  @override
  @JsonKey(name: 'alternative_names')
  List<String> get alternativeNames;
  @override
  @JsonKey(name: 'logo_gallery')
  List<CompanyLogo> get logoGallery;
  @override
  @JsonKey(name: 'produced_movies')
  List<dynamic> get producedMovies;
  @override
  @JsonKey(name: 'produced_series')
  List<dynamic> get producedSeries;
  @override
  @JsonKey(ignore: true)
  _$$CompanyImplCopyWith<_$CompanyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ParentCompany _$ParentCompanyFromJson(Map<String, dynamic> json) {
  return _ParentCompany.fromJson(json);
}

/// @nodoc
mixin _$ParentCompany {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'logo_path')
  String? get logoPath => throw _privateConstructorUsedError;
  @JsonKey(name: 'origin_country')
  String? get originCountry => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ParentCompanyCopyWith<ParentCompany> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ParentCompanyCopyWith<$Res> {
  factory $ParentCompanyCopyWith(
    ParentCompany value,
    $Res Function(ParentCompany) then,
  ) = _$ParentCompanyCopyWithImpl<$Res, ParentCompany>;
  @useResult
  $Res call({
    int id,
    String name,
    @JsonKey(name: 'logo_path') String? logoPath,
    @JsonKey(name: 'origin_country') String? originCountry,
  });
}

/// @nodoc
class _$ParentCompanyCopyWithImpl<$Res, $Val extends ParentCompany>
    implements $ParentCompanyCopyWith<$Res> {
  _$ParentCompanyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? logoPath = freezed,
    Object? originCountry = freezed,
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
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ParentCompanyImplCopyWith<$Res>
    implements $ParentCompanyCopyWith<$Res> {
  factory _$$ParentCompanyImplCopyWith(
    _$ParentCompanyImpl value,
    $Res Function(_$ParentCompanyImpl) then,
  ) = __$$ParentCompanyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String name,
    @JsonKey(name: 'logo_path') String? logoPath,
    @JsonKey(name: 'origin_country') String? originCountry,
  });
}

/// @nodoc
class __$$ParentCompanyImplCopyWithImpl<$Res>
    extends _$ParentCompanyCopyWithImpl<$Res, _$ParentCompanyImpl>
    implements _$$ParentCompanyImplCopyWith<$Res> {
  __$$ParentCompanyImplCopyWithImpl(
    _$ParentCompanyImpl _value,
    $Res Function(_$ParentCompanyImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? logoPath = freezed,
    Object? originCountry = freezed,
  }) {
    return _then(
      _$ParentCompanyImpl(
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
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ParentCompanyImpl implements _ParentCompany {
  const _$ParentCompanyImpl({
    required this.id,
    required this.name,
    @JsonKey(name: 'logo_path') this.logoPath,
    @JsonKey(name: 'origin_country') this.originCountry,
  });

  factory _$ParentCompanyImpl.fromJson(Map<String, dynamic> json) =>
      _$$ParentCompanyImplFromJson(json);

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
  String toString() {
    return 'ParentCompany(id: $id, name: $name, logoPath: $logoPath, originCountry: $originCountry)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ParentCompanyImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.logoPath, logoPath) ||
                other.logoPath == logoPath) &&
            (identical(other.originCountry, originCountry) ||
                other.originCountry == originCountry));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, logoPath, originCountry);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ParentCompanyImplCopyWith<_$ParentCompanyImpl> get copyWith =>
      __$$ParentCompanyImplCopyWithImpl<_$ParentCompanyImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ParentCompanyImplToJson(this);
  }
}

abstract class _ParentCompany implements ParentCompany {
  const factory _ParentCompany({
    required final int id,
    required final String name,
    @JsonKey(name: 'logo_path') final String? logoPath,
    @JsonKey(name: 'origin_country') final String? originCountry,
  }) = _$ParentCompanyImpl;

  factory _ParentCompany.fromJson(Map<String, dynamic> json) =
      _$ParentCompanyImpl.fromJson;

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
  @JsonKey(ignore: true)
  _$$ParentCompanyImplCopyWith<_$ParentCompanyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CompanyLogo _$CompanyLogoFromJson(Map<String, dynamic> json) {
  return _CompanyLogo.fromJson(json);
}

/// @nodoc
mixin _$CompanyLogo {
  @JsonKey(name: 'file_path')
  String get filePath => throw _privateConstructorUsedError;
  int? get width => throw _privateConstructorUsedError;
  int? get height => throw _privateConstructorUsedError;
  @JsonKey(name: 'aspect_ratio')
  double? get aspectRatio => throw _privateConstructorUsedError;
  @JsonKey(name: 'vote_average')
  double? get voteAverage => throw _privateConstructorUsedError;
  @JsonKey(name: 'vote_count')
  int? get voteCount => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CompanyLogoCopyWith<CompanyLogo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CompanyLogoCopyWith<$Res> {
  factory $CompanyLogoCopyWith(
    CompanyLogo value,
    $Res Function(CompanyLogo) then,
  ) = _$CompanyLogoCopyWithImpl<$Res, CompanyLogo>;
  @useResult
  $Res call({
    @JsonKey(name: 'file_path') String filePath,
    int? width,
    int? height,
    @JsonKey(name: 'aspect_ratio') double? aspectRatio,
    @JsonKey(name: 'vote_average') double? voteAverage,
    @JsonKey(name: 'vote_count') int? voteCount,
  });
}

/// @nodoc
class _$CompanyLogoCopyWithImpl<$Res, $Val extends CompanyLogo>
    implements $CompanyLogoCopyWith<$Res> {
  _$CompanyLogoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? filePath = null,
    Object? width = freezed,
    Object? height = freezed,
    Object? aspectRatio = freezed,
    Object? voteAverage = freezed,
    Object? voteCount = freezed,
  }) {
    return _then(
      _value.copyWith(
            filePath: null == filePath
                ? _value.filePath
                : filePath // ignore: cast_nullable_to_non_nullable
                      as String,
            width: freezed == width
                ? _value.width
                : width // ignore: cast_nullable_to_non_nullable
                      as int?,
            height: freezed == height
                ? _value.height
                : height // ignore: cast_nullable_to_non_nullable
                      as int?,
            aspectRatio: freezed == aspectRatio
                ? _value.aspectRatio
                : aspectRatio // ignore: cast_nullable_to_non_nullable
                      as double?,
            voteAverage: freezed == voteAverage
                ? _value.voteAverage
                : voteAverage // ignore: cast_nullable_to_non_nullable
                      as double?,
            voteCount: freezed == voteCount
                ? _value.voteCount
                : voteCount // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CompanyLogoImplCopyWith<$Res>
    implements $CompanyLogoCopyWith<$Res> {
  factory _$$CompanyLogoImplCopyWith(
    _$CompanyLogoImpl value,
    $Res Function(_$CompanyLogoImpl) then,
  ) = __$$CompanyLogoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: 'file_path') String filePath,
    int? width,
    int? height,
    @JsonKey(name: 'aspect_ratio') double? aspectRatio,
    @JsonKey(name: 'vote_average') double? voteAverage,
    @JsonKey(name: 'vote_count') int? voteCount,
  });
}

/// @nodoc
class __$$CompanyLogoImplCopyWithImpl<$Res>
    extends _$CompanyLogoCopyWithImpl<$Res, _$CompanyLogoImpl>
    implements _$$CompanyLogoImplCopyWith<$Res> {
  __$$CompanyLogoImplCopyWithImpl(
    _$CompanyLogoImpl _value,
    $Res Function(_$CompanyLogoImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? filePath = null,
    Object? width = freezed,
    Object? height = freezed,
    Object? aspectRatio = freezed,
    Object? voteAverage = freezed,
    Object? voteCount = freezed,
  }) {
    return _then(
      _$CompanyLogoImpl(
        filePath: null == filePath
            ? _value.filePath
            : filePath // ignore: cast_nullable_to_non_nullable
                  as String,
        width: freezed == width
            ? _value.width
            : width // ignore: cast_nullable_to_non_nullable
                  as int?,
        height: freezed == height
            ? _value.height
            : height // ignore: cast_nullable_to_non_nullable
                  as int?,
        aspectRatio: freezed == aspectRatio
            ? _value.aspectRatio
            : aspectRatio // ignore: cast_nullable_to_non_nullable
                  as double?,
        voteAverage: freezed == voteAverage
            ? _value.voteAverage
            : voteAverage // ignore: cast_nullable_to_non_nullable
                  as double?,
        voteCount: freezed == voteCount
            ? _value.voteCount
            : voteCount // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CompanyLogoImpl implements _CompanyLogo {
  const _$CompanyLogoImpl({
    @JsonKey(name: 'file_path') required this.filePath,
    this.width,
    this.height,
    @JsonKey(name: 'aspect_ratio') this.aspectRatio,
    @JsonKey(name: 'vote_average') this.voteAverage,
    @JsonKey(name: 'vote_count') this.voteCount,
  });

  factory _$CompanyLogoImpl.fromJson(Map<String, dynamic> json) =>
      _$$CompanyLogoImplFromJson(json);

  @override
  @JsonKey(name: 'file_path')
  final String filePath;
  @override
  final int? width;
  @override
  final int? height;
  @override
  @JsonKey(name: 'aspect_ratio')
  final double? aspectRatio;
  @override
  @JsonKey(name: 'vote_average')
  final double? voteAverage;
  @override
  @JsonKey(name: 'vote_count')
  final int? voteCount;

  @override
  String toString() {
    return 'CompanyLogo(filePath: $filePath, width: $width, height: $height, aspectRatio: $aspectRatio, voteAverage: $voteAverage, voteCount: $voteCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CompanyLogoImpl &&
            (identical(other.filePath, filePath) ||
                other.filePath == filePath) &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.aspectRatio, aspectRatio) ||
                other.aspectRatio == aspectRatio) &&
            (identical(other.voteAverage, voteAverage) ||
                other.voteAverage == voteAverage) &&
            (identical(other.voteCount, voteCount) ||
                other.voteCount == voteCount));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    filePath,
    width,
    height,
    aspectRatio,
    voteAverage,
    voteCount,
  );

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CompanyLogoImplCopyWith<_$CompanyLogoImpl> get copyWith =>
      __$$CompanyLogoImplCopyWithImpl<_$CompanyLogoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CompanyLogoImplToJson(this);
  }
}

abstract class _CompanyLogo implements CompanyLogo {
  const factory _CompanyLogo({
    @JsonKey(name: 'file_path') required final String filePath,
    final int? width,
    final int? height,
    @JsonKey(name: 'aspect_ratio') final double? aspectRatio,
    @JsonKey(name: 'vote_average') final double? voteAverage,
    @JsonKey(name: 'vote_count') final int? voteCount,
  }) = _$CompanyLogoImpl;

  factory _CompanyLogo.fromJson(Map<String, dynamic> json) =
      _$CompanyLogoImpl.fromJson;

  @override
  @JsonKey(name: 'file_path')
  String get filePath;
  @override
  int? get width;
  @override
  int? get height;
  @override
  @JsonKey(name: 'aspect_ratio')
  double? get aspectRatio;
  @override
  @JsonKey(name: 'vote_average')
  double? get voteAverage;
  @override
  @JsonKey(name: 'vote_count')
  int? get voteCount;
  @override
  @JsonKey(ignore: true)
  _$$CompanyLogoImplCopyWith<_$CompanyLogoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
