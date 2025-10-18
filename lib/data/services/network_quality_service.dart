import 'dart:async';

import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

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
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Timer? _probeTimer;
  Duration? _lastLatency;

  NetworkQuality get quality => _quality;
  Duration? get lastLatency => _lastLatency;

  /// Initialize connectivity listener and start TMDB latency probes.
  Future<void> initialize() async {
    final results = await _connectivity.checkConnectivity();
    _updateQuality(results);
    _subscription ??=
        _connectivity.onConnectivityChanged.listen(_updateQuality);
    _probeTimer?.cancel();
    _probeTimer = Timer.periodic(_probeInterval, (timer) async {
      await refreshQuality(timeout: _probeTimeout);
    });
    await refreshQuality();
    _probeTimer?.cancel();
    _probeTimer = Timer.periodic(
      _probeInterval,
      (_) => refreshQuality(timeout: _probeTimeout),
    );
  }

  void _updateQuality(List<ConnectivityResult> results) {
    final result = results.isNotEmpty ? results.first : ConnectivityResult.none;
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

  Future<void> refreshQuality({Duration timeout = const Duration(seconds: 3)}) async {
    if (_quality == NetworkQuality.offline) {
      _lastLatency = null;
      return;
    }

    final stopwatch = Stopwatch()..start();
    try {
      final response = await http.get(
        Uri.parse('https://image.tmdb.org'),
      ).timeout(timeout);
      stopwatch.stop();
      if (response.statusCode < 500) {
        _lastLatency = stopwatch.elapsed;
        _reconcileLatency(_lastLatency!);
      }
    } on SocketException {
      _updateQuality([ConnectivityResult.none]);
    } on TimeoutException {
      _updateQuality([ConnectivityResult.other]);
    } catch (_) {
      // Ignore, keep previous quality
    }
  }

  void _reconcileLatency(Duration latency) {
    final milliseconds = latency.inMilliseconds;
    NetworkQuality inferred;
    if (milliseconds <= 120) {
      inferred = NetworkQuality.excellent;
    } else if (milliseconds <= 300) {
      inferred = NetworkQuality.balanced;
    } else {
      inferred = NetworkQuality.constrained;
    }

    if (inferred != _quality && _quality != NetworkQuality.offline) {
      _quality = inferred;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _probeTimer?.cancel();
    _probeTimer = null;
    _client.close();
    super.dispose();
  }
}
