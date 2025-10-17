// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'watch_provider_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WatchProviderImpl _$$WatchProviderImplFromJson(Map<String, dynamic> json) =>
    _$WatchProviderImpl(
      id: (json['id'] as num).toInt(),
      providerId: (json['provider_id'] as num?)?.toInt(),
      providerName: json['provider_name'] as String?,
      logoPath: json['logo_path'] as String?,
      displayPriority: (json['display_priority'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$WatchProviderImplToJson(_$WatchProviderImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'provider_id': instance.providerId,
      'provider_name': instance.providerName,
      'logo_path': instance.logoPath,
      'display_priority': instance.displayPriority,
    };

_$WatchProviderResultsImpl _$$WatchProviderResultsImplFromJson(
        Map<String, dynamic> json) =>
    _$WatchProviderResultsImpl(
      link: json['link'] as String?,
      flatrate: (json['flatrate'] as List<dynamic>?)
              ?.map((e) => WatchProvider.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      buy: (json['buy'] as List<dynamic>?)
              ?.map((e) => WatchProvider.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      rent: (json['rent'] as List<dynamic>?)
              ?.map((e) => WatchProvider.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      ads: (json['ads'] as List<dynamic>?)
              ?.map((e) => WatchProvider.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      free: (json['free'] as List<dynamic>?)
              ?.map((e) => WatchProvider.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$WatchProviderResultsImplToJson(
        _$WatchProviderResultsImpl instance) =>
    <String, dynamic>{
      'link': instance.link,
      'flatrate': instance.flatrate,
      'buy': instance.buy,
      'rent': instance.rent,
      'ads': instance.ads,
      'free': instance.free,
    };

_$WatchProviderRegionImpl _$$WatchProviderRegionImplFromJson(
        Map<String, dynamic> json) =>
    _$WatchProviderRegionImpl(
      countryCode: json['iso_3166_1'] as String,
      englishName: json['english_name'] as String,
      nativeName: json['native_name'] as String?,
    );

Map<String, dynamic> _$$WatchProviderRegionImplToJson(
        _$WatchProviderRegionImpl instance) =>
    <String, dynamic>{
      'iso_3166_1': instance.countryCode,
      'english_name': instance.englishName,
      'native_name': instance.nativeName,
    };
