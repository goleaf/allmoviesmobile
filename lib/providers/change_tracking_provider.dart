import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../data/models/change_model.dart';
import '../data/models/notification_item.dart';
import '../data/models/paginated_response.dart';
import '../data/services/local_storage_service.dart';
import '../data/services/network_quality_service.dart';
import '../data/tmdb_repository.dart';

enum _TrackedType { movie, tv, person }

/// Polls TMDB change-tracking endpoints and surfaces them as in-app
/// notifications.
class ChangeTrackingProvider extends ChangeNotifier {
  ChangeTrackingProvider(
    this._repository,
    this._storage, {
    NetworkQualityNotifier? networkQualityNotifier,
    Duration pollInterval = const Duration(minutes: 5),
    int maxNotifications = 20,
    int maxResourcesPerPoll = 6,
    int maxChangesPerResource = 4,
  })  : _networkQualityNotifier = networkQualityNotifier,
        _pollInterval = pollInterval,
        _maxNotifications = maxNotifications,
        _maxResourcesPerPoll = maxResourcesPerPoll,
        _maxChangesPerResource = maxChangesPerResource {
    _cursor = _storage.getChangeTrackingCursor() ??
        DateTime.now().toUtc().subtract(const Duration(hours: 6));
    _seenChangeIds = _storage.getChangeTrackerSeenIds();
    _updates = _storage
        .getNotifications()
        .where((notification) =>
            notification.category == NotificationCategory.contentUpdate)
        .toList(growable: false);
    _updates.sort(_sortNotifications);
    unawaited(_truncateAndPersist());
    _startTimer(immediate: true);
  }

  final TmdbRepository _repository;
  final LocalStorageService _storage;
  final NetworkQualityNotifier? _networkQualityNotifier;
  final Duration _pollInterval;
  final int _maxNotifications;
  final int _maxResourcesPerPoll;
  final int _maxChangesPerResource;

  Timer? _pollTimer;
  bool _isFetching = false;
  DateTime? _cursor;
  List<AppNotification> _updates = const <AppNotification>[];
  Set<String> _seenChangeIds = const <String>{};

  List<AppNotification> get updates => List.unmodifiable(_updates);
  bool get isFetching => _isFetching;
  bool get hasUnread => _updates.any((notification) => !notification.isRead);
  int get unreadCount =>
      _updates.where((notification) => !notification.isRead).length;
  DateTime? get lastChecked => _cursor;

  Future<void> refresh() => _checkForUpdates(manual: true);

  Future<void> markAllRead() async {
    if (!hasUnread) {
      return;
    }
    final unreadIds = _updates
        .where((notification) => !notification.isRead)
        .map((notification) => notification.id)
        .toList(growable: false);
    _updates = _updates
        .map((notification) => notification.copyWith(isRead: true))
        .toList(growable: false);
    await _storage.markNotificationsRead(unreadIds);
    await _truncateAndPersist();
    notifyListeners();
  }

