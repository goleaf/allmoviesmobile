import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

/// Centralized error handling for the application
class ErrorHandler {
  static final _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.none,
    ),
  );

  /// Log an error with context
  static void logError(
    String message,
    dynamic error, [
    StackTrace? stackTrace,
  ]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Log a warning
  static void logWarning(String message, [dynamic data]) {
    _logger.w(message, error: data);
  }

  /// Log info
  static void logInfo(String message, [dynamic data]) {
    _logger.i(message, error: data);
  }

  /// Log debug info
  static void logDebug(String message, [dynamic data]) {
    _logger.d(message, error: data);
  }

  /// Convert errors to user-friendly messages
  static String getUserFriendlyMessage(dynamic error) {
    if (error == null) {
      return 'An unexpected error occurred';
    }

    final errorString = error.toString().toLowerCase();

    if (errorString.contains('network') ||
        errorString.contains('socket') ||
        errorString.contains('connection')) {
      return 'Network error. Please check your internet connection.';
    }

    if (errorString.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }

    if (errorString.contains('401') || errorString.contains('unauthorized')) {
      return 'Authentication failed. Please check your API key.';
    }

    if (errorString.contains('403') || errorString.contains('forbidden')) {
      return 'Access denied. Invalid API key or rate limit exceeded.';
    }

    if (errorString.contains('404') || errorString.contains('not found')) {
      return 'Requested resource not found.';
    }

    if (errorString.contains('500') || errorString.contains('server')) {
      return 'Server error. Please try again later.';
    }

    if (errorString.contains('format') || errorString.contains('parse')) {
      return 'Invalid data format received.';
    }

    // Default message
    return 'Something went wrong. Please try again.';
  }

  /// Show error dialog
  static Future<void> showErrorDialog(
    BuildContext context,
    String title,
    dynamic error, {
    VoidCallback? onRetry,
  }) async {
    final message = getUserFriendlyMessage(error);

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: const Text('Retry'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show error snackbar
  static void showErrorSnackBar(
    BuildContext context,
    dynamic error, {
    Duration duration = const Duration(seconds: 4),
  }) {
    final message = getUserFriendlyMessage(error);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: duration,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Wrap async operations with error handling
  static Future<T?> safeExecute<T>({
    required Future<T> Function() operation,
    String? errorMessage,
    VoidCallback? onError,
  }) async {
    try {
      return await operation();
    } catch (error, stackTrace) {
      logError(errorMessage ?? 'Operation failed', error, stackTrace);
      onError?.call();
      return null;
    }
  }
}

