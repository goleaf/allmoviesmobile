// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'episode_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Episode _$EpisodeFromJson(Map<String, dynamic> json) {
  return _Episode.fromJson(json);
}

/// @nodoc
mixin _$Episode {
  int get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'episode_number')
  int get episodeNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'season_number')
  int get seasonNumber => throw _privateConstructorUsedError;
  String? get overview => throw _privateConstructorUsedError;
  @JsonKey(name: 'air_date')
  String? get airDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'still_path')
  String? get stillPath => throw _privateConstructorUsedError;
  @JsonKey(name: 'vote_average')
  double? get voteAverage => throw _privateConstructorUsedError;
  @JsonKey(name: 'vote_count')
  int? get voteCount => throw _privateConstructorUsedError;
  int? get runtime => throw _privateConstructorUsedError;
  List<Cast> get cast => throw _privateConstructorUsedError;
  List<Crew> get crew => throw _privateConstructorUsedError;
  List<Video> get videos => throw _privateConstructorUsedError;

  /// Serializes this Episode to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Episode
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EpisodeCopyWith<Episode> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EpisodeCopyWith<$Res> {
  factory $EpisodeCopyWith(Episode value, $Res Function(Episode) then) =
      _$EpisodeCopyWithImpl<$Res, Episode>;
  @useResult
  $Res call({
    int id,
    String name,
    @JsonKey(name: 'episode_number') int episodeNumber,
    @JsonKey(name: 'season_number') int seasonNumber,
    String? overview,
    @JsonKey(name: 'air_date') String? airDate,
    @JsonKey(name: 'still_path') String? stillPath,
    @JsonKey(name: 'vote_average') double? voteAverage,
    @JsonKey(name: 'vote_count') int? voteCount,
    int? runtime,
    List<Cast> cast,
    List<Crew> crew,
    List<Video> videos,
  });
}

/// @nodoc
class _$EpisodeCopyWithImpl<$Res, $Val extends Episode>
    implements $EpisodeCopyWith<$Res> {
  _$EpisodeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Episode
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? episodeNumber = null,
    Object? seasonNumber = null,
    Object? overview = freezed,
    Object? airDate = freezed,
    Object? stillPath = freezed,
    Object? voteAverage = freezed,
    Object? voteCount = freezed,
    Object? runtime = freezed,
    Object? cast = null,
    Object? crew = null,
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
            episodeNumber: null == episodeNumber
                ? _value.episodeNumber
                : episodeNumber // ignore: cast_nullable_to_non_nullable
                      as int,
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
            stillPath: freezed == stillPath
                ? _value.stillPath
                : stillPath // ignore: cast_nullable_to_non_nullable
                      as String?,
            voteAverage: freezed == voteAverage
                ? _value.voteAverage
                : voteAverage // ignore: cast_nullable_to_non_nullable
                      as double?,
            voteCount: freezed == voteCount
                ? _value.voteCount
                : voteCount // ignore: cast_nullable_to_non_nullable
                      as int?,
            runtime: freezed == runtime
                ? _value.runtime
                : runtime // ignore: cast_nullable_to_non_nullable
                      as int?,
            cast: null == cast
                ? _value.cast
                : cast // ignore: cast_nullable_to_non_nullable
                      as List<Cast>,
            crew: null == crew
                ? _value.crew
                : crew // ignore: cast_nullable_to_non_nullable
                      as List<Crew>,
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
abstract class _$$EpisodeImplCopyWith<$Res> implements $EpisodeCopyWith<$Res> {
  factory _$$EpisodeImplCopyWith(
    _$EpisodeImpl value,
    $Res Function(_$EpisodeImpl) then,
  ) = __$$EpisodeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    String name,
    @JsonKey(name: 'episode_number') int episodeNumber,
    @JsonKey(name: 'season_number') int seasonNumber,
    String? overview,
    @JsonKey(name: 'air_date') String? airDate,
    @JsonKey(name: 'still_path') String? stillPath,
    @JsonKey(name: 'vote_average') double? voteAverage,
    @JsonKey(name: 'vote_count') int? voteCount,
    int? runtime,
    List<Cast> cast,
    List<Crew> crew,
    List<Video> videos,
  });
}

