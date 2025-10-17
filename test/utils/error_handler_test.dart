import 'package:flutter_test/flutter_test.dart';
import 'package:allmovies_mobile/core/utils/error_handler.dart';

void main() {
  group('ErrorHandler Tests', () {
    test('should convert network errors to friendly message', () {
      final message = ErrorHandler.getUserFriendlyMessage(
        Exception('Network socket error'),
      );

      expect(message, contains('Network error'));
      expect(message, contains('internet connection'));
    });

    test('should convert timeout errors to friendly message', () {
      final message = ErrorHandler.getUserFriendlyMessage(
        Exception('Request timeout'),
      );

      expect(message, contains('timed out'));
    });

    test('should convert 401 errors to friendly message', () {
      final message = ErrorHandler.getUserFriendlyMessage(
        Exception('401 Unauthorized'),
      );

      expect(message, contains('Authentication'));
      expect(message, contains('API key'));
    });

    test('should convert 403 errors to friendly message', () {
      final message = ErrorHandler.getUserFriendlyMessage(
        Exception('403 Forbidden'),
      );

      expect(message, contains('Access denied'));
    });

    test('should convert 404 errors to friendly message', () {
      final message = ErrorHandler.getUserFriendlyMessage(
        Exception('404 Not Found'),
      );

      expect(message, contains('not found'));
    });

    test('should convert 500 errors to friendly message', () {
      final message = ErrorHandler.getUserFriendlyMessage(
        Exception('500 Internal Server Error'),
      );

      expect(message, contains('Server error'));
    });

    test('should handle null error gracefully', () {
      final message = ErrorHandler.getUserFriendlyMessage(null);

      expect(message, contains('unexpected error'));
    });

    test('should return default message for unknown errors', () {
      final message = ErrorHandler.getUserFriendlyMessage(
        Exception('Some random error'),
      );

      expect(message, contains('Something went wrong'));
    });

    test('should execute safe operation successfully', () async {
      final result = await ErrorHandler.safeExecute(
        operation: () async => 'Success',
      );

      expect(result, 'Success');
    });

    test('should handle safe operation failure', () async {
      final result = await ErrorHandler.safeExecute<String>(
        operation: () async => throw Exception('Test error'),
      );

      expect(result, null);
    });

    test('should call onError callback on failure', () async {
      var errorCalled = false;

      await ErrorHandler.safeExecute(
        operation: () async => throw Exception('Test'),
        onError: () => errorCalled = true,
      );

      expect(errorCalled, true);
    });
  });
}

