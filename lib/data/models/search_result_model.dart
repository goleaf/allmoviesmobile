import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_result_model.freezed.dart';
part 'search_result_model.g.dart';

enum MediaType {
  @JsonValue('movie')
  movie,
  @JsonValue('tv')
  tv,
  @JsonValue('person')
  person,
}

@freezed
class SearchResult with _$SearchResult {
  const factory SearchResult({
    required int id,
    @JsonKey(name: 'media_type') required MediaType mediaType,
    String? title, // For movies
    String? name, // For TV shows and people
    @JsonKey(name: 'original_title') String? originalTitle,
    @JsonKey(name: 'original_name') String? originalName,
    String? overview,
    @JsonKey(name: 'poster_path') String? posterPath,
    @JsonKey(name: 'backdrop_path') String? backdropPath,
    @JsonKey(name: 'profile_path') String? profilePath, // For people
    @JsonKey(name: 'vote_average') double? voteAverage,
    @JsonKey(name: 'vote_count') int? voteCount,
    double? popularity,
    @JsonKey(name: 'release_date') String? releaseDate, // For movies
    @JsonKey(name: 'first_air_date') String? firstAirDate, // For TV
  }) = _SearchResult;

  factory SearchResult.fromJson(Map<String, dynamic> json) =>
      _$SearchResultFromJson(json);
}

@freezed
class SearchResponse with _$SearchResponse {
  const factory SearchResponse({
    @Default(1) int page,
    @Default([]) List<SearchResult> results,
    @JsonKey(name: 'total_pages') @Default(0) int totalPages,
    @JsonKey(name: 'total_results') @Default(0) int totalResults,
  }) = _SearchResponse;

  factory SearchResponse.fromJson(Map<String, dynamic> json) =>
      _$SearchResponseFromJson(json);
}

