import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../data/models/episode_group_model.dart';
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
  final List<EpisodeGroup> _episodeGroups = <EpisodeGroup>[];
  bool _episodeGroupsLoading = false;
  String? _episodeGroupsError;
  String? _selectedEpisodeGroupId;

  TVDetailed? get details => _details;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  int? get selectedSeasonNumber => _selectedSeasonNumber;

  List<Season> get seasons => _details?.seasons ?? const [];

  UnmodifiableListView<EpisodeGroup> get episodeGroups =>
      UnmodifiableListView<EpisodeGroup>(_episodeGroups);

  bool get isEpisodeGroupsLoading => _episodeGroupsLoading;

  String? get episodeGroupsError => _episodeGroupsError;

  String? get selectedEpisodeGroupId => _selectedEpisodeGroupId;

  EpisodeGroup? get selectedEpisodeGroup {
    if (_episodeGroups.isEmpty) {
      return null;
    }
    if (_selectedEpisodeGroupId == null) {
      return _episodeGroups.first;
    }
    for (final group in _episodeGroups) {
      if (group.id == _selectedEpisodeGroupId) {
        return group;
      }
    }
    return _episodeGroups.first;
  }

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
      _episodeGroups.clear();
      _episodeGroupsError = null;
      _selectedEpisodeGroupId = null;

      _selectedSeasonNumber = _resolveInitialSeasonNumber(details);
      notifyListeners();

      final selected = _selectedSeasonNumber;
      if (selected != null) {
        unawaited(_ensureSeasonLoaded(selected));
        unawaited(_ensureSeasonImagesLoaded(selected));
      }
      unawaited(_loadEpisodeGroups());
    } catch (error) {
      _errorMessage = _mapError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => load(forceRefresh: true);

  /// Forces a reload of episode groups from TMDB.
  Future<void> refreshEpisodeGroups() =>
      _loadEpisodeGroups(forceRefresh: true);

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

  /// Updates the currently active alternative order by identifier.
  void selectEpisodeGroup(String groupId) {
    if (_selectedEpisodeGroupId == groupId) {
      return;
    }
    final hasMatch = _episodeGroups.any((group) => group.id == groupId);
    if (!hasMatch) {
      return;
    }
    _selectedEpisodeGroupId = groupId;
    notifyListeners();
  }

  /// Re-attempts loading episode groups after a failure.
  Future<void> retryEpisodeGroups() =>
      _loadEpisodeGroups(forceRefresh: true);

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

  /// Loads alternative episode orderings from TMDB.
  ///
  /// The provider first calls `GET /3/tv/$tvId/episode_groups` to obtain the
  /// available group identifiers, then hydrates every entry with
  /// `GET /3/tv/episode_group/{id}` which returns the JSON payload describing
  /// the nested collections and episodes.
  Future<void> _loadEpisodeGroups({bool forceRefresh = false}) async {
    if (_episodeGroupsLoading && !forceRefresh) {
      return;
    }

    if (!forceRefresh && _episodeGroups.isNotEmpty) {
      return;
    }

    _episodeGroupsLoading = true;
    if (forceRefresh) {
      _episodeGroupsError = null;
    }
    notifyListeners();

    try {
      final groups = await _repository.fetchTvEpisodeGroups(
        tvId,
        forceRefresh: forceRefresh,
      );
      _episodeGroups
        ..clear()
        ..addAll(groups);
      if (_episodeGroups.isNotEmpty) {
        if (_selectedEpisodeGroupId == null ||
            !_episodeGroups.any((group) => group.id == _selectedEpisodeGroupId)) {
          _selectedEpisodeGroupId = _episodeGroups.first.id;
        }
      } else {
        _selectedEpisodeGroupId = null;
      }
      _episodeGroupsError = null;
    } catch (error) {
      _episodeGroups
        ..clear();
      _episodeGroupsError = _mapError(error);
      _selectedEpisodeGroupId = null;
    } finally {
      _episodeGroupsLoading = false;
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
