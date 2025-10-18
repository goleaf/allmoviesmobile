import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../data/models/notification_item.dart';
import '../data/services/local_storage_service.dart';
import 'preferences_provider.dart';

/// Central store for in-app notifications persisted through
/// [LocalStorageService].
///
/// The provider keeps an in-memory copy of all notifications, filters them
/// according to the user's preferences, and exposes helpers to mutate read
/// states while notifying listeners of changes.
class NotificationsProvider extends ChangeNotifier {
  NotificationsProvider({
    required LocalStorageService storage,
    PreferencesProvider? preferences,
  })  : _storage = storage,
        _allNotifications = storage.getNotifications() {
    if (preferences != null) {
      bindPreferences(preferences);
    }
    _rebuildVisible(force: true);
  }

  final LocalStorageService _storage;
  List<AppNotification> _allNotifications;
  List<AppNotification> _visibleNotifications = const <AppNotification>[];
  PreferencesProvider? _preferences;

  UnmodifiableListView<AppNotification> get notifications =>
      UnmodifiableListView(_visibleNotifications);

  bool get hasNotifications => _visibleNotifications.isNotEmpty;

  int get unreadCount =>
      _visibleNotifications.where((notification) => !notification.isRead).length;

  /// Rebinds the provider to a [PreferencesProvider] instance so the toggle
  /// state stays in sync when dependency injection rebuilds the tree.
  void bindPreferences(PreferencesProvider preferences) {
    if (identical(_preferences, preferences)) {
      return;
    }
    _preferences?.removeListener(_handlePreferencesChanged);
    _preferences = preferences;
    _preferences?.addListener(_handlePreferencesChanged);
    _rebuildVisible(force: true);
  }

  @override
  void dispose() {
    _preferences?.removeListener(_handlePreferencesChanged);
    super.dispose();
  }

  /// Reloads notifications from storage.
  void refresh() {
    _allNotifications = _storage.getNotifications();
    _rebuildVisible();
  }

  /// Adds a notification or replaces an existing one.
  Future<void> upsert(AppNotification notification) async {
    final didPersist = await _storage.upsertNotification(notification);
    if (!didPersist) {
      return;
    }

    final updated = List<AppNotification>.from(_allNotifications);
    final index =
        updated.indexWhere((candidate) => candidate.id == notification.id);
    if (index >= 0) {
      updated[index] = notification;
    } else {
      updated.insert(0, notification);
    }
    _allNotifications = updated;
    _rebuildVisible();
  }

  /// Marks the notifications with the provided [ids] as read.
  Future<void> markNotificationsRead(Iterable<String> ids) async {
    final idSet = ids.toSet();
    if (idSet.isEmpty) {
      return;
    }
    final didPersist = await _storage.markNotificationsRead(idSet);
    if (!didPersist) {
      return;
    }
    _allNotifications = _storage.getNotifications();
    _rebuildVisible();
  }

  /// Marks every visible notification as read.
  Future<void> markAllRead() =>
      markNotificationsRead(_visibleNotifications.map((n) => n.id));

  /// Removes every persisted notification.
  Future<void> clearAll() async {
    final didClear = await _storage.clearNotifications();
    if (!didClear) {
      return;
    }
    _allNotifications = const <AppNotification>[];
    _visibleNotifications = const <AppNotification>[];
    notifyListeners();
  }

  void _handlePreferencesChanged() {
    _rebuildVisible(force: true);
  }

  void _rebuildVisible({bool force = false}) {
    final filtered = _applyPreferences(_allNotifications);
    if (force || !listEquals(filtered, _visibleNotifications)) {
      _visibleNotifications = filtered;
      notifyListeners();
    }
  }

  List<AppNotification> _applyPreferences(List<AppNotification> source) {
    final preferences = _preferences;
    if (preferences == null) {
      return List<AppNotification>.from(source);
    }

    return source
        .where((notification) => _shouldSurface(notification, preferences))
        .toList(growable: false);
  }

  bool _shouldSurface(
    AppNotification notification,
    PreferencesProvider preferences,
  ) {
    switch (notification.category) {
      case NotificationCategory.system:
        if (_isMarketing(notification)) {
          return preferences.notificationsMarketing;
        }
        return preferences.notificationsNewReleases;
      case NotificationCategory.social:
        return preferences.notificationsMarketing;
      case NotificationCategory.list:
        return preferences.notificationsWatchlistAlerts;
      case NotificationCategory.recommendation:
        return preferences.notificationsRecommendations;
    }
  }

  bool _isMarketing(AppNotification notification) {
    final metadata = notification.metadata;
    if (metadata.isEmpty) {
      return false;
    }
    final explicitFlag = metadata['marketing'];
    if (explicitFlag is bool) {
      return explicitFlag;
    }
    final type = metadata['type'];
    if (type is String) {
      final normalized = type.toLowerCase();
      return normalized == 'marketing' ||
          normalized == 'promo' ||
          normalized == 'promotion';
    }
    return false;
  }
}
