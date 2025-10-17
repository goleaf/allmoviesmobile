// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'season_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Season _$SeasonFromJson(Map<String, dynamic> json) {
  return _Season.fromJson(json);
}

/// @nodoc
mixin _$Season {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'season_number')
  int get seasonNumber => throw _privateConstructorUsedError;
  String? get overview => throw _privateConstructorUsedError;
  @JsonKey(name: 'air_date')
  String? get airDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'poster_path')
  String? get posterPath => throw _privateConstructorUsedError;
  @JsonKey(name: 'backdrop_path')
  String? get backdropPath => throw _privateConstructorUsedError;
  @JsonKey(name: 'episode_count')
  int? get episodeCount => throw _privateConstructorUsedError;
  List<Cast> get cast => throw _privateConstructorUsedError;
  List<Crew> get crew => throw _privateConstructorUsedError;
  List<Episode> get episodes => throw _privateConstructorUsedError;
  List<Video> get videos => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SeasonCopyWith<Season> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SeasonCopyWith<$Res> {
  factory $SeasonCopyWith(Season value, $Res Function(Season) then) =
      _$SeasonCopyWithImpl<$Res, Season>;
  @useResult
  $Res call({
    int id,
    String name,
    @JsonKey(name: 'season_number') int seasonNumber,
    String? overview,
    @JsonKey(name: 'air_date') String? airDate,
    @JsonKey(name: 'poster_path') String? posterPath,
    @JsonKey(name: 'backdrop_path') String? backdropPath,
    @JsonKey(name: 'episode_count') int? episodeCount,
    List<Cast> cast,
    List<Crew> crew,
    List<Episode> episodes,
    List<Video> videos,
  });
}

/// @nodoc
class _$SeasonCopyWithImpl<$Res, $Val extends Season>
    implements $SeasonCopyWith<$Res> {
  _$SeasonCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? seasonNumber = null,
    Object? overview = freezed,
    Object? airDate = freezed,
    Object? posterPath = freezed,
    Object? backdropPath = freezed,
    Object? episodeCount = freezed,
    Object? cast = null,
    Object? crew = null,
    Object? episodes = null,
    Object? videos = null,
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
            seasonNumber: null == seasonNumber
                ? _value.seasonNumber
                : seasonNumber // ignore: cast_nullable_to_non_nullable
                      as int,
            overview: freezed == overview
                ? _value.overview
                : overview // ignore: cast_nullable_to_non_nullable
                      as String?,
            airDate: freezed == airDate
                ? _value.airDate
                : airDate // ignore: cast_nullable_to_non_nullable
                      as String?,
            posterPath: freezed == posterPath
                ? _value.posterPath
                : posterPath // ignore: cast_nullable_to_non_nullable
                      as String?,
            backdropPath: freezed == backdropPath
                ? _value.backdropPath
                : backdropPath // ignore: cast_nullable_to_non_nullable
                      as String?,
            episodeCount: freezed == episodeCount
                ? _value.episodeCount
                : episodeCount // ignore: cast_nullable_to_non_nullable
                      as int?,
            cast: null == cast
                ? _value.cast
                : cast // ignore: cast_nullable_to_non_nullable
                      as List<Cast>,
            crew: null == crew
                ? _value.crew
                : crew // ignore: cast_nullable_to_non_nullable
                      as List<Crew>,
            episodes: null == episodes
                ? _value.episodes
                : episodes // ignore: cast_nullable_to_non_nullable
                      as List<Episode>,
            videos: null == videos
                ? _value.videos
                : videos // ignore: cast_nullable_to_non_nullable
                      as List<Video>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SeasonImplCopyWith<$Res> implements $SeasonCopyWith<$Res> {
  factory _$$SeasonImplCopyWith(
    _$SeasonImpl value,
    $Res Function(_$SeasonImpl) then,
  ) = __$$SeasonImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String name,
    @JsonKey(name: 'season_number') int seasonNumber,
    String? overview,
    @JsonKey(name: 'air_date') String? airDate,
    @JsonKey(name: 'poster_path') String? posterPath,
    @JsonKey(name: 'backdrop_path') String? backdropPath,
    @JsonKey(name: 'episode_count') int? episodeCount,
    List<Cast> cast,
    List<Crew> crew,
    List<Episode> episodes,
    List<Video> videos,
  });
}

