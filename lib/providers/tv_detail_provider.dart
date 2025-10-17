import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/models/episode_model.dart';
import '../data/models/media_images.dart';
import '../data/models/season_model.dart';
import '../data/models/tv_detailed_model.dart';
import '../data/tmdb_repository.dart';

class TvDetailProvider extends ChangeNotifier {
  TvDetailProvider(this._repository, {required this.tvId});

  final TmdbRepository _repository;
  final int tvId;

  TVDetailed? _details;
  bool _isLoading = false;
  String? _errorMessage;
  int? _selectedSeasonNumber;
  final Map<int, Season> _seasonDetails = <int, Season>{};
  final Set<int> _loadingSeasons = <int>{};
  final Map<int, String> _seasonErrors = <int, String>{};
  final Map<int, MediaImages> _seasonImages = <int, MediaImages>{};
  final Set<int> _loadingSeasonImages = <int>{};
  final Map<int, String> _seasonImageErrors = <int, String>{};

  TVDetailed? get details => _details;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int? get selectedSeasonNumber => _selectedSeasonNumber;

  List<Season> get seasons => _details?.seasons ?? const [];

  Season? seasonForNumber(int? seasonNumber) {
    if (seasonNumber == null) {
      return null;
    }
    return _seasonDetails[seasonNumber] ?? _findSeason(seasonNumber);
  }

  MediaImages? seasonImagesForNumber(int? seasonNumber) {
    if (seasonNumber == null) {
      return null;
    }
    return _seasonImages[seasonNumber];
  }

  List<Episode> episodesForSeason(int? seasonNumber) {
    final season = seasonForNumber(seasonNumber);
    if (season == null) {
      return const [];
    }
    return season.episodes;
  }

  bool isSeasonLoading(int seasonNumber) =>
      _loadingSeasons.contains(seasonNumber);

  String? seasonError(int seasonNumber) => _seasonErrors[seasonNumber];

  bool isSeasonImagesLoading(int seasonNumber) =>
      _loadingSeasonImages.contains(seasonNumber);

  String? seasonImagesError(int seasonNumber) =>
      _seasonImageErrors[seasonNumber];

  Future<void> load({bool forceRefresh = false}) async {
    if (_isLoading && !forceRefresh) {
      return;
    }

    _isLoading = true;
    if (forceRefresh) {
      _errorMessage = null;
    }
    notifyListeners();

    try {
      final details = await _repository.fetchTvDetails(
        tvId,
        forceRefresh: forceRefresh,
      );

      _details = details;
      _errorMessage = null;
      _seasonDetails.clear();
      _seasonErrors.clear();
      _loadingSeasons.clear();
      _seasonImages.clear();
      _seasonImageErrors.clear();
      _loadingSeasonImages.clear();

      _selectedSeasonNumber = _resolveInitialSeasonNumber(details);
      notifyListeners();

      final selected = _selectedSeasonNumber;
      if (selected != null) {
        unawaited(_ensureSeasonLoaded(selected));
        unawaited(_ensureSeasonImagesLoaded(selected));
      }
    } catch (error) {
      _errorMessage = _mapError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => load(forceRefresh: true);

  Future<void> selectSeason(int seasonNumber) async {
    if (_selectedSeasonNumber == seasonNumber) {
      return;
    }
    _selectedSeasonNumber = seasonNumber;
    notifyListeners();
    await Future.wait<void>([
      _ensureSeasonLoaded(seasonNumber),
      _ensureSeasonImagesLoaded(seasonNumber),
    ]);
  }

  Future<void> retrySeason(int seasonNumber) =>
      _ensureSeasonLoaded(seasonNumber, forceRefresh: true);

  Future<void> retrySeasonImages(int seasonNumber) =>
      _ensureSeasonImagesLoaded(seasonNumber, forceRefresh: true);

  Future<void> _ensureSeasonLoaded(
    int seasonNumber, {
    bool forceRefresh = false,
  }) async {
    if (_loadingSeasons.contains(seasonNumber)) {
      return;
    }

    final cached = _seasonDetails[seasonNumber];
    if (!forceRefresh && cached != null && cached.episodes.isNotEmpty) {
      return;
    }

    _loadingSeasons.add(seasonNumber);
    _seasonErrors.remove(seasonNumber);
    notifyListeners();

    try {
      final season = await _repository.fetchTvSeason(
        tvId,
        seasonNumber,
        forceRefresh: forceRefresh,
      );
      _seasonDetails[seasonNumber] = season;
      _mergeSeasonIntoDetails(season);
    } catch (error) {
      _seasonErrors[seasonNumber] = _mapError(error);
    } finally {
      _loadingSeasons.remove(seasonNumber);
      notifyListeners();
    }
  }

  Future<void> _ensureSeasonImagesLoaded(
    int seasonNumber, {
    bool forceRefresh = false,
  }) async {
    if (_loadingSeasonImages.contains(seasonNumber)) {
      return;
    }

    final cached = _seasonImages[seasonNumber];
    if (!forceRefresh && cached != null) {
      return;
    }

    _loadingSeasonImages.add(seasonNumber);
    _seasonImageErrors.remove(seasonNumber);
    notifyListeners();

    try {
      final images = await _repository.fetchTvSeasonImages(
        tvId,
        seasonNumber,
        forceRefresh: forceRefresh,
      );
      _seasonImages[seasonNumber] = images;
    } catch (error) {
      _seasonImageErrors[seasonNumber] = _mapError(error);
    } finally {
      _loadingSeasonImages.remove(seasonNumber);
      notifyListeners();
    }
  }

  void _mergeSeasonIntoDetails(Season season) {
    final currentDetails = _details;
    if (currentDetails == null) {
      return;
    }

    final updatedSeasons = currentDetails.seasons
        .map((existing) {
          if (existing.seasonNumber == season.seasonNumber) {
            return season;
          }
          return existing;
        })
        .toList(growable: false);

    _details = currentDetails.copyWith(seasons: updatedSeasons);
  }

  int? _resolveInitialSeasonNumber(TVDetailed details) {
    final seasons = List<Season>.of(details.seasons);
    if (seasons.isEmpty) {
      return null;
    }

    seasons.sort((a, b) => a.seasonNumber.compareTo(b.seasonNumber));
    for (final season in seasons) {
      final episodeCount = season.episodeCount ?? season.episodes.length;
      if (season.seasonNumber > 0 && episodeCount > 0) {
        return season.seasonNumber;
      }
    }
    return seasons.first.seasonNumber;
  }

  Season? _findSeason(int seasonNumber) {
    final list = _details?.seasons ?? const [];
    for (final season in list) {
      if (season.seasonNumber == seasonNumber) {
        return season;
      }
    }
    return null;
  }

  String _mapError(Object error) {
    if (error is TmdbException) {
      return error.message;
    }
    return error.toString();
  }
}
