import 'package:freezed_annotation/freezed_annotation.dart';

part 'translation_model.freezed.dart';
part 'translation_model.g.dart';

@freezed
class TranslationData with _$TranslationData {
  const factory TranslationData({
    String? title,
    String? overview,
    String? homepage,
    String? tagline,
  }) = _TranslationData;

  factory TranslationData.fromJson(Map<String, dynamic> json) =>
      _$TranslationDataFromJson(json);
}

@freezed
class Translation with _$Translation {
  const factory Translation({
    @JsonKey(name: 'iso_3166_1') required String iso31661,
    @JsonKey(name: 'iso_639_1') required String iso6391,
    required String name,
    @JsonKey(name: 'english_name') required String englishName,
    required TranslationData data,
  }) = _Translation;

  factory Translation.fromJson(Map<String, dynamic> json) =>
      _$TranslationFromJson(json);
}

extension TranslationX on Translation {
  String get displayName => '$englishName (${iso31661.toUpperCase()})';
}
