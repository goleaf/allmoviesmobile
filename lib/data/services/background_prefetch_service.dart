import 'dart:async';

import 'package:flutter/widgets.dart';

import '../tmdb_repository.dart';
import 'network_quality_service.dart';

/// Schedules opportunistic background fetches while the app is idle/resumed.
class BackgroundPrefetchService with WidgetsBindingObserver {
  BackgroundPrefetchService({
    required TmdbRepository repository,
    required NetworkQualityNotifier networkQualityNotifier,
    Duration idleDelay = const Duration(seconds: 5),
  })  : _repository = repository,
        _networkQualityNotifier = networkQualityNotifier,
        _idleDelay = idleDelay;

  final TmdbRepository _repository;
  final NetworkQualityNotifier _networkQualityNotifier;
  final Duration _idleDelay;

  Timer? _prefetchTimer;
  bool _isInitialized = false;
  bool _isPrefetching = false;

  void initialize() {
    if (_isInitialized) return;
    _isInitialized = true;
    WidgetsBinding.instance.addObserver(this);
    _schedulePrefetch();
  }

  void dispose() {
    if (!_isInitialized) return;
    WidgetsBinding.instance.removeObserver(this);
    _prefetchTimer?.cancel();
    _isInitialized = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _schedulePrefetch();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        _prefetchTimer?.cancel();
        break;
    }
  }

  void _schedulePrefetch() {
    _prefetchTimer?.cancel();
    _prefetchTimer = Timer(_idleDelay, _performPrefetch);
  }

  Future<void> _performPrefetch() async {
    if (_isPrefetching) {
      return;
    }
    if (_networkQualityNotifier.quality == NetworkQuality.offline) {
      return;
    }

    _isPrefetching = true;
    try {
      await Future.wait<void>([
        _repository.prefetchTrendingBundle(),
        _repository.prefetchMoviesDashboard(),
        _repository.prefetchSeriesDashboard(),
        _repository.prefetchPeopleSpotlight(),
      ]);
    } finally {
      _isPrefetching = false;
      _schedulePrefetch();
    }
  }
}
