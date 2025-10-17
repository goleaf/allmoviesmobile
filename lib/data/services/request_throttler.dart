import 'dart:async';
import 'dart:collection';

import 'network_quality_service.dart';

class RequestThrottler {
  RequestThrottler({
    int maxConcurrent = 6,
    int maxRequestsPerInterval = 12,
    Duration interval = const Duration(seconds: 1),
  })  : _maxConcurrent = maxConcurrent,
        _maxRequestsPerInterval = maxRequestsPerInterval,
        _interval = interval;

  int _maxConcurrent;
  int _maxRequestsPerInterval;
  Duration _interval;
  int _inFlight = 0;
  final Queue<Completer<void>> _waitQueue = Queue<Completer<void>>();
  final Queue<DateTime> _requestTimestamps = Queue<DateTime>();

  Future<T> schedule<T>(Future<T> Function() task) async {
    await _acquire();
    try {
      await _waitForAvailability();
      final result = await task();
      _recordRequest();
      return result;
    } finally {
      _release();
    }
  }

  Future<void> _acquire() async {
    if (_inFlight < _maxConcurrent) {
      _inFlight++;
      return;
    }

    final completer = Completer<void>();
    _waitQueue.add(completer);
    await completer.future;
  }

  void _release() {
    _inFlight = (_inFlight - 1).clamp(0, _maxConcurrent);
    if (_waitQueue.isNotEmpty && _inFlight < _maxConcurrent) {
      _inFlight++;
      _waitQueue.removeFirst().complete();
    }
  }

  Future<void> _waitForAvailability() async {
    while (_requestTimestamps.length >= _maxRequestsPerInterval) {
      final oldest = _requestTimestamps.first;
      final elapsed = DateTime.now().difference(oldest);
      if (elapsed >= _interval) {
        _requestTimestamps.removeFirst();
      } else {
        await Future.delayed(_interval - elapsed);
      }
    }
  }

  void _recordRequest() {
    final now = DateTime.now();
    _requestTimestamps.addLast(now);
    _prune(now);
  }

  void _prune(DateTime now) {
    while (_requestTimestamps.isNotEmpty &&
        now.difference(_requestTimestamps.first) >= _interval) {
      _requestTimestamps.removeFirst();
    }
  }

  void updateLimits({
    int? maxConcurrent,
    int? maxRequestsPerInterval,
    Duration? interval,
  }) {
    if (maxConcurrent != null && maxConcurrent > 0) {
      _maxConcurrent = maxConcurrent;
    }
    if (maxRequestsPerInterval != null && maxRequestsPerInterval > 0) {
      _maxRequestsPerInterval = maxRequestsPerInterval;
    }
    if (interval != null && !interval.isNegative && interval > Duration.zero) {
      _interval = interval;
    }
  }

  void applyNetworkQuality(NetworkQuality quality) {
    switch (quality) {
      case NetworkQuality.offline:
        updateLimits(
          maxConcurrent: 1,
          maxRequestsPerInterval: 1,
          interval: const Duration(seconds: 3),
        );
      case NetworkQuality.constrained:
        updateLimits(
          maxConcurrent: 2,
          maxRequestsPerInterval: 3,
          interval: const Duration(seconds: 2),
        );
      case NetworkQuality.balanced:
        updateLimits(
          maxConcurrent: 4,
          maxRequestsPerInterval: 6,
          interval: const Duration(milliseconds: 900),
        );
      case NetworkQuality.excellent:
        updateLimits(
          maxConcurrent: 6,
          maxRequestsPerInterval: 12,
          interval: const Duration(milliseconds: 500),
        );
    }
  }
}
