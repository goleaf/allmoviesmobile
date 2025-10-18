# Performance Check – March 7, 2024

This document captures the most recent performance verification pass for the AllMovies Mobile application. The focus of this session was to surface endpoint-level latency for the movie home feed and validate that the existing source tree passes static analysis without regression.

## Instrumentation summary

- Added stopwatch-driven telemetry in `MoviesProvider.refresh` to track how long each TMDB-backed section takes to hydrate. Every section now records its latest refresh duration in milliseconds and exposes it via the new `lastFetchDurationsMs` getter for UI overlays or debugging panels.
- Each measurement is mapped to the exact REST path powering the payload (for example, `/3/movie/now_playing`). This mapping is logged through the shared `PerformanceMonitor` utility so QA can cross-reference UI behavior with console traces.
- The provider also tracks a `lastTotalFetchDurationMs` aggregate, making it trivial to gauge whole-home load health without adding extra timers in the UI layer.

## How to capture timings

1. Launch the application with debug logging enabled.
2. Trigger a home refresh (pull to refresh or restart the app).
3. Inspect `MoviesProvider.lastFetchDurationsMs` through the Flutter DevTools Provider inspector or by wiring the values into a debug banner.
4. Optional: call `PerformanceMonitor.printAllStatistics()` from a debug action to dump counts, min/max, and average durations gathered across sessions.

## Static analysis

Attempted to run `flutter analyze`, but the Flutter SDK is unavailable in the current container image. Once the toolchain is restored, rerun the analyzer to validate that the telemetry helpers keep the tree lint-clean.
