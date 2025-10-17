import 'dart:async';

/// Helper class for retrying failed operations
class RetryHelper {
  /// Retry an operation with exponential backoff
  static Future<T> retry<T>({
    required Future<T> Function() operation,
    int maxAttempts = 3,
    Duration initialDelay = const Duration(seconds: 1),
    double backoffFactor = 2.0,
    bool Function(dynamic error)? shouldRetry,
  }) async {
    var currentDelay = initialDelay;
    dynamic lastError;

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        return await operation();
      } catch (error) {
        lastError = error;

        // Check if we should retry this error
        if (shouldRetry != null && !shouldRetry(error)) {
          rethrow;
        }

        // If this was the last attempt, rethrow
        if (attempt == maxAttempts) {
          rethrow;
        }

        // Wait before retrying with exponential backoff
        await Future.delayed(currentDelay);
        currentDelay = Duration(
          milliseconds: (currentDelay.inMilliseconds * backoffFactor).round(),
        );
      }
    }

    // This should never be reached, but just in case
    throw lastError ?? Exception('Retry failed after $maxAttempts attempts');
  }

  /// Check if an error is retryable
  static bool isRetryable(dynamic error) {
    if (error == null) return false;

    final errorString = error.toString().toLowerCase();

    // Network errors are usually retryable
    if (errorString.contains('network') ||
        errorString.contains('socket') ||
        errorString.contains('connection') ||
        errorString.contains('timeout')) {
      return true;
    }

    // Server errors might be temporary
    if (errorString.contains('500') ||
        errorString.contains('502') ||
        errorString.contains('503') ||
        errorString.contains('504')) {
      return true;
    }

    // Client errors are usually not retryable
    if (errorString.contains('400') ||
        errorString.contains('401') ||
        errorString.contains('403') ||
        errorString.contains('404')) {
      return false;
    }

    // Default to not retryable
    return false;
  }

  /// Retry with simple delays (no exponential backoff)
  static Future<T> retryWithFixedDelay<T>({
    required Future<T> Function() operation,
    int maxAttempts = 3,
    Duration delay = const Duration(seconds: 2),
  }) async {
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        return await operation();
      } catch (error) {
        if (attempt == maxAttempts) {
          rethrow;
        }
        await Future.delayed(delay);
      }
    }

    throw Exception('Retry failed after $maxAttempts attempts');
  }
}

