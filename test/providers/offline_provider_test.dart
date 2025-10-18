import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:allmovies_mobile/data/models/saved_media_item.dart';
import 'package:allmovies_mobile/data/services/offline_service.dart';
import 'package:allmovies_mobile/providers/offline_provider.dart';

import '../test_support/fakes.dart';

Future<void> _waitForCondition(
  bool Function() predicate, {
  Duration timeout = const Duration(seconds: 2),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (!predicate()) {
    if (DateTime.now().isAfter(deadline)) {
      throw TimeoutException('Condition not met within $timeout');
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

SavedMediaItem _buildItem(int id, {String title = 'Offline Seed'}) {
  return SavedMediaItem(
    id: id,
    type: SavedMediaType.movie,
    title: title,
    posterPath: '/poster_$id.jpg',
    releaseDate: '2024-01-01',
    voteAverage: 8.5,
    voteCount: 1200,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OfflineProvider', () {
    test('initializes offline with cached downloads and queued tasks', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final prefs = await SharedPreferences.getInstance();
      final service = OfflineService(prefs: prefs);
      final seedItem = _buildItem(7, title: 'Cached Film');

      // Seed the service before constructing the provider so initialization
      // picks up the cached download list and pending sync queue.
      await service.toggleDownloaded(seedItem);
      service.setOffline(true);
      await service.recordWatchlistMutation(
        mediaId: seedItem.id,
        mediaType: seedItem.type,
        added: true,
        snapshot: seedItem,
      );

      final connectivity = FakeConnectivity(ConnectivityResult.none);
      final provider = OfflineProvider(service, connectivity: connectivity);
      addTearDown(() {
        provider.dispose();
        connectivity.dispose();
      });

      await _waitForCondition(() => provider.isInitialized);

      expect(provider.isOffline, isTrue);
      expect(provider.downloadedItems.map((item) => item.id), contains(7));
      expect(provider.pendingTasks, isNotEmpty);
    });

    test('connectivity changes trigger sync and clear processed queue', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final prefs = await SharedPreferences.getInstance();
      final service = OfflineService(prefs: prefs);
      final connectivity = FakeConnectivity(ConnectivityResult.none);
      final provider = OfflineProvider(service, connectivity: connectivity);
      addTearDown(() {
        provider.dispose();
        connectivity.dispose();
      });

      await _waitForCondition(() => provider.isInitialized);
      expect(provider.isOffline, isTrue);

      final queued = _buildItem(11, title: 'Queued Entry');
      await service.recordWatchlistMutation(
        mediaId: queued.id,
        mediaType: queued.type,
        added: true,
        snapshot: queued,
      );
      await _waitForCondition(() => provider.pendingTasks.isNotEmpty);

      // Go back online and ensure pending queue is flushed.
      connectivity.emit(ConnectivityResult.wifi);
      await _waitForCondition(() => provider.isOffline == false);
      await _waitForCondition(() => provider.pendingTasks.isEmpty);
    });

    test('toggleDownload updates downloaded list and supports clearing data', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final prefs = await SharedPreferences.getInstance();
      final service = OfflineService(prefs: prefs);
      final connectivity = FakeConnectivity(ConnectivityResult.wifi);
      final provider = OfflineProvider(service, connectivity: connectivity);
      addTearDown(() {
        provider.dispose();
        connectivity.dispose();
      });

      await _waitForCondition(() => provider.isInitialized);

      final media = _buildItem(21, title: 'Downloadable');
      final added = await provider.toggleDownload(media);
      expect(added, isTrue);
      await _waitForCondition(
        () => provider.downloadedItems.any((item) => item.id == media.id),
      );

      final removed = await provider.toggleDownload(media);
      expect(removed, isFalse);
      await _waitForCondition(
        () => provider.downloadedItems.every((item) => item.id != media.id),
      );

      // Clearing offline data should wipe any cached state and notify listeners.
      await provider.clearOfflineData();
      expect(provider.downloadedItems, isEmpty);
      expect(provider.pendingTasks, isEmpty);
    });
  });
}
