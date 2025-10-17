import 'package:flutter_test/flutter_test.dart';
import 'package:allmovies_mobile/core/utils/retry_helper.dart';

void main() {
  group('RetryHelper Tests', () {
    test('should succeed on first attempt', () async {
      var attempts = 0;

      final result = await RetryHelper.retry(
        operation: () async {
          attempts++;
          return 'Success';
        },
      );

      expect(result, 'Success');
      expect(attempts, 1);
    });

    test('should retry on failure and eventually succeed', () async {
      var attempts = 0;

      final result = await RetryHelper.retry(
        maxAttempts: 3,
        initialDelay: Duration(milliseconds: 10),
        operation: () async {
          attempts++;
          if (attempts < 3) {
            throw Exception('Retry me');
          }
          return 'Success';
        },
      );

      expect(result, 'Success');
      expect(attempts, 3);
    });

    test('should throw after max attempts', () async {
      var attempts = 0;

      await expectLater(
        RetryHelper.retry(
          maxAttempts: 3,
          initialDelay: Duration(milliseconds: 10),
          operation: () async {
            attempts++;
            throw Exception('Always fails');
          },
        ),
        throwsException,
      );

      expect(attempts, 3);
    });

    test('should respect shouldRetry callback', () async {
      var attempts = 0;

      expect(
        () => RetryHelper.retry(
          maxAttempts: 3,
          initialDelay: Duration(milliseconds: 10),
          shouldRetry: (error) => false, // Never retry
          operation: () async {
            attempts++;
            throw Exception('Fail');
          },
        ),
        throwsException,
      );

      expect(attempts, 1); // Should only try once
    });

    test('isRetryable should detect network errors', () {
      expect(RetryHelper.isRetryable(Exception('Network error')), true);
      expect(RetryHelper.isRetryable(Exception('Connection timeout')), true);
      expect(RetryHelper.isRetryable(Exception('Socket exception')), true);
    });

    test('isRetryable should detect server errors', () {
      expect(RetryHelper.isRetryable(Exception('500 error')), true);
      expect(RetryHelper.isRetryable(Exception('502 error')), true);
      expect(RetryHelper.isRetryable(Exception('503 error')), true);
    });

    test('isRetryable should not retry client errors', () {
      expect(RetryHelper.isRetryable(Exception('400 error')), false);
      expect(RetryHelper.isRetryable(Exception('401 error')), false);
      expect(RetryHelper.isRetryable(Exception('404 error')), false);
    });

    test('retryWithFixedDelay should work correctly', () async {
      var attempts = 0;

      final result = await RetryHelper.retryWithFixedDelay(
        maxAttempts: 3,
        delay: Duration(milliseconds: 10),
        operation: () async {
          attempts++;
          if (attempts < 2) {
            throw Exception('Retry');
          }
          return 'Success';
        },
      );

      expect(result, 'Success');
      expect(attempts, 2);
    });
  });
}
