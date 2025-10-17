import 'package:freezed_annotation/freezed_annotation.dart';

import 'company_model.dart';
import 'country_model.dart';
import 'credit_model.dart';
import 'external_ids_model.dart';
import 'genre_model.dart';
import 'image_model.dart';
import 'language_model.dart';
import 'movie_ref_model.dart';
import 'video_model.dart';

part 'movie_detailed_model.freezed.dart';
part 'movie_detailed_model.g.dart';

/// Comprehensive movie model with all details
@freezed
class MovieDetailed with _$MovieDetailed {
  const factory MovieDetailed({
    required int id,
    required String title,
    @JsonKey(name: 'original_title') required String originalTitle,
    @JsonKey(name: 'vote_average') required double voteAverage,
    @JsonKey(name: 'vote_count') required int voteCount,
    String? overview,
    String? tagline,
    @JsonKey(name: 'release_date') String? releaseDate,
    int? runtime,
    @Default([]) List<Genre> genres,
    @JsonKey(name: 'production_companies')
    @Default([])
    List<Company> productionCompanies,
    @JsonKey(name: 'production_countries')
    @Default([])
    List<Country> productionCountries,
    @JsonKey(name: 'spoken_languages') @Default([]) List<Language> spokenLanguages,
    @JsonKey(name: 'poster_path') String? posterPath,
    @JsonKey(name: 'backdrop_path') String? backdropPath,
    double? popularity,
    String? status,
    String? homepage,
    @JsonKey(name: 'external_ids')
    @Default(ExternalIds())
    ExternalIds externalIds,
    int? budget,
    int? revenue,
    @Default([]) List<Video> videos,
    @Default([]) List<ImageModel> images,
    @Default([]) List<MovieRef> recommendations,
    @Default([]) List<MovieRef> similar,
    @Default([]) List<Cast> cast,
    @Default([]) List<Crew> crew,
  }) = _MovieDetailed;

  factory MovieDetailed.fromJson(Map<String, dynamic> json) =>
      _$MovieDetailedFromJson(json);
}

