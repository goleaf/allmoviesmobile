// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'movie_detailed_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

MovieDetailed _$MovieDetailedFromJson(Map<String, dynamic> json) {
  return _MovieDetailed.fromJson(json);
}

/// @nodoc
mixin _$MovieDetailed {
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  @JsonKey(name: 'original_title')
  String get originalTitle => throw _privateConstructorUsedError;
  @JsonKey(name: 'vote_average')
  double get voteAverage => throw _privateConstructorUsedError;
  @JsonKey(name: 'vote_count')
  int get voteCount => throw _privateConstructorUsedError;
  String? get overview => throw _privateConstructorUsedError;
  String? get tagline => throw _privateConstructorUsedError;
  @JsonKey(name: 'release_date')
  String? get releaseDate => throw _privateConstructorUsedError;
  int? get runtime => throw _privateConstructorUsedError;
  List<Genre> get genres => throw _privateConstructorUsedError;
  @JsonKey(name: 'production_companies')
  List<Company> get productionCompanies => throw _privateConstructorUsedError;
  @JsonKey(name: 'production_countries')
  List<Country> get productionCountries => throw _privateConstructorUsedError;
  @JsonKey(name: 'spoken_languages')
  List<Language> get spokenLanguages => throw _privateConstructorUsedError;
  @JsonKey(name: 'poster_path')
  String? get posterPath => throw _privateConstructorUsedError;
  @JsonKey(name: 'backdrop_path')
  String? get backdropPath => throw _privateConstructorUsedError;
  double? get popularity => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;
  String? get homepage => throw _privateConstructorUsedError;
  @JsonKey(name: 'external_ids')
  ExternalIds get externalIds => throw _privateConstructorUsedError;
  int? get budget => throw _privateConstructorUsedError;
  int? get revenue => throw _privateConstructorUsedError;
  List<Video> get videos => throw _privateConstructorUsedError;
  List<ImageModel> get images => throw _privateConstructorUsedError;
  List<MovieRef> get recommendations => throw _privateConstructorUsedError;
  List<MovieRef> get similar => throw _privateConstructorUsedError;
  List<Cast> get cast => throw _privateConstructorUsedError;
  List<Crew> get crew => throw _privateConstructorUsedError;

  /// Serializes this MovieDetailed to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MovieDetailed
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MovieDetailedCopyWith<MovieDetailed> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MovieDetailedCopyWith<$Res> {
  factory $MovieDetailedCopyWith(
    MovieDetailed value,
    $Res Function(MovieDetailed) then,
  ) = _$MovieDetailedCopyWithImpl<$Res, MovieDetailed>;
  @useResult
  $Res call({
    int id,
    String title,
    @JsonKey(name: 'original_title') String originalTitle,
    @JsonKey(name: 'vote_average') double voteAverage,
    @JsonKey(name: 'vote_count') int voteCount,
    String? overview,
    String? tagline,
    @JsonKey(name: 'release_date') String? releaseDate,
    int? runtime,
    List<Genre> genres,
    @JsonKey(name: 'production_companies') List<Company> productionCompanies,
    @JsonKey(name: 'production_countries') List<Country> productionCountries,
    @JsonKey(name: 'spoken_languages') List<Language> spokenLanguages,
    @JsonKey(name: 'poster_path') String? posterPath,
    @JsonKey(name: 'backdrop_path') String? backdropPath,
    double? popularity,
    String? status,
    String? homepage,
    @JsonKey(name: 'external_ids') ExternalIds externalIds,
    int? budget,
    int? revenue,
    List<Video> videos,
    List<ImageModel> images,
    List<MovieRef> recommendations,
    List<MovieRef> similar,
    List<Cast> cast,
    List<Crew> crew,
  });

  $ExternalIdsCopyWith<$Res> get externalIds;
}

/// @nodoc
class _$MovieDetailedCopyWithImpl<$Res, $Val extends MovieDetailed>
    implements $MovieDetailedCopyWith<$Res> {
  _$MovieDetailedCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MovieDetailed
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? originalTitle = null,
    Object? voteAverage = null,
    Object? voteCount = null,
    Object? overview = freezed,
    Object? tagline = freezed,
    Object? releaseDate = freezed,
    Object? runtime = freezed,
    Object? genres = null,
    Object? productionCompanies = null,
    Object? productionCountries = null,
    Object? spokenLanguages = null,
    Object? posterPath = freezed,
    Object? backdropPath = freezed,
    Object? popularity = freezed,
    Object? status = freezed,
    Object? homepage = freezed,
    Object? externalIds = null,
    Object? budget = freezed,
    Object? revenue = freezed,
    Object? videos = null,
    Object? images = null,
    Object? recommendations = null,
    Object? similar = null,
    Object? cast = null,
    Object? crew = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            originalTitle: null == originalTitle
                ? _value.originalTitle
                : originalTitle // ignore: cast_nullable_to_non_nullable
                      as String,
            voteAverage: null == voteAverage
                ? _value.voteAverage
                : voteAverage // ignore: cast_nullable_to_non_nullable
                      as double,
            voteCount: null == voteCount
                ? _value.voteCount
                : voteCount // ignore: cast_nullable_to_non_nullable
                      as int,
            overview: freezed == overview
                ? _value.overview
                : overview // ignore: cast_nullable_to_non_nullable
                      as String?,
            tagline: freezed == tagline
                ? _value.tagline
                : tagline // ignore: cast_nullable_to_non_nullable
                      as String?,
            releaseDate: freezed == releaseDate
                ? _value.releaseDate
                : releaseDate // ignore: cast_nullable_to_non_nullable
                      as String?,
            runtime: freezed == runtime
                ? _value.runtime
                : runtime // ignore: cast_nullable_to_non_nullable
                      as int?,
            genres: null == genres
                ? _value.genres
                : genres // ignore: cast_nullable_to_non_nullable
                      as List<Genre>,
            productionCompanies: null == productionCompanies
                ? _value.productionCompanies
                : productionCompanies // ignore: cast_nullable_to_non_nullable
                      as List<Company>,
            productionCountries: null == productionCountries
                ? _value.productionCountries
                : productionCountries // ignore: cast_nullable_to_non_nullable
                      as List<Country>,
            spokenLanguages: null == spokenLanguages
                ? _value.spokenLanguages
                : spokenLanguages // ignore: cast_nullable_to_non_nullable
                      as List<Language>,
            posterPath: freezed == posterPath
                ? _value.posterPath
                : posterPath // ignore: cast_nullable_to_non_nullable
                      as String?,
            backdropPath: freezed == backdropPath
                ? _value.backdropPath
                : backdropPath // ignore: cast_nullable_to_non_nullable
                      as String?,
            popularity: freezed == popularity
                ? _value.popularity
                : popularity // ignore: cast_nullable_to_non_nullable
                      as double?,
            status: freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String?,
            homepage: freezed == homepage
                ? _value.homepage
                : homepage // ignore: cast_nullable_to_non_nullable
                      as String?,
            externalIds: null == externalIds
                ? _value.externalIds
                : externalIds // ignore: cast_nullable_to_non_nullable
                      as ExternalIds,
            budget: freezed == budget
                ? _value.budget
                : budget // ignore: cast_nullable_to_non_nullable
                      as int?,
            revenue: freezed == revenue
                ? _value.revenue
                : revenue // ignore: cast_nullable_to_non_nullable
                      as int?,
            videos: null == videos
                ? _value.videos
                : videos // ignore: cast_nullable_to_non_nullable
                      as List<Video>,
            images: null == images
                ? _value.images
                : images // ignore: cast_nullable_to_non_nullable
                      as List<ImageModel>,
            recommendations: null == recommendations
                ? _value.recommendations
                : recommendations // ignore: cast_nullable_to_non_nullable
                      as List<MovieRef>,
            similar: null == similar
                ? _value.similar
                : similar // ignore: cast_nullable_to_non_nullable
                      as List<MovieRef>,
          )
          as $Val,
    );
  }

  /// Create a copy of MovieDetailed
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ExternalIdsCopyWith<$Res> get externalIds {
    return $ExternalIdsCopyWith<$Res>(_value.externalIds, (value) {
      return _then(_value.copyWith(externalIds: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MovieDetailedImplCopyWith<$Res>
    implements $MovieDetailedCopyWith<$Res> {
  factory _$$MovieDetailedImplCopyWith(
    _$MovieDetailedImpl value,
    $Res Function(_$MovieDetailedImpl) then,
  ) = __$$MovieDetailedImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String title,
    @JsonKey(name: 'original_title') String originalTitle,
    @JsonKey(name: 'vote_average') double voteAverage,
    @JsonKey(name: 'vote_count') int voteCount,
    String? overview,
    String? tagline,
    @JsonKey(name: 'release_date') String? releaseDate,
    int? runtime,
    List<Genre> genres,
    @JsonKey(name: 'production_companies') List<Company> productionCompanies,
    @JsonKey(name: 'production_countries') List<Country> productionCountries,
    @JsonKey(name: 'spoken_languages') List<Language> spokenLanguages,
    @JsonKey(name: 'poster_path') String? posterPath,
    @JsonKey(name: 'backdrop_path') String? backdropPath,
    double? popularity,
    String? status,
    String? homepage,
    @JsonKey(name: 'external_ids') ExternalIds externalIds,
    int? budget,
    int? revenue,
    List<Video> videos,
    List<ImageModel> images,
    List<MovieRef> recommendations,
    List<MovieRef> similar,
    List<Cast> cast,
    List<Crew> crew,
  });

  @override
  $ExternalIdsCopyWith<$Res> get externalIds;
}

/// @nodoc
class __$$MovieDetailedImplCopyWithImpl<$Res>
    extends _$MovieDetailedCopyWithImpl<$Res, _$MovieDetailedImpl>
    implements _$$MovieDetailedImplCopyWith<$Res> {
  __$$MovieDetailedImplCopyWithImpl(
    _$MovieDetailedImpl _value,
    $Res Function(_$MovieDetailedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MovieDetailed
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? originalTitle = null,
    Object? voteAverage = null,
    Object? voteCount = null,
    Object? overview = freezed,
    Object? tagline = freezed,
    Object? releaseDate = freezed,
    Object? runtime = freezed,
    Object? genres = null,
    Object? productionCompanies = null,
    Object? productionCountries = null,
    Object? spokenLanguages = null,
    Object? posterPath = freezed,
    Object? backdropPath = freezed,
    Object? popularity = freezed,
    Object? status = freezed,
    Object? homepage = freezed,
    Object? externalIds = null,
    Object? budget = freezed,
    Object? revenue = freezed,
    Object? videos = null,
    Object? images = null,
    Object? recommendations = null,
    Object? similar = null,
    Object? cast = null,
    Object? crew = null,
  }) {
    return _then(
      _$MovieDetailedImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        originalTitle: null == originalTitle
            ? _value.originalTitle
            : originalTitle // ignore: cast_nullable_to_non_nullable
                  as String,
        voteAverage: null == voteAverage
            ? _value.voteAverage
            : voteAverage // ignore: cast_nullable_to_non_nullable
                  as double,
        voteCount: null == voteCount
            ? _value.voteCount
            : voteCount // ignore: cast_nullable_to_non_nullable
                  as int,
        overview: freezed == overview
            ? _value.overview
            : overview // ignore: cast_nullable_to_non_nullable
                  as String?,
        tagline: freezed == tagline
            ? _value.tagline
            : tagline // ignore: cast_nullable_to_non_nullable
                  as String?,
        releaseDate: freezed == releaseDate
            ? _value.releaseDate
            : releaseDate // ignore: cast_nullable_to_non_nullable
                  as String?,
        runtime: freezed == runtime
            ? _value.runtime
            : runtime // ignore: cast_nullable_to_non_nullable
                  as int?,
        genres: null == genres
            ? _value._genres
            : genres // ignore: cast_nullable_to_non_nullable
                  as List<Genre>,
        productionCompanies: null == productionCompanies
            ? _value._productionCompanies
            : productionCompanies // ignore: cast_nullable_to_non_nullable
                  as List<Company>,
        productionCountries: null == productionCountries
            ? _value._productionCountries
            : productionCountries // ignore: cast_nullable_to_non_nullable
                  as List<Country>,
        spokenLanguages: null == spokenLanguages
            ? _value._spokenLanguages
            : spokenLanguages // ignore: cast_nullable_to_non_nullable
                  as List<Language>,
        posterPath: freezed == posterPath
            ? _value.posterPath
            : posterPath // ignore: cast_nullable_to_non_nullable
                  as String?,
        backdropPath: freezed == backdropPath
            ? _value.backdropPath
            : backdropPath // ignore: cast_nullable_to_non_nullable
                  as String?,
        popularity: freezed == popularity
            ? _value.popularity
            : popularity // ignore: cast_nullable_to_non_nullable
                  as double?,
        status: freezed == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String?,
        homepage: freezed == homepage
            ? _value.homepage
            : homepage // ignore: cast_nullable_to_non_nullable
                  as String?,
        externalIds: null == externalIds
            ? _value.externalIds
            : externalIds // ignore: cast_nullable_to_non_nullable
                  as ExternalIds,
        budget: freezed == budget
            ? _value.budget
            : budget // ignore: cast_nullable_to_non_nullable
                  as int?,
        revenue: freezed == revenue
            ? _value.revenue
            : revenue // ignore: cast_nullable_to_non_nullable
                  as int?,
        videos: null == videos
            ? _value._videos
            : videos // ignore: cast_nullable_to_non_nullable
                  as List<Video>,
        images: null == images
            ? _value._images
            : images // ignore: cast_nullable_to_non_nullable
                  as List<ImageModel>,
        recommendations: null == recommendations
            ? _value._recommendations
            : recommendations // ignore: cast_nullable_to_non_nullable
                  as List<MovieRef>,
        similar: null == similar
            ? _value._similar
            : similar // ignore: cast_nullable_to_non_nullable
                as List<MovieRef>,
        cast: null == cast
            ? _value.cast
            : cast // ignore: cast_nullable_to_non_nullable
                as List<Cast>,
        crew: null == crew
            ? _value.crew
            : crew // ignore: cast_nullable_to_non_nullable
                as List<Crew>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MovieDetailedImpl implements _MovieDetailed {
  const _$MovieDetailedImpl({
    required this.id,
    required this.title,
    @JsonKey(name: 'original_title') required this.originalTitle,
    @JsonKey(name: 'vote_average') required this.voteAverage,
    @JsonKey(name: 'vote_count') required this.voteCount,
    this.overview,
    this.tagline,
    @JsonKey(name: 'release_date') this.releaseDate,
    this.runtime,
    final List<Genre> genres = const [],
    @JsonKey(name: 'production_companies')
    final List<Company> productionCompanies = const [],
    @JsonKey(name: 'production_countries')
    final List<Country> productionCountries = const [],
    @JsonKey(name: 'spoken_languages')
    final List<Language> spokenLanguages = const [],
    @JsonKey(name: 'poster_path') this.posterPath,
    @JsonKey(name: 'backdrop_path') this.backdropPath,
    this.popularity,
    this.status,
    this.homepage,
    @JsonKey(name: 'external_ids') this.externalIds = const ExternalIds(),
    this.budget,
    this.revenue,
    final List<Video> videos = const [],
    final List<ImageModel> images = const [],
    final List<MovieRef> recommendations = const [],
    final List<MovieRef> similar = const [],
    final List<Cast> cast = const [],
    final List<Crew> crew = const [],
  }) : _genres = genres,
       _productionCompanies = productionCompanies,
       _productionCountries = productionCountries,
       _spokenLanguages = spokenLanguages,
       _videos = videos,
       _images = images,
       _recommendations = recommendations,
       _similar = similar,
       _cast = cast,
       _crew = crew;

  factory _$MovieDetailedImpl.fromJson(Map<String, dynamic> json) =>
      _$$MovieDetailedImplFromJson(json);

  @override
  final int id;
  @override
  final String title;
  @override
  @JsonKey(name: 'original_title')
  final String originalTitle;
  @override
  @JsonKey(name: 'vote_average')
  final double voteAverage;
  @override
  @JsonKey(name: 'vote_count')
  final int voteCount;
  @override
  final String? overview;
  @override
  final String? tagline;
  @override
  @JsonKey(name: 'release_date')
  final String? releaseDate;
  @override
  final int? runtime;
  final List<Genre> _genres;
  @override
  @JsonKey()
  List<Genre> get genres {
    if (_genres is EqualUnmodifiableListView) return _genres;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_genres);
  }

  final List<Company> _productionCompanies;
  @override
  @JsonKey(name: 'production_companies')
  List<Company> get productionCompanies {
    if (_productionCompanies is EqualUnmodifiableListView)
      return _productionCompanies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_productionCompanies);
  }

  final List<Country> _productionCountries;
  @override
  @JsonKey(name: 'production_countries')
  List<Country> get productionCountries {
    if (_productionCountries is EqualUnmodifiableListView)
      return _productionCountries;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_productionCountries);
  }

  final List<Language> _spokenLanguages;
  @override
  @JsonKey(name: 'spoken_languages')
  List<Language> get spokenLanguages {
    if (_spokenLanguages is EqualUnmodifiableListView) return _spokenLanguages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_spokenLanguages);
  }

  @override
  @JsonKey(name: 'poster_path')
  final String? posterPath;
  @override
  @JsonKey(name: 'backdrop_path')
  final String? backdropPath;
  @override
  final double? popularity;
  @override
  final String? status;
  @override
  final String? homepage;
  @override
  @JsonKey(name: 'external_ids')
  final ExternalIds externalIds;
  @override
  final int? budget;
  @override
  final int? revenue;
  final List<Video> _videos;
  @override
  @JsonKey()
  List<Video> get videos {
    if (_videos is EqualUnmodifiableListView) return _videos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_videos);
  }

  final List<ImageModel> _images;
  @override
  @JsonKey()
  List<ImageModel> get images {
    if (_images is EqualUnmodifiableListView) return _images;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_images);
  }

  final List<MovieRef> _recommendations;
  @override
  @JsonKey()
  List<MovieRef> get recommendations {
    if (_recommendations is EqualUnmodifiableListView) return _recommendations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recommendations);
  }

  final List<MovieRef> _similar;
  @override
  @JsonKey()
  List<MovieRef> get similar {
    if (_similar is EqualUnmodifiableListView) return _similar;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_similar);
  }

  final List<Cast> _cast;
  @override
  @JsonKey()
  List<Cast> get cast {
    if (_cast is EqualUnmodifiableListView) return _cast;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_cast);
  }

  final List<Crew> _crew;
  @override
  @JsonKey()
  List<Crew> get crew {
    if (_crew is EqualUnmodifiableListView) return _crew;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_crew);
  }

  @override
  String toString() {
    return 'MovieDetailed(id: $id, title: $title, originalTitle: $originalTitle, voteAverage: $voteAverage, voteCount: $voteCount, overview: $overview, tagline: $tagline, releaseDate: $releaseDate, runtime: $runtime, genres: $genres, productionCompanies: $productionCompanies, productionCountries: $productionCountries, spokenLanguages: $spokenLanguages, posterPath: $posterPath, backdropPath: $backdropPath, popularity: $popularity, status: $status, homepage: $homepage, externalIds: $externalIds, budget: $budget, revenue: $revenue, videos: $videos, images: $images, recommendations: $recommendations, similar: $similar, cast: $cast, crew: $crew)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MovieDetailedImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.originalTitle, originalTitle) ||
                other.originalTitle == originalTitle) &&
            (identical(other.voteAverage, voteAverage) ||
                other.voteAverage == voteAverage) &&
            (identical(other.voteCount, voteCount) ||
                other.voteCount == voteCount) &&
            (identical(other.overview, overview) ||
                other.overview == overview) &&
            (identical(other.tagline, tagline) || other.tagline == tagline) &&
            (identical(other.releaseDate, releaseDate) ||
                other.releaseDate == releaseDate) &&
            (identical(other.runtime, runtime) || other.runtime == runtime) &&
            const DeepCollectionEquality().equals(other._genres, _genres) &&
            const DeepCollectionEquality().equals(
              other._productionCompanies,
              _productionCompanies,
            ) &&
            const DeepCollectionEquality().equals(
              other._productionCountries,
              _productionCountries,
            ) &&
            const DeepCollectionEquality().equals(
              other._spokenLanguages,
              _spokenLanguages,
            ) &&
            (identical(other.posterPath, posterPath) ||
                other.posterPath == posterPath) &&
            (identical(other.backdropPath, backdropPath) ||
                other.backdropPath == backdropPath) &&
            (identical(other.popularity, popularity) ||
                other.popularity == popularity) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.homepage, homepage) ||
                other.homepage == homepage) &&
            (identical(other.externalIds, externalIds) ||
                other.externalIds == externalIds) &&
            (identical(other.budget, budget) || other.budget == budget) &&
            (identical(other.revenue, revenue) || other.revenue == revenue) &&
            const DeepCollectionEquality().equals(other._videos, _videos) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            const DeepCollectionEquality().equals(
              other._recommendations,
              _recommendations,
            ) &&
            const DeepCollectionEquality().equals(other._similar, _similar) &&
            const DeepCollectionEquality().equals(other._cast, _cast) &&
            const DeepCollectionEquality().equals(other._crew, _crew));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    title,
    originalTitle,
    voteAverage,
    voteCount,
    overview,
    tagline,
    releaseDate,
    runtime,
    const DeepCollectionEquality().hash(_genres),
    const DeepCollectionEquality().hash(_productionCompanies),
    const DeepCollectionEquality().hash(_productionCountries),
    const DeepCollectionEquality().hash(_spokenLanguages),
    posterPath,
    backdropPath,
    popularity,
    status,
    homepage,
    externalIds,
    budget,
    revenue,
    const DeepCollectionEquality().hash(_videos),
      const DeepCollectionEquality().hash(_images),
      const DeepCollectionEquality().hash(_recommendations),
      const DeepCollectionEquality().hash(_similar),
      const DeepCollectionEquality().hash(_cast),
      const DeepCollectionEquality().hash(_crew),
    ]);

  /// Create a copy of MovieDetailed
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MovieDetailedImplCopyWith<_$MovieDetailedImpl> get copyWith =>
      __$$MovieDetailedImplCopyWithImpl<_$MovieDetailedImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MovieDetailedImplToJson(this);
  }
}

