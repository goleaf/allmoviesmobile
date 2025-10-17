// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tv_detailed_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

TVDetailed _$TVDetailedFromJson(Map<String, dynamic> json) {
  return _TVDetailed.fromJson(json);
}

/// @nodoc
mixin _$TVDetailed {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'original_name')
  String get originalName => throw _privateConstructorUsedError;
  @JsonKey(name: 'vote_average')
  double get voteAverage => throw _privateConstructorUsedError;
  @JsonKey(name: 'vote_count')
  int get voteCount => throw _privateConstructorUsedError;
  String? get overview => throw _privateConstructorUsedError;
  String? get tagline => throw _privateConstructorUsedError;
  @JsonKey(name: 'first_air_date')
  String? get firstAirDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_air_date')
  String? get lastAirDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'number_of_seasons')
  int? get numberOfSeasons => throw _privateConstructorUsedError;
  @JsonKey(name: 'number_of_episodes')
  int? get numberOfEpisodes => throw _privateConstructorUsedError;
  @JsonKey(name: 'episode_run_time')
  List<int> get episodeRunTime => throw _privateConstructorUsedError;
  List<Genre> get genres => throw _privateConstructorUsedError;
  @JsonKey(name: 'production_companies')
  List<Company> get productionCompanies => throw _privateConstructorUsedError;
  @JsonKey(name: 'production_countries')
  List<Country> get productionCountries => throw _privateConstructorUsedError;
  @JsonKey(name: 'spoken_languages')
  List<Language> get spokenLanguages => throw _privateConstructorUsedError;
  List<Network> get networks => throw _privateConstructorUsedError;
  @JsonKey(name: 'poster_path')
  String? get posterPath => throw _privateConstructorUsedError;
  @JsonKey(name: 'backdrop_path')
  String? get backdropPath => throw _privateConstructorUsedError;
  double? get popularity => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;
  String? get homepage => throw _privateConstructorUsedError;
  @JsonKey(name: 'external_ids')
  ExternalIds get externalIds => throw _privateConstructorUsedError;
  List<Cast> get cast => throw _privateConstructorUsedError;
  List<Season> get seasons => throw _privateConstructorUsedError;
  List<Video> get videos => throw _privateConstructorUsedError;
  List<ImageModel> get images => throw _privateConstructorUsedError;
  List<TVRef> get recommendations => throw _privateConstructorUsedError;
  List<TVRef> get similar => throw _privateConstructorUsedError;

  /// Serializes this TVDetailed to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TVDetailed
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TVDetailedCopyWith<TVDetailed> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TVDetailedCopyWith<$Res> {
  factory $TVDetailedCopyWith(
    TVDetailed value,
    $Res Function(TVDetailed) then,
  ) = _$TVDetailedCopyWithImpl<$Res, TVDetailed>;
  @useResult
  $Res call({
    int id,
    String name,
    @JsonKey(name: 'original_name') String originalName,
    @JsonKey(name: 'vote_average') double voteAverage,
    @JsonKey(name: 'vote_count') int voteCount,
    String? overview,
    String? tagline,
    @JsonKey(name: 'first_air_date') String? firstAirDate,
    @JsonKey(name: 'last_air_date') String? lastAirDate,
    @JsonKey(name: 'number_of_seasons') int? numberOfSeasons,
    @JsonKey(name: 'number_of_episodes') int? numberOfEpisodes,
    @JsonKey(name: 'episode_run_time') List<int> episodeRunTime,
    List<Genre> genres,
    @JsonKey(name: 'production_companies') List<Company> productionCompanies,
    @JsonKey(name: 'production_countries') List<Country> productionCountries,
    @JsonKey(name: 'spoken_languages') List<Language> spokenLanguages,
    List<Network> networks,
    @JsonKey(name: 'poster_path') String? posterPath,
    @JsonKey(name: 'backdrop_path') String? backdropPath,
    double? popularity,
    String? status,
    String? homepage,
    @JsonKey(name: 'external_ids') ExternalIds externalIds,
    List<Cast> cast,
    List<Season> seasons,
    List<Video> videos,
    List<ImageModel> images,
    List<TVRef> recommendations,
    List<TVRef> similar,
  });

  $ExternalIdsCopyWith<$Res> get externalIds;
}

