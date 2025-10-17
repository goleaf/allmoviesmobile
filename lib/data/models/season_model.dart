import 'package:freezed_annotation/freezed_annotation.dart';

import 'credit_model.dart';
import 'episode_model.dart';
import 'video_model.dart';

part 'season_model.freezed.dart';
part 'season_model.g.dart';

@freezed
class Season with _$Season {
  const factory Season({
    required int id,
    required String name,
    @JsonKey(name: 'season_number') required int seasonNumber,
    String? overview,
    @JsonKey(name: 'air_date') String? airDate,
    @JsonKey(name: 'poster_path') String? posterPath,
    @JsonKey(name: 'backdrop_path') String? backdropPath,
    @JsonKey(name: 'episode_count') int? episodeCount,
    @Default([]) List<Cast> cast,
    @Default([]) List<Crew> crew,
    @Default([]) List<Episode> episodes,
    @Default([]) List<Video> videos,
  }) = _Season;

  const Season._();

  factory Season.fromJson(Map<String, dynamic> json) =>
      _$SeasonFromJson(json);

  String? get posterUrl =>
      posterPath != null ? 'https://image.tmdb.org/t/p/w500$posterPath' : null;

  String? get backdropUrl => backdropPath != null
      ? 'https://image.tmdb.org/t/p/w780$backdropPath'
      : null;
}

