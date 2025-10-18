import 'dart:async';

import '../logging/app_logger.dart';
import 'analytics_service.dart';

/// Coordinates the high-level analytics events used across the application.
///
/// The class exposes semantic helpers (e.g. [logSearch] or [logFavoriteChange])
/// that wrap the lower-level [AnalyticsService] API and make sure parameters
/// comply with Firebase Analytics requirements (string/number/bool values).
class AppAnalytics {
  AppAnalytics({
    required AnalyticsService service,
    required AppLogger logger,
  })  : _service = service,
        _logger = logger;

  static const String _eventAppOpen = 'app_open';
  static const String _eventScreenView = 'screen_view';
  static const String _eventTabSelected = 'tab_selected';
  static const String _eventSearch = 'search_performed';
  static const String _eventSearchFailed = 'search_failed';
  static const String _eventFavorite = 'favorite_updated';
  static const String _eventWatchlist = 'watchlist_updated';
  static const String _eventDeepLink = 'deep_link_opened';

  static const String _paramScreenName = 'screen_name';
  static const String _paramScreenClass = 'screen_class';
  static const String _paramTabName = 'tab_name';
  static const String _paramQuery = 'query';
  static const String _paramOrigin = 'origin';
  static const String _paramResultCount = 'result_count';
  static const String _paramError = 'error';
  static const String _paramMediaId = 'media_id';
  static const String _paramMediaType = 'media_type';
  static const String _paramAction = 'action';
  static const String _paramTitle = 'title';
  static const String _paramDeepLinkType = 'deep_link_type';
  static const String _paramLabel = 'label';

  final AnalyticsService _service;
  final AppLogger _logger;

  /// Logs the standard `app_open` event used by Firebase dashboards.
  Future<void> logAppOpen() => _logEvent(_eventAppOpen);

  /// Emits a screen view event mirroring the native SDK behaviour.
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) {
    return _logEvent(
      _eventScreenView,
      parameters: <String, Object?>{
        _paramScreenName: screenName,
        _paramScreenClass: screenClass ?? screenName,
      },
    );
  }

  /// Tracks navigation bar interactions so we can analyse the most used tabs.
  Future<void> logTabSelection(String tabName) {
    return _logEvent(
      _eventTabSelected,
      parameters: <String, Object?>{_paramTabName: tabName},
    );
  }

  /// Records a successful search including query origin and hit count.
  Future<void> logSearch({
    required String query,
    String origin = 'manual',
    int? resultCount,
  }) {
    return _logEvent(
      _eventSearch,
      parameters: <String, Object?>{
        _paramQuery: query,
        _paramOrigin: origin,
        _paramResultCount: resultCount,
      },
    );
  }

  /// Records a failed search with the associated error message (sanitized).
  Future<void> logSearchError({
    required String query,
    String origin = 'manual',
    required String error,
  }) {
    return _logEvent(
      _eventSearchFailed,
      parameters: <String, Object?>{
        _paramQuery: query,
        _paramOrigin: origin,
        _paramError: error,
      },
    );
  }

  /// Captures favourite mutations (add/remove) together with media metadata.
  Future<void> logFavoriteChange({
    required int mediaId,
    required String mediaType,
    required bool added,
    String? title,
  }) {
    return _logEvent(
      _eventFavorite,
      parameters: <String, Object?>{
        _paramMediaId: mediaId,
        _paramMediaType: mediaType,
        _paramAction: added ? 'added' : 'removed',
        _paramTitle: title,
      },
    );
  }

  /// Captures watchlist mutations (add/remove) together with media metadata.
  Future<void> logWatchlistChange({
    required int mediaId,
    required String mediaType,
    required bool added,
    String? title,
  }) {
    return _logEvent(
      _eventWatchlist,
      parameters: <String, Object?>{
        _paramMediaId: mediaId,
        _paramMediaType: mediaType,
        _paramAction: added ? 'added' : 'removed',
        _paramTitle: title,
      },
    );
  }

  /// Emits an event whenever a deep link is opened so marketing campaigns can
  /// be attributed later on inside Firebase.
  Future<void> logDeepLink({
    required String type,
    int? id,
    String? label,
  }) {
    return _logEvent(
      _eventDeepLink,
      parameters: <String, Object?>{
        _paramDeepLinkType: type,
        _paramMediaId: id,
        _paramLabel: label,
      },
    );
  }

  /// Maps the selected locale to a Firebase Analytics user property.
  Future<void> setPreferredLanguage(String languageCode) {
    return _runGuarded(
      () => _service.setUserProperty('preferred_language', languageCode),
    );
  }

  /// Maps the preferred theme mode to a Firebase Analytics user property.
  Future<void> setThemeMode(String themeMode) {
    return _runGuarded(
      () => _service.setUserProperty('theme_mode', themeMode),
    );
  }

  Future<void> _logEvent(
    String name, {
    Map<String, Object?> parameters = const <String, Object?>{},
  }) {
    final sanitized = <String, Object?>{};
    parameters.forEach((key, value) {
      if (value == null) {
        return;
      }
      if (value is bool || value is num || value is String) {
        sanitized[key] = value;
      } else if (value is Enum) {
        sanitized[key] = value.name;
      } else {
        sanitized[key] = value.toString();
      }
    });

    return _runGuarded(
      () => _service.logEvent(name, parameters: sanitized),
    );
  }

  Future<void> _runGuarded(FutureOr<void> Function() operation) async {
    try {
      await operation();
    } catch (error, stackTrace) {
      _logger.warning('Analytics dispatch failed', error, stackTrace);
    }
  }
}
