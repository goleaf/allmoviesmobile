import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../core/config/app_config.dart';

enum NetworkQuality { offline, constrained, balanced, excellent }

/// Observes connectivity changes, probes TMDB latency periodically, and
/// exposes a coarse network quality metric for adaptive throttling.
class NetworkQualityNotifier extends ChangeNotifier {
  NetworkQualityNotifier({
    Connectivity? connectivity,
    http.Client? client,
    Duration probeInterval = const Duration(seconds: 45),
    Duration probeTimeout = const Duration(seconds: 3),
  })  : _connectivity = connectivity ?? Connectivity(),
        _client = client ?? http.Client(),
        _probeInterval = probeInterval,
        _probeTimeout = probeTimeout;

  final Connectivity _connectivity;
  final http.Client _client;
  final Duration _probeInterval;
  final Duration _probeTimeout;
  NetworkQuality _quality = NetworkQuality.excellent;
  StreamSubscription<ConnectivityResult>? _subscription;
  Timer? _probeTimer;
  double? _lastLatencyMs;

  NetworkQuality get quality => _quality;
  double? get lastLatencyMs => _lastLatencyMs;

  /// Initialize connectivity listener and start TMDB latency probes.
  Future<void> initialize() async {
    final result = await _connectivity.checkConnectivity();
    _updateQuality(result);
    _subscription ??=
        _connectivity.onConnectivityChanged.listen(_updateQuality);
    _startProbeTimer();
  }

  /// Issue a small authenticated request against `/3/configuration` to measure
  /// response latency. The endpoint returns global CDN metadata and is safe to
  /// call frequently; the JSON payload resembles:
  /// `{ "images": { "secure_base_url": "https://image.tmdb.org/t/p/" }, "change_keys": [] }`.
  Future<void> probeLatency() async {
    // Skip probes when offline to avoid unnecessary work.
    if (_quality == NetworkQuality.offline) {
      return;
    }

    final apiKey = AppConfig.tmdbApiKey;
    if (apiKey.isEmpty) {
      return;
    }

    final stopwatch = Stopwatch()..start();
    try {
      final uri = Uri.https('api.themoviedb.org', '/3/configuration', {
        'api_key': apiKey,
      });
      final response = await _client
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(_probeTimeout);
      stopwatch.stop();
      if (response.statusCode == 200) {
        _lastLatencyMs = stopwatch.elapsedMicroseconds / 1000;
        _updateQualityFromLatency();
      } else {
        _downgradeQuality();
      }
    } catch (_) {
      stopwatch.stop();
      _downgradeQuality();
    }
  }

  void _startProbeTimer() {
    _probeTimer?.cancel();
    _probeTimer = Timer.periodic(_probeInterval, (_) {
      unawaited(probeLatency());
    });
    // Kick off the first probe eagerly so UI can adapt immediately.
    unawaited(probeLatency());
  }

  void _updateQuality(ConnectivityResult result) {
    final nextQuality = switch (result) {
      ConnectivityResult.none => NetworkQuality.offline,
      ConnectivityResult.bluetooth => NetworkQuality.constrained,
      ConnectivityResult.vpn => _quality,
      ConnectivityResult.other => NetworkQuality.balanced,
      ConnectivityResult.wifi => NetworkQuality.excellent,
      ConnectivityResult.ethernet => NetworkQuality.excellent,
      ConnectivityResult.mobile => NetworkQuality.balanced,
    };

    if (nextQuality != _quality) {
      _quality = nextQuality;
      notifyListeners();
    }
  }

  void _updateQualityFromLatency() {
    final latency = _lastLatencyMs;
    if (latency == null) {
      return;
    }

    final candidate = () {
      if (latency > 1200) {
        return NetworkQuality.constrained;
      }
      if (latency > 600) {
        return NetworkQuality.balanced;
      }
      return NetworkQuality.excellent;
    }();

    if (candidate != _quality && _quality != NetworkQuality.offline) {
      _quality = candidate;
      notifyListeners();
    }
  }

  void _downgradeQuality() {
    if (_quality == NetworkQuality.offline) {
      return;
    }
    final downgraded = _quality == NetworkQuality.excellent
        ? NetworkQuality.balanced
        : NetworkQuality.constrained;
    if (downgraded != _quality) {
      _quality = downgraded;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _probeTimer?.cancel();
    _client.close();
    super.dispose();
  }
}
