import 'package:firebase_analytics/firebase_analytics.dart';

import '../logging/app_logger.dart';

abstract class AnalyticsService {
  Future<void> logEvent(
    String name, {
    Map<String, Object?> parameters = const <String, Object?>{},
  });

  Future<void> setUserId(String? userId);

  Future<void> setUserProperty(String name, String? value);
}

class DebugAnalyticsService implements AnalyticsService {
  DebugAnalyticsService(this._logger);

  final AppLogger _logger;

  @override
  Future<void> logEvent(
    String name, {
    Map<String, Object?> parameters = const <String, Object?>{},
  }) async {
    _logger.debug(
      'Analytics event: $name ${parameters.isNotEmpty ? parameters : ''}',
    );
  }

  @override
  Future<void> setUserId(String? userId) async {
    _logger.debug('Analytics userId: $userId');
  }

  @override
  Future<void> setUserProperty(String name, String? value) async {
    _logger.debug('Analytics userProperty: $name=$value');
  }
}

/// Concrete [AnalyticsService] implementation backed by
/// [`FirebaseAnalytics`](https://firebase.google.com/docs/analytics)
/// so all tracking events are forwarded to the Firebase console.
class FirebaseAnalyticsService implements AnalyticsService {
  FirebaseAnalyticsService({
    required FirebaseAnalytics analytics,
    required AppLogger logger,
  })  : _analytics = analytics,
        _logger = logger;

  final FirebaseAnalytics _analytics;
  final AppLogger _logger;

  /// Sends a custom analytics event to Firebase. Parameters are sanitized to
  /// comply with Firebase's accepted value types (string, number, boolean).
  @override
  Future<void> logEvent(
    String name, {
    Map<String, Object?> parameters = const <String, Object?>{},
  }) async {
    final Map<String, Object>? payload = parameters.isEmpty
        ? null
        : Map<String, Object>.fromEntries(
            parameters.entries.where((e) => e.value is Object).map(
                  (e) => MapEntry<String, Object>(e.key, e.value as Object),
                ),
          );
    try {
      await _analytics.logEvent(name: name, parameters: payload);
    } catch (error, stackTrace) {
      _logger.warning(
        'Failed to forward analytics event to Firebase: $name',
        error,
        stackTrace,
      );
    }
  }

  /// Associates events with a user identifier so cross-session behaviour can
  /// be analysed inside Firebase Analytics.
  @override
  Future<void> setUserId(String? userId) async {
    try {
      await _analytics.setUserId(id: userId);
    } catch (error, stackTrace) {
      _logger.warning(
        'Failed to update Firebase Analytics userId: $userId',
        error,
        stackTrace,
      );
    }
  }

  /// Stores a custom user property (for example preferred theme or locale)
  /// that can be used for segmentation inside Firebase Analytics.
  @override
  Future<void> setUserProperty(String name, String? value) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
    } catch (error, stackTrace) {
      _logger.warning(
        'Failed to update Firebase Analytics userProperty: $name=$value',
        error,
        stackTrace,
      );
    }
  }
}
