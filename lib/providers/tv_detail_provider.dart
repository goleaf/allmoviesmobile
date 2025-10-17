import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/models/episode_group_model.dart';
import '../data/models/episode_model.dart';
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
  List<EpisodeGroup> _episodeGroups = const <EpisodeGroup>[];
  bool _episodeGroupsLoading = false;
  String? _episodeGroupsError;
  String? _selectedEpisodeGroupId;

  TVDetailed? get details => _details;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int? get selectedSeasonNumber => _selectedSeasonNumber;

  List<Season> get seasons => _details?.seasons ?? const [];

  List<EpisodeGroup> get episodeGroups => _episodeGroups;
  bool get areEpisodeGroupsLoading => _episodeGroupsLoading;
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

  List<EpisodeGroupNode> get selectedEpisodeGroupNodes =>
      selectedEpisodeGroup?.groups ?? const <EpisodeGroupNode>[];

  Season? seasonForNumber(int? seasonNumber) {
    if (seasonNumber == null) {
      return null;
    }
    return _seasonDetails[seasonNumber] ?? _findSeason(seasonNumber);
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

  Future<void> load({bool forceRefresh = false}) async {
    if (_isLoading && !forceRefresh) {
      return;
    }

    _isLoading = true;
    if (forceRefresh) {
      _errorMessage = null;
    }
    notifyListeners();

    final episodeGroupsFuture =
        _loadEpisodeGroups(forceRefresh: forceRefresh);

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

      _selectedSeasonNumber = _resolveInitialSeasonNumber(details);
      notifyListeners();

      final selected = _selectedSeasonNumber;
      if (selected != null) {
        unawaited(_ensureSeasonLoaded(selected));
      }
    } catch (error) {
      _errorMessage = _mapError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    await episodeGroupsFuture;
  }

  Future<void> refresh() => load(forceRefresh: true);

  Future<void> selectSeason(int seasonNumber) async {
    if (_selectedSeasonNumber == seasonNumber) {
      return;
    }
    _selectedSeasonNumber = seasonNumber;
    notifyListeners();
    await _ensureSeasonLoaded(seasonNumber);
  }

  Future<void> retrySeason(int seasonNumber) =>
      _ensureSeasonLoaded(seasonNumber, forceRefresh: true);

  Future<void> retryEpisodeGroups() =>
      _loadEpisodeGroups(forceRefresh: true);

  void selectEpisodeGroup(String groupId) {
    if (_selectedEpisodeGroupId == groupId) {
      return;
    }
    if (!_episodeGroups.any((group) => group.id == groupId)) {
      return;
    }
    _selectedEpisodeGroupId = groupId;
    notifyListeners();
  }

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

  Future<void> _loadEpisodeGroups({bool forceRefresh = false}) async {
    if (_episodeGroupsLoading && !forceRefresh) {
      return;
    }

    if (forceRefresh) {
      _episodeGroups = const <EpisodeGroup>[];
      _selectedEpisodeGroupId = null;
      _episodeGroupsError = null;
    }

    _episodeGroupsLoading = true;
    notifyListeners();

    try {
      final groups = await _repository.fetchTvEpisodeGroups(
        tvId,
        forceRefresh: forceRefresh,
      );
      _episodeGroups = groups;
      _episodeGroupsError = null;
      _selectedEpisodeGroupId =
          _resolveEpisodeGroupSelection(_selectedEpisodeGroupId, groups);
    } catch (error) {
      _episodeGroupsError = _mapError(error);
      if (_episodeGroups.isEmpty) {
        _selectedEpisodeGroupId = null;
      } else {
        _selectedEpisodeGroupId = _resolveEpisodeGroupSelection(
          _selectedEpisodeGroupId,
          _episodeGroups,
        );
      }
    } finally {
      _episodeGroupsLoading = false;
      notifyListeners();
    }
  }

  String? _resolveEpisodeGroupSelection(
    String? currentSelection,
    List<EpisodeGroup> groups,
  ) {
    if (groups.isEmpty) {
      return null;
    }
    if (currentSelection != null) {
      for (final group in groups) {
        if (group.id == currentSelection) {
          return group.id;
        }
      }
    }
    return groups.first.id;
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
