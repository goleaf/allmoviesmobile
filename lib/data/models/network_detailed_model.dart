import 'package:freezed_annotation/freezed_annotation.dart';

part 'network_detailed_model.freezed.dart';
part 'network_detailed_model.g.dart';

/// Alternative network name
@freezed
class AlternativeName with _$AlternativeName {
  const factory AlternativeName({
    required String name,
    required String type,
  }) = _AlternativeName;

  factory AlternativeName.fromJson(Map<String, dynamic> json) =>
      _$AlternativeNameFromJson(json);
}

/// Detailed network model
@freezed
class NetworkDetailed with _$NetworkDetailed {
  const factory NetworkDetailed({
    required int id,
    required String name,
    @JsonKey(name: 'logo_path') String? logoPath,
    @JsonKey(name: 'origin_country') required String originCountry,
    String? headquarters,
    String? homepage,
    @JsonKey(name: 'alternative_names')
    @Default([])
    List<AlternativeName> alternativeNames,
  }) = _NetworkDetailed;

  factory NetworkDetailed.fromJson(Map<String, dynamic> json) =>
      _$NetworkDetailedFromJson(json);
}

