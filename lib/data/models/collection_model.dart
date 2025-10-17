import 'package:freezed_annotation/freezed_annotation.dart';
import 'movie_ref_model.dart';

part 'collection_model.freezed.dart';
part 'collection_model.g.dart';

/// Movie collection model
@freezed
class Collection with _$Collection {
  const factory Collection({
    required int id,
    required String name,
    @JsonKey(name: 'poster_path') String? posterPath,
    @JsonKey(name: 'backdrop_path') String? backdropPath,
  }) = _Collection;

  factory Collection.fromJson(Map<String, dynamic> json) =>
      _$CollectionFromJson(json);
}

/// Detailed collection with all parts
@freezed
class CollectionDetails with _$CollectionDetails {
  const factory CollectionDetails({
    required int id,
    required String name,
    String? overview,
    @JsonKey(name: 'poster_path') String? posterPath,
    @JsonKey(name: 'backdrop_path') String? backdropPath,
    @Default([]) List<MovieRef> parts,
  }) = _CollectionDetails;

  factory CollectionDetails.fromJson(Map<String, dynamic> json) =>
      _$CollectionDetailsFromJson(json);
}
