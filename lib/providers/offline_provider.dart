import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../data/models/saved_media_item.dart';
import '../data/services/offline_service.dart';

/// Tracks connectivity status, manages synchronization of offline mutations,
/// and exposes derived state for widgets that need to react to offline mode.
class OfflineProvider extends ChangeNotifier {
  OfflineProvider(
    this._offlineService, {
    Connectivity? connectivity,
  }) : _connectivity = connectivity ?? Connectivity() {
    _initialize();
  }

  final OfflineService _offlineService;
  final Connectivity _connectivity;

  StreamSubscription<ConnectivityResult>? _connectivitySub;
  StreamSubscription<OfflineEvent>? _offlineEventsSub;

  bool _isOffline = false;
  bool _isInitialized = false;
  List<SavedMediaItem> _downloadedItems = const <SavedMediaItem>[];
  List<OfflineSyncTask> _pendingTasks = const <OfflineSyncTask>[];

  bool get isOffline => _isOffline;
  bool get isInitialized => _isInitialized;
  List<SavedMediaItem> get downloadedItems => List.unmodifiable(_downloadedItems);
  List<OfflineSyncTask> get pendingTasks => List.unmodifiable(_pendingTasks);
  OfflineService get service => _offlineService;

  DateTime? get lastSyncedAt => _offlineService.getLastSyncedAt();

  Future<void> _initialize() async {
    final result = await _connectivity.checkConnectivity();
    await _handleConnectivity(result, notify: false);
    await _refreshDownloads();
    await _refreshQueue();
    _isInitialized = true;
    notifyListeners();

    _connectivitySub =
        _connectivity.onConnectivityChanged.listen(_handleConnectivity);
    _offlineEventsSub = _offlineService.events.listen((event) async {
      switch (event.type) {
        case OfflineEventType.downloads:
          await _refreshDownloads();
          break;
        case OfflineEventType.syncQueue:
        case OfflineEventType.cleared:
          await _refreshQueue();
          break;
        case OfflineEventType.caches:
        case OfflineEventType.connectivity:
          break;
      }
      notifyListeners();
    });
  }

  Future<void> _refreshDownloads() async {
    _downloadedItems = await _offlineService.getDownloadedItems();
  }

  Future<void> _refreshQueue() async {
    _pendingTasks = await _offlineService.getPendingSyncTasks();
  }

  Future<void> _handleConnectivity(ConnectivityResult result,
      {bool notify = true}) async {
    final offline = result == ConnectivityResult.none;
    _isOffline = offline;
    _offlineService.setOffline(offline);
    if (!offline) {
      final processed = await _offlineService.syncPendingActions();
      if (processed > 0) {
        await _refreshQueue();
      }
    }
    if (notify) {
      notifyListeners();
    }
  }

  Future<bool> toggleDownload(SavedMediaItem item) async {
    final result = await _offlineService.toggleDownloaded(item);
    await _refreshDownloads();
    notifyListeners();
    return result;
  }

  Future<bool> isDownloaded(int id, SavedMediaType type) {
    return _offlineService.isDownloaded(id, type);
  }

  Future<OfflineStorageStats> getStorageStats() {
    return _offlineService.getStorageStats();
  }

  Future<void> clearOfflineData() async {
    await _offlineService.clearAll();
    await _refreshDownloads();
    await _refreshQueue();
    notifyListeners();
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    _offlineEventsSub?.cancel();
    super.dispose();
  }
}
