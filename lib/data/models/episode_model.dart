import 'package:freezed_annotation/freezed_annotation.dart';
import 'credit_model.dart';
import 'video_model.dart';

part 'episode_model.freezed.dart';
part 'episode_model.g.dart';

@freezed
class Episode with _$Episode {
  const factory Episode({
    required int id,
    required String name,
    @JsonKey(name: 'episode_number') required int episodeNumber,
    @JsonKey(name: 'season_number') required int seasonNumber,
    String? overview,
    @JsonKey(name: 'air_date') String? airDate,
    @JsonKey(name: 'still_path') String? stillPath,
    @JsonKey(name: 'vote_average') double? voteAverage,
    @JsonKey(name: 'vote_count') int? voteCount,
    int? runtime,
    @Default([]) List<Cast> cast,
    @JsonKey(name: 'guest_stars') @Default([]) List<Cast> guestStars,
    @Default([]) List<Crew> crew,
    @Default([]) List<Video> videos,
  }) = _Episode;

  factory Episode.fromJson(Map<String, dynamic> json) =>
      _$EpisodeFromJson(json);
}
