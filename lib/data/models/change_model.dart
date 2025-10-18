import 'package:flutter/foundation.dart';
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

/// Lightweight entry returned by the paginated change-list endpoints.
///
/// These payloads come from requests like `GET /3/movie/changes` and look like
/// the following:
/// ```json
/// {
///   "results": [
///     { "id": 120, "adult": false },
///     { "id": 680, "adult": false }
///   ],
///   "page": 1,
///   "total_pages": 338,
///   "total_results": 6752
/// }
/// ```
@immutable
class ChangeResource {
  const ChangeResource({
    required this.id,
    this.adult,
  });

  factory ChangeResource.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final parsedId = rawId is int
        ? rawId
        : int.tryParse('$rawId') ?? 0;

    return ChangeResource(
      id: parsedId,
      adult: json['adult'] as bool?,
    );
  }

  /// Numeric TMDB identifier for the resource that changed.
  final int id;

  /// Whether the item is marked as adult content.
  final bool? adult;
}
