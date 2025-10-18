import 'dart:async';

/// Simple rate limiter that enforces a minimum delay between operations.
class RateLimiter {
  RateLimiter(this._minDelay);

  final Duration _minDelay;
  DateTime? _lastExecution;

  /// Schedule a task to run after the rate limit delay has passed.
  Future<T> schedule<T>(Future<T> Function() task) async {
    final now = DateTime.now();
    if (_lastExecution != null) {
      final elapsed = now.difference(_lastExecution!);
      if (elapsed < _minDelay) {
        await Future.delayed(_minDelay - elapsed);
      }
    }
    _lastExecution = DateTime.now();
    return await task();
  }
}

