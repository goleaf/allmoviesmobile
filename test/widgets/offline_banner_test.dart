import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart' as legacy_provider;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:allmovies_mobile/data/models/saved_media_item.dart';
import 'package:allmovies_mobile/data/services/offline_service.dart';
import 'package:allmovies_mobile/providers/offline_provider.dart';
import 'package:allmovies_mobile/presentation/widgets/offline_banner.dart';

import '../test_support/fakes.dart';
import '../test_support/test_wrapper.dart';

class _RecordingOfflineService extends OfflineService {
  _RecordingOfflineService({required SharedPreferences prefs})
      : super(prefs: prefs);

  int syncCallCount = 0;

  @override
  Future<int> syncPendingActions() async {
    syncCallCount++;
    final pending = await getPendingSyncTasks();
    // Keep the queue intact so the banner continues to show a syncing state
    // until tests explicitly flush it.
    return pending.length;
  }

  Future<int> completeSync() => super.syncPendingActions();
}

SavedMediaItem _offlineItem(int id) {
  return SavedMediaItem(
    id: id,
    type: SavedMediaType.movie,
    title: 'Offline $id',
    releaseDate: '2024-02-02',
    posterPath: '/offline_$id.jpg',
  );
}

Future<void> _waitFor(bool Function() predicate,
    {Duration timeout = const Duration(seconds: 2)}) async {
  final deadline = DateTime.now().add(timeout);
  while (!predicate()) {
    if (DateTime.now().isAfter(deadline)) {
      throw TimeoutException('Condition not met before $timeout elapsed');
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('OfflineBanner reflects offline and syncing states', (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    final service = _RecordingOfflineService(prefs: prefs);
    final connectivity = FakeConnectivity(ConnectivityResult.none);
    final provider = OfflineProvider(service, connectivity: connectivity);
    addTearDown(() {
      provider.dispose();
      connectivity.dispose();
    });

    await pumpTestApp(
      tester,
      legacy_provider.ChangeNotifierProvider<OfflineProvider>.value(
        value: provider,
        child: const OfflineBanner(),
      ),
      settle: false,
    );

    await tester.runAsync(() async {
      await _waitFor(() => provider.isInitialized);
    });
    await tester.pumpAndSettle();

    expect(find.text('Offline mode: showing cached data'), findsOneWidget);

    // Queue a pending action so the banner can surface the syncing message
    // when connectivity returns.
    await tester.runAsync(() async {
      final snapshot = _offlineItem(42);
      await service.recordWatchlistMutation(
        mediaId: snapshot.id,
        mediaType: snapshot.type,
        added: true,
        snapshot: snapshot,
      );
      await _waitFor(() => provider.pendingTasks.isNotEmpty);
    });

    connectivity.emit(ConnectivityResult.wifi);
    await tester.pumpAndSettle();

    expect(
      find.text('Back online! Syncing offline actions…'),
      findsOneWidget,
    );
    await tester.tap(find.text('Sync now'));
    await tester.pump();
    expect(service.syncCallCount, 1);

    // Complete the sync and verify the banner can disappear once no work
    // remains pending.
    await tester.runAsync(() async {
      await service.completeSync();
    });
    connectivity.emit(ConnectivityResult.wifi);
    await tester.pumpAndSettle();
    expect(find.text('Back online! Syncing offline actions…'), findsNothing);
  });
}
