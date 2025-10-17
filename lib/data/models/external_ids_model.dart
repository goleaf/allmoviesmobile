import 'package:freezed_annotation/freezed_annotation.dart';

part 'external_ids_model.freezed.dart';
part 'external_ids_model.g.dart';

@freezed
class ExternalIds with _$ExternalIds {
  const factory ExternalIds({
    @JsonKey(name: 'imdb_id') String? imdbId,
    @JsonKey(name: 'facebook_id') String? facebookId,
    @JsonKey(name: 'instagram_id') String? instagramId,
    @JsonKey(name: 'twitter_id') String? twitterId,
  }) = _ExternalIds;

  factory ExternalIds.fromJson(Map<String, dynamic> json) =>
      _$ExternalIdsFromJson(json);
}