abstract class _MovieDetailed implements MovieDetailed {
  const factory _MovieDetailed({
    required final int id,
    required final String title,
    @JsonKey(name: 'original_title') required final String originalTitle,
    @JsonKey(name: 'vote_average') required final double voteAverage,
    @JsonKey(name: 'vote_count') required final int voteCount,
    final String? overview,
    final String? tagline,
    @JsonKey(name: 'release_date') final String? releaseDate,
    final int? runtime,
    final List<Genre> genres,
    @JsonKey(name: 'production_companies')
    final List<Company> productionCompanies,
    @JsonKey(name: 'production_countries')
    final List<Country> productionCountries,
    @JsonKey(name: 'spoken_languages') final List<Language> spokenLanguages,
    @JsonKey(name: 'poster_path') final String? posterPath,
    @JsonKey(name: 'backdrop_path') final String? backdropPath,
    final double? popularity,
    final String? status,
    final String? homepage,
    @JsonKey(name: 'external_ids') final ExternalIds externalIds,
    final int? budget,
    final int? revenue,
    final List<Video> videos,
    final List<ImageModel> images,
    final List<MovieRef> recommendations,
    final List<MovieRef> similar,
    final List<Cast> cast,
    final List<Crew> crew,
  }) = _$MovieDetailedImpl;

