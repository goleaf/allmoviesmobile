import '../logging/app_logger.dart';

abstract class CrashReportingService {
  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    Map<String, Object?>? context,
  });

  Future<void> recordMessage(
    String message, {
    Map<String, Object?>? context,
  });
}

class DebugCrashReportingService implements CrashReportingService {
  DebugCrashReportingService(this._logger);

  final AppLogger _logger;

  @override
  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    Map<String, Object?>? context,
  }) async {
    _logger.error(
      'Crash captured: $error',
      error,
      stackTrace,
    );
    if (context != null && context.isNotEmpty) {
      _logger.debug('Crash context: $context');
    }
  }

  @override
  Future<void> recordMessage(
    String message, {
    Map<String, Object?>? context,
  }) async {
    _logger.warning(
      'Crashlytics message: $message',
      context,
    );
  }
}
