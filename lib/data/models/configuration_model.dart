import 'package:freezed_annotation/freezed_annotation.dart';

part 'configuration_model.freezed.dart';
part 'configuration_model.g.dart';

/// API Configuration for images
@freezed
class ImagesConfiguration with _$ImagesConfiguration {
  const factory ImagesConfiguration({
    @JsonKey(name: 'base_url') required String baseUrl,
    @JsonKey(name: 'secure_base_url') required String secureBaseUrl,
    @JsonKey(name: 'backdrop_sizes') @Default([]) List<String> backdropSizes,
    @JsonKey(name: 'logo_sizes') @Default([]) List<String> logoSizes,
    @JsonKey(name: 'poster_sizes') @Default([]) List<String> posterSizes,
    @JsonKey(name: 'profile_sizes') @Default([]) List<String> profileSizes,
    @JsonKey(name: 'still_sizes') @Default([]) List<String> stillSizes,
  }) = _ImagesConfiguration;

  factory ImagesConfiguration.fromJson(Map<String, dynamic> json) =>
      _$ImagesConfigurationFromJson(json);
}

/// API Configuration
@freezed
class ApiConfiguration with _$ApiConfiguration {
  const factory ApiConfiguration({
    required ImagesConfiguration images,
    @JsonKey(name: 'change_keys') @Default([]) List<String> changeKeys,
  }) = _ApiConfiguration;

  factory ApiConfiguration.fromJson(Map<String, dynamic> json) =>
      _$ApiConfigurationFromJson(json);
}

/// Country model
@freezed
class CountryInfo with _$CountryInfo {
  const factory CountryInfo({
    @JsonKey(name: 'iso_3166_1') required String code,
    @JsonKey(name: 'english_name') required String englishName,
    @JsonKey(name: 'native_name') String? nativeName,
  }) = _CountryInfo;

  factory CountryInfo.fromJson(Map<String, dynamic> json) =>
      _$CountryInfoFromJson(json);
}

/// Language model
@freezed
class LanguageInfo with _$LanguageInfo {
  const factory LanguageInfo({
    @JsonKey(name: 'iso_639_1') required String code,
    @JsonKey(name: 'english_name') required String englishName,
    @JsonKey(name: 'native_name') String? name,
  }) = _LanguageInfo;

  factory LanguageInfo.fromJson(Map<String, dynamic> json) =>
      _$LanguageInfoFromJson(json);
}

/// Job/Department model
@freezed
class Job with _$Job {
  const factory Job({
    required String department,
    @Default([]) List<String> jobs,
  }) = _Job;

  factory Job.fromJson(Map<String, dynamic> json) => _$JobFromJson(json);
}

/// Timezone model
@freezed
class Timezone with _$Timezone {
  const factory Timezone({
    @JsonKey(name: 'iso_3166_1') required String countryCode,
    @Default([]) List<String> zones,
  }) = _Timezone;

  factory Timezone.fromJson(Map<String, dynamic> json) =>
      _$TimezoneFromJson(json);
}

