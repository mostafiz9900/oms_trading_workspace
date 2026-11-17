import 'dart:convert';

import 'package:dio/dio.dart' as dio;

/// Response shape kept at the repository boundary while requests use Dio.
class Response<T> {
  const Response({
    required this.statusCode,
    required this.body,
    this.statusText,
    this.bodyString,
  });

  factory Response.fromDio(dio.Response<T> response) {
    final data = response.data;
    return Response<T>(
      statusCode: response.statusCode,
      statusText: response.statusMessage,
      body: data,
      bodyString: _bodyAsString(data),
    );
  }

  factory Response.fromDioException(dio.DioException exception) {
    final failedResponse = exception.response;
    final data = failedResponse?.data;
    return Response<T>(
      statusCode: failedResponse?.statusCode,
      statusText: failedResponse?.statusMessage ?? exception.message,
      body: data,
      bodyString: _bodyAsString(data),
    );
  }

  final int? statusCode;
  final String? statusText;
  final dynamic body;
  final String? bodyString;

  bool get isOk =>
      statusCode != null && statusCode! >= 200 && statusCode! < 300;

  static String? _bodyAsString(Object? data) {
    if (data == null) return null;
    if (data is String) return data;
    try {
      return jsonEncode(data);
    } on Object {
      return data.toString();
    }
  }
}
