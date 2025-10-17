import 'package:freezed_annotation/freezed_annotation.dart';

part 'movie_ref_model.freezed.dart';
part 'movie_ref_model.g.dart';

/// Lightweight reference to a movie (used in lists, recommendations, similar movies)
@freezed
class MovieRef with _$MovieRef {
  const factory MovieRef({
    required int id,
    required String title,
  }) = _MovieRef;

  factory MovieRef.fromJson(Map<String, dynamic> json) =>
      _$MovieRefFromJson(json);
}