/// @nodoc
class __$$EpisodeImplCopyWithImpl<$Res>
    extends _$EpisodeCopyWithImpl<$Res, _$EpisodeImpl>
    implements _$$EpisodeImplCopyWith<$Res> {
  __$$EpisodeImplCopyWithImpl(
    _$EpisodeImpl _value,
    $Res Function(_$EpisodeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Episode
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? episodeNumber = null,
    Object? seasonNumber = null,
    Object? overview = freezed,
    Object? airDate = freezed,
    Object? stillPath = freezed,
    Object? voteAverage = freezed,
    Object? voteCount = freezed,
    Object? runtime = freezed,
    Object? cast = null,
    Object? crew = null,
    Object? videos = null,
  }) {
    return _then(
      _$EpisodeImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        episodeNumber: null == episodeNumber
            ? _value.episodeNumber
            : episodeNumber // ignore: cast_nullable_to_non_nullable
                  as int,
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
        stillPath: freezed == stillPath
            ? _value.stillPath
            : stillPath // ignore: cast_nullable_to_non_nullable
                  as String?,
        voteAverage: freezed == voteAverage
            ? _value.voteAverage
            : voteAverage // ignore: cast_nullable_to_non_nullable
                  as double?,
        voteCount: freezed == voteCount
            ? _value.voteCount
            : voteCount // ignore: cast_nullable_to_non_nullable
                  as int?,
        runtime: freezed == runtime
            ? _value.runtime
            : runtime // ignore: cast_nullable_to_non_nullable
                  as int?,
        cast: null == cast
            ? _value._cast
            : cast // ignore: cast_nullable_to_non_nullable
                  as List<Cast>,
        crew: null == crew
            ? _value._crew
            : crew // ignore: cast_nullable_to_non_nullable
                  as List<Crew>,
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
class _$EpisodeImpl implements _Episode {
  const _$EpisodeImpl({
    required this.id,
    required this.name,
    @JsonKey(name: 'episode_number') required this.episodeNumber,
    @JsonKey(name: 'season_number') required this.seasonNumber,
    this.overview,
    @JsonKey(name: 'air_date') this.airDate,
    @JsonKey(name: 'still_path') this.stillPath,
    @JsonKey(name: 'vote_average') this.voteAverage,
    @JsonKey(name: 'vote_count') this.voteCount,
    this.runtime,
    final List<Cast> cast = const [],
    final List<Crew> crew = const [],
    final List<Video> videos = const [],
  })  : _cast = cast,
        _crew = crew,
        _videos = videos;

  factory _$EpisodeImpl.fromJson(Map<String, dynamic> json) =>
      _$$EpisodeImplFromJson(json);

  @override
  final int id;
  @override
  final String name;
  @override
  @JsonKey(name: 'episode_number')
  final int episodeNumber;
  @override
  @JsonKey(name: 'season_number')
  final int seasonNumber;
  @override
  final String? overview;
  @override
  @JsonKey(name: 'air_date')
  final String? airDate;
  @override
  @JsonKey(name: 'still_path')
  final String? stillPath;
  @override
  @JsonKey(name: 'vote_average')
  final double? voteAverage;
  @override
  @JsonKey(name: 'vote_count')
  final int? voteCount;
  @override
  final int? runtime;
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
    return 'Episode(id: $id, name: $name, episodeNumber: $episodeNumber, seasonNumber: $seasonNumber, overview: $overview, airDate: $airDate, stillPath: $stillPath, voteAverage: $voteAverage, voteCount: $voteCount, runtime: $runtime, cast: $cast, crew: $crew, videos: $videos)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EpisodeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.episodeNumber, episodeNumber) ||
                other.episodeNumber == episodeNumber) &&
            (identical(other.seasonNumber, seasonNumber) ||
                other.seasonNumber == seasonNumber) &&
            (identical(other.overview, overview) ||
                other.overview == overview) &&
            (identical(other.airDate, airDate) || other.airDate == airDate) &&
            (identical(other.stillPath, stillPath) ||
                other.stillPath == stillPath) &&
            (identical(other.voteAverage, voteAverage) ||
                other.voteAverage == voteAverage) &&
            (identical(other.voteCount, voteCount) ||
                other.voteCount == voteCount) &&
            (identical(other.runtime, runtime) || other.runtime == runtime) &&
            const DeepCollectionEquality().equals(other._cast, _cast) &&
            const DeepCollectionEquality().equals(other._crew, _crew) &&
            const DeepCollectionEquality().equals(other._videos, _videos));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    episodeNumber,
    seasonNumber,
    overview,
    airDate,
    stillPath,
    voteAverage,
    voteCount,
    runtime,
    const DeepCollectionEquality().hash(_cast),
    const DeepCollectionEquality().hash(_crew),
    const DeepCollectionEquality().hash(_videos),
  );

  /// Create a copy of Episode
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EpisodeImplCopyWith<_$EpisodeImpl> get copyWith =>
      __$$EpisodeImplCopyWithImpl<_$EpisodeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EpisodeImplToJson(this);
  }
}

abstract class _Episode implements Episode {
  const factory _Episode({
    required final int id,
    required final String name,
    @JsonKey(name: 'episode_number') required final int episodeNumber,
    @JsonKey(name: 'season_number') required final int seasonNumber,
    final String? overview,
    @JsonKey(name: 'air_date') final String? airDate,
    @JsonKey(name: 'still_path') final String? stillPath,
    @JsonKey(name: 'vote_average') final double? voteAverage,
    @JsonKey(name: 'vote_count') final int? voteCount,
    final int? runtime,
    final List<Cast> cast,
    final List<Crew> crew,
    final List<Video> videos,
  }) = _$EpisodeImpl;

  factory _Episode.fromJson(Map<String, dynamic> json) = _$EpisodeImpl.fromJson;

  @override
  int get id;
  @override
  String get name;
  @override
  @JsonKey(name: 'episode_number')
  int get episodeNumber;
  @override
  @JsonKey(name: 'season_number')
  int get seasonNumber;
  @override
  String? get overview;
  @override
  @JsonKey(name: 'air_date')
  String? get airDate;
  @override
  @JsonKey(name: 'still_path')
  String? get stillPath;
  @override
  @JsonKey(name: 'vote_average')
  double? get voteAverage;
  @override
  @JsonKey(name: 'vote_count')
  int? get voteCount;
  @override
  int? get runtime;
  @override
  List<Cast> get cast;
  @override
  List<Crew> get crew;
  @override
  List<Video> get videos;

  /// Create a copy of Episode
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EpisodeImplCopyWith<_$EpisodeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
