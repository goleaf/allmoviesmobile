import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:allmovies_mobile/data/services/local_storage_service.dart';
import 'package:allmovies_mobile/data/services/offline_service.dart';
import 'package:allmovies_mobile/data/services/network_quality_service.dart';
import 'package:allmovies_mobile/main.dart';

import '../test_support/fakes.dart';

class _TestNetworkQualityNotifier extends NetworkQualityNotifier {
  bool disposed = false;

  @override
  Future<void> initialize() async {
    // Do nothing to avoid network and platform channel usage in tests.
  }

  @override
  void dispose() {
    disposed = true;
    super.dispose();
  }
}

void main() {
  testWidgets('disposes network quality notifier when AllMoviesApp is removed',
      (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    final storageService = LocalStorageService(prefs);
    final offlineService = OfflineService(prefs: prefs);
    final notifier = _TestNetworkQualityNotifier();

    await notifier.initialize();

    await tester.pumpWidget(
      AllMoviesApp(
        storageService: storageService,
        prefs: prefs,
        offlineService: offlineService,
        tmdbRepository: FakeTmdbRepository(),
        networkQualityNotifier: notifier,
      ),
    );

    await tester.pump();
    expect(notifier.disposed, isFalse);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();

    expect(notifier.disposed, isTrue);
  });
}
