import 'package:flutter/foundation.dart';

import '../data/models/media_images.dart';
import '../data/models/image_model.dart';
import '../data/models/season_model.dart';
import '../data/tmdb_repository.dart';

class SeasonDetailProvider extends ChangeNotifier {
  SeasonDetailProvider(
    this._repository, {
    required this.tvId,
    required this.seasonNumber,
  });

  final TmdbRepository _repository;
  final int tvId;
  final int seasonNumber;

  Season? _season;
  MediaImages? _images;

  bool _isLoadingSeason = false;
  bool _isLoadingImages = false;
  bool _hasLoadedSeason = false;
  bool _hasLoadedImages = false;

  String? _seasonError;
  String? _imagesError;

  Season? get season => _season;
  MediaImages? get images => _images;

  List<ImageModel> get posters => _images?.posters ?? const [];
  List<ImageModel> get backdrops => _images?.backdrops ?? const [];

  bool get isLoadingSeason => _isLoadingSeason;
  bool get isLoadingImages => _isLoadingImages;
  bool get hasLoadedSeason => _hasLoadedSeason;
  bool get hasLoadedImages => _hasLoadedImages;

  bool get isPrimingSeason => !_hasLoadedSeason && _isLoadingSeason;
  bool get isPrimingImages => !_hasLoadedImages && _isLoadingImages;
  bool get showSeasonError => !_hasLoadedSeason && _seasonError != null;
  bool get showImagesError => !_hasLoadedImages && _imagesError != null;

  bool get isSeasonRefreshing => _isLoadingSeason && _hasLoadedSeason;

  String? get seasonError => _seasonError;
  String? get imagesError => _imagesError;

  bool get hasAnyImages => posters.isNotEmpty || backdrops.isNotEmpty;

  Future<void> load({bool forceRefresh = false}) async {
    await Future.wait<void>([
      _loadSeason(forceRefresh: forceRefresh),
      _loadImages(forceRefresh: forceRefresh),
    ]);
  }

  Future<void> refresh() => load(forceRefresh: true);

  Future<void> retrySeason() => _loadSeason(forceRefresh: true);

  Future<void> retryImages() => _loadImages(forceRefresh: true);

  Future<void> _loadSeason({bool forceRefresh = false}) async {
    if (_isLoadingSeason) return;
    if (!forceRefresh && _hasLoadedSeason) return;

    _isLoadingSeason = true;
    _seasonError = null;
    notifyListeners();

    try {
      final loaded = await _repository.fetchTvSeason(
        tvId,
        seasonNumber,
        forceRefresh: forceRefresh,
      );
      _season = loaded;
      _hasLoadedSeason = true;
      _seasonError = null;
    } catch (error, stackTrace) {
      debugPrint('Failed to load season detail: $error');
      debugPrintStack(stackTrace: stackTrace);
      _seasonError = error.toString();
    } finally {
      _isLoadingSeason = false;
      notifyListeners();
    }
  }

  Future<void> _loadImages({bool forceRefresh = false}) async {
    if (_isLoadingImages) return;
    if (!forceRefresh && _hasLoadedImages) return;

    _isLoadingImages = true;
    _imagesError = null;
    notifyListeners();

    try {
      final loaded = await _repository.fetchTvSeasonImages(
        tvId,
        seasonNumber,
        forceRefresh: forceRefresh,
      );
      _images = loaded;
      _hasLoadedImages = true;
      _imagesError = null;
    } catch (error, stackTrace) {
      debugPrint('Failed to load season images: $error');
      debugPrintStack(stackTrace: stackTrace);
      _imagesError = error.toString();
    } finally {
      _isLoadingImages = false;
      notifyListeners();
    }
  }
}
