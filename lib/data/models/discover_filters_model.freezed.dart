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
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DiscoverFilters _$DiscoverFiltersFromJson(Map<String, dynamic> json) {
  return _DiscoverFilters.fromJson(json);
}

/// @nodoc
mixin _$DiscoverFilters {
  int get page => throw _privateConstructorUsedError;
  @JsonKey(name: 'sort_by')
  SortBy get sortBy => throw _privateConstructorUsedError;
  @JsonKey(name: 'include_adult')
  bool get includeAdult => throw _privateConstructorUsedError;
  @JsonKey(name: 'certification_country')
  String? get certificationCountry => throw _privateConstructorUsedError;
  @JsonKey(name: 'certification')
  String? get certification => throw _privateConstructorUsedError;
  @JsonKey(name: 'certification.lte')
  String? get certificationLte => throw _privateConstructorUsedError;
  @JsonKey(name: 'certification.gte')
  String? get certificationGte => throw _privateConstructorUsedError;
  @JsonKey(name: 'with_genres')
  String? get withGenres => throw _privateConstructorUsedError;
  @JsonKey(name: 'primary_release_year')
  int? get primaryReleaseYear => throw _privateConstructorUsedError;
  @JsonKey(name: 'primary_release_date.gte')
  String? get primaryReleaseDateGte => throw _privateConstructorUsedError;
  @JsonKey(name: 'primary_release_date.lte')
  String? get primaryReleaseDateLte => throw _privateConstructorUsedError;
  @JsonKey(name: 'release_date.gte')
  String? get releaseDateGte => throw _privateConstructorUsedError;
  @JsonKey(name: 'release_date.lte')
  String? get releaseDateLte => throw _privateConstructorUsedError;
  @JsonKey(name: 'with_release_type')
  String? get withReleaseType => throw _privateConstructorUsedError;
  @JsonKey(name: 'with_origin_country')
  String? get withOriginCountry => throw _privateConstructorUsedError;
  @JsonKey(name: 'with_original_language')
  String? get withOriginalLanguage => throw _privateConstructorUsedError;
  @JsonKey(name: 'with_cast')
  String? get withCast => throw _privateConstructorUsedError;
  @JsonKey(name: 'with_crew')
  String? get withCrew => throw _privateConstructorUsedError;
  @JsonKey(name: 'with_companies')
  String? get withCompanies => throw _privateConstructorUsedError;
  @JsonKey(name: 'with_keywords')
  String? get withKeywords => throw _privateConstructorUsedError;
  @JsonKey(name: 'with_runtime.gte')
  int? get runtimeGte => throw _privateConstructorUsedError;
  @JsonKey(name: 'with_runtime.lte')
  int? get runtimeLte => throw _privateConstructorUsedError;
  @JsonKey(name: 'vote_average.gte')
  double? get voteAverageGte => throw _privateConstructorUsedError;
  @JsonKey(name: 'vote_average.lte')
  double? get voteAverageLte => throw _privateConstructorUsedError;
  @JsonKey(name: 'vote_count.gte')
  int? get voteCountGte => throw _privateConstructorUsedError;
  @JsonKey(name: 'vote_count.lte')
  int? get voteCountLte => throw _privateConstructorUsedError;
  @JsonKey(name: 'with_watch_providers')
  String? get withWatchProviders => throw _privateConstructorUsedError;
  @JsonKey(name: 'watch_region')
  String? get watchRegion => throw _privateConstructorUsedError;
  @JsonKey(name: 'with_watch_monetization_types')
  String? get withWatchMonetizationTypes => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DiscoverFiltersCopyWith<DiscoverFilters> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DiscoverFiltersCopyWith<$Res> {
  factory $DiscoverFiltersCopyWith(
          DiscoverFilters value, $Res Function(DiscoverFilters) then) =
      _$DiscoverFiltersCopyWithImpl<$Res, DiscoverFilters>;
  @useResult
  $Res call(
      {int page,
      @JsonKey(name: 'sort_by') SortBy sortBy,
      @JsonKey(name: 'include_adult') bool includeAdult,
      @JsonKey(name: 'certification_country') String? certificationCountry,
      @JsonKey(name: 'certification') String? certification,
      @JsonKey(name: 'certification.lte') String? certificationLte,
      @JsonKey(name: 'certification.gte') String? certificationGte,
      @JsonKey(name: 'with_genres') String? withGenres,
      @JsonKey(name: 'primary_release_year') int? primaryReleaseYear,
      @JsonKey(name: 'primary_release_date.gte') String? primaryReleaseDateGte,
      @JsonKey(name: 'primary_release_date.lte') String? primaryReleaseDateLte,
      @JsonKey(name: 'release_date.gte') String? releaseDateGte,
      @JsonKey(name: 'release_date.lte') String? releaseDateLte,
      @JsonKey(name: 'with_release_type') String? withReleaseType,
      @JsonKey(name: 'with_origin_country') String? withOriginCountry,
      @JsonKey(name: 'with_original_language') String? withOriginalLanguage,
      @JsonKey(name: 'with_cast') String? withCast,
      @JsonKey(name: 'with_crew') String? withCrew,
      @JsonKey(name: 'with_companies') String? withCompanies,
      @JsonKey(name: 'with_keywords') String? withKeywords,
      @JsonKey(name: 'with_runtime.gte') int? runtimeGte,
      @JsonKey(name: 'with_runtime.lte') int? runtimeLte,
      @JsonKey(name: 'vote_average.gte') double? voteAverageGte,
      @JsonKey(name: 'vote_average.lte') double? voteAverageLte,
      @JsonKey(name: 'vote_count.gte') int? voteCountGte,
      @JsonKey(name: 'vote_count.lte') int? voteCountLte,
      @JsonKey(name: 'with_watch_providers') String? withWatchProviders,
      @JsonKey(name: 'watch_region') String? watchRegion,
      @JsonKey(name: 'with_watch_monetization_types')
      String? withWatchMonetizationTypes});
}

/// @nodoc
class _$DiscoverFiltersCopyWithImpl<$Res, $Val extends DiscoverFilters>
    implements $DiscoverFiltersCopyWith<$Res> {
  _$DiscoverFiltersCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? page = null,
    Object? sortBy = null,
    Object? includeAdult = null,
    Object? certificationCountry = freezed,
    Object? certification = freezed,
    Object? certificationLte = freezed,
    Object? certificationGte = freezed,
    Object? withGenres = freezed,
    Object? primaryReleaseYear = freezed,
    Object? primaryReleaseDateGte = freezed,
    Object? primaryReleaseDateLte = freezed,
    Object? releaseDateGte = freezed,
    Object? releaseDateLte = freezed,
    Object? withReleaseType = freezed,
    Object? withOriginCountry = freezed,
    Object? withOriginalLanguage = freezed,
    Object? withCast = freezed,
    Object? withCrew = freezed,
    Object? withCompanies = freezed,
    Object? withKeywords = freezed,
    Object? runtimeGte = freezed,
    Object? runtimeLte = freezed,
    Object? voteAverageGte = freezed,
    Object? voteAverageLte = freezed,
    Object? voteCountGte = freezed,
    Object? voteCountLte = freezed,
    Object? withWatchProviders = freezed,
    Object? watchRegion = freezed,
    Object? withWatchMonetizationTypes = freezed,
  }) {
    return _then(_value.copyWith(
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      sortBy: null == sortBy
          ? _value.sortBy
          : sortBy // ignore: cast_nullable_to_non_nullable
              as SortBy,
      includeAdult: null == includeAdult
          ? _value.includeAdult
          : includeAdult // ignore: cast_nullable_to_non_nullable
              as bool,
      certificationCountry: freezed == certificationCountry
          ? _value.certificationCountry
          : certificationCountry // ignore: cast_nullable_to_non_nullable
              as String?,
      certification: freezed == certification
          ? _value.certification
          : certification // ignore: cast_nullable_to_non_nullable
              as String?,
      certificationLte: freezed == certificationLte
          ? _value.certificationLte
          : certificationLte // ignore: cast_nullable_to_non_nullable
              as String?,
      certificationGte: freezed == certificationGte
          ? _value.certificationGte
          : certificationGte // ignore: cast_nullable_to_non_nullable
              as String?,
      withGenres: freezed == withGenres
          ? _value.withGenres
          : withGenres // ignore: cast_nullable_to_non_nullable
              as String?,
      primaryReleaseYear: freezed == primaryReleaseYear
          ? _value.primaryReleaseYear
          : primaryReleaseYear // ignore: cast_nullable_to_non_nullable
              as int?,
      primaryReleaseDateGte: freezed == primaryReleaseDateGte
          ? _value.primaryReleaseDateGte
          : primaryReleaseDateGte // ignore: cast_nullable_to_non_nullable
              as String?,
      primaryReleaseDateLte: freezed == primaryReleaseDateLte
          ? _value.primaryReleaseDateLte
          : primaryReleaseDateLte // ignore: cast_nullable_to_non_nullable
              as String?,
      releaseDateGte: freezed == releaseDateGte
          ? _value.releaseDateGte
          : releaseDateGte // ignore: cast_nullable_to_non_nullable
              as String?,
      releaseDateLte: freezed == releaseDateLte
          ? _value.releaseDateLte
          : releaseDateLte // ignore: cast_nullable_to_non_nullable
              as String?,
      withReleaseType: freezed == withReleaseType
          ? _value.withReleaseType
          : withReleaseType // ignore: cast_nullable_to_non_nullable
              as String?,
      withOriginCountry: freezed == withOriginCountry
          ? _value.withOriginCountry
          : withOriginCountry // ignore: cast_nullable_to_non_nullable
              as String?,
      withOriginalLanguage: freezed == withOriginalLanguage
          ? _value.withOriginalLanguage
          : withOriginalLanguage // ignore: cast_nullable_to_non_nullable
              as String?,
      withCast: freezed == withCast
          ? _value.withCast
          : withCast // ignore: cast_nullable_to_non_nullable
              as String?,
      withCrew: freezed == withCrew
          ? _value.withCrew
          : withCrew // ignore: cast_nullable_to_non_nullable
              as String?,
      withCompanies: freezed == withCompanies
          ? _value.withCompanies
          : withCompanies // ignore: cast_nullable_to_non_nullable
              as String?,
      withKeywords: freezed == withKeywords
          ? _value.withKeywords
          : withKeywords // ignore: cast_nullable_to_non_nullable
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
      voteAverageLte: freezed == voteAverageLte
          ? _value.voteAverageLte
          : voteAverageLte // ignore: cast_nullable_to_non_nullable
              as double?,
      voteCountGte: freezed == voteCountGte
          ? _value.voteCountGte
          : voteCountGte // ignore: cast_nullable_to_non_nullable
              as int?,
      voteCountLte: freezed == voteCountLte
          ? _value.voteCountLte
          : voteCountLte // ignore: cast_nullable_to_non_nullable
              as int?,
      withWatchProviders: freezed == withWatchProviders
          ? _value.withWatchProviders
          : withWatchProviders // ignore: cast_nullable_to_non_nullable
              as String?,
      watchRegion: freezed == watchRegion
          ? _value.watchRegion
          : watchRegion // ignore: cast_nullable_to_non_nullable
              as String?,
      withWatchMonetizationTypes: freezed == withWatchMonetizationTypes
          ? _value.withWatchMonetizationTypes
          : withWatchMonetizationTypes // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DiscoverFiltersImplCopyWith<$Res>
    implements $DiscoverFiltersCopyWith<$Res> {
  factory _$$DiscoverFiltersImplCopyWith(_$DiscoverFiltersImpl value,
          $Res Function(_$DiscoverFiltersImpl) then) =
      __$$DiscoverFiltersImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int page,
      @JsonKey(name: 'sort_by') SortBy sortBy,
      @JsonKey(name: 'include_adult') bool includeAdult,
      @JsonKey(name: 'certification_country') String? certificationCountry,
      @JsonKey(name: 'certification') String? certification,
      @JsonKey(name: 'certification.lte') String? certificationLte,
      @JsonKey(name: 'certification.gte') String? certificationGte,
      @JsonKey(name: 'with_genres') String? withGenres,
      @JsonKey(name: 'primary_release_year') int? primaryReleaseYear,
      @JsonKey(name: 'primary_release_date.gte') String? primaryReleaseDateGte,
      @JsonKey(name: 'primary_release_date.lte') String? primaryReleaseDateLte,
      @JsonKey(name: 'release_date.gte') String? releaseDateGte,
      @JsonKey(name: 'release_date.lte') String? releaseDateLte,
      @JsonKey(name: 'with_release_type') String? withReleaseType,
      @JsonKey(name: 'with_origin_country') String? withOriginCountry,
      @JsonKey(name: 'with_original_language') String? withOriginalLanguage,
      @JsonKey(name: 'with_cast') String? withCast,
      @JsonKey(name: 'with_crew') String? withCrew,
      @JsonKey(name: 'with_companies') String? withCompanies,
      @JsonKey(name: 'with_keywords') String? withKeywords,
      @JsonKey(name: 'with_runtime.gte') int? runtimeGte,
      @JsonKey(name: 'with_runtime.lte') int? runtimeLte,
      @JsonKey(name: 'vote_average.gte') double? voteAverageGte,
      @JsonKey(name: 'vote_average.lte') double? voteAverageLte,
      @JsonKey(name: 'vote_count.gte') int? voteCountGte,
      @JsonKey(name: 'vote_count.lte') int? voteCountLte,
      @JsonKey(name: 'with_watch_providers') String? withWatchProviders,
      @JsonKey(name: 'watch_region') String? watchRegion,
      @JsonKey(name: 'with_watch_monetization_types')
      String? withWatchMonetizationTypes});
}

/// @nodoc
class __$$DiscoverFiltersImplCopyWithImpl<$Res>
    extends _$DiscoverFiltersCopyWithImpl<$Res, _$DiscoverFiltersImpl>
    implements _$$DiscoverFiltersImplCopyWith<$Res> {
  __$$DiscoverFiltersImplCopyWithImpl(
      _$DiscoverFiltersImpl _value, $Res Function(_$DiscoverFiltersImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? page = null,
    Object? sortBy = null,
    Object? includeAdult = null,
    Object? certificationCountry = freezed,
    Object? certification = freezed,
    Object? certificationLte = freezed,
    Object? certificationGte = freezed,
    Object? withGenres = freezed,
    Object? primaryReleaseYear = freezed,
    Object? primaryReleaseDateGte = freezed,
    Object? primaryReleaseDateLte = freezed,
    Object? releaseDateGte = freezed,
    Object? releaseDateLte = freezed,
    Object? withReleaseType = freezed,
    Object? withOriginCountry = freezed,
    Object? withOriginalLanguage = freezed,
    Object? withCast = freezed,
    Object? withCrew = freezed,
    Object? withCompanies = freezed,
    Object? withKeywords = freezed,
    Object? runtimeGte = freezed,
    Object? runtimeLte = freezed,
    Object? voteAverageGte = freezed,
    Object? voteAverageLte = freezed,
    Object? voteCountGte = freezed,
    Object? voteCountLte = freezed,
    Object? withWatchProviders = freezed,
    Object? watchRegion = freezed,
    Object? withWatchMonetizationTypes = freezed,
  }) {
    return _then(_$DiscoverFiltersImpl(
      page: null == page
          ? _value.page
          : page // ignore: cast_nullable_to_non_nullable
              as int,
      sortBy: null == sortBy
          ? _value.sortBy
          : sortBy // ignore: cast_nullable_to_non_nullable
              as SortBy,
      includeAdult: null == includeAdult
          ? _value.includeAdult
          : includeAdult // ignore: cast_nullable_to_non_nullable
              as bool,
      certificationCountry: freezed == certificationCountry
          ? _value.certificationCountry
          : certificationCountry // ignore: cast_nullable_to_non_nullable
              as String?,
      certification: freezed == certification
          ? _value.certification
          : certification // ignore: cast_nullable_to_non_nullable
              as String?,
      certificationLte: freezed == certificationLte
          ? _value.certificationLte
          : certificationLte // ignore: cast_nullable_to_non_nullable
              as String?,
      certificationGte: freezed == certificationGte
          ? _value.certificationGte
          : certificationGte // ignore: cast_nullable_to_non_nullable
              as String?,
      withGenres: freezed == withGenres
          ? _value.withGenres
          : withGenres // ignore: cast_nullable_to_non_nullable
              as String?,
      primaryReleaseYear: freezed == primaryReleaseYear
          ? _value.primaryReleaseYear
          : primaryReleaseYear // ignore: cast_nullable_to_non_nullable
              as int?,
      primaryReleaseDateGte: freezed == primaryReleaseDateGte
          ? _value.primaryReleaseDateGte
          : primaryReleaseDateGte // ignore: cast_nullable_to_non_nullable
              as String?,
      primaryReleaseDateLte: freezed == primaryReleaseDateLte
          ? _value.primaryReleaseDateLte
          : primaryReleaseDateLte // ignore: cast_nullable_to_non_nullable
              as String?,
      releaseDateGte: freezed == releaseDateGte
          ? _value.releaseDateGte
          : releaseDateGte // ignore: cast_nullable_to_non_nullable
              as String?,
      releaseDateLte: freezed == releaseDateLte
          ? _value.releaseDateLte
          : releaseDateLte // ignore: cast_nullable_to_non_nullable
              as String?,
      withReleaseType: freezed == withReleaseType
          ? _value.withReleaseType
          : withReleaseType // ignore: cast_nullable_to_non_nullable
              as String?,
      withOriginCountry: freezed == withOriginCountry
          ? _value.withOriginCountry
          : withOriginCountry // ignore: cast_nullable_to_non_nullable
              as String?,
      withOriginalLanguage: freezed == withOriginalLanguage
          ? _value.withOriginalLanguage
          : withOriginalLanguage // ignore: cast_nullable_to_non_nullable
              as String?,
      withCast: freezed == withCast
          ? _value.withCast
          : withCast // ignore: cast_nullable_to_non_nullable
              as String?,
      withCrew: freezed == withCrew
          ? _value.withCrew
          : withCrew // ignore: cast_nullable_to_non_nullable
              as String?,
      withCompanies: freezed == withCompanies
          ? _value.withCompanies
          : withCompanies // ignore: cast_nullable_to_non_nullable
              as String?,
      withKeywords: freezed == withKeywords
          ? _value.withKeywords
          : withKeywords // ignore: cast_nullable_to_non_nullable
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
      voteAverageLte: freezed == voteAverageLte
          ? _value.voteAverageLte
          : voteAverageLte // ignore: cast_nullable_to_non_nullable
              as double?,
      voteCountGte: freezed == voteCountGte
          ? _value.voteCountGte
          : voteCountGte // ignore: cast_nullable_to_non_nullable
              as int?,
      voteCountLte: freezed == voteCountLte
          ? _value.voteCountLte
          : voteCountLte // ignore: cast_nullable_to_non_nullable
              as int?,
      withWatchProviders: freezed == withWatchProviders
          ? _value.withWatchProviders
          : withWatchProviders // ignore: cast_nullable_to_non_nullable
              as String?,
      watchRegion: freezed == watchRegion
          ? _value.watchRegion
          : watchRegion // ignore: cast_nullable_to_non_nullable
              as String?,
      withWatchMonetizationTypes: freezed == withWatchMonetizationTypes
          ? _value.withWatchMonetizationTypes
          : withWatchMonetizationTypes // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DiscoverFiltersImpl implements _DiscoverFilters {
  const _$DiscoverFiltersImpl(
      {this.page = 1,
      @JsonKey(name: 'sort_by') this.sortBy = SortBy.popularityDesc,
      @JsonKey(name: 'include_adult') this.includeAdult = false,
      @JsonKey(name: 'certification_country') this.certificationCountry,
      @JsonKey(name: 'certification') this.certification,
      @JsonKey(name: 'certification.lte') this.certificationLte,
      @JsonKey(name: 'certification.gte') this.certificationGte,
      @JsonKey(name: 'with_genres') this.withGenres,
      @JsonKey(name: 'primary_release_year') this.primaryReleaseYear,
      @JsonKey(name: 'primary_release_date.gte') this.primaryReleaseDateGte,
      @JsonKey(name: 'primary_release_date.lte') this.primaryReleaseDateLte,
      @JsonKey(name: 'release_date.gte') this.releaseDateGte,
      @JsonKey(name: 'release_date.lte') this.releaseDateLte,
      @JsonKey(name: 'with_release_type') this.withReleaseType,
      @JsonKey(name: 'with_origin_country') this.withOriginCountry,
      @JsonKey(name: 'with_original_language') this.withOriginalLanguage,
      @JsonKey(name: 'with_cast') this.withCast,
      @JsonKey(name: 'with_crew') this.withCrew,
      @JsonKey(name: 'with_companies') this.withCompanies,
      @JsonKey(name: 'with_keywords') this.withKeywords,
      @JsonKey(name: 'with_runtime.gte') this.runtimeGte,
      @JsonKey(name: 'with_runtime.lte') this.runtimeLte,
      @JsonKey(name: 'vote_average.gte') this.voteAverageGte,
      @JsonKey(name: 'vote_average.lte') this.voteAverageLte,
      @JsonKey(name: 'vote_count.gte') this.voteCountGte,
      @JsonKey(name: 'vote_count.lte') this.voteCountLte,
      @JsonKey(name: 'with_watch_providers') this.withWatchProviders,
      @JsonKey(name: 'watch_region') this.watchRegion,
      @JsonKey(name: 'with_watch_monetization_types')
      this.withWatchMonetizationTypes});

  factory _$DiscoverFiltersImpl.fromJson(Map<String, dynamic> json) =>
      _$$DiscoverFiltersImplFromJson(json);

  @override
  @JsonKey()
  final int page;
  @override
  @JsonKey(name: 'sort_by')
  final SortBy sortBy;
  @override
  @JsonKey(name: 'include_adult')
  final bool includeAdult;
  @override
  @JsonKey(name: 'certification_country')
  final String? certificationCountry;
  @override
  @JsonKey(name: 'certification')
  final String? certification;
  @override
  @JsonKey(name: 'certification.lte')
  final String? certificationLte;
  @override
  @JsonKey(name: 'certification.gte')
  final String? certificationGte;
  @override
  @JsonKey(name: 'with_genres')
  final String? withGenres;
  @override
  @JsonKey(name: 'primary_release_year')
  final int? primaryReleaseYear;
  @override
  @JsonKey(name: 'primary_release_date.gte')
  final String? primaryReleaseDateGte;
  @override
  @JsonKey(name: 'primary_release_date.lte')
  final String? primaryReleaseDateLte;
  @override
  @JsonKey(name: 'release_date.gte')
  final String? releaseDateGte;
  @override
  @JsonKey(name: 'release_date.lte')
  final String? releaseDateLte;
  @override
  @JsonKey(name: 'with_release_type')
  final String? withReleaseType;
  @override
  @JsonKey(name: 'with_origin_country')
  final String? withOriginCountry;
  @override
  @JsonKey(name: 'with_original_language')
  final String? withOriginalLanguage;
  @override
  @JsonKey(name: 'with_cast')
  final String? withCast;
  @override
  @JsonKey(name: 'with_crew')
  final String? withCrew;
  @override
  @JsonKey(name: 'with_companies')
  final String? withCompanies;
  @override
  @JsonKey(name: 'with_keywords')
  final String? withKeywords;
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
  @JsonKey(name: 'vote_average.lte')
  final double? voteAverageLte;
  @override
  @JsonKey(name: 'vote_count.gte')
  final int? voteCountGte;
  @override
  @JsonKey(name: 'vote_count.lte')
  final int? voteCountLte;
  @override
  @JsonKey(name: 'with_watch_providers')
  final String? withWatchProviders;
  @override
  @JsonKey(name: 'watch_region')
  final String? watchRegion;
  @override
  @JsonKey(name: 'with_watch_monetization_types')
  final String? withWatchMonetizationTypes;

  @override
  String toString() {
    return 'DiscoverFilters(page: $page, sortBy: $sortBy, includeAdult: $includeAdult, certificationCountry: $certificationCountry, certification: $certification, certificationLte: $certificationLte, certificationGte: $certificationGte, withGenres: $withGenres, primaryReleaseYear: $primaryReleaseYear, primaryReleaseDateGte: $primaryReleaseDateGte, primaryReleaseDateLte: $primaryReleaseDateLte, releaseDateGte: $releaseDateGte, releaseDateLte: $releaseDateLte, withReleaseType: $withReleaseType, withOriginCountry: $withOriginCountry, withOriginalLanguage: $withOriginalLanguage, withCast: $withCast, withCrew: $withCrew, withCompanies: $withCompanies, withKeywords: $withKeywords, runtimeGte: $runtimeGte, runtimeLte: $runtimeLte, voteAverageGte: $voteAverageGte, voteAverageLte: $voteAverageLte, voteCountGte: $voteCountGte, voteCountLte: $voteCountLte, withWatchProviders: $withWatchProviders, watchRegion: $watchRegion, withWatchMonetizationTypes: $withWatchMonetizationTypes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DiscoverFiltersImpl &&
            (identical(other.page, page) || other.page == page) &&
            (identical(other.sortBy, sortBy) || other.sortBy == sortBy) &&
            (identical(other.includeAdult, includeAdult) ||
                other.includeAdult == includeAdult) &&
            (identical(other.certificationCountry, certificationCountry) ||
                other.certificationCountry == certificationCountry) &&
            (identical(other.certification, certification) ||
                other.certification == certification) &&
            (identical(other.certificationLte, certificationLte) ||
                other.certificationLte == certificationLte) &&
            (identical(other.certificationGte, certificationGte) ||
                other.certificationGte == certificationGte) &&
            (identical(other.withGenres, withGenres) ||
                other.withGenres == withGenres) &&
            (identical(other.primaryReleaseYear, primaryReleaseYear) ||
                other.primaryReleaseYear == primaryReleaseYear) &&
            (identical(other.primaryReleaseDateGte, primaryReleaseDateGte) ||
                other.primaryReleaseDateGte == primaryReleaseDateGte) &&
            (identical(other.primaryReleaseDateLte, primaryReleaseDateLte) ||
                other.primaryReleaseDateLte == primaryReleaseDateLte) &&
            (identical(other.releaseDateGte, releaseDateGte) ||
                other.releaseDateGte == releaseDateGte) &&
            (identical(other.releaseDateLte, releaseDateLte) ||
                other.releaseDateLte == releaseDateLte) &&
            (identical(other.withReleaseType, withReleaseType) ||
                other.withReleaseType == withReleaseType) &&
            (identical(other.withOriginCountry, withOriginCountry) ||
                other.withOriginCountry == withOriginCountry) &&
            (identical(other.withOriginalLanguage, withOriginalLanguage) ||
                other.withOriginalLanguage == withOriginalLanguage) &&
            (identical(other.withCast, withCast) ||
                other.withCast == withCast) &&
            (identical(other.withCrew, withCrew) ||
                other.withCrew == withCrew) &&
            (identical(other.withCompanies, withCompanies) ||
                other.withCompanies == withCompanies) &&
            (identical(other.withKeywords, withKeywords) ||
                other.withKeywords == withKeywords) &&
            (identical(other.runtimeGte, runtimeGte) ||
                other.runtimeGte == runtimeGte) &&
            (identical(other.runtimeLte, runtimeLte) ||
                other.runtimeLte == runtimeLte) &&
            (identical(other.voteAverageGte, voteAverageGte) ||
                other.voteAverageGte == voteAverageGte) &&
            (identical(other.voteAverageLte, voteAverageLte) ||
                other.voteAverageLte == voteAverageLte) &&
            (identical(other.voteCountGte, voteCountGte) ||
                other.voteCountGte == voteCountGte) &&
            (identical(other.voteCountLte, voteCountLte) ||
                other.voteCountLte == voteCountLte) &&
            (identical(other.withWatchProviders, withWatchProviders) ||
                other.withWatchProviders == withWatchProviders) &&
            (identical(other.watchRegion, watchRegion) ||
                other.watchRegion == watchRegion) &&
            (identical(other.withWatchMonetizationTypes,
                    withWatchMonetizationTypes) ||
                other.withWatchMonetizationTypes ==
                    withWatchMonetizationTypes));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        page,
        sortBy,
        includeAdult,
        certificationCountry,
        certification,
        certificationLte,
        certificationGte,
        withGenres,
        primaryReleaseYear,
        primaryReleaseDateGte,
        primaryReleaseDateLte,
        releaseDateGte,
        releaseDateLte,
        withReleaseType,
        withOriginCountry,
        withOriginalLanguage,
        withCast,
        withCrew,
        withCompanies,
        withKeywords,
        runtimeGte,
        runtimeLte,
        voteAverageGte,
        voteAverageLte,
        voteCountGte,
        voteCountLte,
        withWatchProviders,
        watchRegion,
        withWatchMonetizationTypes
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DiscoverFiltersImplCopyWith<_$DiscoverFiltersImpl> get copyWith =>
      __$$DiscoverFiltersImplCopyWithImpl<_$DiscoverFiltersImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DiscoverFiltersImplToJson(
      this,
    );
  }
}

abstract class _DiscoverFilters implements DiscoverFilters {
  const factory _DiscoverFilters(
      {final int page,
      @JsonKey(name: 'sort_by') final SortBy sortBy,
      @JsonKey(name: 'include_adult') final bool includeAdult,
      @JsonKey(name: 'certification_country')
      final String? certificationCountry,
      @JsonKey(name: 'certification') final String? certification,
      @JsonKey(name: 'certification.lte') final String? certificationLte,
      @JsonKey(name: 'certification.gte') final String? certificationGte,
      @JsonKey(name: 'with_genres') final String? withGenres,
      @JsonKey(name: 'primary_release_year') final int? primaryReleaseYear,
      @JsonKey(name: 'primary_release_date.gte')
      final String? primaryReleaseDateGte,
      @JsonKey(name: 'primary_release_date.lte')
      final String? primaryReleaseDateLte,
      @JsonKey(name: 'release_date.gte') final String? releaseDateGte,
      @JsonKey(name: 'release_date.lte') final String? releaseDateLte,
      @JsonKey(name: 'with_release_type') final String? withReleaseType,
      @JsonKey(name: 'with_origin_country') final String? withOriginCountry,
      @JsonKey(name: 'with_original_language')
      final String? withOriginalLanguage,
      @JsonKey(name: 'with_cast') final String? withCast,
      @JsonKey(name: 'with_crew') final String? withCrew,
      @JsonKey(name: 'with_companies') final String? withCompanies,
      @JsonKey(name: 'with_keywords') final String? withKeywords,
      @JsonKey(name: 'with_runtime.gte') final int? runtimeGte,
      @JsonKey(name: 'with_runtime.lte') final int? runtimeLte,
      @JsonKey(name: 'vote_average.gte') final double? voteAverageGte,
      @JsonKey(name: 'vote_average.lte') final double? voteAverageLte,
      @JsonKey(name: 'vote_count.gte') final int? voteCountGte,
      @JsonKey(name: 'vote_count.lte') final int? voteCountLte,
      @JsonKey(name: 'with_watch_providers') final String? withWatchProviders,
      @JsonKey(name: 'watch_region') final String? watchRegion,
      @JsonKey(name: 'with_watch_monetization_types')
      final String? withWatchMonetizationTypes}) = _$DiscoverFiltersImpl;

  factory _DiscoverFilters.fromJson(Map<String, dynamic> json) =
      _$DiscoverFiltersImpl.fromJson;

  @override
  int get page;
  @override
  @JsonKey(name: 'sort_by')
  SortBy get sortBy;
  @override
  @JsonKey(name: 'include_adult')
  bool get includeAdult;
  @override
  @JsonKey(name: 'certification_country')
  String? get certificationCountry;
  @override
  @JsonKey(name: 'certification')
  String? get certification;
  @override
  @JsonKey(name: 'certification.lte')
  String? get certificationLte;
  @override
  @JsonKey(name: 'certification.gte')
  String? get certificationGte;
  @override
  @JsonKey(name: 'with_genres')
  String? get withGenres;
  @override
  @JsonKey(name: 'primary_release_year')
  int? get primaryReleaseYear;
  @override
  @JsonKey(name: 'primary_release_date.gte')
  String? get primaryReleaseDateGte;
  @override
  @JsonKey(name: 'primary_release_date.lte')
  String? get primaryReleaseDateLte;
  @override
  @JsonKey(name: 'release_date.gte')
  String? get releaseDateGte;
  @override
  @JsonKey(name: 'release_date.lte')
  String? get releaseDateLte;
  @override
  @JsonKey(name: 'with_release_type')
  String? get withReleaseType;
  @override
  @JsonKey(name: 'with_origin_country')
  String? get withOriginCountry;
  @override
  @JsonKey(name: 'with_original_language')
  String? get withOriginalLanguage;
  @override
  @JsonKey(name: 'with_cast')
  String? get withCast;
  @override
  @JsonKey(name: 'with_crew')
  String? get withCrew;
  @override
  @JsonKey(name: 'with_companies')
  String? get withCompanies;
  @override
  @JsonKey(name: 'with_keywords')
  String? get withKeywords;
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
  @JsonKey(name: 'vote_average.lte')
  double? get voteAverageLte;
  @override
  @JsonKey(name: 'vote_count.gte')
  int? get voteCountGte;
  @override
  @JsonKey(name: 'vote_count.lte')
  int? get voteCountLte;
  @override
  @JsonKey(name: 'with_watch_providers')
  String? get withWatchProviders;
  @override
  @JsonKey(name: 'watch_region')
  String? get watchRegion;
  @override
  @JsonKey(name: 'with_watch_monetization_types')
  String? get withWatchMonetizationTypes;
  @override
  @JsonKey(ignore: true)
  _$$DiscoverFiltersImplCopyWith<_$DiscoverFiltersImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
