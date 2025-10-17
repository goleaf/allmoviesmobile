import 'dart:collection';

import 'image_model.dart';

class MediaImages {
  MediaImages({
    Iterable<ImageModel> posters = const [],
    Iterable<ImageModel> backdrops = const [],
    Iterable<ImageModel> stills = const [],
  })  : posters = List.unmodifiable(posters),
        backdrops = List.unmodifiable(backdrops),
        stills = List.unmodifiable(stills);

  MediaImages.empty()
      : posters = const UnmodifiableListView<ImageModel>([]),
        backdrops = const UnmodifiableListView<ImageModel>([]),
        stills = const UnmodifiableListView<ImageModel>([]);

  final List<ImageModel> posters;
  final List<ImageModel> backdrops;
  final List<ImageModel> stills;

  bool get hasAny =>
      posters.isNotEmpty || backdrops.isNotEmpty || stills.isNotEmpty;
}
