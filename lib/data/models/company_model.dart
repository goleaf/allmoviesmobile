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
    @JsonKey(name: 'produced_movies') @Default([]) List<dynamic> producedMovies,
    @JsonKey(name: 'produced_series') @Default([]) List<dynamic> producedSeries,
  }) = _Company;

  factory Company.fromJson(Map<String, dynamic> json) =>
      _$CompanyFromJson(json);
}

