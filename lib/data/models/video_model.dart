import 'package:freezed_annotation/freezed_annotation.dart';

part 'video_model.freezed.dart';
part 'video_model.g.dart';

@freezed
class Video with _$Video {
  const factory Video({
    required String key,
    required String site,
    required String type,
    required String name,
    required bool official,
    @JsonKey(name: 'published_at') required String publishedAt,
  }) = _Video;

  factory Video.fromJson(Map<String, dynamic> json) => _$VideoFromJson(json);
}
