import 'package:freezed_annotation/freezed_annotation.dart';

part 'credit_model.freezed.dart';
part 'credit_model.g.dart';

@freezed
class Cast with _$Cast {
  const factory Cast({
    required int id,
    required String name,
    String? character,
    @JsonKey(name: 'profile_path') String? profilePath,
    @Default(0) int order,
  }) = _Cast;

  factory Cast.fromJson(Map<String, dynamic> json) => _$CastFromJson(json);
}

@freezed
class Crew with _$Crew {
  const factory Crew({
    required int id,
    required String name,
    required String job,
    required String department,
    @JsonKey(name: 'profile_path') String? profilePath,
  }) = _Crew;

  factory Crew.fromJson(Map<String, dynamic> json) => _$CrewFromJson(json);
}

@freezed
class Credits with _$Credits {
  const factory Credits({
    @Default([]) List<Cast> cast,
    @Default([]) List<Crew> crew,
  }) = _Credits;

  factory Credits.fromJson(Map<String, dynamic> json) =>
      _$CreditsFromJson(json);
}

