import 'package:flutter/foundation.dart';

import '../data/models/episode_model.dart';
import '../data/models/media_images.dart';
import '../data/models/image_model.dart';
import '../data/tmdb_repository.dart';

class EpisodeDetailProvider extends ChangeNotifier {
  EpisodeDetailProvider(
    this._repository, {
    required this.tvId,
    required this.seasonNumber,
    required this.episodeNumber,
    Episode? initialEpisode,
  })  : _episode = initialEpisode,
        _hasLoadedEpisode = initialEpisode != null;

  final TmdbRepository _repository;
  final int tvId;
  final int seasonNumber;
  final int episodeNumber;

  Episode? _episode;
  MediaImages? _images;
  bool _isLoadingEpisode = false;
  bool _isLoadingImages = false;
  bool _hasLoadedEpisode;
  bool _hasLoadedImages = false;
  String? _episodeError;
  String? _imagesError;

  Episode? get episode => _episode;
  MediaImages? get images => _images;
  String? get episodeError => _episodeError;
  String? get imagesError => _imagesError;
  bool get isLoadingEpisode => _isLoadingEpisode;
  bool get isLoadingImages => _isLoadingImages;
  bool get hasLoadedEpisode => _hasLoadedEpisode;
  bool get hasLoadedImages => _hasLoadedImages;
  bool get isPrimingEpisode => !_hasLoadedEpisode && _isLoadingEpisode;
  bool get shouldShowEpisodeError => !_hasLoadedEpisode && _episodeError != null;
  List<ImageModel> get stills => _images?.stills ?? const [];

  Future<void> load({bool forceRefresh = false}) async {
    await Future.wait<void>([
      _loadEpisode(forceRefresh: forceRefresh),
      _loadImages(forceRefresh: forceRefresh),
    ]);
  }

  Future<void> refresh() async {
    await load(forceRefresh: true);
  }

  Future<void> retryEpisode() => _loadEpisode(forceRefresh: true);

  Future<void> retryImages() => _loadImages(forceRefresh: true);

  Future<void> _loadEpisode({bool forceRefresh = false}) async {
    if (_isLoadingEpisode) {
      return;
    }
    if (!forceRefresh && _hasLoadedEpisode) {
      return;
    }

    _isLoadingEpisode = true;
    _episodeError = null;
    notifyListeners();

    try {
      final loaded = await _repository.fetchTvEpisode(
        tvId,
        seasonNumber,
        episodeNumber,
        forceRefresh: forceRefresh,
      );
      _episode = loaded;
      _hasLoadedEpisode = true;
    } catch (error, stackTrace) {
      debugPrint('Failed to load episode detail: $error');
      debugPrintStack(stackTrace: stackTrace);
      _episodeError = error.toString();
    } finally {
      _isLoadingEpisode = false;
      notifyListeners();
    }
  }

  Future<void> _loadImages({bool forceRefresh = false}) async {
    if (_isLoadingImages) {
      return;
    }
    if (!forceRefresh && _hasLoadedImages) {
      return;
    }

    _isLoadingImages = true;
    _imagesError = null;
    notifyListeners();

    try {
      final loaded = await _repository.fetchTvEpisodeImages(
        tvId,
        seasonNumber,
        episodeNumber,
        forceRefresh: forceRefresh,
      );
      _images = loaded;
      _hasLoadedImages = true;
    } catch (error, stackTrace) {
      debugPrint('Failed to load episode images: $error');
      debugPrintStack(stackTrace: stackTrace);
      _imagesError = error.toString();
    } finally {
      _isLoadingImages = false;
      notifyListeners();
    }
  }
}
