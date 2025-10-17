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
