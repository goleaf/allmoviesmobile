// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'discover_filters_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DiscoverFilters _$DiscoverFiltersFromJson(Map<String, dynamic> json) {
  return _DiscoverFilters.fromJson(json);
}

/// @nodoc
mixin _$DiscoverFilters {
  int get page => throw _privateConstructorUsedError;
  @JsonKey(name: 'sort_by')
  SortBy get sortBy => throw _privateConstructorUsedError;
  @JsonKey(name: 'with_genres')
  String? get withGenres => throw _privateConstructorUsedError;
  @JsonKey(name: 'primary_release_year')
  int? get primaryReleaseYear => throw _privateConstructorUsedError;
  @JsonKey(name: 'primary_release_date.gte')
  String? get releaseDateGte => throw _privateConstructorUsedError;
  @JsonKey(name: 'primary_release_date.lte')
  String? get releaseDateLte => throw _privateConstructorUsedError;
  @JsonKey(name: 'with_origin_country')
  String? get withOriginCountry => throw _privateConstructorUsedError;
  @JsonKey(name: 'with_original_language')
  String? get withOriginalLanguage => throw _privateConstructorUsedError;
  @JsonKey(name: 'with_runtime.gte')
  int? get runtimeGte => throw _privateConstructorUsedError;
  @JsonKey(name: 'with_runtime.lte')
  int? get runtimeLte => throw _privateConstructorUsedError;
  @JsonKey(name: 'vote_average.gte')
  double? get voteAverageGte => throw _privateConstructorUsedError;
  @JsonKey(name: 'vote_count.gte')
  int? get voteCountGte => throw _privateConstructorUsedError;

  /// Serializes this DiscoverFilters to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DiscoverFilters
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DiscoverFiltersCopyWith<DiscoverFilters> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DiscoverFiltersCopyWith<$Res> {
  factory $DiscoverFiltersCopyWith(
    DiscoverFilters value,
    $Res Function(DiscoverFilters) then,
  ) = _$DiscoverFiltersCopyWithImpl<$Res, DiscoverFilters>;
  @useResult
  $Res call({
    int page,
    @JsonKey(name: 'sort_by') SortBy sortBy,
    @JsonKey(name: 'with_genres') String? withGenres,
    @JsonKey(name: 'primary_release_year') int? primaryReleaseYear,
    @JsonKey(name: 'primary_release_date.gte') String? releaseDateGte,
    @JsonKey(name: 'primary_release_date.lte') String? releaseDateLte,
    @JsonKey(name: 'with_origin_country') String? withOriginCountry,
    @JsonKey(name: 'with_original_language') String? withOriginalLanguage,
    @JsonKey(name: 'with_runtime.gte') int? runtimeGte,
    @JsonKey(name: 'with_runtime.lte') int? runtimeLte,
    @JsonKey(name: 'vote_average.gte') double? voteAverageGte,
    @JsonKey(name: 'vote_count.gte') int? voteCountGte,
  });
}

/// @nodoc
class _$DiscoverFiltersCopyWithImpl<$Res, $Val extends DiscoverFilters>
    implements $DiscoverFiltersCopyWith<$Res> {
  _$DiscoverFiltersCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DiscoverFilters
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? page = null,
    Object? sortBy = null,
    Object? withGenres = freezed,
    Object? primaryReleaseYear = freezed,
    Object? releaseDateGte = freezed,
    Object? releaseDateLte = freezed,
    Object? withOriginCountry = freezed,
    Object? withOriginalLanguage = freezed,
    Object? runtimeGte = freezed,
    Object? runtimeLte = freezed,
    Object? voteAverageGte = freezed,
    Object? voteCountGte = freezed,
  }) {
    return _then(
      _value.copyWith(
            page: null == page
                ? _value.page
                : page // ignore: cast_nullable_to_non_nullable
                      as int,
            sortBy: null == sortBy
                ? _value.sortBy
                : sortBy // ignore: cast_nullable_to_non_nullable
                      as SortBy,
            withGenres: freezed == withGenres
                ? _value.withGenres
                : withGenres // ignore: cast_nullable_to_non_nullable
                      as String?,
            primaryReleaseYear: freezed == primaryReleaseYear
                ? _value.primaryReleaseYear
                : primaryReleaseYear // ignore: cast_nullable_to_non_nullable
                      as int?,
            releaseDateGte: freezed == releaseDateGte
                ? _value.releaseDateGte
                : releaseDateGte // ignore: cast_nullable_to_non_nullable
                      as String?,
            releaseDateLte: freezed == releaseDateLte
                ? _value.releaseDateLte
                : releaseDateLte // ignore: cast_nullable_to_non_nullable
                      as String?,
            withOriginCountry: freezed == withOriginCountry
                ? _value.withOriginCountry
                : withOriginCountry // ignore: cast_nullable_to_non_nullable
                      as String?,
            withOriginalLanguage: freezed == withOriginalLanguage
                ? _value.withOriginalLanguage
                : withOriginalLanguage // ignore: cast_nullable_to_non_nullable
                      as String?,
            runtimeGte: freezed == runtimeGte
                ? _value.runtimeGte
                : runtimeGte // ignore: cast_nullable_to_non_nullable
                      as int?,
            runtimeLte: freezed == runtimeLte
                ? _value.runtimeLte
                : runtimeLte // ignore: cast_nullable_to_non_nullable
                      as int?,
            voteAverageGte: freezed == voteAverageGte
                ? _value.voteAverageGte
                : voteAverageGte // ignore: cast_nullable_to_non_nullable
                      as double?,
            voteCountGte: freezed == voteCountGte
                ? _value.voteCountGte
                : voteCountGte // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DiscoverFiltersImplCopyWith<$Res>
    implements $DiscoverFiltersCopyWith<$Res> {
  factory _$$DiscoverFiltersImplCopyWith(
    _$DiscoverFiltersImpl value,
    $Res Function(_$DiscoverFiltersImpl) then,
  ) = __$$DiscoverFiltersImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int page,
    @JsonKey(name: 'sort_by') SortBy sortBy,
    @JsonKey(name: 'with_genres') String? withGenres,
    @JsonKey(name: 'primary_release_year') int? primaryReleaseYear,
    @JsonKey(name: 'primary_release_date.gte') String? releaseDateGte,
    @JsonKey(name: 'primary_release_date.lte') String? releaseDateLte,
    @JsonKey(name: 'with_origin_country') String? withOriginCountry,
    @JsonKey(name: 'with_original_language') String? withOriginalLanguage,
    @JsonKey(name: 'with_runtime.gte') int? runtimeGte,
    @JsonKey(name: 'with_runtime.lte') int? runtimeLte,
    @JsonKey(name: 'vote_average.gte') double? voteAverageGte,
    @JsonKey(name: 'vote_count.gte') int? voteCountGte,
  });
}

/// @nodoc
class __$$DiscoverFiltersImplCopyWithImpl<$Res>
    extends _$DiscoverFiltersCopyWithImpl<$Res, _$DiscoverFiltersImpl>
    implements _$$DiscoverFiltersImplCopyWith<$Res> {
  __$$DiscoverFiltersImplCopyWithImpl(
    _$DiscoverFiltersImpl _value,
    $Res Function(_$DiscoverFiltersImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DiscoverFilters
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? page = null,
    Object? sortBy = null,
    Object? withGenres = freezed,
    Object? primaryReleaseYear = freezed,
    Object? releaseDateGte = freezed,
    Object? releaseDateLte = freezed,
    Object? withOriginCountry = freezed,
    Object? withOriginalLanguage = freezed,
    Object? runtimeGte = freezed,
    Object? runtimeLte = freezed,
    Object? voteAverageGte = freezed,
    Object? voteCountGte = freezed,
  }) {
    return _then(
      _$DiscoverFiltersImpl(
        page: null == page
            ? _value.page
            : page // ignore: cast_nullable_to_non_nullable
                  as int,
        sortBy: null == sortBy
            ? _value.sortBy
            : sortBy // ignore: cast_nullable_to_non_nullable
                  as SortBy,
        withGenres: freezed == withGenres
            ? _value.withGenres
            : withGenres // ignore: cast_nullable_to_non_nullable
                  as String?,
        primaryReleaseYear: freezed == primaryReleaseYear
            ? _value.primaryReleaseYear
            : primaryReleaseYear // ignore: cast_nullable_to_non_nullable
                  as int?,
        releaseDateGte: freezed == releaseDateGte
            ? _value.releaseDateGte
            : releaseDateGte // ignore: cast_nullable_to_non_nullable
                  as String?,
        releaseDateLte: freezed == releaseDateLte
            ? _value.releaseDateLte
            : releaseDateLte // ignore: cast_nullable_to_non_nullable
                  as String?,
        withOriginCountry: freezed == withOriginCountry
            ? _value.withOriginCountry
            : withOriginCountry // ignore: cast_nullable_to_non_nullable
                  as String?,
        withOriginalLanguage: freezed == withOriginalLanguage
            ? _value.withOriginalLanguage
            : withOriginalLanguage // ignore: cast_nullable_to_non_nullable
                  as String?,
        runtimeGte: freezed == runtimeGte
            ? _value.runtimeGte
            : runtimeGte // ignore: cast_nullable_to_non_nullable
                  as int?,
        runtimeLte: freezed == runtimeLte
            ? _value.runtimeLte
            : runtimeLte // ignore: cast_nullable_to_non_nullable
                  as int?,
        voteAverageGte: freezed == voteAverageGte
            ? _value.voteAverageGte
            : voteAverageGte // ignore: cast_nullable_to_non_nullable
                  as double?,
        voteCountGte: freezed == voteCountGte
            ? _value.voteCountGte
            : voteCountGte // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DiscoverFiltersImpl implements _DiscoverFilters {
  const _$DiscoverFiltersImpl({
    this.page = 1,
    @JsonKey(name: 'sort_by') this.sortBy = SortBy.popularityDesc,
    @JsonKey(name: 'with_genres') this.withGenres,
    @JsonKey(name: 'primary_release_year') this.primaryReleaseYear,
    @JsonKey(name: 'primary_release_date.gte') this.releaseDateGte,
    @JsonKey(name: 'primary_release_date.lte') this.releaseDateLte,
    @JsonKey(name: 'with_origin_country') this.withOriginCountry,
    @JsonKey(name: 'with_original_language') this.withOriginalLanguage,
    @JsonKey(name: 'with_runtime.gte') this.runtimeGte,
    @JsonKey(name: 'with_runtime.lte') this.runtimeLte,
    @JsonKey(name: 'vote_average.gte') this.voteAverageGte,
    @JsonKey(name: 'vote_count.gte') this.voteCountGte,
  });

  factory _$DiscoverFiltersImpl.fromJson(Map<String, dynamic> json) =>
      _$$DiscoverFiltersImplFromJson(json);

  @override
  @JsonKey()
  final int page;
  @override
  @JsonKey(name: 'sort_by')
  final SortBy sortBy;
  @override
  @JsonKey(name: 'with_genres')
  final String? withGenres;
  @override
  @JsonKey(name: 'primary_release_year')
  final int? primaryReleaseYear;
  @override
  @JsonKey(name: 'primary_release_date.gte')
  final String? releaseDateGte;
  @override
  @JsonKey(name: 'primary_release_date.lte')
  final String? releaseDateLte;
  @override
  @JsonKey(name: 'with_origin_country')
  final String? withOriginCountry;
  @override
  @JsonKey(name: 'with_original_language')
  final String? withOriginalLanguage;
  @override
  @JsonKey(name: 'with_runtime.gte')
  final int? runtimeGte;
  @override
  @JsonKey(name: 'with_runtime.lte')
  final int? runtimeLte;
  @override
  @JsonKey(name: 'vote_average.gte')
  final double? voteAverageGte;
  @override
  @JsonKey(name: 'vote_count.gte')
  final int? voteCountGte;

  @override
  String toString() {
    return 'DiscoverFilters(page: $page, sortBy: $sortBy, withGenres: $withGenres, primaryReleaseYear: $primaryReleaseYear, releaseDateGte: $releaseDateGte, releaseDateLte: $releaseDateLte, withOriginCountry: $withOriginCountry, withOriginalLanguage: $withOriginalLanguage, runtimeGte: $runtimeGte, runtimeLte: $runtimeLte, voteAverageGte: $voteAverageGte, voteCountGte: $voteCountGte)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DiscoverFiltersImpl &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.sortBy, sortBy) || other.sortBy == sortBy) &&
            (identical(other.withGenres, withGenres) ||
                other.withGenres == withGenres) &&
            (identical(other.primaryReleaseYear, primaryReleaseYear) ||
                other.primaryReleaseYear == primaryReleaseYear) &&
            (identical(other.releaseDateGte, releaseDateGte) ||
                other.releaseDateGte == releaseDateGte) &&
            (identical(other.releaseDateLte, releaseDateLte) ||
                other.releaseDateLte == releaseDateLte) &&
            (identical(other.withOriginCountry, withOriginCountry) ||
                other.withOriginCountry == withOriginCountry) &&
            (identical(other.withOriginalLanguage, withOriginalLanguage) ||
                other.withOriginalLanguage == withOriginalLanguage) &&
            (identical(other.runtimeGte, runtimeGte) ||
                other.runtimeGte == runtimeGte) &&
            (identical(other.runtimeLte, runtimeLte) ||
                other.runtimeLte == runtimeLte) &&
            (identical(other.voteAverageGte, voteAverageGte) ||
                other.voteAverageGte == voteAverageGte) &&
            (identical(other.voteCountGte, voteCountGte) ||
                other.voteCountGte == voteCountGte));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    page,
    sortBy,
    withGenres,
    primaryReleaseYear,
    releaseDateGte,
    releaseDateLte,
    withOriginCountry,
    withOriginalLanguage,
    runtimeGte,
    runtimeLte,
    voteAverageGte,
    voteCountGte,
  );

  /// Create a copy of DiscoverFilters
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DiscoverFiltersImplCopyWith<_$DiscoverFiltersImpl> get copyWith =>
      __$$DiscoverFiltersImplCopyWithImpl<_$DiscoverFiltersImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$DiscoverFiltersImplToJson(this);
  }
}

abstract class _DiscoverFilters implements DiscoverFilters {
  const factory _DiscoverFilters({
    final int page,
    @JsonKey(name: 'sort_by') final SortBy sortBy,
    @JsonKey(name: 'with_genres') final String? withGenres,
    @JsonKey(name: 'primary_release_year') final int? primaryReleaseYear,
    @JsonKey(name: 'primary_release_date.gte') final String? releaseDateGte,
    @JsonKey(name: 'primary_release_date.lte') final String? releaseDateLte,
    @JsonKey(name: 'with_origin_country') final String? withOriginCountry,
    @JsonKey(name: 'with_original_language') final String? withOriginalLanguage,
    @JsonKey(name: 'with_runtime.gte') final int? runtimeGte,
    @JsonKey(name: 'with_runtime.lte') final int? runtimeLte,
    @JsonKey(name: 'vote_average.gte') final double? voteAverageGte,
    @JsonKey(name: 'vote_count.gte') final int? voteCountGte,
  }) = _$DiscoverFiltersImpl;

  factory _DiscoverFilters.fromJson(Map<String, dynamic> json) =
      _$DiscoverFiltersImpl.fromJson;

  @override
  int get page;
  @override
  @JsonKey(name: 'sort_by')
  SortBy get sortBy;
  @override
  @JsonKey(name: 'with_genres')
  String? get withGenres;
  @override
  @JsonKey(name: 'primary_release_year')
  int? get primaryReleaseYear;
  @override
  @JsonKey(name: 'primary_release_date.gte')
  String? get releaseDateGte;
  @override
  @JsonKey(name: 'primary_release_date.lte')
  String? get releaseDateLte;
  @override
  @JsonKey(name: 'with_origin_country')
  String? get withOriginCountry;
  @override
  @JsonKey(name: 'with_original_language')
  String? get withOriginalLanguage;
  @override
  @JsonKey(name: 'with_runtime.gte')
  int? get runtimeGte;
  @override
  @JsonKey(name: 'with_runtime.lte')
  int? get runtimeLte;
  @override
  @JsonKey(name: 'vote_average.gte')
  double? get voteAverageGte;
  @override
  @JsonKey(name: 'vote_count.gte')
  int? get voteCountGte;

  /// Create a copy of DiscoverFilters
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DiscoverFiltersImplCopyWith<_$DiscoverFiltersImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
