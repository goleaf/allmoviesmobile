import 'package:freezed_annotation/freezed_annotation.dart';

import 'company_model.dart';
import 'country_model.dart';
import 'credit_model.dart';
import 'external_ids_model.dart';
import 'genre_model.dart';
import 'image_model.dart';
import 'keyword_model.dart';
import 'language_model.dart';
import 'network_model.dart';
import 'season_model.dart';
import 'tv_ref_model.dart';
import 'video_model.dart';

part 'tv_detailed_model.freezed.dart';
part 'tv_detailed_model.g.dart';

/// Comprehensive TV show model with all details
@freezed
class TVDetailed with _$TVDetailed {
  const factory TVDetailed({
    required int id,
    required String name,
    @JsonKey(name: 'original_name') required String originalName,
    @JsonKey(name: 'vote_average') required double voteAverage,
    @JsonKey(name: 'vote_count') required int voteCount,
    String? overview,
    String? tagline,
    @JsonKey(name: 'first_air_date') String? firstAirDate,
    @JsonKey(name: 'last_air_date') String? lastAirDate,
    @JsonKey(name: 'number_of_seasons') int? numberOfSeasons,
    @JsonKey(name: 'number_of_episodes') int? numberOfEpisodes,
    @JsonKey(name: 'episode_run_time') @Default([]) List<int> episodeRunTime,
    @Default([]) List<Genre> genres,
    @JsonKey(name: 'production_companies')
    @Default([])
    List<Company> productionCompanies,
    @JsonKey(name: 'production_countries')
    @Default([])
    List<Country> productionCountries,
    @JsonKey(name: 'spoken_languages')
    @Default([])
    List<Language> spokenLanguages,
    @Default([]) List<Network> networks,
    @JsonKey(name: 'poster_path') String? posterPath,
    @JsonKey(name: 'backdrop_path') String? backdropPath,
    double? popularity,
    String? status,
    String? homepage,
    @JsonKey(name: 'external_ids')
    @Default(ExternalIds())
    ExternalIds externalIds,
    @Default([]) List<Cast> cast,
    @Default([]) List<Season> seasons,
    @Default([]) List<Video> videos,
    @Default([]) List<ImageModel> images,
    @Default([]) List<TVRef> recommendations,
    @Default([]) List<TVRef> similar,
    @Default([]) List<Keyword> keywords,
  }) = _TVDetailed;

  factory TVDetailed.fromJson(Map<String, dynamic> json) =>
      _$TVDetailedFromJson(json);
}
