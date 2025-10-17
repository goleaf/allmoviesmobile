import 'package:flutter/foundation.dart';

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

  Season? get season => _season;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> load({bool forceRefresh = false}) async {
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
