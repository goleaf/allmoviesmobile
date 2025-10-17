import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// Monitor and log performance metrics
class PerformanceMonitor {
  static final _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.none,
    ),
  );

  static final Map<String, DateTime> _timers = {};
  static final Map<String, List<int>> _metrics = {};

  /// Start timing an operation
  static void startTimer(String operationName) {
    if (!kReleaseMode) {
      _timers[operationName] = DateTime.now();
    }
  }

  /// Stop timing and log the duration
  static void stopTimer(String operationName, {bool logResult = true}) {
    if (!kReleaseMode) {
      final startTime = _timers[operationName];
      if (startTime != null) {
        final duration = DateTime.now().difference(startTime);
        final milliseconds = duration.inMilliseconds;

        // Store metric
        _metrics[operationName] ??= [];
        _metrics[operationName]!.add(milliseconds);

        if (logResult) {
          _logger.d('⏱️ $operationName: ${milliseconds}ms');
        }

        _timers.remove(operationName);
      }
    }
  }

  /// Log a performance metric
  static void logMetric(String name, dynamic value) {
    if (!kReleaseMode) {
      _logger.d('📊 $name: $value');
    }
  }

  /// Get average time for an operation
  static double? getAverageTime(String operationName) {
    final metrics = _metrics[operationName];
    if (metrics == null || metrics.isEmpty) return null;

    final sum = metrics.reduce((a, b) => a + b);
    return sum / metrics.length;
  }

  /// Get statistics for an operation
  static Map<String, dynamic>? getStatistics(String operationName) {
    final metrics = _metrics[operationName];
    if (metrics == null || metrics.isEmpty) return null;

    final sorted = List<int>.from(metrics)..sort();
    final min = sorted.first;
    final max = sorted.last;
    final sum = metrics.reduce((a, b) => a + b);
    final avg = sum / metrics.length;
    final median = sorted[sorted.length ~/ 2];

    return {
      'count': metrics.length,
      'min': min,
      'max': max,
      'avg': avg.toStringAsFixed(2),
      'median': median,
    };
  }

  /// Print all statistics
  static void printAllStatistics() {
    if (!kReleaseMode) {
      _logger.i('📈 Performance Statistics:');
      for (final operation in _metrics.keys) {
        final stats = getStatistics(operation);
        if (stats != null) {
          _logger.i('  $operation: $stats');
        }
      }
    }
  }

  /// Clear all metrics
  static void clearMetrics() {
    _timers.clear();
    _metrics.clear();
  }

  /// Measure the execution time of a function
  static Future<T> measure<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    startTimer(operationName);
    try {
      return await operation();
    } finally {
      stopTimer(operationName);
    }
  }

  /// Measure the execution time of a synchronous function
  static T measureSync<T>(String operationName, T Function() operation) {
    startTimer(operationName);
    try {
      return operation();
    } finally {
      stopTimer(operationName);
    }
  }
}
