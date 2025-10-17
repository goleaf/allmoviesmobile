import 'package:freezed_annotation/freezed_annotation.dart';

part 'movie_ref_model.freezed.dart';
part 'movie_ref_model.g.dart';

/// Lightweight reference to a movie (used in lists, recommendations, similar movies)
@freezed
class MovieRef with _$MovieRef {
  const factory MovieRef({
    required int id,
    required String title,
    @JsonKey(name: 'poster_path') String? posterPath,
    @JsonKey(name: 'backdrop_path') String? backdropPath,
    @JsonKey(name: 'vote_average') double? voteAverage,
    @JsonKey(name: 'release_date') String? releaseDate,
    @JsonKey(name: 'media_type') String? mediaType,
  }) = _MovieRef;

  factory MovieRef.fromJson(Map<String, dynamic> json) =>
      _$MovieRefFromJson(json);
}

extension MovieRefX on MovieRef {
  String? get posterUrl =>
      posterPath != null ? 'https://image.tmdb.org/t/p/w342$posterPath' : null;

  String? get backdropUrl => backdropPath != null
      ? 'https://image.tmdb.org/t/p/w780$backdropPath'
      : null;

  String? get releaseYear => releaseDate != null && releaseDate!.isNotEmpty
      ? releaseDate!.split('-').first
      : null;
}