/// @nodoc
class _$TVDetailedCopyWithImpl<$Res, $Val extends TVDetailed>
    implements $TVDetailedCopyWith<$Res> {
  _$TVDetailedCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TVDetailed
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? originalName = null,
    Object? voteAverage = null,
    Object? voteCount = null,
    Object? overview = freezed,
    Object? tagline = freezed,
    Object? firstAirDate = freezed,
    Object? lastAirDate = freezed,
    Object? numberOfSeasons = freezed,
    Object? numberOfEpisodes = freezed,
    Object? episodeRunTime = null,
    Object? genres = null,
    Object? productionCompanies = null,
    Object? productionCountries = null,
    Object? spokenLanguages = null,
    Object? networks = null,
    Object? posterPath = freezed,
    Object? backdropPath = freezed,
    Object? popularity = freezed,
    Object? status = freezed,
    Object? homepage = freezed,
    Object? externalIds = null,
    Object? cast = null,
    Object? seasons = null,
    Object? videos = null,
    Object? images = null,
    Object? recommendations = null,
    Object? similar = null,
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
            originalName: null == originalName
                ? _value.originalName
                : originalName // ignore: cast_nullable_to_non_nullable
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
            firstAirDate: freezed == firstAirDate
                ? _value.firstAirDate
                : firstAirDate // ignore: cast_nullable_to_non_nullable
                      as String?,
            lastAirDate: freezed == lastAirDate
                ? _value.lastAirDate
                : lastAirDate // ignore: cast_nullable_to_non_nullable
                      as String?,
            numberOfSeasons: freezed == numberOfSeasons
                ? _value.numberOfSeasons
                : numberOfSeasons // ignore: cast_nullable_to_non_nullable
                      as int?,
            numberOfEpisodes: freezed == numberOfEpisodes
                ? _value.numberOfEpisodes
                : numberOfEpisodes // ignore: cast_nullable_to_non_nullable
                      as int?,
            episodeRunTime: null == episodeRunTime
                ? _value.episodeRunTime
                : episodeRunTime // ignore: cast_nullable_to_non_nullable
                      as List<int>,
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
            networks: null == networks
                ? _value.networks
                : networks // ignore: cast_nullable_to_non_nullable
                      as List<Network>,
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
        cast: null == cast
            ? _value._cast
            : cast // ignore: cast_nullable_to_non_nullable
                as List<Cast>,
        seasons: null == seasons
            ? _value.seasons
            : seasons // ignore: cast_nullable_to_non_nullable
                as List<Season>,
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
                      as List<TVRef>,
            similar: null == similar
                ? _value.similar
                : similar // ignore: cast_nullable_to_non_nullable
                      as List<TVRef>,
          )
          as $Val,
    );
  }

  /// Create a copy of TVDetailed
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
abstract class _$$TVDetailedImplCopyWith<$Res>
    implements $TVDetailedCopyWith<$Res> {
  factory _$$TVDetailedImplCopyWith(
    _$TVDetailedImpl value,
    $Res Function(_$TVDetailedImpl) then,
  ) = __$$TVDetailedImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String name,
    @JsonKey(name: 'original_name') String originalName,
    @JsonKey(name: 'vote_average') double voteAverage,
    @JsonKey(name: 'vote_count') int voteCount,
    String? overview,
    String? tagline,
    @JsonKey(name: 'first_air_date') String? firstAirDate,
    @JsonKey(name: 'last_air_date') String? lastAirDate,
    @JsonKey(name: 'number_of_seasons') int? numberOfSeasons,
    @JsonKey(name: 'number_of_episodes') int? numberOfEpisodes,
    @JsonKey(name: 'episode_run_time') List<int> episodeRunTime,
    List<Genre> genres,
    @JsonKey(name: 'production_companies') List<Company> productionCompanies,
    @JsonKey(name: 'production_countries') List<Country> productionCountries,
    @JsonKey(name: 'spoken_languages') List<Language> spokenLanguages,
    List<Network> networks,
    @JsonKey(name: 'poster_path') String? posterPath,
    @JsonKey(name: 'backdrop_path') String? backdropPath,
    double? popularity,
    String? status,
    String? homepage,
    @JsonKey(name: 'external_ids') ExternalIds externalIds,
    List<Cast> cast,
    List<Season> seasons,
    List<Video> videos,
    List<ImageModel> images,
    List<TVRef> recommendations,
    List<TVRef> similar,
  });

  @override
  $ExternalIdsCopyWith<$Res> get externalIds;
}

