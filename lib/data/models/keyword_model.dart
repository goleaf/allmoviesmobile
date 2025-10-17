import 'package:freezed_annotation/freezed_annotation.dart';

part 'keyword_model.freezed.dart';
part 'keyword_model.g.dart';

/// Keyword model
@freezed
class Keyword with _$Keyword {
  const factory Keyword({required int id, required String name}) = _Keyword;

  factory Keyword.fromJson(Map<String, dynamic> json) =>
      _$KeywordFromJson(json);
}

/// Keyword details with additional information
@freezed
class KeywordDetails with _$KeywordDetails {
  const factory KeywordDetails({required int id, required String name}) =
      _KeywordDetails;

  factory KeywordDetails.fromJson(Map<String, dynamic> json) =>
      _$KeywordDetailsFromJson(json);
}
