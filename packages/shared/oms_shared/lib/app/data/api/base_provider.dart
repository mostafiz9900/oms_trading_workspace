import 'package:dio/dio.dart' as dio;
import 'package:getxify/getxify.dart';

import '../../core/values/app_config.dart';
import 'http_response.dart' as api;
import 'interceptors/request_interceptor.dart';
import 'interceptors/response_interceptor.dart';

/// Shared authenticated client for OMS API providers.
///
/// Repositories receive a stable response model while the transport uses Dio.
class BaseProvider extends GetxService {
  BaseProvider({dio.Dio? client}) : _dio = client ?? _createClient() {
    _dio.interceptors.add(
      dio.InterceptorsWrapper(
        onRequest: (options, handler) async {
          await requestInterceptor(options);
          handler.next(options);
        },
        onResponse: (response, handler) {
          responseInterceptor(response);
          handler.next(response);
        },
        onError: (error, handler) {
          responseErrorInterceptor(error);
          handler.next(error);
        },
      ),
    );
  }

  final dio.Dio _dio;

  static dio.Dio _createClient() => dio.Dio(
    dio.BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      contentType: dio.Headers.jsonContentType,
      responseType: dio.ResponseType.json,
      headers: const {dio.Headers.acceptHeader: dio.Headers.jsonContentType},
      validateStatus: (status) => status != null,
    ),
  );

  Future<api.Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
  }) => _send(() => _dio.get<dynamic>(path, queryParameters: query));

  Future<api.Response<dynamic>> post(String path, [Object? data]) =>
      _send(() => _dio.post<dynamic>(path, data: data));

  Future<api.Response<dynamic>> put(String path, [Object? data]) =>
      _send(() => _dio.put<dynamic>(path, data: data));

  Future<api.Response<dynamic>> patch(String path, [Object? data]) =>
      _send(() => _dio.patch<dynamic>(path, data: data));

  Future<api.Response<dynamic>> delete(String path) =>
      _send(() => _dio.delete<dynamic>(path));

  Future<api.Response<dynamic>> _send(
    Future<dio.Response<dynamic>> Function() request,
  ) async {
    try {
      return api.Response<dynamic>.fromDio(await request());
    } on dio.DioException catch (error) {
      return api.Response<dynamic>.fromDioException(error);
    }
  }

  @override
  void onClose() {
    _dio.close(force: true);
    super.onClose();
  }
}
