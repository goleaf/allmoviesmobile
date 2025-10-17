import 'package:freezed_annotation/freezed_annotation.dart';

part 'network_model.freezed.dart';
part 'network_model.g.dart';

@freezed
class Network with _$Network {
  const factory Network({
    required int id,
    required String name,
    @JsonKey(name: 'logo_path') String? logoPath,
    @JsonKey(name: 'origin_country') String? originCountry,
  }) = _Network;

  factory Network.fromJson(Map<String, dynamic> json) =>
      _$NetworkFromJson(json);
}
