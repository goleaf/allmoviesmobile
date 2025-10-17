import 'package:freezed_annotation/freezed_annotation.dart';

part 'change_model.freezed.dart';
part 'change_model.g.dart';

/// Change item value
@freezed
class ChangeValue with _$ChangeValue {
  const factory ChangeValue({dynamic value}) = _ChangeValue;

  factory ChangeValue.fromJson(Map<String, dynamic> json) =>
      _$ChangeValueFromJson(json);
}

/// Change item
@freezed
class ChangeItem with _$ChangeItem {
  const factory ChangeItem({
    required String id,
    required String action,
    required String time,
    @JsonKey(name: 'iso_639_1') String? language,
    @JsonKey(name: 'iso_3166_1') String? country,
    dynamic value,
    @JsonKey(name: 'original_value') dynamic originalValue,
  }) = _ChangeItem;

  factory ChangeItem.fromJson(Map<String, dynamic> json) =>
      _$ChangeItemFromJson(json);
}

/// Change entry
@freezed
class Change with _$Change {
  const factory Change({
    required String key,
    @Default([]) List<ChangeItem> items,
  }) = _Change;

  factory Change.fromJson(Map<String, dynamic> json) => _$ChangeFromJson(json);
}

/// Changes response
@freezed
class ChangesResponse with _$ChangesResponse {
  const factory ChangesResponse({@Default([]) List<Change> changes}) =
      _ChangesResponse;

  factory ChangesResponse.fromJson(Map<String, dynamic> json) =>
      _$ChangesResponseFromJson(json);
}
