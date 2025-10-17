import 'package:freezed_annotation/freezed_annotation.dart';

part 'company_model.freezed.dart';
part 'company_model.g.dart';

@freezed
class Company with _$Company {
  const factory Company({
    required int id,
    required String name,
    @JsonKey(name: 'logo_path') String? logoPath,
    @JsonKey(name: 'origin_country') String? originCountry,
    String? description,
    String? headquarters,
    String? homepage,
    @JsonKey(name: 'parent_company') ParentCompany? parentCompany,
    @JsonKey(name: 'alternative_names')
    @Default(<String>[])
    List<String> alternativeNames,
    @JsonKey(name: 'logo_gallery')
    @Default(<CompanyLogo>[])
    List<CompanyLogo> logoGallery,
    @JsonKey(name: 'produced_movies') @Default([]) List<dynamic> producedMovies,
    @JsonKey(name: 'produced_series') @Default([]) List<dynamic> producedSeries,
  }) = _Company;

  factory Company.fromJson(Map<String, dynamic> json) =>
      _$CompanyFromJson(json);
}

@freezed
class ParentCompany with _$ParentCompany {
  const factory ParentCompany({
    required int id,
    required String name,
    @JsonKey(name: 'logo_path') String? logoPath,
    @JsonKey(name: 'origin_country') String? originCountry,
  }) = _ParentCompany;

  factory ParentCompany.fromJson(Map<String, dynamic> json) =>
      _$ParentCompanyFromJson(json);
}

@freezed
class CompanyLogo with _$CompanyLogo {
  const factory CompanyLogo({
    @JsonKey(name: 'file_path') required String filePath,
    int? width,
    int? height,
    @JsonKey(name: 'aspect_ratio') double? aspectRatio,
    @JsonKey(name: 'vote_average') double? voteAverage,
    @JsonKey(name: 'vote_count') int? voteCount,
  }) = _CompanyLogo;

  factory CompanyLogo.fromJson(Map<String, dynamic> json) =>
      _$CompanyLogoFromJson(json);
}