  factory _MovieDetailed.fromJson(Map<String, dynamic> json) =
      _$MovieDetailedImpl.fromJson;

  @override
  int get id;
  @override
  String get title;
  @override
  @JsonKey(name: 'original_title')
  String get originalTitle;
  @override
  @JsonKey(name: 'vote_average')
  double get voteAverage;
  @override
  @JsonKey(name: 'vote_count')
  int get voteCount;
  @override
  String? get overview;
  @override
  String? get tagline;
  @override
  @JsonKey(name: 'release_date')
  String? get releaseDate;
  @override
  int? get runtime;
  @override
  List<Genre> get genres;
  @override
  @JsonKey(name: 'production_companies')
  List<Company> get productionCompanies;
  @override
  @JsonKey(name: 'production_countries')
  List<Country> get productionCountries;
  @override
  @JsonKey(name: 'spoken_languages')
  List<Language> get spokenLanguages;
  @override
  @JsonKey(name: 'poster_path')
  String? get posterPath;
  @override
  @JsonKey(name: 'backdrop_path')
  String? get backdropPath;
  @override
  double? get popularity;
  @override
  String? get status;
  @override
  String? get homepage;
  @override
  @JsonKey(name: 'external_ids')
  ExternalIds get externalIds;
  @override
  int? get budget;
  @override
  int? get revenue;
  @override
  List<Video> get videos;
  @override
  List<ImageModel> get images;
  @override
  List<MovieRef> get recommendations;
  @override
  List<MovieRef> get similar;
  @override
  List<Cast> get cast;
  @override
  List<Crew> get crew;

  /// Create a copy of MovieDetailed
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MovieDetailedImplCopyWith<_$MovieDetailedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
