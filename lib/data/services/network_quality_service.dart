import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

enum NetworkQuality { offline, constrained, balanced, excellent }

/// Observes connectivity changes and exposes a coarse network quality metric.
class NetworkQualityNotifier extends ChangeNotifier {
  NetworkQualityNotifier({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;
  NetworkQuality _quality = NetworkQuality.excellent;
  StreamSubscription<ConnectivityResult>? _subscription;

  NetworkQuality get quality => _quality;

  Future<void> initialize() async {
    final result = await _connectivity.checkConnectivity();
    _updateQuality(result);
    _subscription ??=
        _connectivity.onConnectivityChanged.listen(_updateQuality);
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

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
