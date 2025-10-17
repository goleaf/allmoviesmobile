import 'dart:async';

import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

enum NetworkQuality { offline, constrained, balanced, excellent }

/// Observes connectivity changes and exposes a coarse network quality metric.
class NetworkQualityNotifier extends ChangeNotifier {
  NetworkQualityNotifier({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;
  NetworkQuality _quality = NetworkQuality.excellent;
  StreamSubscription<ConnectivityResult>? _subscription;
  Duration? _lastLatency;

  NetworkQuality get quality => _quality;
  Duration? get lastLatency => _lastLatency;

  Future<void> initialize() async {
    final result = await _connectivity.checkConnectivity();
    _updateQuality(result);
    _subscription ??=
        _connectivity.onConnectivityChanged.listen(_updateQuality);
    await refreshQuality();
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
      _updateQuality(ConnectivityResult.none);
    } on TimeoutException {
      _updateQuality(ConnectivityResult.other);
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
    super.dispose();
  }
}
