import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/preferences_keys.dart';
import '../../core/firebase/firebase_options.dart';
import '../../core/navigation/deep_link_handler.dart';
import '../../core/navigation/deep_link_parser.dart';
import '../models/notification_item.dart';
import 'local_storage_service.dart';

const _androidChannelId = 'allmovies_default';
const _androidChannelName = 'AllMovies updates';
const _androidChannelDescription =
    'Alerts about new releases, watchlist changes, and recommendations.';

/// Supported push notification preference buckets.
enum NotificationTopic {
  newReleases,
  watchlistAlerts,
  recommendations,
  marketing,
}

extension NotificationTopicData on NotificationTopic {
  String get topicName {
    switch (this) {
      case NotificationTopic.newReleases:
        return 'new-releases';
      case NotificationTopic.watchlistAlerts:
        return 'watchlist-alerts';
      case NotificationTopic.recommendations:
        return 'recommendations';
      case NotificationTopic.marketing:
        return 'marketing';
    }
  }

  String get preferenceKey {
    switch (this) {
      case NotificationTopic.newReleases:
        return PreferenceKeys.notificationsNewReleases;
      case NotificationTopic.watchlistAlerts:
        return PreferenceKeys.notificationsWatchlistAlerts;
      case NotificationTopic.recommendations:
        return PreferenceKeys.notificationsRecommendations;
      case NotificationTopic.marketing:
        return PreferenceKeys.notificationsMarketing;
    }
  }

  bool get defaultEnabled => this != NotificationTopic.marketing;
}

/// Coordinates Firebase Cloud Messaging registration, local presentation,
/// topic subscription management, and deep-link routing for notification taps.
class PushNotificationService extends ChangeNotifier {
  PushNotificationService({
    required LocalStorageService storageService,
    required SharedPreferences preferences,
    DeepLinkHandler? deepLinkHandler,
    FirebaseMessaging? firebaseMessaging,
    FlutterLocalNotificationsPlugin? localNotificationsPlugin,
    Logger? logger,
  }) : _storage = storageService,
       _prefs = preferences,
       _deepLinkHandler = deepLinkHandler,
       _messaging = firebaseMessaging ?? FirebaseMessaging.instance,
       _localNotifications =
           localNotificationsPlugin ?? FlutterLocalNotificationsPlugin(),
       _logger = logger ?? Logger(printer: PrettyPrinter(methodCount: 0));

  static bool _backgroundHandlerRegistered = false;

  final LocalStorageService _storage;
  final SharedPreferences _prefs;
  final DeepLinkHandler? _deepLinkHandler;
  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications;
  final Logger _logger;

  final List<AppNotification> _notifications = <AppNotification>[];

  StreamSubscription<String>? _tokenSubscription;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedAppSubscription;

  AuthorizationStatus _authorizationStatus = AuthorizationStatus.notDetermined;
  bool _firebaseReady = false;
  bool _isOptedIn = false;
  bool _initialized = false;
  Object? _lastError;
  int _activeOperations = 0;

  bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  bool get isInitialized => _initialized;
  bool get isBusy => _activeOperations > 0;
  bool get isPermissionGranted =>
      _authorizationStatus == AuthorizationStatus.authorized ||
      _authorizationStatus == AuthorizationStatus.provisional;
  bool get isPermissionDenied =>
      _authorizationStatus == AuthorizationStatus.denied;
  bool get isPermissionUndetermined =>
      _authorizationStatus == AuthorizationStatus.notDetermined;
  bool get isNotificationsEnabled =>
      _firebaseReady && _isOptedIn && isPermissionGranted;

  Object? get lastError => _lastError;
  AuthorizationStatus get authorizationStatus => _authorizationStatus;

  List<AppNotification> get notifications =>
      List<AppNotification>.unmodifiable(_notifications);

