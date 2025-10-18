import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart' as legacy_provider;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:allmovies_mobile/data/models/saved_media_item.dart';
import 'package:allmovies_mobile/data/services/offline_service.dart';
import 'package:allmovies_mobile/providers/offline_provider.dart';
import 'package:allmovies_mobile/presentation/widgets/offline_banner.dart';

import '../test/test_support/fakes.dart';
import '../test/test_support/test_wrapper.dart';

class _RecordingOfflineService extends OfflineService {
  _RecordingOfflineService({required SharedPreferences prefs})
      : super(prefs: prefs);

  int syncCallCount = 0;

  @override
  Future<int> syncPendingActions() async {
    syncCallCount++;
    final pending = await getPendingSyncTasks();
    return pending.length;
  }

  Future<int> flushQueue() => super.syncPendingActions();
}

SavedMediaItem _buildItem(int id) {
  return SavedMediaItem(
    id: id,
    type: SavedMediaType.movie,
    title: 'Queued $id',
    releaseDate: '2024-03-03',
  );
}

Future<void> _waitFor(bool Function() predicate) async {
  final deadline = DateTime.now().add(const Duration(seconds: 2));
  while (!predicate()) {
    if (DateTime.now().isAfter(deadline)) {
      throw TimeoutException('Condition not met within allotted time');
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Offline banner integrates with provider state changes', (tester) async {
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

    await tester.runAsync(() async {
      final snapshot = _buildItem(77);
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
    expect(find.text('Back online! Syncing offline actions…'), findsOneWidget);

    await tester.tap(find.text('Sync now'));
    await tester.pump();
    expect(service.syncCallCount, 1);

    await tester.runAsync(() async {
      await service.flushQueue();
    });
    connectivity.emit(ConnectivityResult.wifi);
    await tester.pumpAndSettle();
    expect(find.text('Back online! Syncing offline actions…'), findsNothing);
  });
}
