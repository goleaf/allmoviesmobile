import 'package:freezed_annotation/freezed_annotation.dart';

part 'alternative_title_model.freezed.dart';
part 'alternative_title_model.g.dart';

@freezed
class AlternativeTitle with _$AlternativeTitle {
  const factory AlternativeTitle({
    @JsonKey(name: 'iso_3166_1') required String iso31661,
    required String title,
    String? type,
  }) = _AlternativeTitle;

  factory AlternativeTitle.fromJson(Map<String, dynamic> json) =>
      _$AlternativeTitleFromJson(json);
}

extension AlternativeTitleX on AlternativeTitle {
  String get displayLabel =>
      type != null && type!.isNotEmpty ? '$title • $type' : title;
}