/// @nodoc
class __$$TVDetailedImplCopyWithImpl<$Res>
    extends _$TVDetailedCopyWithImpl<$Res, _$TVDetailedImpl>
    implements _$$TVDetailedImplCopyWith<$Res> {
  __$$TVDetailedImplCopyWithImpl(
    _$TVDetailedImpl _value,
    $Res Function(_$TVDetailedImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TVDetailed
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? originalName = null,
    Object? voteAverage = null,
    Object? voteCount = null,
    Object? overview = freezed,
    Object? tagline = freezed,
    Object? firstAirDate = freezed,
    Object? lastAirDate = freezed,
    Object? numberOfSeasons = freezed,
    Object? numberOfEpisodes = freezed,
    Object? episodeRunTime = null,
    Object? genres = null,
    Object? productionCompanies = null,
    Object? productionCountries = null,
    Object? spokenLanguages = null,
    Object? networks = null,
    Object? posterPath = freezed,
    Object? backdropPath = freezed,
    Object? popularity = freezed,
    Object? status = freezed,
    Object? homepage = freezed,
    Object? externalIds = null,
    Object? cast = null,
    Object? seasons = null,
    Object? videos = null,
    Object? images = null,
    Object? recommendations = null,
    Object? similar = null,
  }) {
    return _then(
      _$TVDetailedImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        originalName: null == originalName
            ? _value.originalName
            : originalName // ignore: cast_nullable_to_non_nullable
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
        firstAirDate: freezed == firstAirDate
            ? _value.firstAirDate
            : firstAirDate // ignore: cast_nullable_to_non_nullable
                  as String?,
        lastAirDate: freezed == lastAirDate
            ? _value.lastAirDate
            : lastAirDate // ignore: cast_nullable_to_non_nullable
                  as String?,
        numberOfSeasons: freezed == numberOfSeasons
            ? _value.numberOfSeasons
            : numberOfSeasons // ignore: cast_nullable_to_non_nullable
                  as int?,
        numberOfEpisodes: freezed == numberOfEpisodes
            ? _value.numberOfEpisodes
            : numberOfEpisodes // ignore: cast_nullable_to_non_nullable
                  as int?,
        episodeRunTime: null == episodeRunTime
            ? _value._episodeRunTime
            : episodeRunTime // ignore: cast_nullable_to_non_nullable
                  as List<int>,
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
        networks: null == networks
            ? _value._networks
            : networks // ignore: cast_nullable_to_non_nullable
                  as List<Network>,
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
        cast: null == cast
            ? _value._cast
            : cast // ignore: cast_nullable_to_non_nullable
                as List<Cast>,
        seasons: null == seasons
            ? _value._seasons
            : seasons // ignore: cast_nullable_to_non_nullable
                  as List<Season>,
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
                  as List<TVRef>,
        similar: null == similar
            ? _value._similar
            : similar // ignore: cast_nullable_to_non_nullable
                  as List<TVRef>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TVDetailedImpl implements _TVDetailed {
  const _$TVDetailedImpl({
    required this.id,
    required this.name,
    @JsonKey(name: 'original_name') required this.originalName,
    @JsonKey(name: 'vote_average') required this.voteAverage,
    @JsonKey(name: 'vote_count') required this.voteCount,
    this.overview,
    this.tagline,
    @JsonKey(name: 'first_air_date') this.firstAirDate,
    @JsonKey(name: 'last_air_date') this.lastAirDate,
    @JsonKey(name: 'number_of_seasons') this.numberOfSeasons,
    @JsonKey(name: 'number_of_episodes') this.numberOfEpisodes,
    @JsonKey(name: 'episode_run_time')
    final List<int> episodeRunTime = const [],
    final List<Genre> genres = const [],
    @JsonKey(name: 'production_companies')
    final List<Company> productionCompanies = const [],
    @JsonKey(name: 'production_countries')
    final List<Country> productionCountries = const [],
    @JsonKey(name: 'spoken_languages')
    final List<Language> spokenLanguages = const [],
    final List<Network> networks = const [],
    @JsonKey(name: 'poster_path') this.posterPath,
    @JsonKey(name: 'backdrop_path') this.backdropPath,
    this.popularity,
    this.status,
    this.homepage,
    @JsonKey(name: 'external_ids') this.externalIds = const ExternalIds(),
    final List<Cast> cast = const [],
    final List<Season> seasons = const [],
    final List<Video> videos = const [],
    final List<ImageModel> images = const [],
    final List<TVRef> recommendations = const [],
    final List<TVRef> similar = const [],
  }) : _episodeRunTime = episodeRunTime,
       _genres = genres,
       _productionCompanies = productionCompanies,
       _productionCountries = productionCountries,
       _spokenLanguages = spokenLanguages,
       _networks = networks,
       _cast = cast,
       _seasons = seasons,
       _videos = videos,
       _images = images,
       _recommendations = recommendations,
       _similar = similar;

  factory _$TVDetailedImpl.fromJson(Map<String, dynamic> json) =>
      _$$TVDetailedImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  @JsonKey(name: 'original_name')
  final String originalName;
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
  @JsonKey(name: 'first_air_date')
  final String? firstAirDate;
  @override
  @JsonKey(name: 'last_air_date')
  final String? lastAirDate;
  @override
  @JsonKey(name: 'number_of_seasons')
  final int? numberOfSeasons;
  @override
  @JsonKey(name: 'number_of_episodes')
  final int? numberOfEpisodes;
  final List<int> _episodeRunTime;
  @override
  @JsonKey(name: 'episode_run_time')
  List<int> get episodeRunTime {
    if (_episodeRunTime is EqualUnmodifiableListView) return _episodeRunTime;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_episodeRunTime);
  }

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

  final List<Network> _networks;
  @override
  @JsonKey()
  List<Network> get networks {
    if (_networks is EqualUnmodifiableListView) return _networks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_networks);
  }

  final List<Cast> _cast;
  @override
  @JsonKey()
  List<Cast> get cast {
    if (_cast is EqualUnmodifiableListView) return _cast;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_cast);
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
  final List<Season> _seasons;
  @override
  @JsonKey()
  List<Season> get seasons {
    if (_seasons is EqualUnmodifiableListView) return _seasons;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_seasons);
  }

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

  final List<TVRef> _recommendations;
  @override
  @JsonKey()
  List<TVRef> get recommendations {
    if (_recommendations is EqualUnmodifiableListView) return _recommendations;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recommendations);
  }

  final List<TVRef> _similar;
  @override
  @JsonKey()
  List<TVRef> get similar {
    if (_similar is EqualUnmodifiableListView) return _similar;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_similar);
  }

  @override
  String toString() {
    return 'TVDetailed(id: $id, name: $name, originalName: $originalName, voteAverage: $voteAverage, voteCount: $voteCount, overview: $overview, tagline: $tagline, firstAirDate: $firstAirDate, lastAirDate: $lastAirDate, numberOfSeasons: $numberOfSeasons, numberOfEpisodes: $numberOfEpisodes, episodeRunTime: $episodeRunTime, genres: $genres, productionCompanies: $productionCompanies, productionCountries: $productionCountries, spokenLanguages: $spokenLanguages, networks: $networks, posterPath: $posterPath, backdropPath: $backdropPath, popularity: $popularity, status: $status, homepage: $homepage, externalIds: $externalIds, cast: $cast, seasons: $seasons, videos: $videos, images: $images, recommendations: $recommendations, similar: $similar)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TVDetailedImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.originalName, originalName) ||
                other.originalName == originalName) &&
            (identical(other.voteAverage, voteAverage) ||
                other.voteAverage == voteAverage) &&
            (identical(other.voteCount, voteCount) ||
                other.voteCount == voteCount) &&
            (identical(other.overview, overview) ||
                other.overview == overview) &&
            (identical(other.tagline, tagline) || other.tagline == tagline) &&
            (identical(other.firstAirDate, firstAirDate) ||
                other.firstAirDate == firstAirDate) &&
            (identical(other.lastAirDate, lastAirDate) ||
                other.lastAirDate == lastAirDate) &&
            (identical(other.numberOfSeasons, numberOfSeasons) ||
                other.numberOfSeasons == numberOfSeasons) &&
            (identical(other.numberOfEpisodes, numberOfEpisodes) ||
                other.numberOfEpisodes == numberOfEpisodes) &&
            const DeepCollectionEquality().equals(
              other._episodeRunTime,
              _episodeRunTime,
            ) &&
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
            const DeepCollectionEquality().equals(other._networks, _networks) &&
            const DeepCollectionEquality().equals(other._cast, _cast) &&
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
            const DeepCollectionEquality().equals(other._seasons, _seasons) &&
            const DeepCollectionEquality().equals(other._videos, _videos) &&
            const DeepCollectionEquality().equals(other._images, _images) &&
            const DeepCollectionEquality().equals(
              other._recommendations,
              _recommendations,
            ) &&
            const DeepCollectionEquality().equals(other._similar, _similar));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    name,
    originalName,
    voteAverage,
    voteCount,
    overview,
    tagline,
    firstAirDate,
    lastAirDate,
    numberOfSeasons,
    numberOfEpisodes,
    const DeepCollectionEquality().hash(_episodeRunTime),
    const DeepCollectionEquality().hash(_genres),
    const DeepCollectionEquality().hash(_productionCompanies),
    const DeepCollectionEquality().hash(_productionCountries),
    const DeepCollectionEquality().hash(_spokenLanguages),
    const DeepCollectionEquality().hash(_networks),
    const DeepCollectionEquality().hash(_cast),
    posterPath,
    backdropPath,
    popularity,
    status,
    homepage,
    externalIds,
    const DeepCollectionEquality().hash(_seasons),
    const DeepCollectionEquality().hash(_videos),
    const DeepCollectionEquality().hash(_images),
    const DeepCollectionEquality().hash(_recommendations),
    const DeepCollectionEquality().hash(_similar),
  ]);

  /// Create a copy of TVDetailed
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TVDetailedImplCopyWith<_$TVDetailedImpl> get copyWith =>
      __$$TVDetailedImplCopyWithImpl<_$TVDetailedImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TVDetailedImplToJson(this);
  }
}

