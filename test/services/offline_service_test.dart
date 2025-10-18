import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:allmovies_mobile/data/models/movie.dart';
import 'package:allmovies_mobile/data/models/saved_media_item.dart';
import 'package:allmovies_mobile/data/services/offline_service.dart';

SavedMediaItem _savedItem(int id, {String title = 'Sample'}) {
  return SavedMediaItem(
    id: id,
    type: SavedMediaType.movie,
    title: title,
    releaseDate: '2023-05-01',
    voteAverage: 7.4,
    voteCount: 640,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OfflineService', () {
    test('toggleDownloaded adds and removes offline entries', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final prefs = await SharedPreferences.getInstance();
      final service = OfflineService(prefs: prefs);

      final movie = _savedItem(101, title: 'Offline Movie');
      final added = await service.toggleDownloaded(movie);
      expect(added, isTrue);
      expect((await service.getDownloadedItems()).single.id, 101);

      final removed = await service.toggleDownloaded(movie);
      expect(removed, isFalse);
      expect(await service.getDownloadedItems(), isEmpty);
    });

    test('recordWatchlistMutation queues and replaces tasks while offline', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final prefs = await SharedPreferences.getInstance();
      final service = OfflineService(prefs: prefs);

      service.setOffline(true);
      final item = _savedItem(202, title: 'Watchlistable');

      await service.recordWatchlistMutation(
        mediaId: item.id,
        mediaType: item.type,
        added: true,
        snapshot: item,
      );
      var queue = await service.getPendingSyncTasks();
      expect(queue.single.action, OfflineSyncAction.watchlistAdd);

      // Recording the opposite mutation should replace the queue entry.
      await service.recordWatchlistMutation(
        mediaId: item.id,
        mediaType: item.type,
        added: false,
        snapshot: item,
      );
      queue = await service.getPendingSyncTasks();
      expect(queue.single.action, OfflineSyncAction.watchlistRemove);
      expect(queue.single.payload?['title'], 'Watchlistable');
    });

    test('syncPendingActions clears queue and updates last sync timestamp', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final prefs = await SharedPreferences.getInstance();
      final service = OfflineService(prefs: prefs);

      service.setOffline(true);
      final favorite = _savedItem(303, title: 'Favorite');
      await service.recordFavoritesMutation(
        mediaId: favorite.id,
        mediaType: favorite.type,
        added: true,
        snapshot: favorite,
      );
      final watchlisted = _savedItem(404, title: 'Queued Watch');
      await service.recordWatchlistMutation(
        mediaId: watchlisted.id,
        mediaType: watchlisted.type,
        added: true,
        snapshot: watchlisted,
      );

      service.setOffline(false);
      final processed = await service.syncPendingActions();
      expect(processed, 2);
      expect(await service.getPendingSyncTasks(), isEmpty);
      expect(service.getLastSyncedAt(), isNotNull);
    });

    test('clearAll removes cached sections, downloads, and metadata', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final prefs = await SharedPreferences.getInstance();
      final service = OfflineService(prefs: prefs);

      final movie = const Movie(id: 505, title: 'Cache Seed', mediaType: 'movie');
      await service.cacheMoviesSection('popular', <Movie>[movie]);
      expect(await service.loadMoviesSection('popular'), isNotNull);

      final saved = _savedItem(606, title: 'Local Only');
      await service.toggleDownloaded(saved);
      service.setOffline(true);
      await service.recordWatchlistMutation(
        mediaId: saved.id,
        mediaType: saved.type,
        added: true,
        snapshot: saved,
      );

      await service.clearAll();

      expect(await service.loadMoviesSection('popular'), isNull);
      expect(await service.getDownloadedItems(), isEmpty);
      expect(await service.getPendingSyncTasks(), isEmpty);
      expect(service.getLastSyncedAt(), isNull);
    });
  });
}
