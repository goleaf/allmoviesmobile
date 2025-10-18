import 'dart:async';
import 'dart:developer' as developer;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// Collects frame timing information and exposes lightweight profiling helpers.
class PerformanceProfiler {
  PerformanceProfiler._();

  static final PerformanceProfiler instance = PerformanceProfiler._();

  static const int _maxSamples = 120;

  final ValueNotifier<FrameTimingsStats?> statsNotifier =
      ValueNotifier<FrameTimingsStats?>(null);

  final List<FrameTiming> _buffer = <FrameTiming>[];
  bool _isListening = false;

  /// Enables the profiler by subscribing to frame timing callbacks.
  void enable() {
    if (_isListening) {
      return;
    }
    SchedulerBinding.instance.addTimingsCallback(_handleTimings);
    _isListening = true;
    developer.log('Performance profiler enabled', name: 'PerformanceProfiler');
  }

  /// Disables the profiler and clears any cached frame timings.
  void disable() {
    if (!_isListening) {
      return;
    }
    SchedulerBinding.instance.removeTimingsCallback(_handleTimings);
    _buffer.clear();
    statsNotifier.value = null;
    _isListening = false;
    developer.log('Performance profiler disabled', name: 'PerformanceProfiler');
  }

  /// Wraps [action] in a [TimelineTask] so it shows in the Flutter DevTools
  /// performance view.
  Future<T> profileAction<T>(String label, Future<T> Function() action) async {
    final task = developer.TimelineTask()..start(label);
    try {
      return await action();
    } finally {
      task.finish();
    }
  }

  void _handleTimings(List<FrameTiming> timings) {
    if (timings.isEmpty) {
      return;
    }
    _buffer..addAll(timings);
    if (_buffer.length > _maxSamples) {
      _buffer.removeRange(0, _buffer.length - _maxSamples);
    }

    final double buildMicros = _buffer
            .map((timing) => timing.buildDuration.inMicroseconds)
            .fold<double>(0, (sum, value) => sum + value) /
        _buffer.length;
    final double rasterMicros = _buffer
            .map((timing) => timing.rasterDuration.inMicroseconds)
            .fold<double>(0, (sum, value) => sum + value) /
        _buffer.length;
    final double frameMicros = _buffer
            .map((timing) => timing.totalSpan.inMicroseconds)
            .fold<double>(0, (sum, value) => sum + value) /
        _buffer.length;

    final stats = FrameTimingsStats(
      averageBuildTime: Duration(microseconds: buildMicros.round()),
      averageRasterTime: Duration(microseconds: rasterMicros.round()),
      frameBudget: const Duration(milliseconds: 16),
      estimatedFps:
          frameMicros == 0 ? 0 : (Duration.microsecondsPerSecond / frameMicros),
    );

    statsNotifier.value = stats;

    developer.log(
      'Frame timings — build: ${stats.averageBuildTime.inMicroseconds / 1000.0}ms, '
      'raster: ${stats.averageRasterTime.inMicroseconds / 1000.0}ms, '
      'fps: ${stats.estimatedFps.toStringAsFixed(1)}',
      name: 'PerformanceProfiler',
    );
  }
}

/// Snapshot of the rolling frame timing statistics produced by
/// [PerformanceProfiler].
class FrameTimingsStats {
  const FrameTimingsStats({
    required this.averageBuildTime,
    required this.averageRasterTime,
    required this.frameBudget,
    required this.estimatedFps,
  });

  final Duration averageBuildTime;
  final Duration averageRasterTime;
  final Duration frameBudget;
  final double estimatedFps;

  bool get isWithinBudget =>
      averageBuildTime <= frameBudget && averageRasterTime <= frameBudget;
}
