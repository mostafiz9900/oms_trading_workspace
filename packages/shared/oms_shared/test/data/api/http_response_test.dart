import 'package:dio/dio.dart' as dio;
import 'package:flutter_test/flutter_test.dart';
import 'package:oms_shared/app/data/api/http_response.dart';

void main() {
  group('Response.fromDio', () {
    test('preserves decoded JSON data and HTTP status', () {
      final response = Response<Map<String, dynamic>>.fromDio(
        dio.Response<Map<String, dynamic>>(
          requestOptions: dio.RequestOptions(path: '/login'),
          statusCode: 201,
          statusMessage: 'Created',
          data: const {'success': true},
        ),
      );

      expect(response.statusCode, 201);
      expect(response.statusText, 'Created');
      expect(response.body, {'success': true});
      expect(response.bodyString, '{"success":true}');
      expect(response.isOk, isTrue);
    });

    test('preserves an HTTP error response body for existing repositories', () {
      final dioResponse = dio.Response<Map<String, dynamic>>(
        requestOptions: dio.RequestOptions(path: '/login'),
        statusCode: 401,
        statusMessage: 'Unauthorized',
        data: const {'message': 'Invalid credentials'},
      );
      final exception = dio.DioException(
        requestOptions: dioResponse.requestOptions,
        response: dioResponse,
        type: dio.DioExceptionType.badResponse,
      );

      final response = Response<dynamic>.fromDioException(exception);

      expect(response.statusCode, 401);
      expect(response.statusText, 'Unauthorized');
      expect(response.body, {'message': 'Invalid credentials'});
      expect(response.isOk, isFalse);
    });
  });
}
