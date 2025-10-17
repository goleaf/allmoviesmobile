import 'package:freezed_annotation/freezed_annotation.dart';

part 'external_ids_model.freezed.dart';
part 'external_ids_model.g.dart';

@freezed
class ExternalIds with _$ExternalIds {
  const factory ExternalIds({
    @JsonKey(name: 'imdb_id') String? imdbId,
    @JsonKey(name: 'facebook_id') String? facebookId,
    @JsonKey(name: 'twitter_id') String? twitterId,
    @JsonKey(name: 'tvdb_id') String? tvdbId,
    @JsonKey(name: 'tvrage_id') String? tvrageId,
  }) = _ExternalIds;

  factory ExternalIds.fromJson(Map<String, dynamic> json) =>
      _$ExternalIdsFromJson(json);
}

extension ExternalIdsX on ExternalIds {
  /// Builds a map of available external links keyed by a short identifier.
  ///
  /// Supported keys: `imdb`, `homepage`, `facebook`, `twitter`, `tvdb`,
  /// `tvrage`.
  Map<String, String> toExternalLinks({String? homepage}) {
    final links = <String, String>{};

    final imdb = imdbId?.trim();
    if (imdb != null && imdb.isNotEmpty) {
      links['imdb'] = 'https://www.imdb.com/title/$imdb';
    }

    final home = homepage?.trim();
    if (home != null && home.isNotEmpty) {
      links['homepage'] = home;
    }

    final facebook = facebookId?.trim();
    if (facebook != null && facebook.isNotEmpty) {
      links['facebook'] = 'https://www.facebook.com/$facebook';
    }

    final twitter = twitterId?.trim();
    if (twitter != null && twitter.isNotEmpty) {
      links['twitter'] = 'https://twitter.com/$twitter';
    }

    final tvdb = tvdbId?.trim();
    if (tvdb != null && tvdb.isNotEmpty) {
      links['tvdb'] = 'https://thetvdb.com/?tab=series&id=$tvdb';
    }

    final tvrage = tvrageId?.trim();
    if (tvrage != null && tvrage.isNotEmpty) {
      links['tvrage'] = 'http://www.tvrage.com/shows/id-$tvrage';
    }

    return links;
  }
}

