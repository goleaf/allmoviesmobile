import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_async/fake_async.dart';

import 'package:allmovies_mobile/data/services/network_quality_service.dart';

import '../test_support/fakes.dart';

class _TestNetworkQualityNotifier extends NetworkQualityNotifier {
  _TestNetworkQualityNotifier(
    Connectivity connectivity, {
    Duration probeInterval = const Duration(seconds: 45),
    Duration probeTimeout = const Duration(seconds: 3),
  }) : super(
          connectivity: connectivity,
          probeInterval: probeInterval,
          probeTimeout: probeTimeout,
        );

  int refreshInvocations = 0;

  @override
  Future<void> refreshQuality({Duration timeout = const Duration(seconds: 3)}) async {
    refreshInvocations++;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('initialize reads initial connectivity and triggers refresh', () async {
    final connectivity = FakeConnectivity(ConnectivityResult.none);
    final notifier = _TestNetworkQualityNotifier(connectivity);
    addTearDown(notifier.dispose);

    await notifier.initialize();

    expect(notifier.quality, NetworkQuality.offline);
    expect(notifier.lastLatency, isNull);
    expect(notifier.refreshInvocations, 1);
  });

  test('connectivity changes map to quality levels', () async {
    final connectivity = FakeConnectivity(ConnectivityResult.wifi);
    final notifier = _TestNetworkQualityNotifier(connectivity);
    addTearDown(notifier.dispose);

    await notifier.initialize();
    expect(notifier.quality, NetworkQuality.excellent);

    connectivity.emit(ConnectivityResult.mobile);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(notifier.quality, NetworkQuality.balanced);

    connectivity.emit(ConnectivityResult.bluetooth);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(notifier.quality, NetworkQuality.constrained);

    connectivity.emit(ConnectivityResult.none);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(notifier.quality, NetworkQuality.offline);
  });

  test('refreshQuality is invoked periodically on a timer', () {
    fakeAsync((async) {
      final connectivity = FakeConnectivity(ConnectivityResult.wifi);
      final notifier = _TestNetworkQualityNotifier(
        connectivity,
        probeInterval: const Duration(seconds: 5),
      );

      async.run((() async {
        await notifier.initialize();
      }));

      expect(notifier.refreshInvocations, 1);

      async.elapse(const Duration(seconds: 5));
      expect(notifier.refreshInvocations, 2);

      async.elapse(const Duration(seconds: 5));
      expect(notifier.refreshInvocations, 3);

      notifier.dispose();
    });
  });
}