/// @nodoc
class __$$SeasonImplCopyWithImpl<$Res>
    extends _$SeasonCopyWithImpl<$Res, _$SeasonImpl>
    implements _$$SeasonImplCopyWith<$Res> {
  __$$SeasonImplCopyWithImpl(
    _$SeasonImpl _value,
    $Res Function(_$SeasonImpl) _then,
  ) : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? seasonNumber = null,
    Object? overview = freezed,
    Object? airDate = freezed,
    Object? posterPath = freezed,
    Object? backdropPath = freezed,
    Object? episodeCount = freezed,
    Object? cast = null,
    Object? crew = null,
    Object? episodes = null,
    Object? videos = null,
  }) {
    return _then(
      _$SeasonImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        seasonNumber: null == seasonNumber
            ? _value.seasonNumber
            : seasonNumber // ignore: cast_nullable_to_non_nullable
                  as int,
        overview: freezed == overview
            ? _value.overview
            : overview // ignore: cast_nullable_to_non_nullable
                  as String?,
        airDate: freezed == airDate
            ? _value.airDate
            : airDate // ignore: cast_nullable_to_non_nullable
                  as String?,
        posterPath: freezed == posterPath
            ? _value.posterPath
            : posterPath // ignore: cast_nullable_to_non_nullable
                  as String?,
        backdropPath: freezed == backdropPath
            ? _value.backdropPath
            : backdropPath // ignore: cast_nullable_to_non_nullable
                  as String?,
        episodeCount: freezed == episodeCount
            ? _value.episodeCount
            : episodeCount // ignore: cast_nullable_to_non_nullable
                  as int?,
        cast: null == cast
            ? _value._cast
            : cast // ignore: cast_nullable_to_non_nullable
                  as List<Cast>,
        crew: null == crew
            ? _value._crew
            : crew // ignore: cast_nullable_to_non_nullable
                  as List<Crew>,
        episodes: null == episodes
            ? _value._episodes
            : episodes // ignore: cast_nullable_to_non_nullable
                  as List<Episode>,
        videos: null == videos
            ? _value._videos
            : videos // ignore: cast_nullable_to_non_nullable
                  as List<Video>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SeasonImpl extends _Season {
  const _$SeasonImpl({
    required this.id,
    required this.name,
    @JsonKey(name: 'season_number') required this.seasonNumber,
    this.overview,
    @JsonKey(name: 'air_date') this.airDate,
    @JsonKey(name: 'poster_path') this.posterPath,
    @JsonKey(name: 'backdrop_path') this.backdropPath,
    @JsonKey(name: 'episode_count') this.episodeCount,
    final List<Cast> cast = const [],
    final List<Crew> crew = const [],
    final List<Episode> episodes = const [],
    final List<Video> videos = const [],
  }) : _cast = cast,
       _crew = crew,
       _episodes = episodes,
       _videos = videos,
       super._();

  factory _$SeasonImpl.fromJson(Map<String, dynamic> json) =>
      _$$SeasonImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  @JsonKey(name: 'season_number')
  final int seasonNumber;
  @override
  final String? overview;
  @override
  @JsonKey(name: 'air_date')
  final String? airDate;
  @override
  @JsonKey(name: 'poster_path')
  final String? posterPath;
  @override
  @JsonKey(name: 'backdrop_path')
  final String? backdropPath;
  @override
  @JsonKey(name: 'episode_count')
  final int? episodeCount;
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

  final List<Episode> _episodes;
  @override
  @JsonKey()
  List<Episode> get episodes {
    if (_episodes is EqualUnmodifiableListView) return _episodes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_episodes);
  }

  final List<Video> _videos;
  @override
  @JsonKey()
  List<Video> get videos {
    if (_videos is EqualUnmodifiableListView) return _videos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_videos);
  }

  @override
  String toString() {
    return 'Season(id: $id, name: $name, seasonNumber: $seasonNumber, overview: $overview, airDate: $airDate, posterPath: $posterPath, backdropPath: $backdropPath, episodeCount: $episodeCount, cast: $cast, crew: $crew, episodes: $episodes, videos: $videos)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SeasonImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.seasonNumber, seasonNumber) ||
                other.seasonNumber == seasonNumber) &&
            (identical(other.overview, overview) ||
                other.overview == overview) &&
            (identical(other.airDate, airDate) || other.airDate == airDate) &&
            (identical(other.posterPath, posterPath) ||
                other.posterPath == posterPath) &&
            (identical(other.backdropPath, backdropPath) ||
                other.backdropPath == backdropPath) &&
            (identical(other.episodeCount, episodeCount) ||
                other.episodeCount == episodeCount) &&
            const DeepCollectionEquality().equals(other._cast, _cast) &&
            const DeepCollectionEquality().equals(other._crew, _crew) &&
            const DeepCollectionEquality().equals(other._episodes, _episodes) &&
            const DeepCollectionEquality().equals(other._videos, _videos));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    seasonNumber,
    overview,
    airDate,
    posterPath,
    backdropPath,
    episodeCount,
    const DeepCollectionEquality().hash(_cast),
    const DeepCollectionEquality().hash(_crew),
    const DeepCollectionEquality().hash(_episodes),
    const DeepCollectionEquality().hash(_videos),
  );

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SeasonImplCopyWith<_$SeasonImpl> get copyWith =>
      __$$SeasonImplCopyWithImpl<_$SeasonImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SeasonImplToJson(this);
  }
}

abstract class _Season extends Season {
  const factory _Season({
    required final int id,
    required final String name,
    @JsonKey(name: 'season_number') required final int seasonNumber,
    final String? overview,
    @JsonKey(name: 'air_date') final String? airDate,
    @JsonKey(name: 'poster_path') final String? posterPath,
    @JsonKey(name: 'backdrop_path') final String? backdropPath,
    @JsonKey(name: 'episode_count') final int? episodeCount,
    final List<Cast> cast,
    final List<Crew> crew,
    final List<Episode> episodes,
    final List<Video> videos,
  }) = _$SeasonImpl;
  const _Season._() : super._();

  factory _Season.fromJson(Map<String, dynamic> json) = _$SeasonImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  @JsonKey(name: 'season_number')
  int get seasonNumber;
  @override
  String? get overview;
  @override
  @JsonKey(name: 'air_date')
  String? get airDate;
  @override
  @JsonKey(name: 'poster_path')
  String? get posterPath;
  @override
  @JsonKey(name: 'backdrop_path')
  String? get backdropPath;
  @override
  @JsonKey(name: 'episode_count')
  int? get episodeCount;
  @override
  List<Cast> get cast;
  @override
  List<Crew> get crew;
  @override
  List<Episode> get episodes;
  @override
  List<Video> get videos;
  @override
  @JsonKey(ignore: true)
  _$$SeasonImplCopyWith<_$SeasonImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
