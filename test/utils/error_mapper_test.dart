import 'package:allmovies_mobile/core/error/error_mapper.dart';
import 'package:allmovies_mobile/core/exceptions/app_exception.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ErrorMapper maps 404 to AppApiException', () {
    final mapper = const ErrorMapper();
    final dio = DioException(
      requestOptions: RequestOptions(path: '/x'),
      response: Response(
        requestOptions: RequestOptions(path: '/x'),
        statusCode: 404,
      ),
      type: DioExceptionType.badResponse,
    );
    final ex = mapper.map(dio);
    expect(ex, isA<AppApiException>());
  });
}
