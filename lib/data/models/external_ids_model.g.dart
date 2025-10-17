// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'external_ids_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExternalIdsImpl _$$ExternalIdsImplFromJson(Map<String, dynamic> json) =>
    _$ExternalIdsImpl(
      imdbId: json['imdb_id'] as String?,
      facebookId: json['facebook_id'] as String?,
      twitterId: json['twitter_id'] as String?,
      tvdbId: json['tvdb_id'] as String?,
      tvrageId: json['tvrage_id'] as String?,
    );

Map<String, dynamic> _$$ExternalIdsImplToJson(_$ExternalIdsImpl instance) =>
    <String, dynamic>{
      'imdb_id': instance.imdbId,
      'facebook_id': instance.facebookId,
      'twitter_id': instance.twitterId,
      'tvdb_id': instance.tvdbId,
      'tvrage_id': instance.tvrageId,
    };
