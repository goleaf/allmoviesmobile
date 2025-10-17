import 'package:freezed_annotation/freezed_annotation.dart';

part 'language_model.freezed.dart';
part 'language_model.g.dart';

@freezed
class Language with _$Language {
  const factory Language({
    @JsonKey(name: 'iso_639_1') required String iso6391,
    required String name,
  }) = _Language;

  factory Language.fromJson(Map<String, dynamic> json) =>
      _$LanguageFromJson(json);
}
