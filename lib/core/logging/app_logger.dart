import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

typedef LogSink = void Function(String message);

class AppLogger {
  AppLogger._();

  static final AppLogger _instance = AppLogger._();

  static AppLogger get instance => _instance;

  final Completer<void> _initialization = Completer<void>();
  late Logger _logger;
  IOSink? _fileSink;

  Future<void> init({bool enableFileLogging = false}) async {
    final outputs = <LogOutput>[ConsoleOutput()];

    if (enableFileLogging &&
        !kIsWeb &&
        (Platform.isAndroid || Platform.isIOS || Platform.isMacOS)) {
      final directory = await getApplicationDocumentsDirectory();
      final logFile = File('${directory.path}/app.log');
      _fileSink = logFile.openWrite(mode: FileMode.append);
      outputs.add(_StreamLogOutput(_fileSink!));
    }

    _logger = Logger(
      printer: PrettyPrinter(
        colors: !kIsWeb,
        printEmojis: true,
        printTime: true,
      ),
      output: MultiOutput(outputs),
      level: kReleaseMode ? Level.warning : Level.debug,
    );

    if (!_initialization.isCompleted) {
      _initialization.complete();
    }
  }

  Future<void> get ready => _initialization.future;

  void debug(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  void info(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  void warning(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  void error(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  void close() {
    _fileSink?.close();
    _fileSink = null;
  }
}

class _StreamLogOutput extends LogOutput {
  _StreamLogOutput(this._sink);

  final IOSink _sink;

  @override
  void output(OutputEvent event) {
    for (final line in event.lines) {
      _sink.writeln(line);
    }
  }
}
