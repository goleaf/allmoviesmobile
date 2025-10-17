import 'package:freezed_annotation/freezed_annotation.dart';
import '../../core/utils/media_image_helper.dart';

part 'person_model.freezed.dart';
part 'person_model.g.dart';

@freezed
class Person with _$Person {
  const factory Person({
    required int id,
    required String name,
    @JsonKey(name: 'profile_path') String? profilePath,
    String? biography,
    @JsonKey(name: 'known_for_department') String? knownForDepartment,
    String? birthday,
    @JsonKey(name: 'place_of_birth') String? placeOfBirth,
    @JsonKey(name: 'also_known_as')
    @Default(<String>[])
    List<String> alsoKnownAs,
    double? popularity,
  }) = _Person;

  factory Person.fromJson(Map<String, dynamic> json) => _$PersonFromJson(json);
}

extension PersonExtensions on Person {
  String? get profileUrl => MediaImageHelper.buildUrl(
    profilePath,
    type: MediaImageType.profile,
    size: MediaImageSize.w500,
  );
}
