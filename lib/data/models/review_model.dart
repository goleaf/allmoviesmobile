import 'package:freezed_annotation/freezed_annotation.dart';

part 'review_model.freezed.dart';
part 'review_model.g.dart';

/// Review author details
@freezed
class ReviewAuthor with _$ReviewAuthor {
  const factory ReviewAuthor({
    required String name,
    required String username,
    @JsonKey(name: 'avatar_path') String? avatarPath,
    double? rating,
  }) = _ReviewAuthor;

  factory ReviewAuthor.fromJson(Map<String, dynamic> json) =>
      _$ReviewAuthorFromJson(json);
}

/// Review model
@freezed
class Review with _$Review {
  const factory Review({
    required String id,
    required String author,
    @JsonKey(name: 'author_details') required ReviewAuthor authorDetails,
    required String content,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
    String? url,
  }) = _Review;

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);
}
