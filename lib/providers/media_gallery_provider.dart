import 'package:flutter/foundation.dart';

import '../data/models/media_images.dart';
import '../data/tmdb_repository.dart';

enum MediaGalleryType { movie, tv }

class MediaGalleryProvider extends ChangeNotifier {
  MediaGalleryProvider(this._repository);

  final TmdbRepository _repository;

  MediaImages? _images;
  bool _isLoading = false;
  String? _errorMessage;
  int? _mediaId;
  MediaGalleryType? _mediaType;

  MediaImages? get images => _images;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  MediaGalleryType? get mediaType => _mediaType;

  Future<void> loadMovieImages(int movieId, {bool forceRefresh = false}) async {
    await _load(
      id: movieId,
      type: MediaGalleryType.movie,
      forceRefresh: forceRefresh,
      loader: () =>
          _repository.fetchMovieImages(movieId, forceRefresh: forceRefresh),
    );
  }

  Future<void> loadTvImages(int tvId, {bool forceRefresh = false}) async {
    await _load(
      id: tvId,
      type: MediaGalleryType.tv,
      forceRefresh: forceRefresh,
      loader: () => _repository.fetchTvImages(tvId, forceRefresh: forceRefresh),
    );
  }

  Future<void> refresh() async {
    final id = _mediaId;
    final type = _mediaType;
    if (id == null || type == null) {
      return;
    }

    switch (type) {
      case MediaGalleryType.movie:
        await loadMovieImages(id, forceRefresh: true);
        break;
      case MediaGalleryType.tv:
        await loadTvImages(id, forceRefresh: true);
        break;
    }
  }

  Future<void> _load({
    required int id,
    required MediaGalleryType type,
    required bool forceRefresh,
    required Future<MediaImages> Function() loader,
  }) async {
    if (!forceRefresh &&
        _mediaId == id &&
        _mediaType == type &&
        _images != null) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await loader();
      _images = data;
      _mediaId = id;
      _mediaType = type;
    } catch (error, stackTrace) {
      debugPrint('Failed to load media images: $error');
      debugPrintStack(stackTrace: stackTrace);
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
