import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/models/media_images.dart';
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
  bool _isLoading = false;
  String? _errorMessage;
  MediaImages? _images;
  bool _isImagesLoading = false;
  String? _imagesError;

  Season? get season => _season;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  MediaImages? get images => _images;
  bool get isImagesLoading => _isImagesLoading;
  String? get imagesError => _imagesError;

  Future<void> load({bool forceRefresh = false}) async {
    await Future.wait<void>([
      _loadSeason(forceRefresh: forceRefresh),
      loadImages(forceRefresh: forceRefresh),
    ]);
  }

  Future<void> loadImages({bool forceRefresh = false}) async {
    if (_isImagesLoading) return;
    if (!forceRefresh && _images != null) return;

    _isImagesLoading = true;
    _imagesError = null;
    notifyListeners();

    try {
      final loaded = await _repository.fetchTvSeasonImages(
        tvId,
        seasonNumber,
        forceRefresh: forceRefresh,
      );
      _images = loaded;
    } catch (e) {
      _imagesError = e.toString();
    } finally {
      _isImagesLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadSeason({bool forceRefresh = false}) async {
    if (_isLoading) return;
    if (!forceRefresh && _season != null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final loaded = await _repository.fetchTvSeason(
        tvId,
        seasonNumber,
        forceRefresh: forceRefresh,
      );
      _season = loaded;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
