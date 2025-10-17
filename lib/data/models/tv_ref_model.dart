import 'package:freezed_annotation/freezed_annotation.dart';

part 'tv_ref_model.freezed.dart';
part 'tv_ref_model.g.dart';

/// Lightweight reference to a TV show (used in lists, recommendations, similar shows)
@freezed
class TVRef with _$TVRef {
  const factory TVRef({
    required int id,
    required String name,
    String? posterPath,
    String? backdropPath,
    double? voteAverage,
    String? firstAirDate,
  }) = _TVRef;

  factory TVRef.fromJson(Map<String, dynamic> json) => _$TVRefFromJson(json);
}
