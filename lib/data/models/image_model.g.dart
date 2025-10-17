// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ImageModelImpl _$$ImageModelImplFromJson(Map<String, dynamic> json) =>
    _$ImageModelImpl(
      filePath: json['file_path'] as String,
      width: (json['width'] as num).toInt(),
      height: (json['height'] as num).toInt(),
      aspectRatio: (json['aspect_ratio'] as num).toDouble(),
      voteAverage: (json['vote_average'] as num?)?.toDouble(),
      voteCount: (json['vote_count'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$ImageModelImplToJson(_$ImageModelImpl instance) =>
    <String, dynamic>{
      'file_path': instance.filePath,
      'width': instance.width,
      'height': instance.height,
      'aspect_ratio': instance.aspectRatio,
      'vote_average': instance.voteAverage,
      'vote_count': instance.voteCount,
    };
