import 'package:equatable/equatable.dart';

/// Base class for all recoverable application exceptions.
class AppException extends Equatable implements Exception {
  const AppException(this.message, {this.cause, this.stackTrace});

  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  @override
  List<Object?> get props => <Object?>[message, cause];

  @override
  String toString() => '$runtimeType($message)';
}

class AppNetworkException extends AppException {
  const AppNetworkException(
    String message, {
    Object? cause,
    StackTrace? stackTrace,
    this.statusCode,
    this.url,
  }) : super(message, cause: cause, stackTrace: stackTrace);

  final int? statusCode;
  final Uri? url;

  @override
  List<Object?> get props => <Object?>[message, cause, statusCode, url];
}

class AppTimeoutException extends AppException {
  const AppTimeoutException(
    String message, {
    Object? cause,
    StackTrace? stackTrace,
  }) : super(message, cause: cause, stackTrace: stackTrace);
}

class AppApiException extends AppException {
  const AppApiException(
    String message, {
    Object? cause,
    StackTrace? stackTrace,
    this.statusCode,
    this.endpoint,
  }) : super(message, cause: cause, stackTrace: stackTrace);

  final int? statusCode;
  final String? endpoint;

  @override
  List<Object?> get props => <Object?>[message, cause, statusCode, endpoint];
}

class AppStorageException extends AppException {
  const AppStorageException(
    String message, {
    Object? cause,
    StackTrace? stackTrace,
  }) : super(message, cause: cause, stackTrace: stackTrace);
}

class AppCacheMissException extends AppException {
  const AppCacheMissException(String message) : super(message);
}
