import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:hive/hive.dart';

import '../exceptions/app_exception.dart';

class ErrorMapper {
  const ErrorMapper();

  AppException map(Object error, {StackTrace? stackTrace, String? endpoint}) {
    if (error is AppException) {
      return error;
    }

    if (error is DioException) {
      final response = error.response;
      final uri = response?.requestOptions.uri ?? error.requestOptions.uri;
      final statusCode = response?.statusCode;

      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return AppTimeoutException(
            'The request to ${uri.toString()} timed out.',
            cause: error,
            stackTrace: stackTrace ?? error.stackTrace,
          );
        case DioExceptionType.badResponse:
          return AppApiException(
            'Server responded with status $statusCode.',
            statusCode: statusCode,
            endpoint: uri.toString(),
            cause: error,
            stackTrace: stackTrace ?? error.stackTrace,
          );
        case DioExceptionType.badCertificate:
        case DioExceptionType.connectionError:
        case DioExceptionType.unknown:
          return AppNetworkException(
            'Unable to connect to the network.',
            statusCode: statusCode,
            url: uri,
            cause: error,
            stackTrace: stackTrace ?? error.stackTrace,
          );
        case DioExceptionType.cancel:
          return AppException(
            'The request was cancelled.',
            cause: error,
            stackTrace: stackTrace ?? error.stackTrace,
          );
      }
    }

    if (error is SocketException) {
      return AppNetworkException(
        'No internet connection.',
        cause: error,
        stackTrace: stackTrace,
      );
    }

    if (error is TimeoutException) {
      return AppTimeoutException(
        'The operation timed out.',
        cause: error,
        stackTrace: stackTrace,
      );
    }

    if (error is HiveError) {
      return AppStorageException(
        'Local storage error: ${error.message}',
        cause: error,
        stackTrace: stackTrace,
      );
    }

    return AppException(
      'Unexpected error: $error',
      cause: error,
      stackTrace: stackTrace,
    );
  }
}
