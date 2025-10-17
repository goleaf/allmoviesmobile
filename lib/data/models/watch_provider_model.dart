import 'package:freezed_annotation/freezed_annotation.dart';

part 'watch_provider_model.freezed.dart';
part 'watch_provider_model.g.dart';

/// Watch provider model (streaming services)
@freezed
class WatchProvider with _$WatchProvider {
  const factory WatchProvider({
    required int id,
    @JsonKey(name: 'provider_id') int? providerId,
    @JsonKey(name: 'provider_name') String? providerName,
    @JsonKey(name: 'logo_path') String? logoPath,
    @JsonKey(name: 'display_priority') int? displayPriority,
  }) = _WatchProvider;

  factory WatchProvider.fromJson(Map<String, dynamic> json) =>
      _$WatchProviderFromJson(json);
}

/// Watch providers by region
@freezed
class WatchProviderResults with _$WatchProviderResults {
  const factory WatchProviderResults({
    String? link,
    @Default([]) List<WatchProvider> flatrate,
    @Default([]) List<WatchProvider> buy,
    @Default([]) List<WatchProvider> rent,
    @Default([]) List<WatchProvider> ads,
    @Default([]) List<WatchProvider> free,
  }) = _WatchProviderResults;

  factory WatchProviderResults.fromJson(Map<String, dynamic> json) =>
      _$WatchProviderResultsFromJson(json);
}

/// Available regions for watch providers
@freezed
class WatchProviderRegion with _$WatchProviderRegion {
  const factory WatchProviderRegion({
    @JsonKey(name: 'iso_3166_1') required String countryCode,
    @JsonKey(name: 'english_name') required String englishName,
    @JsonKey(name: 'native_name') String? nativeName,
  }) = _WatchProviderRegion;

  factory WatchProviderRegion.fromJson(Map<String, dynamic> json) =>
      _$WatchProviderRegionFromJson(json);
}
