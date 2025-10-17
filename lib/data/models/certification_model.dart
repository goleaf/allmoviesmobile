import 'package:freezed_annotation/freezed_annotation.dart';

part 'certification_model.freezed.dart';
part 'certification_model.g.dart';

/// Content certification/rating
@freezed
class Certification with _$Certification {
  const factory Certification({
    required String certification,
    required String meaning,
    required int order,
  }) = _Certification;

  factory Certification.fromJson(Map<String, dynamic> json) =>
      _$CertificationFromJson(json);
}

/// Content release date with certification
@freezed
class ReleaseDates with _$ReleaseDates {
  const factory ReleaseDates({
    required String certification,
    @JsonKey(name: 'iso_639_1') String? language,
    String? note,
    @JsonKey(name: 'release_date') String? releaseDate,
    int? type,
  }) = _ReleaseDates;

  factory ReleaseDates.fromJson(Map<String, dynamic> json) =>
      _$ReleaseDatesFromJson(json);
}

/// Release dates result by country
@freezed
class ReleaseDatesResult with _$ReleaseDatesResult {
  const factory ReleaseDatesResult({
    @JsonKey(name: 'iso_3166_1') required String countryCode,
    @Default([]) List<ReleaseDates> releaseDates,
  }) = _ReleaseDatesResult;

  factory ReleaseDatesResult.fromJson(Map<String, dynamic> json) =>
      _$ReleaseDatesResultFromJson(json);
}
