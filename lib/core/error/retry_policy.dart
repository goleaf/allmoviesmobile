import 'package:retry/retry.dart';

import '../exceptions/app_exception.dart';

typedef RetryableOperation<T> = Future<T> Function();

class RetryPolicy {
  const RetryPolicy({
    this.maxAttempts = 3,
    this.delayFactor = const Duration(milliseconds: 500),
    this.maxDelay = const Duration(seconds: 5),
  });

  final int maxAttempts;
  final Duration delayFactor;
  final Duration maxDelay;

  Future<T> execute<T>(RetryableOperation<T> operation) {
    final retryOptions = RetryOptions(
      maxAttempts: maxAttempts,
      delayFactor: delayFactor,
      maxDelay: maxDelay,
    );

    return retryOptions.retry(
      operation,
      retryIf: (error) =>
          error is AppNetworkException ||
          error is AppTimeoutException ||
          error is AppApiException,
    );
  }
}
