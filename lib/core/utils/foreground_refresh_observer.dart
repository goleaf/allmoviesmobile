import 'dart:async';

import 'package:flutter/widgets.dart';

class ForegroundRefreshObserver with WidgetsBindingObserver {
  ForegroundRefreshObserver({
    this.minimumInterval = const Duration(minutes: 15),
  });

  final Duration minimumInterval;
  final List<Future<void> Function()> _callbacks = [];
  DateTime _lastInvocation = DateTime.fromMillisecondsSinceEpoch(0);
  bool _attached = false;

  void attach() {
    if (_attached) return;
    WidgetsBinding.instance.addObserver(this);
    _attached = true;
  }

  void detach() {
    if (!_attached) return;
    WidgetsBinding.instance.removeObserver(this);
    _attached = false;
  }

  void registerCallback(Future<void> Function() callback) {
    _callbacks.add(callback);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      return;
    }

    final now = DateTime.now();
    if (now.difference(_lastInvocation) < minimumInterval) {
      return;
    }

    _lastInvocation = now;
    for (final callback in _callbacks) {
      unawaited(callback());
    }
  }
}
