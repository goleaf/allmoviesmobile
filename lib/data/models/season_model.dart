import 'package:freezed_annotation/freezed_annotation.dart';
import 'episode_model.dart';

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
    @JsonKey(name: 'episode_count') int? episodeCount,
    @Default([]) List<Episode> episodes,
  }) = _Season;

  factory Season.fromJson(Map<String, dynamic> json) =>
      _$SeasonFromJson(json);
}