  void _startTimer({bool immediate = false}) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _checkForUpdates());
    if (immediate) {
      Future.microtask(() => _checkForUpdates());
    }
  }

  Future<void> _checkForUpdates({bool manual = false}) async {
    if (_isFetching) {
      return;
    }
    if (_networkQualityNotifier?.quality == NetworkQuality.offline) {
      return;
    }

    _isFetching = true;
    if (manual) {
      notifyListeners();
    }

    try {
      final now = DateTime.now().toUtc();
      final start = _cursor ?? now.subtract(const Duration(hours: 6));
      final startDate = _formatDate(start);
      final endDate = _formatDate(now);

      final changeLists = await Future.wait(<Future<List<AppNotification>>>[
        _collectUpdatesForType(_TrackedType.movie, startDate, endDate),
        _collectUpdatesForType(_TrackedType.tv, startDate, endDate),
        _collectUpdatesForType(_TrackedType.person, startDate, endDate),
      ]);

      final newNotifications = changeLists.expand((list) => list).toList();
      if (newNotifications.isNotEmpty) {
        _updates = <AppNotification>[...newNotifications, ..._updates];
        _updates.sort(_sortNotifications);
        await _truncateAndPersist();
        await _storage.saveChangeTrackerSeenIds(_seenChangeIds);
      }

      _cursor = now;
      await _storage.setChangeTrackingCursor(now);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Change tracking poll failed: $error');
        debugPrint('$stackTrace');
      }
    } finally {
      _isFetching = false;
      notifyListeners();
    }
  }

  Future<List<AppNotification>> _collectUpdatesForType(
    _TrackedType type,
    String startDate,
    String endDate,
  ) async {
    PaginatedResponse<ChangeResource> changeList;
    try {
      changeList = switch (type) {
        _TrackedType.movie => await _repository.fetchMovieChangeList(
            startDate: startDate,
            endDate: endDate,
            forceRefresh: true,
          ),
        _TrackedType.tv => await _repository.fetchTvChangeList(
            startDate: startDate,
            endDate: endDate,
            forceRefresh: true,
          ),
        _TrackedType.person => await _repository.fetchPersonChangeList(
            startDate: startDate,
            endDate: endDate,
            forceRefresh: true,
          ),
      };
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Failed to fetch change list for ${type.name}: $error');
      }
      return const <AppNotification>[];
    }

    if (changeList.results.isEmpty) {
      return const <AppNotification>[];
    }

    final resources = changeList.results.take(_maxResourcesPerPoll).toList();
    final notifications = <AppNotification>[];

    for (final resource in resources) {
      final detailsName = await _resolveDisplayName(type, resource.id);

      ChangesResponse changes;
      try {
        changes = await _fetchChanges(type, resource.id,
            startDate: startDate, endDate: endDate);
      } catch (error) {
        if (kDebugMode) {
          debugPrint(
            'Failed to fetch change details for ${type.name} ${resource.id}: $error',
          );
        }
        continue;
      }

      for (final change in changes.changes) {
        if (change.items.isEmpty) {
          continue;
        }
        final subset = change.items.take(_maxChangesPerResource);
        for (final item in subset) {
          final notificationId = 'change_${type.name}_${item.id}';
          if (_seenChangeIds.contains(notificationId)) {
            continue;
          }
          final createdAt = _parseTimestamp(item.time) ?? DateTime.now().toUtc();
          if (_cursor != null && createdAt.isBefore(_cursor!)) {
            continue;
          }
          final message = _formatChangeMessage(
            change.key,
            item.action,
            item.language,
          );
          notifications.add(
            AppNotification(
              id: notificationId,
              title: detailsName,
              message: message,
              category: NotificationCategory.contentUpdate,
              metadata: <String, dynamic>{
                'type': type.name,
                'resourceId': resource.id,
                'changeKey': change.key,
                'action': item.action,
                'time': item.time,
                if (item.language != null) 'language': item.language,
                if (item.country != null) 'country': item.country,
              },
              createdAt: createdAt,
            ),
          );
          _seenChangeIds.add(notificationId);
        }
      }
    }

    notifications.sort(_sortNotifications);
    return notifications;
  }

  Future<String> _resolveDisplayName(_TrackedType type, int id) async {
    try {
      switch (type) {
        case _TrackedType.movie:
          final details = await _repository.fetchMovieDetails(id);
          return details.title?.isNotEmpty == true
              ? details.title
              : details.originalTitle ?? 'Movie #$id';
        case _TrackedType.tv:
          final details = await _repository.fetchTvDetails(id);
          return details.name?.isNotEmpty == true
              ? details.name
              : details.originalName ?? 'Series #$id';
        case _TrackedType.person:
          final details = await _repository.fetchPersonDetails(id);
          return details.name?.isNotEmpty == true
              ? details.name
              : 'Person #$id';
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint(
          'Failed to resolve display name for ${type.name} $id: $error',
        );
      }
      return '${_capitalize(type.name)} #$id';
    }
  }

  Future<ChangesResponse> _fetchChanges(
    _TrackedType type,
    int id, {
    required String startDate,
    required String endDate,
  }) {
    return switch (type) {
      _TrackedType.movie => _repository.fetchMovieChanges(
          id,
          startDate: startDate,
          endDate: endDate,
          forceRefresh: true,
        ),
      _TrackedType.tv => _repository.fetchTvChanges(
          id,
          startDate: startDate,
          endDate: endDate,
          forceRefresh: true,
        ),
      _TrackedType.person => _repository.fetchPersonChanges(
          id,
          startDate: startDate,
          endDate: endDate,
          forceRefresh: true,
        ),
    };
  }

  Future<void> _truncateAndPersist() async {
    if (_updates.isEmpty) {
      return;
    }
    _updates.sort(_sortNotifications);
    if (_updates.length > _maxNotifications) {
      _updates =
          _updates.take(_maxNotifications).toList(growable: false);
    }

    final stored = _storage.getNotifications();
    final others = stored
        .where((notification) =>
            notification.category != NotificationCategory.contentUpdate)
        .toList(growable: false);
    await _storage.saveNotifications(<AppNotification>[..._updates, ...others]);
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  static String _formatDate(DateTime date) {
    return date.toUtc().toIso8601String().split('T').first;
  }

  static int _sortNotifications(
    AppNotification a,
    AppNotification b,
  ) {
    return b.createdAt.compareTo(a.createdAt);
  }

  static DateTime? _parseTimestamp(String? raw) {
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final normalized = raw.trim().endsWith('UTC')
        ? raw.trim().replaceFirst(' UTC', 'Z').replaceFirst(' ', 'T')
        : raw.replaceFirst(' ', 'T');
    try {
      return DateTime.parse(normalized).toUtc();
    } catch (_) {
      return null;
    }
  }

  String _formatChangeMessage(String key, String action, String? language) {
    final keyLabel = key
        .split('_')
        .where((segment) => segment.isNotEmpty)
        .map((segment) =>
            segment[0].toUpperCase() + segment.substring(1).toLowerCase())
        .join(' ');
    final actionLabel = switch (action.toLowerCase()) {
      'added' => 'added',
      'updated' => 'updated',
      'deleted' => 'removed',
      _ => action,
    };
    final buffer = StringBuffer()
      ..write(keyLabel)
      ..write(' ')
      ..write(actionLabel);
    if (language != null && language.isNotEmpty) {
      buffer
        ..write(' ')
        ..write('(${language.toUpperCase()})');
    }
    return buffer.toString();
  }

  static String _capitalize(String value) {
    if (value.isEmpty) {
      return value;
    }
    if (value.length == 1) {
      return value.toUpperCase();
    }
    return value[0].toUpperCase() + value.substring(1);
  }
}