abstract class _TVDetailed implements TVDetailed {
  const factory _TVDetailed({
    required final int id,
    required final String name,
    @JsonKey(name: 'original_name') required final String originalName,
    @JsonKey(name: 'vote_average') required final double voteAverage,
    @JsonKey(name: 'vote_count') required final int voteCount,
    final String? overview,
    final String? tagline,
    @JsonKey(name: 'first_air_date') final String? firstAirDate,
    @JsonKey(name: 'last_air_date') final String? lastAirDate,
    @JsonKey(name: 'number_of_seasons') final int? numberOfSeasons,
    @JsonKey(name: 'number_of_episodes') final int? numberOfEpisodes,
    @JsonKey(name: 'episode_run_time') final List<int> episodeRunTime,
    final List<Genre> genres,
    @JsonKey(name: 'production_companies')
    final List<Company> productionCompanies,
    @JsonKey(name: 'production_countries')
    final List<Country> productionCountries,
    @JsonKey(name: 'spoken_languages') final List<Language> spokenLanguages,
    final List<Network> networks,
    @JsonKey(name: 'poster_path') final String? posterPath,
    @JsonKey(name: 'backdrop_path') final String? backdropPath,
    final double? popularity,
    final String? status,
    final String? homepage,
    @JsonKey(name: 'external_ids') final ExternalIds externalIds,
    final List<Cast> cast,
    final List<Season> seasons,
    final List<Video> videos,
    final List<ImageModel> images,
    final List<TVRef> recommendations,
    final List<TVRef> similar,
  }) = _$TVDetailedImpl;

  factory _TVDetailed.fromJson(Map<String, dynamic> json) =
      _$TVDetailedImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  @JsonKey(name: 'original_name')
  String get originalName;
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
  @JsonKey(name: 'first_air_date')
  String? get firstAirDate;
  @override
  @JsonKey(name: 'last_air_date')
  String? get lastAirDate;
  @override
  @JsonKey(name: 'number_of_seasons')
  int? get numberOfSeasons;
  @override
  @JsonKey(name: 'number_of_episodes')
  int? get numberOfEpisodes;
  @override
  @JsonKey(name: 'episode_run_time')
  List<int> get episodeRunTime;
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
  List<Network> get networks;
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
  List<Cast> get cast;
  @override
  List<Season> get seasons;
  @override
  List<Video> get videos;
  @override
  List<ImageModel> get images;
  @override
  List<TVRef> get recommendations;
  @override
  List<TVRef> get similar;

  /// Create a copy of TVDetailed
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TVDetailedImplCopyWith<_$TVDetailedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