  /// Register the top-level Firebase Messaging background handler once.
  static void registerBackgroundHandler() {
    if (_backgroundHandlerRegistered || kIsWeb) {
      return;
    }
    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }
    FirebaseMessaging.onBackgroundMessage(pushNotificationBackgroundHandler);
    _backgroundHandlerRegistered = true;
  }

  /// Kickstarts Firebase initialization, permission probing, and listeners.
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    if (!isSupported) {
      _initialized = true;
      notifyListeners();
      return;
    }

    final options = DefaultFirebaseOptions.currentPlatform;
    if (DefaultFirebaseOptions.isPlaceholder(options)) {
      _logger.i(
        'Push notifications disabled: Firebase project not configured.',
      );
      _initialized = true;
      notifyListeners();
      return;
    }

    try {
      await _ensureFirebaseInitialized(options!);
      await _initializeLocalNotifications();
      await _loadStoredNotifications();
      await _initializeTopicPreferences();

      final settings = await _messaging.getNotificationSettings();
      _authorizationStatus = settings.authorizationStatus;
      _isOptedIn = _prefs.getBool(PreferenceKeys.notificationsEnabled) ?? false;
      if (!isPermissionGranted && _isOptedIn) {
        _isOptedIn = false;
        await _prefs.setBool(PreferenceKeys.notificationsEnabled, false);
      }

      await _messaging.setAutoInitEnabled(true);
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
            alert: true,
            badge: true,
            sound: true,
          );

      if (isNotificationsEnabled) {
        await _ensureDeviceRegistration();
        await _syncTopicSubscriptions();
      }

      _tokenSubscription = _messaging.onTokenRefresh.listen(
        _handleTokenRefresh,
      );
      _foregroundSubscription = FirebaseMessaging.onMessage.listen(
        _handleForegroundMessage,
      );
      _openedAppSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
        _handleOpenedMessage,
      );

      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        await _handleOpenedMessage(initialMessage);
      }

      _firebaseReady = true;
    } catch (error, stackTrace) {
      _lastError = error;
      _logger.e('Failed to initialize push notifications', error, stackTrace);
    } finally {
      _initialized = true;
      notifyListeners();
    }
  }

  /// Requests the user's permission and subscribes to enabled topics.
  Future<bool> enableNotifications() async {
    if (!isSupported || !_firebaseReady) {
      return false;
    }

    _activeOperations++;
    notifyListeners();
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      _authorizationStatus = settings.authorizationStatus;
      await _prefs.setString(
        PreferenceKeys.notificationsPermissionStatus,
        _authorizationStatus.name,
      );

      if (!isPermissionGranted) {
        _isOptedIn = false;
        await _prefs.setBool(PreferenceKeys.notificationsEnabled, false);
        notifyListeners();
        return false;
      }

      _isOptedIn = true;
      await _prefs.setBool(PreferenceKeys.notificationsEnabled, true);
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
            alert: true,
            badge: true,
            sound: true,
          );

      await _ensureDeviceRegistration();
      await _syncTopicSubscriptions();
      notifyListeners();
      return true;
    } catch (error, stackTrace) {
      _lastError = error;
      _logger.e('Failed to enable push notifications', error, stackTrace);
      return false;
    } finally {
      _activeOperations--;
      notifyListeners();
    }
  }

  /// Unsubscribes from all topics and deletes the local FCM token.
  Future<bool> disableNotifications() async {
    if (!isSupported || !_firebaseReady) {
      return false;
    }

    _activeOperations++;
    notifyListeners();
    try {
      _isOptedIn = false;
      await _prefs.setBool(PreferenceKeys.notificationsEnabled, false);
      await _prefs.remove(PreferenceKeys.notificationsDeviceToken);
      await _prefs.remove(PreferenceKeys.notificationsPermissionStatus);
      await _unsubscribeFromAllTopics();
      try {
        await _messaging.deleteToken();
      } catch (error, stackTrace) {
        _logger.w('Failed to delete FCM token', error, stackTrace);
      }
      notifyListeners();
      return true;
    } catch (error, stackTrace) {
      _lastError = error;
      _logger.e('Failed to disable push notifications', error, stackTrace);
      return false;
    } finally {
      _activeOperations--;
      notifyListeners();
    }
  }

  /// Returns whether a specific notification topic is enabled.
  bool isTopicEnabled(NotificationTopic topic) {
    return _prefs.getBool(topic.preferenceKey) ?? topic.defaultEnabled;
  }

  /// Toggles the subscription status for a notification topic.
  Future<void> setTopicEnabled(NotificationTopic topic, bool enabled) async {
    if (!isSupported) {
      return;
    }

    _activeOperations++;
    notifyListeners();
    try {
      await _prefs.setBool(topic.preferenceKey, enabled);
      if (!isNotificationsEnabled) {
        notifyListeners();
        return;
      }
      if (enabled) {
        await _messaging.subscribeToTopic(topic.topicName);
      } else {
        await _messaging.unsubscribeFromTopic(topic.topicName);
      }
    } catch (error, stackTrace) {
      _lastError = error;
      _logger.e(
        'Failed to update subscription for ${topic.topicName}',
        error,
        stackTrace,
      );
    } finally {
      _activeOperations--;
      notifyListeners();
    }
  }

  /// Reloads notifications from persistent storage.
  Future<void> refreshFromStorage() async {
    await _loadStoredNotifications();
    notifyListeners();
  }

  @override
  void dispose() {
    _tokenSubscription?.cancel();
    _foregroundSubscription?.cancel();
    _openedAppSubscription?.cancel();
    super.dispose();
  }

  Future<void> _ensureFirebaseInitialized(FirebaseOptions options) async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: options);
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestSoundPermission: false,
      requestBadgePermission: false,
    );

    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload == null || payload.isEmpty) {
          return;
        }
        try {
          final decoded = json.decode(payload) as Map<String, dynamic>;
          final deepLink = PushNotificationService._parseDeepLinkFromData(
            decoded,
          );
          if (deepLink != null) {
            _deepLinkHandler?.enqueueLink(deepLink);
          }
        } catch (error, stackTrace) {
          _logger.w(
            'Failed to handle notification tap payload',
            error,
            stackTrace,
          );
        }
      },
    );

    if (defaultTargetPlatform == TargetPlatform.android) {
      const channel = AndroidNotificationChannel(
        _androidChannelId,
        _androidChannelName,
        description: _androidChannelDescription,
        importance: Importance.high,
      );
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await androidPlugin?.createNotificationChannel(channel);
    }
  }

  Future<void> _initializeTopicPreferences() async {
    for (final topic in NotificationTopic.values) {
      if (!_prefs.containsKey(topic.preferenceKey)) {
        await _prefs.setBool(topic.preferenceKey, topic.defaultEnabled);
      }
    }
  }

  Future<void> _loadStoredNotifications() async {
    _notifications
      ..clear()
      ..addAll(_storage.getNotifications());
  }

  Future<void> _ensureDeviceRegistration() async {
    try {
      final token = await _messaging.getToken();
      if (token == null || token.isEmpty) {
        return;
      }
      await _prefs.setString(PreferenceKeys.notificationsDeviceToken, token);
      final abbreviated = token.length <= 12
          ? token
          : '${token.substring(0, 6)}…${token.substring(token.length - 4)}';
      _logger.i('Registered push token ($abbreviated)');
      await _syncTopicSubscriptions();
    } catch (error, stackTrace) {
      _lastError = error;
      _logger.e(
        'Failed to register device for push notifications',
        error,
        stackTrace,
      );
    }
  }

  Future<void> _syncTopicSubscriptions() async {
    if (!isNotificationsEnabled) {
      return;
    }
    for (final topic in NotificationTopic.values) {
      final enabled = isTopicEnabled(topic);
      try {
        if (enabled) {
          await _messaging.subscribeToTopic(topic.topicName);
        } else {
          await _messaging.unsubscribeFromTopic(topic.topicName);
        }
      } catch (error, stackTrace) {
        _logger.w(
          'Topic sync failed for ${topic.topicName}',
          error,
          stackTrace,
        );
      }
    }
  }

  Future<void> _unsubscribeFromAllTopics() async {
    for (final topic in NotificationTopic.values) {
      try {
        await _messaging.unsubscribeFromTopic(topic.topicName);
      } catch (error, stackTrace) {
        _logger.w(
          'Failed to unsubscribe from ${topic.topicName}',
          error,
          stackTrace,
        );
      }
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final parsed = parseRemoteMessage(message);
    if (parsed != null) {
      await _storage.upsertNotification(parsed);
      await _loadStoredNotifications();
      notifyListeners();
    }

    if (message.notification == null && message.data.isEmpty) {
      return;
    }

    final payload = _buildPayload(message);
    final notification = message.notification;
    final title = notification?.title ?? parsed?.title;
    final body = notification?.body ?? parsed?.message;

    if (title == null && body == null) {
      return;
    }

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _androidChannelId,
        _androidChannelName,
        channelDescription: _androidChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: false,
        presentSound: true,
      ),
    );

    await _localNotifications.show(
      (message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString())
          .hashCode,
      title,
      body,
      details,
      payload: json.encode(payload),
    );
  }

  Future<void> _handleOpenedMessage(RemoteMessage message) async {
    final parsed = parseRemoteMessage(message);
    if (parsed != null) {
      await _storage.upsertNotification(parsed);
      await _loadStoredNotifications();
      notifyListeners();
    }
    final deepLink = parseDeepLink(message);
    if (deepLink != null) {
      _deepLinkHandler?.enqueueLink(deepLink);
    }
  }

  Future<void> _handleTokenRefresh(String token) async {
    await _prefs.setString(PreferenceKeys.notificationsDeviceToken, token);
    final abbreviated = token.length <= 12
        ? token
        : '${token.substring(0, 6)}…${token.substring(token.length - 4)}';
    _logger.i('Push token refreshed ($abbreviated)');
    if (isNotificationsEnabled) {
      await _syncTopicSubscriptions();
    }
  }

  Map<String, dynamic> _buildPayload(RemoteMessage message) {
    final data = Map<String, dynamic>.from(message.data);
    data['message_id'] = message.messageId;
    return data;
  }

  static DeepLinkData? _parseDeepLinkFromData(Map<String, dynamic> data) {
    final deepLink = data['deep_link'] as String?;
    if (deepLink != null && deepLink.isNotEmpty) {
      return DeepLinkParser.parse(deepLink);
    }
    final targetType = (data['target_type'] as String?)?.toLowerCase();
    final targetId = int.tryParse('${data['target_id'] ?? ''}');
    switch (targetType) {
      case 'movie':
        if (targetId != null) {
          return DeepLinkData.movie(targetId);
        }
        break;
      case 'tv':
      case 'tv_show':
      case 'show':
        if (targetId != null) {
          return DeepLinkData.tvShow(targetId);
        }
        break;
      case 'season':
        final season = int.tryParse('${data['season_number'] ?? ''}');
        if (targetId != null && season != null) {
          return DeepLinkData.season(targetId, season);
        }
        break;
      case 'episode':
        final season = int.tryParse('${data['season_number'] ?? ''}');
        final episode = int.tryParse('${data['episode_number'] ?? ''}');
        if (targetId != null && season != null && episode != null) {
          return DeepLinkData.episode(targetId, season, episode);
        }
        break;
      case 'person':
        if (targetId != null) {
          return DeepLinkData.person(targetId);
        }
        break;
      case 'company':
        if (targetId != null) {
          return DeepLinkData.company(targetId);
        }
        break;
      case 'collection':
        if (targetId != null) {
          return DeepLinkData.collection(targetId);
        }
        break;
      case 'search':
        final query = data['query'] as String?;
        if (query != null && query.isNotEmpty) {
          return DeepLinkData.search(query);
        }
        break;
    }
    return null;
  }

  static NotificationCategory _categoryFromString(String? raw) {
    if (raw == null || raw.isEmpty) {
      return NotificationCategory.system;
    }
    final normalized = raw.toLowerCase();
    for (final category in NotificationCategory.values) {
      if (category.name.toLowerCase() == normalized) {
        return category;
      }
    }
    return NotificationCategory.system;
  }

  static AppNotification? parseRemoteMessage(RemoteMessage message) {
    final notification = message.notification;
    final title = notification?.title ?? message.data['title'] as String? ?? '';
    final body = notification?.body ?? message.data['body'] as String? ?? '';
    if (title.isEmpty && body.isEmpty && message.data.isEmpty) {
      return null;
    }

    final id =
        message.messageId ??
        message.data['id']?.toString() ??
        DateTime.now().millisecondsSinceEpoch.toString();
    final category = _categoryFromString(
      message.data['category'] as String? ?? message.data['topic'] as String?,
    );
    final metadata = Map<String, dynamic>.from(message.data);
    metadata.removeWhere((key, value) => value == null);

    return AppNotification(
      id: id,
      title: title.isEmpty ? 'AllMovies' : title,
      message: body,
      category: category,
      actionRoute: message.data['action_route'] as String?,
      metadata: metadata,
    );
  }

  static DeepLinkData? parseDeepLink(RemoteMessage message) {
    return _parseDeepLinkFromData(message.data);
  }
}

@pragma('vm:entry-point')
Future<void> pushNotificationBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  final options = DefaultFirebaseOptions.currentPlatform;
  if (DefaultFirebaseOptions.isPlaceholder(options)) {
    return;
  }
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: options!);
    }
    final prefs = await SharedPreferences.getInstance();
    final storage = LocalStorageService(prefs);
    final parsed = PushNotificationService.parseRemoteMessage(message);
    if (parsed != null) {
      await storage.upsertNotification(parsed);
    }
  } catch (_) {
    // Ignore background errors to avoid crashing the background isolate.
  }
}
